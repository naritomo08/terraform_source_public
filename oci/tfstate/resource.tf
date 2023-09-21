resource "oci_objectstorage_bucket" "example_bucket" {
  namespace        = "${var.tenancy_namespace}"
  compartment_id   = "${var.compartment_ocid}"
  name             = "tfstate_bucket"
  access_type      = "NoPublicAccess"
}