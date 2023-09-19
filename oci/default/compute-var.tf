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
  type = "map"
  default = {
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa2wpo37usm2lz4gkv26lai7kjwbml7bj2xyrze2yzcqycsls6evxa"
  }
}
variable "ssh_public_key" {
  default = "${ssh_public_server_key}"
}