#VPCのCIDERを記載します。
variable "vpc_cidr" {
  default = "192.168.0.0/23"
}

#下記のresourceで使うタグ用の変数を定義
variable "app_name" {
  default = "awsvpc"
}
