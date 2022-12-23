#AWSを今回は使いますという宣言
provider "aws" {
  region = "ap-northeast-1"
}

# 自分のパブリックIP取得用
provider "http" {}