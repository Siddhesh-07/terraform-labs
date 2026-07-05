variable "ami_id" {
  type = string
  default = "ami-06067086cf86c58e6"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
}