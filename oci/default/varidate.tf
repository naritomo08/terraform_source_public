variable "tenancy_ocid" {
  default = "テナンシのOCID"
}
variable "user_ocid" {
  default = "ユーザーのOCID"
}
variable "fingerprint" {
  default = "フィンガープリント"
}
variable "private_key_path" {
  default = "../apikey/id_rsa"
}
variable "region" {
  default = "使用しているリージョンの識別子"
}
variable "compartment_ocid" {
  default = "コンパートメントのOCID"
}
variable "ssh_public_key" {
  default = "../apikey/id_server_rsa.pemの中身を記載"
}