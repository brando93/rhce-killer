variable "aws_region" {
  default = "us-east-1"
}
variable "project_name" {
  default = "rhce-killer"
}
variable "my_ip" {
  description = "Your public IP in CIDR (e.g. 1.2.3.4/32). Run: curl ifconfig.me"
  type        = string
}
variable "control_instance_type" {
  default = "t3.medium"
}
variable "node_instance_type" {
  default = "t3.micro"
}
