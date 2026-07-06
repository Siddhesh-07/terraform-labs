variable "db_subnet_group_name" {
  type        = string
  default     = "db-subnet-group"
}

variable "subnet_ids" {
  type        = list(string)
}

variable "db_identifier" {
  type        = string
  default     = "my-db"
}

variable "db_engine" {
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  type        = string
  default     = "15.3"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  default     = 20
}

variable "database_name" {
  type        = string
  default     = "myappdb"
}

variable "master_username" {
  type        = string
  default     = "admin"
}

variable "master_password" {
  type        = string
  sensitive   = true
}

variable "security_group_ids" {
  type        = list(string)
}