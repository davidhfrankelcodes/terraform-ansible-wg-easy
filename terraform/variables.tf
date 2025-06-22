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
  description = "The hostname of the build environment (for DDNS)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "terraform-ansible-wg-easy"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
