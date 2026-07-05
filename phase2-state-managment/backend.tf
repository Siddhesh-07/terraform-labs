terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-siddhesh"  
    key            = "phase2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}