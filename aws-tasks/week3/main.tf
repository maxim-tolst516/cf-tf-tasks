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

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name = "test_dtable-2"
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5
  hash_key = "uuid"

  attribute {
    name = "uuid"
    type = "S"
  }
//  ttl {
//    attribute_name = "TimeToExist"
//    enabled = false
//  }

  tags = {
    Name = "test_dtable-2"
  }
}

resource "aws_db_instance" "pg_database" {
  identifier             = "mydb"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.5"
  username               = "postgres"
  password               = "postgres"
//  db_subnet_group_name   = aws_db_subnet_group.education.name
//  vpc_security_group_ids = [aws_security_group.rds.id]
//  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
//
//data "template_file" "user_data" {
//  template = file("init-s3.sh")
//}


resource "aws_instance" "app_server" {
  ami = "ami-077e31c4939f6a2f3"
  instance_type = "t2.micro"
  key_name = "es-tut"
  user_data = <<EOF
          #!/bin/bash
          sudo yum update -y
          sudo /bin/echo "Hello World" >> /tmp/testfile.txt
          sudo aws s3 cp s3://db-scripts2/dynamodb-script.sh /tmp/dynamodb-script.sh --region us-east-2
          sudo aws s3 cp s3://db-scripts2/rds-script.sql /tmp/rds-script.sql --region us-east-2
          sudo sh /tmp/dynamodb-script.sh
          sudo sh /tmp/rds-script.sql

EOF
  security_groups = [
    aws_security_group.ec2_security.name
  ]
  iam_instance_profile = aws_iam_instance_profile.base_instance_profile.id
  tags = {
    Name = var.instance_name
    version = 0.1
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
        },
      },
    ]
  })
  path = "/"

  tags = {
    tag-key = "tag-value"
  }
}

//resource "aws_iam_role" "role_one" {
//  assume_role_policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Action   = ["s3:*" , "ec2:*", "rds:*", "dynamodb:*"]
//        Effect = "Allow"
//        Resource = "*"
//      },
//    ]
//  })
//  path = "/"
//
//  tags = {
//    tag-key = "tag-value"
//  }
//}

resource "aws_iam_instance_profile" "base_instance_profile" {
  path = "/"
  role = aws_iam_role.rw_role.id
//  roles = [aws_iam_role.rw_role.id, aws_iam_role.role_one.id]
}

resource "aws_iam_role_policy" "s3_rw_policy" {
  name = "test_policy"
  role = aws_iam_role.rw_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*" , "ec2:*", "rds:*", "dynamodb:*"]
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