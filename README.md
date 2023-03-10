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

### terraformコンテナ稼働

```bash
cd ..
docker-compose up -d
```

### terraform利用

AWSの場合は予め"serverkey"名でセキュリティキー登録すること。

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

* GCPコンソールから

GCPコンソールに入り、ComputeEngineの
接続列のSSHをクリックして、コンソールが
出てくることを確認する。

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
