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
    ami = "ami-06067086cf86c58e6"
    instance_type = "t3.micro"

    tags = {
      Name = "terraform-lab-instance"
    }
  
}