output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "jenkins_public_ip" {
  value       = module.jenkins.public_ip
  description = "The public IP address of the Jenkins server"
}