variable "project_name" {type = string}
variable "vpc_id" {type = string}
variable "subnet_id" {type = string}
variable "instance_type" {
  type = string
  default = "t3.medium" 
}
variable "key_name" {
  type        = string
  description = "SSH key pair to use for the jenkins instance"
}