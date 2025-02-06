#providing the provifer
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#AWS configuration
provider "aws" {
    region = "ap-south-1"
    access_key = "AKIA4SDNWAAJK3BQKEEW"
    secret_key = "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"
}

#creating a connection
resource "tls_private_key" "tast_01" {
  algorithm = "RSA"
  rsa_bits  = 4096
} 

#creating a pem file
resource "aws_key_pair" "task_key_pair" {
  key_name   = "deployer-key"
  public_key = tls_private_key.tast_01.public_key_openssh
}

#copying a pem file
resource "local_file" "private_key" {
content = tls_private_key.tast_01.private_key_pem
filename = "deployer-key"
}

# Create a Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP inbound traffic"

  # Inbound rule for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows SSH from any IP (change for security)
  }

  # Inbound rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule (Allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#creatinga a ec2 instance
resource "aws_instance" "public_instance" {
  ami                     = "ami-00bb6a80f01f03502"
  instance_type           = "t2.micro"
  key_name = aws_key_pair.task_key_pair.key_name

  tags = {
    Name = "public_instance"
  }
}

#creating a s3 bucket
resource "aws_s3_bucket" "Taskk" {
  bucket = "my-tf-test-bucket701741"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
