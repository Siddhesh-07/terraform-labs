variable "ami_id" {
    type = string
    #default = "ami-06067086cf86c58e6"
}

variable "subnet_id" {
  type = string
  #default = ""
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "instance_name" {
  type = string
  #default = "server"
}

variable "security_group_ids" {
  type = list(string)
  default = []
}