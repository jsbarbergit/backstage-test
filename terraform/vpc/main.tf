terraform {
  required_version = ">=1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.33.0, <6.0.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = var.tags
  }
}

variable "app_name" {
  description = "A unique identifer to be used for ephemeral testing resources"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  default     = {}
  type        = map(string)
}

resource "aws_vpc" "rds_module_testing" {
  cidr_block           = "192.168.0.0/24"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.app_name}-test"
  }
}

# Create a new subnets within the VPC
resource "aws_subnet" "app_subnet_2a" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = "192.168.0.0/26"
  availability_zone = "eu-west-2a"
  tags = {
    "Name" = "${var.app_name}-test-app-subnet-2a"
  }
}

resource "aws_subnet" "app_subnet_2b" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = "192.168.0.64/26"
  availability_zone = "eu-west-2b"
  tags = {
    "Name" = "${var.app_name}-test-app-subnet-2b"
  }
}

resource "aws_subnet" "db_subnet_2a" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = "192.168.0.128/26"
  availability_zone = "eu-west-2a"
  tags = {
    "Name" = "${var.app_name}-test-db-subnet-2a"
  }
}

resource "aws_subnet" "db_subnet_2b" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = "192.168.0.192/26"
  availability_zone = "eu-west-2b"
  tags = {
    "Name" = "${var.app_name}-test-db-subnet-2b"
  }
}

output "vpc_id" {
  value = aws_vpc.rds_module_testing.id
}

output "db_subnet_ids" {
  value = [aws_subnet.db_subnet_2a.id, aws_subnet.db_subnet_2b.id]
}
