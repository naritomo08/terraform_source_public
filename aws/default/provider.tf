#AWSを今回は使いますという宣言
provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17.0"
    }
  }

}

# 自分のパブリックIP取得用
provider "http" {}
