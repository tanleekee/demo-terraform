# Introduction
This simple IAC demo will use terrafrom script to create ec2 instance and RDS instance.
ec2 instance will host php web page that interact with RDS database.

## Pre-Requisite
- AWS account
- Computer with any modern browser and have access to internet

## Setup Terraform in AWS cloudshell

### Download Terraform and extract into Home folder

```
curl -o terraform.zip https://releases.hashicorp.com/terraform/1.9.1/terraform_1.9.1_darwin_arm64.zip
```
```
unzip terraform.zip -d bin/
```
### Verify terraform
```
terraform --version
```

## Running terraform to create cloud resources 
Create a demo folder
```
mkdir ~/demo
```
Download main.tf into demo folder
```
cd demo
curl -o main.tf https://raw.githubusercontent.com/tanleekee/demo-terraform/main/main.tf
```
Initialise terraform
```
terraform init
```
These 2 commands are optional in this demo.
```
terraform fmt
```
```
terraform validate
```

Preview cloud resources creation
```
terraform plan
```
Create cloud resources. Terraform will prompt for confirmation. Enter yes to proceed, or no to cancel.
```
terraform apply
```
Validate web page hosted on ec2 (HTTP) is accessible. You whould see a simple web page showing **Hello, World!**
```
http://public_IP_address_of_ec2/index.html
```
Validate RDS is up and working using the php web page
```
http://public_IP_address_of_ec2/demo.php
```
## Clean up cloud resources
:warning: **Warning:** Remember to clean up all cloud resources to stop incurring cost in your AWS account.
```
terraform destroy
```
## Code blocks for resources creation
### ec2 creation
```
# Create an EC2 instance
resource "aws_instance" "web_server" {
  
  depends_on = [
    aws_db_instance.mysql_db
  ]

  tags = {
    Name = "IAC-demo-ec2"
  }

  ami           = "ami-06c68f701d8090592" # Amazon Linux AMI
  instance_type = "t2.micro"
  subnet_id     = tolist(data.aws_subnets.default_subnets.ids)[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
}
```

### RDS creation
```
# Create an RDS MySQL instance
resource "aws_db_instance" "mysql_db" {
  engine                 = "mysql"
  engine_version         = "8.0.37"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "demodb" # Change this value 
  username               = "demouser" # Change this value
  password               = "demoPassword" # Change this value
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.default_subnet_group.name
}
```

### Security Group creation
```
 # Create a security group for EC2
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
```

### User Data

```
user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd php php-mysqli mariadb105
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello, World!</h1>" > /var/www/html/index.html
    sudo usermod -a -G apache ec2-user
    sudo chown -R ec2-user:apache /var/www
    sudo chmod 2775 /var/www
    find /var/www -type d -exec sudo chmod 2775 {} \;
    find /var/www -type f -exec sudo chmod 0664 {} \;
    mkdir /var/www/inc
    cat <<EOINC > /var/www/inc/dbinfo.inc
    <?php
      define('DB_SERVER', '${aws_db_instance.mysql_db.endpoint}');
      define('DB_USERNAME', 'demouser');
      define('DB_PASSWORD', 'demoPassword');
      define('DB_DATABASE', 'demodb');
    ?>
    EOINC
    cat 
    curl -o /var/www/html/demo.php https://raw.githubusercontent.com/tanleekee/demo-terraform/main/demo.php
    EOF
```



## Reference

PHP script reference:
1. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.WebServerDB.CreateWebServer.html

   
