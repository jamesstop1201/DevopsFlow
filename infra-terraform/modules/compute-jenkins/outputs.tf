output "public_ip" {
  value = aws_instance.jenkins_server.public_ip
  description = "Jenkins 伺服器的公有 IP，後續 Ansible 連線使用"
}

output "jenkins_role_name" {
  value = aws_iam_role.jenkins_role.name
  description = "Jenkins 伺服器使用的 IAM Role 名稱"
}