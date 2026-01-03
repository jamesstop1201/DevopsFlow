terraform {
  # 這是將主專案連動到管理層 S3 
  backend "s3" {
    bucket         = "mini-finance-tfstate-832f3e96"
    key            = "dev/mini-finance/terraform.tfstate" # 在 S3 裡的存放路徑
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking" # 剛才建立的鎖
    encrypt        = true                      # 開啟加密
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- 接下來我們會在這裡呼叫 VPC 模組 ---


# 2. 呼叫你的 VPC 模組
module "networking" {
  source = "../../modules/networking-vpc"

  # 這裡就是把 dev 的變數「餵」給模組
  project_name    = var.project_name
  cluster_name    = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}
