# VCN
variable "vcn_cidr_block" {
  default = "192.168.100.0/23"
}
variable "vcn_display_name" {
  default = "techvan-VCN"
}
variable "vcn_dns_label" {
  default = "techvanVCN"
}

# internet gateway
variable "internet_gateway_display_name"  {
  default = "techvanIGW"
}

# route table
variable "route_table_display_name" {
  default = "techvan_RT_Web"
}

# security list web
variable "sl_egress_destination_web" {
  default = "0.0.0.0/0"
}
variable "sl_egress_protocol_web" {
  default = "ALL"
}
variable "sl_ingress_protocol_web" {
  default = "6"
}
variable "sl_ingress_tcp_dest_port_max_web" {
  default = "22"
}
variable "sl_ingress_tcp_dest_port_min_web" {
  default = "22"
}
variable "sl_ingress_tcp_dest_port_max_oracle" {
  default = "1521"
}
variable "sl_ingress_tcp_dest_port_min_oracle" {
  default = "1521"
}
variable "sl_display_name_web" {
  default = "techvan_SL_Web"
}
# subnet web
variable "web_subnet_cidr_block" {
  default = "192.168.100.0/25"
}
variable "web_subnet_display_name" {
  default = "public_subnet"
}
variable "web_subnet_dns_label" {
  default = "techvan"
}
variable "web_subnet_prohibit_public_ip_on_vnic" {
  default = "false"
}
variable "availability_domain" {
  default = {
    ap-tokyo-1 = "DXeC:AP-TOKYO-1-AD-1"
    ap-osaka-1 = "eLug:AP-OSAKA-1-AD-1"
  }
}