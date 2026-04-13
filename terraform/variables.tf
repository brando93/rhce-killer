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
  description = "Instance type for control node (On-Demand for stability)"
  default     = "t3.medium"
}

variable "node_instance_type" {
  description = "Instance type for managed nodes (Spot for cost savings)"
  default     = "t3.micro"
}

variable "node_spot_max_price" {
  description = "Maximum price for Spot instances (set to On-Demand price to avoid interruptions)"
  default     = "0.0104" # t3.micro On-Demand price in us-east-1
}
