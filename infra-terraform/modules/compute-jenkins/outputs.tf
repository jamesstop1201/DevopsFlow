output "public_ip" {
  value = aws_instance.jenkins_server.public_ip
  description = "Jenkins 伺服器的公有 IP，後續 Ansible 連線使用"
}