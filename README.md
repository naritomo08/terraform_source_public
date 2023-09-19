# terraform_source_public

複数人作業に必要なftstate保管バケット作成も含めた、
terraformソース集になります。

## 各ソースで作成できるもの。

### AWS

* ftstate保管バケット(S3/dynamodb)
* VPC
* サブネット
* Internet Gateway
* Route table
* Security Group
* EC2

### Azure

* ftstate保管バケット(ストレージコンテナ)
* リソースグループ
* サブネット
* Network_Security_Group
* Network_Security_rule
* 仮想マシン
    - ネットワークインターフェース
    - パブリックIP
    - 仮想マシン

### GCP

* ftstate保管バケット(storage_bucket)
* VPC
* サブネットワーク
* google_compute_firewall
* google_compute_instance

### OCI

* ftstate保管バケット
* VCN
* Subnet
* Internet gateway
* Route Table
* Compute

## 使用方法

### dockerソースファイル入手

```bash
git clone https://github.com/naritomo08/terraform_docker_public.git terraform
cd terraform
git clone https://github.com/naritomo08/terraform_source_public.git source
cd source
```

後にファイル編集などをして、git通知が煩わしいときは
作成したフォルダで以下のコマンドを入れる。

```bash
 rm -rf .git
```

### AWS/Azureアクセスキー入手、GCPアクセスJSONファイル入手

```bash
vi .env.example

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

→AWSの場合、操作ユーザに対応した
 上記の情報を入れる。

ARM_SUBSCRIPTION_ID=
ARM_CLIENT_ID=
ARM_CLIENT_SECRET=
ARM_TENANT_ID=

→AWSの場合、操作ユーザに対応した
 上記の情報を入れる。

gcp管理画面からアクセスjsonキー(gcp.json)を入手して、gcpフォルダ内に入れる。
```

環境変数を取得するための方法は以下を参照してください。

