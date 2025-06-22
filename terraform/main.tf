provider "aws" {
  region = var.aws_region
}

# 1️⃣ Generate an SSH keypair
resource "tls_private_key" "debian_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2️⃣ AWS Key Pair
resource "aws_key_pair" "debian" {
  key_name   = "debian_ssh_key"
  public_key = tls_private_key.debian_key.public_key_openssh

  tags = var.tags
}

# 3️⃣ DNS for Build Environment
data "dns_a_record_set" "build_env" {
  host = var.build_env_host
}

# 4️⃣ Create a security group
resource "aws_security_group" "debian_ssh" {
  name        = "debian_ssh_sg"
  description = "Allow SSH from build environment, WG and app from anywhere"

  tags = var.tags

  # SSH only from build environment IP
  ingress {
    description = "SSH from build environment IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.dns_a_record_set.build_env.addrs[0]}/32"]
  }

  # WireGuard UDP open to the world
  ingress {
    description = "WireGuard UDP access from anywhere"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App Web Port open to the world
  ingress {
    description = "App Web Port access from anywhere"
    from_port   = 51821
    to_port     = 51821
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

# 5️⃣ EC2 instance
resource "aws_instance" "debian" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.debian.key_name

  vpc_security_group_ids      = [aws_security_group.debian_ssh.id]
  associate_public_ip_address = true

  tags = var.tags
}

# 6️⃣ Output the public IP
output "debian_public_ip" {
  value = aws_instance.debian.public_ip
}

# 7️⃣ Output the private key
output "debian_ssh_private_key" {
  value     = tls_private_key.debian_key.private_key_pem
  sensitive = true
}

# 8️⃣ Save the private key to a .pem file
resource "local_file" "debian_ssh_key" {
  content         = tls_private_key.debian_key.private_key_pem
  filename        = "${path.module}/debian_ssh_key.pem"
  file_permission = "0600"
}

# 9️⃣ Output the resolved IP of the build environment (optional!)
output "build_env_ip" {
  value = data.dns_a_record_set.build_env.addrs[0]
}

# 🔟 Run Ansible after EC2 is up
resource "null_resource" "configure_ec2" {
  depends_on = [aws_instance.debian]

  provisioner "local-exec" {
    # disable ssh host key prompts
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    command = <<EOT
      # give the box time to start SSH
      sleep 30 && \
      ansible-playbook \
        -i ${aws_instance.debian.public_ip}, \
        -u admin \
        --private-key ${path.module}/debian_ssh_key.pem \
        --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' \
        ${path.module}/../ansible/playbook.yml
    EOT
  }
}
