# Jenkins 防火牆
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Allow SSH and Jenkins web traffic"
  vpc_id      = var.vpc_id

  # SSH 存取 (Ansible 需要)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 建議之後改為自己的 IP
  }

  # Jenkins 網頁管理介面
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 出向流量 (下載套件、推送到 ECR)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1. 定義 IAM 角色 (Role)
resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_name}-jenkins-role"

  # 允許 EC2 服務借用這個角色
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# 2. 附加權限策略 (Policy) - 給予 ECR 完整存取權限
resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# 3. 建立 Instance Profile
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
} 


# 取得最新版的 Ubuntu 22.04 AMI ID
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical 的 AWS 帳號 ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  # 放在公有子網
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true # 這樣你才能連得到它

  # 綁定身分證
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "${var.project_name}-jenkins-server"
  }
}