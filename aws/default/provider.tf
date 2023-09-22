#AWSを今回は使いますという宣言
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

  required_version = "1.3.8"
}

# 自分のパブリックIP取得用
provider "http" {}