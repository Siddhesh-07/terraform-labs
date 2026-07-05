output "instance_name" {
    value = var.instance_name
}

output "instance_id" {
    value = aws_instance.main.id
}

output "public_ip" {
  value = aws_instance.main.public_ip
}