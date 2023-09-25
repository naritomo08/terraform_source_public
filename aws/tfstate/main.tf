provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }

  required_version = "1.5.7"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "<バケット名>" #適当なユニークの名前に変えてください
    force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
    name = "<dynamodb名>" #適当なユニークの名前に変えてください
    read_capacity = 1
    write_capacity = 1
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
