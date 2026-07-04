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
  
  tags = {
    Name = var.instance_name
  }
}