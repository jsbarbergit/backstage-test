terraform {
  backend "s3" {}
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

variable "vpc_size" {
  description = "VPC CIDR Range"
  type        = string
  validation {
    condition = contains(["small", "medium", "large"], var.vpc_size)
    error_message = "Invalid vpc_size given. Must be one of small, medium or large"
  }
}

variable "tags" {
  description = "Common tags for all resources"
  default     = {}
  type        = map(string)
}

locals {
  cidr_range = {
    "small": {
      "cidr": "10.0.0.0/26",
      "app_sub1": "10.0.0.0/28",
      "app_sub2": "10.0.0.16/28",
      "db_sub1": "10.0.0.32/28",
      "db_sub2": "10.0.0.48/28"
    },
    "medium":{
      "cidr": "10.0.0.0/24",
      "app_sub1": "10.0.0.0/26",
      "app_sub2": "10.0.0.64/26",
      "db_sub1": "10.0.0.128/26",
      "db_sub2": "10.0.0.192/26"
    },
    "large":{
      "cidr": "10.0.0.0/22",
      "app_sub1": "10.0.0.0/24",
      "app_sub2": "10.0.1.0/24",
      "db_sub1": "10.0.2.0/24",
      "db_sub2": "10.0.3.0/24"
    },
  }
}

resource "aws_vpc" "rds_module_testing" {
  cidr_block           = local.cidr_range[var.vpc_size]["cidr"]
  enable_dns_hostnames = true
  tags = {
    Name = "${var.app_name}-test"
  }
}

# Create a new subnets within the VPC
resource "aws_subnet" "app_subnet_2a" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = local.cidr_range[var.vpc_size]["app_sub1"]
  availability_zone = "eu-west-2a"
  tags = {
    "Name" = "${var.app_name}-test-app-subnet-2a"
  }
}

resource "aws_subnet" "app_subnet_2b" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = local.cidr_range[var.vpc_size]["app_sub2"]
  availability_zone = "eu-west-2b"
  tags = {
    "Name" = "${var.app_name}-test-app-subnet-2b"
  }
}

resource "aws_subnet" "db_subnet_2a" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = local.cidr_range[var.vpc_size]["db_sub1"]
  availability_zone = "eu-west-2a"
  tags = {
    "Name" = "${var.app_name}-test-db-subnet-2a"
  }
}

resource "aws_subnet" "db_subnet_2b" {
  vpc_id            = aws_vpc.rds_module_testing.id
  cidr_block        = local.cidr_range[var.vpc_size]["db_sub2"]
  availability_zone = "eu-west-2b"
  tags = {
    "Name" = "${var.app_name}-test-db-subnet-2b"
  }
}

output "vpc_id" {
  value = aws_vpc.rds_module_testing.id
}

output "app_subnet_ids" {
  value = [aws_subnet.app_subnet_2a.id, aws_subnet.app_subnet_2b.id]
}

output "db_subnet_ids" {
  value = [aws_subnet.db_subnet_2a.id, aws_subnet.db_subnet_2b.id]
}
