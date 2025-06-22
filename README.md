# Terraform Minimal Debian EC2 Project

This project demonstrates the smallest possible Terraform configuration to launch a Debian EC2 instance on AWS. All configuration is parameterized for flexibility and security.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- An AWS account

## Usage

1. **Clone this repository**

2. **Set variables**
   
   Edit `terraform.tfvars` and set:
   - `aws_region` (e.g., `us-east-1`)
   - `ami_id` (see below for how to get the latest Debian AMI)
   - `instance_type` (optional, defaults to `t3.micro`)

   To get the latest Debian AMI, you can use the provided script:
   ```sh
   ./scripts/get_debian_ami.sh
   ```

3. **Initialize Terraform**
   ```sh
   terraform init
   ```

4. **Plan the deployment**
   ```sh
   terraform plan
   ```

5. **Apply the configuration**
   ```sh
   terraform apply
   ```
   Confirm when prompted.

## Teardown (Destroy Resources)
To remove all resources created by this project:
```sh
terraform destroy
```
Confirm when prompted. This will terminate the EC2 instance and remove all managed infrastructure.

## Notes
- Do **not** commit your `terraform.tfvars` or any files containing secrets.
- The `.gitignore` is set up to protect sensitive and generated files.

## File Overview
- `main.tf`: Main Terraform configuration
- `versions.tf`: Provider and Terraform version constraints
- `terraform.tfvars`: Variable values (not committed)
- `scripts/get_debian_ami.sh`: Helper script to find the latest Debian AMI

---

**Enjoy your minimal, parameterized Terraform project!**
