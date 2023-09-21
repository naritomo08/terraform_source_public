variable "NumInstances"{
  default = "1"
}
variable "instance_shape" {
  default = "VM.Standard2.1"
}
variable "instance_display_name" {
  default = "WebInstance"
}
variable "instance_image_ocid" {
  default = {
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaoqr2sierzhvur65danvbzwz7u5gjhe4stbgil273n2xyp2cpnydq"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa7slxd3wjvwuer2crlmm5qz3g2y2yma2ru3hhffyqi4bvk6mzu2aa"
  }
}
variable "ssh_public_key_path" {
  default = "../apikey/id_server_rsa.pub"
}