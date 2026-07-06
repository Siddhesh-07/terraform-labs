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

module "networking" {
  source = "./modules/vpc_setup"

  vpc_name = "phase3-vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
}



module "ec2_instance_1" {
  source = "./modules/ec2_instance"
  ami_id = var.ami_id
  instance_type = "t3.micro"
  instance_name = "app-server-1"
  security_group_ids = [module.networking.security_group_id]
  subnet_id = module.networking.public_subnet_id

}

module "ec2_instance_2" {
  source = "./modules/ec2_instance"

  ami_id = var.ami_id
  instance_type = "t3.micro"
  instance_name = "app-server-2"
  security_group_ids = [module.networking.security_group_id]
  subnet_id = module.networking.public_subnet_id
}

module "database" {
  source = "./modules/rds_basic"

  db_identifier        = "phase3-postgres-db"
  db_engine            = "postgres"
  db_engine_version    = "15.3"
  db_instance_class    = "db.t3.micro"
  allocated_storage    = 20
  database_name        = "appdb"
  master_username      = "postgres"
  master_password      = "TerraformPassword123!"  
  db_subnet_group_name = "phase3-db-subnet-group"
  subnet_ids           = [module.networking.private_subnet_id, module.networking.private_subnet_2_id]
  security_group_ids   = [module.networking.security_group_id]
}