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
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaattpocc2scb7ece7xwpadvo4c5e7iuyg7p3mhbm554uurcgnwh5cq"
  }
}
variable "ssh_public_key" {
  default = "${ssh_public_server_key}"
}