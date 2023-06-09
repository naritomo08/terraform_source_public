#resourceでVPCを作成します。
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.app_name
  }
}

#上記のVPCにサブネットを追加します。
resource "aws_subnet" "public_1a" {
  # 上記で作成したVPCを参照し、そのVPC内にSubnetを作成します。
  vpc_id = aws_vpc.main_vpc.id

  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1a"
  cidr_block        = "192.168.0.0/25"
  # trueにするとインスタンスにパブリックIPアドレスを自動的に割り当ててくれる
  map_public_ip_on_launch = true
  tags = {
    Name = "awsvpc-prod"
  }
}

#上記のVPCにサブネットを追加します。
resource "aws_subnet" "public_1c" {
  # 上記で作成したVPCを参照し、そのVPC内にSubnetを作成します。
  vpc_id = aws_vpc.main_vpc.id

  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1c"
  cidr_block        = "192.168.0.128/25"
  # trueにするとインスタンスにパブリックIPアドレスを自動的に割り当ててくれる
  map_public_ip_on_launch = true
  tags = {
    Name = "awsvpc-prod"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-aws-igw"
  }
}

# ---------------------------
# Route table
# ---------------------------
# Route table作成
resource "aws_route_table" "aws_public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }
  tags = {
    Name = "terraform-aws-public-rt"
  }
}

# SubnetとRoute tableの関連付け
resource "aws_route_table_association" "aws_public_rt_associate" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.aws_public_rt.id
}

resource "aws_route_table_association" "aws_public_rt_associate1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.aws_public_rt.id
}

# ---------------------------
# Security Group
# ---------------------------
# 自分のパブリックIP取得
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

variable "allowed_cidr" {
  default = null
}

locals {
  myip         = chomp(data.http.ifconfig.body)
  allowed_cidr = (var.allowed_cidr == null) ? "${local.myip}/32" : var.allowed_cidr
}

# Security Group作成
resource "aws_security_group" "aws_ec2_sg" {
  name        = "terraform-aws-ec2-sg"
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-aws-ec2-sg"
  }

  # インバウンドルール
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ====================
#
# Elastic IP
#
# ====================
resource "aws_eip" "example" {
  instance = aws_instance.aws_ec2.id
  vpc      = true
}

# ポリシー作成(SSM許可)

resource "aws_iam_role_policy" "instance_role_policy" {
    name = "EC2SSMPolicy_apply"
    role = "${aws_iam_role.instance_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# ロール作成(SSM許可)

resource "aws_iam_role" "instance_role" {
    name = "EC2SSMRole_apply"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# ロール指定プロファイル作成(SSM許可)
resource "aws_iam_instance_profile" "instance_role" {
    name = "SSM_apply_profile"
    role = aws_iam_role.instance_role.name
}

# ---------------------------
# EC2
# ---------------------------
# セキュリティキーは既存のものを使用する(事前に登録すること)。
# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2作成(パブリックIP別付与)
resource "aws_instance" "aws_ec2" {
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.micro"
  availability_zone           = "ap-northeast-1a"
  vpc_security_group_ids      = [aws_security_group.aws_ec2_sg.id]
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = "false"
  key_name                    = "serverkey"
  iam_instance_profile = "SSM_apply_profile"
  tags = {
    Name = "vm01"
  }
}