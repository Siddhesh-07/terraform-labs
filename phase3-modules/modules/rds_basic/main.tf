resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_db_instance" "main" {
  identifier       = var.db_identifier
  engine           = var.db_engine
  instance_class   = var.db_instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot    = true

  tags = {
    Name = var.db_identifier
  }
}