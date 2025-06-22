# main.tf - Minimal parameterized Terraform project to launch a Debian EC2 instance

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "debian" {
  ami           = var.ami_id
  instance_type = var.instance_type
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for Debian EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
