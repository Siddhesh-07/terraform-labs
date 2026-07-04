data "aws_vpc" "vpc1"{
    filter {
        name = "tag:Name"
        values = ["vpc1"]
    }
}

data "aws_security_group" "server-sg" {
    vpc_id = data.aws_vpc.vpc1.id
    name = "server-sg"
}

data "aws_subnet" "public-subnet" {
  vpc_id = data.aws_vpc.vpc1.id
    filter {
    name   = "tag:Name"
    values = ["public-subnet"]
  }

}