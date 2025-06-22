# terraform-ansible-wg-easy

> *A high-level overview of the project architecture.*

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Setup Instructions](#setup-instructions)

   * [Terraform](#terraform)
   * [Ansible](#ansible)
5. [SSH Access](#ssh-access)
6. [Usage](#usage)
7. [Screenshots](#screenshots)

   1. [Web UI](#1-web-ui)
   2. [PEM File Location](#2-pem-file-location)
   3. [EC2 Dashboard](#3-ec2-dashboard)
   4. [Security Group View](#4-security-group-view)
8. [Variables Reference](#variables-reference)
9. [Contributing](#contributing)
10. [License](#license)

## Introduction

This project automates the deployment of a WireGuard VPN + Web UI using Terraform, Ansible, and Docker Compose on AWS.
It provisions a Debian EC2 instance, installs Docker & Docker Compose, deploys the [wg-easy](https://github.com/weejewel/wg-easy) container, and configures Cloudflare Dynamic DNS.

## Features

* ✅ Infrastructure as Code with Terraform
* ✅ Configuration Management with Ansible
* ✅ Secure SSH key generation
* ✅ WireGuard VPN + Web interface via Docker
* ✅ Cloudflare DDNS integration
* ✅ Automatic security group rules
* ✅ Dynamic SSH restriction to build environment IP

## Prerequisites

* AWS account with appropriate IAM permissions
* Terraform (v1.0+)
* Ansible (v2.10+)
* Docker & Docker Compose installed locally (for testing)
* DNS entry (e.g., `homelab.davidhfrankel.com`) pointing to your environment

## Setup Instructions

### Terraform

1. Clone the repo:

   ```bash
   git clone https://github.com/yourusername/terraform-vpn.git
   cd terraform-vpn/terraform
   ```
2. Configure variables in `terraform.tfvars` (see `terraform.tfvars.example`):

   ```hcl
   aws_region      = "us-east-1"
   ami_id           = "ami-..."
   instance_type    = "t3.micro"
   build_env_host   = "homelab.davidhfrankel.com"
   ```
3. Initialize & apply:

   ```bash
   terraform init
   terraform apply -auto-approve
   ```

### Ansible

After Terraform deploys, the `null_resource` provisioner will automatically run Ansible:

* Installs official Docker Engine & Compose plugin
* Copies the `docker/` folder and `.env`
* Brings up the `docker-compose.yaml`

## SSH Access

Once the EC2 instance is up, Terraform outputs the public IP and generates a private key:

```bash
# Private key saved to:
$ pwd
/path/to/terraform-vpn/terraform
$ ls debian_ssh_key.pem
```

Connect with:

```bash
ssh -i ./debian_ssh_key.pem admin@${debian_public_ip}
```

## Usage

* Access WireGuard UI: `https://<your-domain>:51821`
* WireGuard port: `51820/UDP`
* Add clients via web interface
* Manage Cloudflare DDNS container for dynamic IP updates

## Screenshots

### 1. Web UI

*WireGuard Easy Web Interface showing connected peers.*

### 2. PEM File Location

*Location of the ****`debian_ssh_key.pem`**** file for SSH access.*

### 3. EC2 Dashboard

*AWS EC2 Console showing the deployed Debian instance.*

### 4. Security Group View

*AWS Security Group rules: SSH restricted to build IP, WG & UI open to the world.*

## Variables Reference

| Variable         | Description                                       | Default    |
| ---------------- | ------------------------------------------------- | ---------- |
| `aws_region`     | AWS region to deploy into                         | n/a        |
| `ami_id`         | Debian AMI ID                                     | n/a        |
| `instance_type`  | EC2 instance type                                 | `t3.micro` |
| `build_env_host` | DDNS hostname for build environment IP resolution | n/a        |

## Contributing

Feel free to open issues or pull requests! This project is a portfolio showcase — feedback is welcome.

## License

MIT © David Frankel
