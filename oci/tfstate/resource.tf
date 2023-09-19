resource "oci_objectstorage_bucket" "example_bucket" {
  namespace        = "${var.tenancy_ocid}"
  compartment_id   = "${compartment_ocid}"
  name             = "tfstate_bucket"
  access_type      = "NoPublicAccess"
}