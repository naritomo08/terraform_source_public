#AWSを今回は使いますと言う宣言
provider "aws" {
  region = "ap-northeast-1"
}

# ftstateをバケットに保管する。
terraform {
  #backend "s3" {
  #  bucket  = "<バケット名>"
  #  region  = "ap-northeast-1"
  #  key     = "terraform.tfstate"
  #  encrypt = true
  #  dynamodb_table = "<dynamedb名>"
  #}
}

#VPCのCIDERを記載します。
variable "vpc_cidr" {
  default = "192.168.0.0/23"
}

#下記のresourceで使うタグ用の変数を定義
variable "app_name" {
  default = "awsvpc"
}

#resourceでVPCを作成します。
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.app_name
  }
}

#上記のVPCにサブネットを追加します。
resource "aws_subnet" "public_1a" {
  # 上記で作成したVPCを参照し、そのVPC内にSubnetを作成します。
  vpc_id = "${aws_vpc.main.id}"

  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1a"
  cidr_block        = "192.168.0.0/25"
  tags = {
    Name = "awsvpc-prod"
  }
}
