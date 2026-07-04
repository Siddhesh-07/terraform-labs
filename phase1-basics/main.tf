terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "main" {
  instance_type = var.instance_type
  ami = var.ami_id
  vpc_security_group_ids = [ data.aws_security_group.server-sg.id ]
  subnet_id = data.aws_subnet.public-subnet.id
  tags = {
    Name = var.instance_name
  }
}