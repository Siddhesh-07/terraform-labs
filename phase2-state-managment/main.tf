provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "phase2" {
  ami           = "ami-06067086cf86c58e6"
  instance_type = "t3.micro"

  tags = {
    Name = "phase2-instance"
  }
}