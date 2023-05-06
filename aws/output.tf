# 作成したEC2のパブリックIPアドレスを出力
#output "ec2_global_ips" {
#  value = aws_instance.aws_ec2.*.public_ip
#}

# 別作成したパブリックIP参照
output "public_ip" {
  value = aws_eip.example.public_ip
}