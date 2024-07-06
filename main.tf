provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Replace with your desired AZ

  tags = {
    Name = "Public Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a security group for the web server
resource "aws_security_group" "web_sg" {
  name        = "Web SG"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web SG"
  }
}

# Create an EC2 instance for the web server
resource "aws_instance" "web_server" {
  ami           = "ami-0cff7528ff583bf9a" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "Web Server"
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "RDS SG"
  description = "Allow inbound traffic from web server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS SG"
  }
}

# Create an RDS MySQL instance
resource "aws_db_instance" "demo_db" {
  identifier             = "demo-db"
  engine                 = "mysql"
  engine_version         = "5.7.33"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "demo_database"
  username               = "admin"
  password               = "changeme" # Replace with a secure password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}
