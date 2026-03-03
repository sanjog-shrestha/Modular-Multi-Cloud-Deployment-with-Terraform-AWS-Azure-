terraform {
  backend "s3" {
    bucket = "multi-cloud-tf-state"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}