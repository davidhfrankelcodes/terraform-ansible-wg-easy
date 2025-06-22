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

# 2️⃣ Create a security group for SSH
resource "aws_security_group" "debian_ssh" {
  name        = "debian_ssh_sg"
  description = "Allow SSH access"

  ingress {
    description = "SSH from any IP (adjust as needed)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # ⚠️ WARNING: This is open to the world, use your IP instead
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# 3️⃣ EC2 instance
resource "aws_instance" "debian" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.debian.key_name

  vpc_security_group_ids      = [aws_security_group.debian_ssh.id]
  associate_public_ip_address = true
}

# 4️⃣ Output the public IP
output "debian_public_ip" {
  value = aws_instance.debian.public_ip
}

# 5️⃣ Output the private key
output "debian_ssh_private_key" {
  value     = tls_private_key.debian_key.private_key_pem
  sensitive = true
}

# 6️⃣ Save the private key to a .pem file
resource "local_file" "debian_ssh_key" {
  content        = tls_private_key.debian_key.private_key_pem
  filename       = "${path.module}/debian_ssh_key.pem"
  file_permission = "0600"
}

# 7️⃣ Run Ansible after EC2 is up
resource "null_resource" "configure_ec2" {
  depends_on = [aws_instance.debian]

  provisioner "local-exec" {
    command = <<EOT
      # Wait 30 seconds for SSH to be available
      sleep 30 && \
      ansible-playbook \
        -i ${aws_instance.debian.public_ip}, \
        -u admin \
        --private-key ${path.module}/debian_ssh_key.pem \
        ${path.module}/../ansible/playbook.yml
    EOT
  }
}
