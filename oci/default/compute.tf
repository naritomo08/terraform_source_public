resource "oci_core_instance" "test_instance" {
    count = "${var.NumInstances}"
    availability_domain = "${oci_core_subnet.test_web_subnet.availability_domain}"    
    compartment_id = "${var.compartment_ocid}"                     
    shape = "${var.instance_shape}"                                
    display_name = "${var.instance_display_name}"
    create_vnic_details {
        subnet_id = "${oci_core_subnet.test_web_subnet.id}"
    }
    source_details {
        source_id = "${var.instance_image_ocid[var.region]}"
        source_type = "image"
    }
    metadata = {
        ssh_authorized_keys = "${var.ssh_public_key}"
    }
}
