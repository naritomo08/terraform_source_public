terraform {
  backend "oci" {
    bucket                 = "tfstate_bucket"
    compartment_ocid       = "${compartment_ocid}"
    tenancy_ocid           = "${var.tenancy_ocid}"
    user_ocid              = "${var.user_ocid}"
    fingerprint            = "${var.fingerprint}"
    private_key_path       = "${var.private_key_path}"
    region                 = "${var.region}"
    disable_auto_retries   = "false"
  }
}