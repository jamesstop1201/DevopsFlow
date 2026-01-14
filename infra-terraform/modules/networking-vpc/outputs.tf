# 輸出 VPC ID，這在建立 Security Group 時必填
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

# 輸出公有子網 ID 列表，這在建立 Jenkins 或 ALB 時會用到
output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of IDs of public subnets"
}

# 輸出私有子網 ID 列表，這在建立 EKS Node Group 時會用到
output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of IDs of private subnets"
}