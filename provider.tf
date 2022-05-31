provider "aws" {
  region = var.region
  default_tags {
    tags = {
    Terraform = "true"
    Environment = terraform.workspace
    }
  }
}

# terraform {
#   backend "s3" {
#     bucket         = "fxlinkpayloadbuckets"
#     key            = "./terraform.tfstate"
#     region         = "eu-west-3"
#     dynamodb_table = "GameScores"
#     encrypt        = true
#   }
# }