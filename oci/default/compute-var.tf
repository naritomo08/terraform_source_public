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
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaj25u2lvizw5m7zzyujx35njtu7qfgy4ci5pqahojdoqoien74znq"
  }
}
variable "ssh_public_key" {
  default = "${ssh_public_server_key}"
}