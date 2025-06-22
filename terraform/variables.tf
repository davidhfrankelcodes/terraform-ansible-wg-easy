# variables.tf

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the Debian EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "build_env_host" {
  description = "The hostname of the build environment (ddns)"
  type        = string
}
