# terraform_source

複数人作業に必要なftstate保管バケット作成も含めた、
terraformソース集になります。

## 各ソースでできること。

### AWS

ftstate保管バケット作成
VPC作成
サブネット作成

### Azure

ftstate保管バケット作成
リソースグループ作成

### GCP

ftstate保管バケット作成
VPC作成

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

### 共通変数ファイルコピー

```bash
cp .env.example ../.env
→変数の中身は予め入れておくこと。
```

### git.json内容書き換え

gitフォルダ内のgit.jsonについて、
コンソールから適切なアクセスファイルに入れ替えること。

### terraformコンテナ稼働

```bash
cd ..
docker-compose up -d
```

### terraform利用

```bash
docker-compose exec terraform ash
cd ソースフォルダ
terraform init
terraform plan
terraform apply
→yesを入力する。
→各コンソールで作成されていることを確認する。
```

2回目以降は以下のコマンドで良い
```bash
terraform plan
terraform apply
→yesを入力する。
→AWSコンソールで作成されていることを確認する。
```

### terraform作成リソース削除

ソースフォルダで実施

```bash
docker-compose exec terraform ash
cd ソースフォルダ
terraform destroy
→yesを入力する。
→AWSコンソールで削除されていることを確認する。
```

一部リソースの場合以下のコマンドで良い。

```bash
terraform destroy -target リソース名
→yesを入力する。
→AWSコンソールで削除されていることを確認する。
```
## tfstateを外出しして対応する方法

グループで行う場合、誰かが初回で行えば良い。
複数人で管理する場合行うこと。

ソースファイルの中にあるterraform部分の中を
コメントアウトを外し、以下のコマンドを入力する。

### 外部バケット作成

```bash
docker-compose exec terraform ash
cd ソースフォルダ/tfstate
terraform init
terraform plan
terraform apply
→yesを入力する。
→各コンソールでバケットが作成されていることを確認する。
```

#### (Azureの場合)以下の作業でストレージ情報を控える。

合わせて、管理コンソールでストレージアカウント名も控える。

以下のコマンドでアカウントキー情報を取得する。

```bash
az login
*idが複数ある場合は、管理画面と確認して使用しているidを選択する。
az account set --subscription="id"
az storage account keys list --resource-group tfstate --account-name <ストレージアカウント名> --query '[0].value' -o tsv
→帰ってくる値を控える。
```

### 外部バケット適用

Azureの場合
ファイル内のterraformで以下のパラメータを入れる。
storage_account_name(ストレージアカウント名)
key(アカウントキー)

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

バケットを削除する際は予め、
中にある全てのファイルを削除し、
その後terraformからのモジュール削除を行うこと。
(AWSのみ)

```bash
docker-compose exec terraform ash
cd ソースフォルダ/tfstate
terraform destroy
→yesを入力する。
→各コンソールでバケットが作成されていることを確認する。
```
