# 作成したComputeEngineのパブリックIPアドレスを出力
output "CE_global_ips" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}