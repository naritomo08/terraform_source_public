provider "aws" {
    region  = "ap-northeast-1"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-state-naritomo" #適当なユニークの名前に変えてください
}

resource "aws_s3_bucket_versioning" "versioning_example" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
    name = "terraform_state_lock_naritomo" #適当なユニークの名前に変えてください
    read_capacity = 1
    write_capacity = 1
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
