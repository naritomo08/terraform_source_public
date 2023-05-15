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
resource "aws_route_table_association" "aws_public_rt_associate1a" {
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

  ingress {
    from_port   = 80
    to_port     = 80
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
resource "aws_eip" "example_1" {
  instance = aws_instance.aws_ec2_1.id
  vpc      = true
}

resource "aws_eip" "example_2" {
  instance = aws_instance.aws_ec2_2.id
  vpc      = true
}

# ---------------------------
# EC2
# ---------------------------
# セキュリティキーは既存のものを使用する(事前に登録すること)。
# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Ubuntu20.04のAMIを取得
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2作成(パブリックIPなし)
resource "aws_instance" "aws_ec2_1" {
  # AmazonLinux2
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  # Ubuntu20.04
  # ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  availability_zone           = "ap-northeast-1a"
  vpc_security_group_ids      = [aws_security_group.aws_ec2_sg.id]
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = "false"
  key_name                    = "serverkey"
  tags = {
    Name = "vm01"
  }
}

resource "aws_instance" "aws_ec2_2" {
  # AmazonLinux2
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  # Ubuntu20.04
  # ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  availability_zone           = "ap-northeast-1c"
  vpc_security_group_ids      = [aws_security_group.aws_ec2_sg.id]
  subnet_id                   = aws_subnet.public_1c.id
  associate_public_ip_address = "false"
  key_name                    = "serverkey"
  tags = {
    Name = "vm02"
  }
}