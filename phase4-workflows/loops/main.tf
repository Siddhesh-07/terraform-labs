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

variable "create_web_server" {
  type    = bool
  default = true
}

variable "create_db_server" {
  type    = bool
  default = false
}

resource "aws_instance" "web" {
  count = var.create_web_server ? 1 : 0
  
  ami           = "ami-06067086cf86c58e6"
  instance_type = "t3.micro"

  tags = {
    Name = "web-server"
  }
}

resource "aws_instance" "db" {
  count = var.create_db_server ? 1 : 0
  
  ami           = "ami-06067086cf86c58e6"
  instance_type = "t3.micro"

  tags = {
    Name = "db-server"
  }
  
  depends_on = [aws_instance.web]
}

output "web_ip" {
  value = var.create_web_server ? aws_instance.web[0].public_ip : "Not created"
}

#output "db_ip" {
 # value = var.create_db_server ? aws_instance.db[0].public_ip : "Not created"
#}
