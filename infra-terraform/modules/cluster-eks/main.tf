# 1. EKS Cluster 
resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.public_subnets
  }
  access_config {
    authentication_mode = var.authentication_mode
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# 2. EKS Node Group 
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.public_subnets

  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
}