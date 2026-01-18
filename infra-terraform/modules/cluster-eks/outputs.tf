output "cluster_name" {
  description = "EKS 叢集的名稱"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS 控制平面的 API Server 網址"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "叢集的 CA 憑證，用於安全連線"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_id" {
  description = "EKS 節點群組的 ID"
  value       = aws_eks_node_group.this.id
}