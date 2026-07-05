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

module "ec2_instance_1" {
  source = "./modules/ec2_instance"

  ami_id = var.ami_id
  instance_type = "t3.micro"
  instance_name = "app-server-1"
  security_group_ids = []

}

module "ec2_instance_2" {
  source = "./modules/ec2_instance"

  ami_id = var.ami_id
  instance_type = "t3.micro"
  instance_name = "app-server-2"
  security_group_ids = []
}