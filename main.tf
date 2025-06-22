# main.tf

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "debian" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
}

output "debian_public_ip" {
  value = aws_instance.debian.public_ip
}

resource "null_resource" "configure_ec2" {
  depends_on = [aws_instance.debian]

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
        -i ${aws_instance.debian.public_ip}, \
        -u admin \
        --private-key ~/.ssh/id_rsa \
        playbook.yml
    EOT
  }
}
