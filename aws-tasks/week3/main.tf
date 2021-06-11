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
  ttl {
    attribute_name = "TimeToExist"
    enabled = false
  }

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