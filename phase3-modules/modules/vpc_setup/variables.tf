variable "vpc_name" {
  type        = string
  default     = "main-vpc"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  type        = string
  default     = "us-east-1a"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
}