locals {
  environment = terraform.workspace
  
  instance_type = {
    default = "t3.micro"
    dev     = "t3.micro"
    prod    = "t3.small"
  }
}

terraform {
  required_version = "> 1.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-06067086cf86c58e6"
  instance_type = local.instance_type[local.environment]

  tags = {
    Name = "web-server-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_instance" "db" {
  ami           = "ami-06067086cf86c58e6"
  instance_type = local.instance_type[local.environment]

   tags = {
    Name = "db-server-${local.environment}"
    Environment = local.environment
  }
}

output "web_ip" {
  value = aws_instance.web.public_ip
}

output "db_ip" {
  value = aws_instance.db.public_ip
}