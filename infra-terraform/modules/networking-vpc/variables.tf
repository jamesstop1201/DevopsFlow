variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "public_subnets"{
    description = "Public subnet cidrs"
    type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet cidrs"
  type        = list(string)
}

variable "project_name" {
  description = "專案名稱"
  type        = string
}