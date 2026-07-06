output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_id" {
  value = module.networking.public_subnet_id
}

output "instance_1_id" {
  value = module.ec2_instance_1.instance_id
}

output "instance_1_public_ip" {
  value = module.ec2_instance_1.public_ip
}

output "instance_2_id" {
  value = module.ec2_instance_2.instance_id
}

output "instance_2_public_ip" {
  value = module.ec2_instance_2.public_ip
}

output "database_endpoint" {
  value = module.database.db_endpoint
}

output "database_name" {
  value = module.database.db_name
}