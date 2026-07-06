output "vpc_id" {
  value = aws_vpc.main.id
  
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

output "security_group_id" {
  value = aws_security_group.main.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}
output "private_subnet_2_id" {
  description = "Second private subnet ID"
  value       = aws_subnet.private_2.id
}