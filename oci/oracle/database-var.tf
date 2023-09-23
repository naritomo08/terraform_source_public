variable "db_system_database_edition" {
  default = "ENTERPRISE_EDITION"
}
variable "db_system_db_home_database_admin_password" {
    default = "ZjTF2TN_48#SpP6"
}
variable "db_system_db_home_database_db_name" {
    default = "ORCL"
}
variable "db_system_db_home_db_version" {
    default = "19.20.0.0"
}
variable "db_system_db_home_display_name" {
    default = "dbhome"
}
variable "db_system_display_name" {
    default = "dbsystem"
}
variable "db_system_hostname" {
    default = "test-db-instance"
}
variable "db_system_shape" {
  default = "VM.Standard.E4.Flex"
}
variable "db_system_ssh_public_keys" {
    default = "../apikey/id_server_rsa.pubの内容に書き換える。"
}
variable "db_system_cpu_core_count" {
  default = "2"
}
variable "db_system_node_count" {
  default = "1"
}
variable "db_system_data_storage_size_in_gb" {
  default = "256"
}

