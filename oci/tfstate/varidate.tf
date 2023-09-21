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
variable "tenancy_namespace" {
  default = "テナンシのオブジェクト・ストレージ・ネームスペース"
}
variable "compartment_ocid" {
  default = "コンパートメントのOCID"
}
variable "ssh_public_server_key" {
  default = "../apikey/id_server_rsa.pem"
}
