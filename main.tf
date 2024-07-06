provider "aws" {
  region = "us-west-1" # Replace with your desired AWS region
}

# Create a security group
resource "aws_security_group" "web_server_sg" {
  name_prefix = "web-server-sg-"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0cff7528ff583bf9a" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
EOF

  tags = {
    Name = "WebServer"
  }
}

output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web_server.public_ip
}
