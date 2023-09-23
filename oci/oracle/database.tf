resource "oci_database_db_system" "test_db_system" {
    availability_domain = "${oci_core_subnet.test_web_subnet.availability_domain}"
    compartment_id = "${var.compartment_ocid}"
    database_edition = "${var.db_system_database_edition}"
    db_home {
        database {
            admin_password = "${var.db_system_db_home_database_admin_password}"
            db_name = "${var.db_system_db_home_database_db_name}"
        }
        db_version = "${var.db_system_db_home_db_version}"
        display_name = "${var.db_system_db_home_display_name}"
    }
    hostname = "${var.db_system_hostname}"
    shape = "${var.db_system_shape}"
    ssh_public_keys = ["${var.db_system_ssh_public_keys}"]
    subnet_id = "${oci_core_subnet.test_web_subnet.id}"
    cpu_core_count = "${var.db_system_cpu_core_count}"
    display_name = "${var.db_system_display_name}"
    node_count = "${var.db_system_node_count}"
    data_storage_size_in_gb = "${var.db_system_data_storage_size_in_gb}"
}
