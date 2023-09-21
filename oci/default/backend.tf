# ftstateをバケットに保管する。
terraform {
  #backend "s3" {
  #  bucket   = "tfstate_bucket"
  #  key      = "terraform.tfstate"
  #  profile  = "oci_access"
  #  region   = "<使用しているリージョンの識別子>"
  #  endpoint = "https://<テナンシのオブジェクト・ストレージ・ネームスペース>.compat.objectstorage.<使用しているリージョンの識別子>.oraclecloud.com"    
  #  skip_region_validation      = true
  #  skip_credentials_validation = true
  #  skip_metadata_api_check     = true
  #  force_path_style            = true
  #}
}