[UbuntuでAWS CLIを使えるようにする](https://qiita.com/SSMU3/items/ce6e291a653f76ddcf79)

[Terraformを使い、Azureのインフラ構築してみた](https://qiita.com/takakuda/items/1e93fb0a7cc542b4adc1)

[TerraformでGoogle Cloudを扱うためのローカル端末環境構築](https://dev.classmethod.jp/articles/accesse-google-cloud-with-terraform/)

### 共通変数ファイルコピー

```bash
cp .env.example ../.env
```

### OCI APIキー作成(OCI利用)

以下のコマンドでOCI APIキーを作成する。

```bash
cd source/oci/apikey
openssl genrsa -out id_rsa
openssl rsa -in id_rsa -pubout -out id_rsa.pem
ls
→id_rsa,id_rsa.pemファイルが存在していることを確認する。
```

### OCID情報の収集（OCI利用）

以下のサイトの"3.OCID情報の収集"を参照し、以下の情報を収集する。

リソースを入れるコンパートメントは予め作成すること。

* テナンシのOCID
* ユーザーのOCID
* フィンガープリント
* コンパートメントのOCID
* 使用しているリージョンの識別子(例:ap-osaka-1)

参考サイト：

[TerraformでOCI上に仮想サーバを建ててみた](https://blogs.techvan.co.jp/oci/2019/04/08/terraform%e3%81%a7oci%e4%b8%8a%e3%81%ab%e4%bb%ae%e6%83%b3%e3%82%b5%e3%83%bc%e3%83%90%e3%82%92%e5%bb%ba%e3%81%a6%e3%81%a6%e3%81%bf%e3%81%9f/)

### 仮想マシン用キー設定（OCI利用）

```bash
cd source/oci/apikey
ssh-keygen -t rsa -N "" -b 2048 -C "id_server_rsa" -f id_server_rsa
ls
→id_server_rsa,id_server_rsa.pubファイルが存在していることを確認する。
```

### OCIアカウント設定（OCI利用）

```bash
vi source/oci/tfstate/varidate.tf
vi source/oci/default/varidate.tf

以下の内容で作成する。
variable "tenancy_ocid" {
  default = "テナンシのOCID"
}
variable "user_ocid" {
  default = "ユーザーのOCID"
}
variable "fingerprint" {
  default = "フィンガープリント"
}
variable "private_key_path" {
  default = "../apikey/id_rsa"
}
variable "region" {
  default = "使用しているリージョンの識別子"
}
variable "compartment_ocid" {
  default = "コンパートメントのOCID"
}
variable "ssh_public_server_key" {
  default = "../apikey/id_server_rsa.pemの中身を記載"
}
```

### OCIインスタンスOSソース選択（OCI利用）

```bash
vi source/oci/default/compute-var.tf

以下の部分について、リージョン名/OCIDを利用しているリージョンに合わせ書き換える。

ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaj25u2lvizw5m7zzyujx35njtu7qfgy4ci5pqahojdoqoien74znq"
```

### terraformコンテナ稼働

```bash
cd ..
docker-compose up -d
```

### terraform利用

AWSの場合、EC2メニューのキーペアにて"serverkey"名でSSHセキュリティキー登録すること。

GCPの場合、ComputeEngineの設定-メタデータにて、SSHセキュリティキー登録すること。

登録後、表示されるユーザ名を控える。

合わせて以下のメタデータ登録も実施すること。

* キー serial-enable
* 値 TRUE

```bash
docker-compose exec terraform ash
cd ソースフォルダ
terraform init
terraform plan
terraform apply
→yesを入力する。
→管理コンソールで作成されていることを確認する。
```

2回目以降は以下のコマンドで良い
```bash
terraform plan
terraform apply
→yesを入力する。
→管理コンソールで作成されていることを確認する。
```

### 各仮想マシンログイン

#### AWS

applyコマンド実施後に出てくるIPを控え、
ユーザ:ec2user、秘密鍵:セキュリティキーに対応した秘密鍵
を使用してSSHログインする。

#### Azure

applyコマンド実施後に出てくるIPを控え、
"resource.tf"内の以下のパラメータを使用してRDPログインする。
admin_username
admin_password

#### GCP

applyコマンド実施後に出てくるIPを控え、
ユーザ:セキュリティーキー登録時に控えたユーザ名、秘密鍵:セキュリティキーに対応した秘密鍵
を使用してSSHログインする。

#### OCI

applyコマンド実施後に出てくるIPを控え、
ユーザ:obc、秘密鍵:セキュリティキーに対応した秘密鍵
を使用してSSHログインする。

### terraform作成リソース削除

ソースフォルダで実施

```bash
docker-compose exec terraform ash
cd ソースフォルダ
terraform destroy
→yesを入力する。
→管理コンソールで削除されていることを確認する。
```

一部リソースの場合以下のコマンドで良い。

```bash
terraform destroy -target リソース名
→yesを入力する。
→管理コンソールで削除されていることを確認する。
```
## tfstateを外出しして対応する方法

グループで行う場合、誰かが初回で行えば良い。
複数人で管理する場合行うこと。

ソースファイルの中にあるterraform部分の中を
コメントアウトを外し、以下のコマンドを入力する。

### 外部バケット作成

先にtfstate/main.tf内の<>部分の名前を適当なリソース名に
変更すること。

```bash
docker-compose exec terraform ash
cd ソースフォルダ/tfstate
terraform init
terraform plan
terraform apply
→yesを入力する。
→管理コンソールでバケットが作成されていることを確認する。
```

* Azureの場合

管理コンソールでストレージ名を控える。
合わせて以下のコマンドでストレージキー情報を取得する。

```bash
az login
*idが複数ある場合は、管理画面と確認して使用しているidを選択する。
az account set --subscription="id"
az storage account keys list --resource-group tfstate --account-name <ストレージアカウント名> --query '[0].value' -o tsv
→帰ってくる値を控える。
```

### 外部バケット適用

各ソースフォルダ内のterraform.shについて、
<>部分の名前を前の手順で設定したものに合わせる。

```bash
docker-compose exec terraform ash
cd ソースフォルダ
terraform init -migrate-state
→apply実施後各コンソールでtfstateが更新されていることを確認する。
```

### ローカルに戻す場合

ソースファイルの中にあるterraform部分の中を
コメントアウトし、以下のコマンドを入力する。

＊他に使用している人がいないか確認すること。

```bash
docker-compose exec terraform ash
cd ソースフォルダ
terraform init -migrate-state
→apply実施後ローカルででtfstateが更新されていることを確認する。
```

### バケットリソース削除

```bash
docker-compose exec terraform ash
cd ソースフォルダ/tfstate
terraform destroy
→yesを入力する。
→各コンソールでバケットが削除されていることを確認する。
```
