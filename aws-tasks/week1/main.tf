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

resource "aws_vpc" "simple_vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "simple_vpc"
  }
}
resource "aws_subnet" "simple_subnet_1" {
  cidr_block = "10.1.0.0/24"
  vpc_id = aws_vpc.simple_vpc.id
  availability_zone = ""
  //  availability_zone = "us-east-2"
}
resource "aws_security_group" "ssh-http-allowed" {
  vpc_id = aws_vpc.simple_vpc.id
  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-and-http-allowed"
  }
}

resource "aws_launch_template" "SimpleLaunchTemplate" {
  image_id = "ami-077e31c4939f6a2f3"
  instance_type = "t2.micro"
  key_name = "es-tut"
  name = "simple_lt"

  user_data = filebase64("ec-init.sh")
  network_interfaces {
    device_index = 0
    associate_public_ip_address = true
//    security_groups = ["sg-a63160d1"]
    security_groups = [aws_security_group.ssh-http-allowed.id]
  }
  block_device_mappings {
    ebs {
      volume_size = 8
      delete_on_termination = true
      volume_type = "gp2"
    }
    device_name = "/dev/xvdcz"
  }
}

resource "aws_autoscaling_group" "simpleASG" {
  max_size = 2
  min_size = 0
  desired_capacity = 2
  health_check_grace_period = 300
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.SimpleLaunchTemplate.id
      }
    }
  }
  vpc_zone_identifier = [
    aws_subnet.simple_subnet_1.id]
}