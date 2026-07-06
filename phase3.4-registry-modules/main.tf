terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name = "registry-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

  enable_nat_gateway = false
}

resource "aws_security_group" "main" {
  name   = "registry-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "5.0"

  name           = "registry-instance"
  ami            = "ami-06067086cf86c58e6"
  instance_type  = "t3.micro"
  subnet_id      = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.main.id]
}