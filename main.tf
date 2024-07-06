provider "aws" {
  region = "us-east-1"
}

# Get the default VPC ID
data "aws_vpc" "default_vpc" {
  default = true
}

# Get the default subnet IDs
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

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

# Create an EC2 instance
resource "aws_instance" "web_server" {
  depends_on = [
    aws_db_instance.mysql_db
  ]

  ami           = "ami-06c68f701d8090592" # Amazon Linux AMI
  instance_type = "t2.micro"
  subnet_id     = tolist(data.aws_subnets.default_subnets.ids)[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

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
      define('DB_SERVER', 'db_instance_endpoint');
      define('DB_USERNAME', 'demouser');
      define('DB_PASSWORD', 'demoPassword');
      define('DB_DATABASE', 'demodb');
    ?>
    EOINC
    curl -o /var/www/html/demo.php https://raw.githubusercontent.com/tanleekee/demo-terraform/main/demo.php
    EOF
}

# Create a security group for RDS
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# Create an RDS MySQL instance
resource "aws_db_instance" "mysql_db" {
  engine                 = "mysql"
  engine_version         = "8.0.37"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "demodb"
  username               = "demouser"
  password               = "demoPassword" # Use a secure password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.default_subnet_group.name
}

# Create a DB subnet group for RDS
resource "aws_db_subnet_group" "default_subnet_group" {
  name       = "default-subnet-group"
  subnet_ids = data.aws_subnets.default_subnets.ids
}

output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}
