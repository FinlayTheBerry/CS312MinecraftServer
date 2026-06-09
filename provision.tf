terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "minecraft_securitygroup" {
  name = "minecraft_securitygroup"
  description = "Allows ssh and minecraft connections."
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 25565
    to_port = 25565
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 25565
    to_port = 25565
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "minecraft_privatekey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "minecraft_keypair" {
  key_name = "minecraft_keypair"
  public_key = tls_private_key.minecraft_privatekey.public_key_openssh
}

resource "local_file" "save_minecraft_key" {
  filename = "${path.module}/minecraft_key.pem"
  content = tls_private_key.minecraft_privatekey.private_key_pem
  file_permission = "0600"
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "minecraft_server" {
  ami = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  key_name = aws_key_pair.minecraft_keypair.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_securitygroup.id]

  tags = {
    Name = "minecraft_instance"
  }
}

resource "aws_eip" "minecraft_elasticip" {
  domain = "vpc"
  instance = aws_instance.minecraft_server.id

  tags = {
    Name = "minecraft_elasticip"
  }
}

resource "local_file" "save_minecraft_hosts" {
  filename = "${path.module}/minecraft_hosts.ini"
  content  = <<EOF
[minecraft_hosts]
minecraft ansible_host="${aws_eip.minecraft_elasticip.public_ip}" ansible_user="ec2-user" ansible_ssh_private_key_file="${path.module}/minecraft_key.pem"
EOF
}

output "Minecraft_Server_IP_Address" {
  value = aws_eip.minecraft_elasticip.public_ip
}
