terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami = "ami-077e31c4939f6a2f3"
  instance_type = "t2.micro"
  key_name = "es-tut"
  user_data = <<EOF
          #!/bin/bash
          sudo yum update -y
          aws s3 cp s3://week2-backet/temp.txt /files/tmp.txt

EOF
  security_groups = [
    aws_security_group.ec2_security.name
  ]
  iam_instance_profile = aws_iam_instance_profile.base_instance_profile.id
  tags = {
    Name = var.instance_name
  }
}

resource "aws_iam_role" "rw_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  path = "/"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "base_instance_profile" {
  path = "/"
  role = aws_iam_role.rw_role.id
}

resource "aws_iam_role_policy" "s3_rw_policy" {
  name = "test_policy"
  role = aws_iam_role.rw_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_security_group" "ec2_security" {
  vpc_id = "vpc-e17dee8a"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}