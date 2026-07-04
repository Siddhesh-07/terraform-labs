variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "ami_id" {
  default = "ami-06067086cf86c58e6"
  type = string
}

variable "instance_name" {
  default = "tf-server"
  type = string
}