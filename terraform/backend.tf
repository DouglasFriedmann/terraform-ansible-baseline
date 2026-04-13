terraform {
  backend "s3" {
    bucket         = "aws-secure-ticketing-tf-state-dougops"
    key            = "dougops/terraform-ansible-baseline/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
