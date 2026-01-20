variable "project_name" {
  description = "專案名稱，用於資源命名標籤"
  type = string
}

variable "vpc_id" {
  description = "VPC 的 ID，EKS 將部署在此網路內"
  type = string
}

variable "public_subnets" {
  description = "公有子網列表，用於部署 EKS 控制平面與節點"
  type = list(string)
}

variable "instance_types" {
  description = "Worker Nodes 的 EC2 規格"
  type = list(string)
}

variable "desired_size" {
  description = "期望的節點數量"
  type = number
  default     = 2
}

variable "max_size" {
  description = "最大擴展節點數量"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "最小節點數量"
  type        = number
  default     = 1
}

variable "jenkins_role_name" {
  description = "Jenkins 伺服器使用的 IAM Role 名稱"
  type        = string
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are CONFIG_MAP, API or API_AND_CONFIG_MAP"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}