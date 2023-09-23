# VCN
resource "oci_core_vcn" "test_vcn" {
    cidr_block = "${var.vcn_cidr_block}"          
    compartment_id = "${var.compartment_ocid}"      
    display_name = "${var.vcn_display_name}"
    dns_label = "${var.vcn_dns_label}"
}

# Internet Gateway
resource "oci_core_internet_gateway" "test_internet_gateway" {
    compartment_id = "${var.compartment_ocid}"    
    vcn_id = "${oci_core_vcn.test_vcn.id}"        
    display_name = "${var.internet_gateway_display_name}"
    enabled = true
}

# route table
resource "oci_core_route_table" "test_route_table" {
    compartment_id = "${var.compartment_ocid}"     
    route_rules {
        network_entity_id = "${oci_core_internet_gateway.test_internet_gateway.id}" 
        destination = "0.0.0.0/0"
    }
    vcn_id = "${oci_core_vcn.test_vcn.id}"
    display_name = "${var.route_table_display_name}"
}

# 自分のパブリックIP取得
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

variable "allowed_cidr" {
  default = null
}

locals {
  myip         = chomp(data.http.ifconfig.response_body)
  allowed_cidr = (var.allowed_cidr == null) ? "${local.myip}/32" : var.allowed_cidr
}

# Security List(Web-Subnet)
resource "oci_core_security_list" "test_security_list_web" {
    compartment_id = "${var.compartment_ocid}"     
    egress_security_rules {
        destination = "${var.sl_egress_destination_web}" 
        protocol = "${var.sl_egress_protocol_web}"       
        stateless = false
        }
    ingress_security_rules {
        source = "${local.allowed_cidr}"
        protocol = "${var.sl_ingress_protocol_web}"
        stateless = false
        tcp_options {
            max = "${var.sl_ingress_tcp_dest_port_max_web}"
            min = "${var.sl_ingress_tcp_dest_port_min_web}"
        }
    }
    ingress_security_rules {
        source = "${var.web_subnet_cidr_block}"
        protocol = "${var.sl_ingress_protocol_web}"
        stateless = false
        tcp_options {
            max = "${var.sl_ingress_tcp_dest_port_max_oracle}"
            min = "${var.sl_ingress_tcp_dest_port_min_oracle}"
        }
    }
    vcn_id = "${oci_core_vcn.test_vcn.id}"
    display_name = "${var.sl_display_name_web}"
}

# Subent(web)
resource "oci_core_subnet" "test_web_subnet" {
    availability_domain = "${var.availability_domain[var.region]}"
    cidr_block = "${var.web_subnet_cidr_block}"                 
    compartment_id = "${var.compartment_ocid}"                  
    security_list_ids = ["${oci_core_security_list.test_security_list_web.id}"]       
    vcn_id = "${oci_core_vcn.test_vcn.id}"                      

    display_name = "${var.web_subnet_display_name}"
    dns_label = "${var.web_subnet_dns_label}"
    prohibit_public_ip_on_vnic = "${var.web_subnet_prohibit_public_ip_on_vnic}"
    route_table_id = "${oci_core_route_table.test_route_table.id}"
}