provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

resource "aws_db_instance" "demo_db" {
  identifier             = "demo-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7.33" # or any other desired MySQL version
  instance_class         = "db.t3.micro"
  name                   = "mydb"
  username               = "dbuser" # Set your desired username
  password               = "DBuser@7788" # Set your desired password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = false # Set to true if you want public access
  vpc_security_group_ids = [aws_security_group.demo_db_sg.id]
}

resource "aws_security_group" "demo_db_sg" {
  name_prefix = "demo-db-sg-"
  vpc_id      = aws_vpc.demo_vpc.id # Replace with your desired VPC ID

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # Replace with your bastion security group ID
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
