# terraform-ansible-wg-easy

This project automates the deployment of a WireGuard VPN + Web UI using Terraform, Ansible, and Docker Compose on AWS.
It provisions a Debian EC2 instance, installs Docker & Docker Compose, deploys the [wg-easy](https://github.com/wg-easy/wg-easy) container, and configures Cloudflare Dynamic DNS.

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Setup Instructions](#setup-instructions)

   * [Terraform](#terraform)
   * [Ansible](#ansible)
5. [SSH Access](#ssh-access)
6. [Usage](#usage)
7. [Variables Reference](#variables-reference)
8. [Contributing](#contributing)
9. [License](#license)

## Introduction

In today’s world of remote work, traveling, and distributed teams, having a secure, reliable VPN is essential for accessing private resources—without the complexity of managing servers or networking by hand. This project streamlines the entire process by combining:

1. **Infrastructure as Code**: Spin up a hardened Debian EC2 instance on AWS with a single `terraform apply`.
2. **Configuration Management**: Automatically install and configure Docker, WireGuard, and Cloudflare DDNS via Ansible.
3. **User-Friendly VPN**: Deploy the popular [wg-easy](https://github.com/wg-easy/wg-easy) container for an intuitive web interface to create, revoke, and monitor VPN clients.
4. **Dynamic Security**: Leverage Cloudflare DNS to keep your domain always pointing at your home or cloud instance, and lock down SSH access dynamically to your build environment’s IP.

Whether you’re a home‐lab enthusiast securing your network, or a team operator needing on‐demand VPN endpoints, this end‐to‐end solution removes manual steps, reduces error, and makes launching a fully managed WireGuard service as simple as writing code.

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
* DNS entry (e.g., `myenvironment.example.com`) pointing to your environment
* **Cloudflare account** with API Token:

  1. Log into your Cloudflare dashboard.
  2. Navigate to **My Profile** → **API Tokens** → **Create Token**.
  3. Select the **Edit DNS** template (or custom with **Zone.DNS** permissions).
  4. Specify the zone (e.g., `yourdomain.com`) and generate the token.
  5. Copy the **API Token** and **Zone ID** from the **Overview** page of your site.

## Setup Instructions

### Terraform

1. Clone the repo:

   ```bash
   git clone https://github.com/davidhfrankelcodes/terraform-ansible-wg-easy.git
   cd terraform-vpn/terraform
   ```
2. Configure variables in `terraform.tfvars` (see `terraform.tfvars.example`):

   ```hcl
   aws_region      = "us-east-1"
   ami_id           = "ami-..."
   instance_type    = "t3.micro"
   build_env_host   = "myenvironment.example.com"
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
