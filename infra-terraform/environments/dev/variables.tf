variable "project_name" {
  type        = string
  description = "專案名稱"
}

variable "cluster_name" {
  type        = string
  description = "EKS 集群名稱"
}

variable "vpc_cidr" {
  type        = string
}

variable "public_subnets" {
  type        = list(string)
}

variable "private_subnets" {
  type        = list(string)
}