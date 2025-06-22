provider "aws" {
  region = var.aws_region
}

# 1️⃣ Generate an SSH keypair
resource "tls_private_key" "debian_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "debian" {
  key_name   = "debian_ssh_key"
  public_key = tls_private_key.debian_key.public_key_openssh
}

resource "aws_instance" "debian" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.debian.key_name
}

# 2️⃣ Output the public IP
output "debian_public_ip" {
  value = aws_instance.debian.public_ip
}

# 3️⃣ Output the private key
output "debian_ssh_private_key" {
  value     = tls_private_key.debian_key.private_key_pem
  sensitive = true
}

# 4️⃣ Save the private key to a .pem file
resource "local_file" "debian_ssh_key" {
  content        = tls_private_key.debian_key.private_key_pem
  filename       = "${path.module}/debian_ssh_key.pem"
  file_permission = "0600"
}

# 5️⃣ Run Ansible after EC2 is up
resource "null_resource" "configure_ec2" {
  depends_on = [aws_instance.debian]

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
        -i ${aws_instance.debian.public_ip}, \
        -u admin \
        --private-key ${path.module}/debian_ssh_key.pem \
        playbook.yml
    EOT
  }
}
