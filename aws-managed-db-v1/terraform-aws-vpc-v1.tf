
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "${local.resource_prefix}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.65.0/24", "10.0.66.0/24", "10.0.67.0/24"]
  private_subnets      = ["10.0.144.0/20", "10.0.160.0/20", "10.0.176.0/20"]
  database_subnets     = ["10.0.193.0/24", "10.0.194.0/24", "10.0.195.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

data "aws_subnets" "db_subnet_1" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-db-${var.region}a"]
  }
}

data "aws_subnets" "db_subnet_2" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-db-${var.region}b"]
  }
}

data "aws_subnets" "db_subnet_3" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-db-${var.region}c"]
  }
}


data "aws_subnets" "public_subnet_1" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-public-${var.region}a"]
  }
}

data "aws_subnets" "public_subnet_2" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-public-${var.region}b"]
  }
}

data "aws_subnets" "public_subnet_3" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-public-${var.region}c"]
  }
}



data "aws_subnets" "private_subnet_1" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-private-${var.region}a"]
  }
}

data "aws_subnets" "private_subnet_2" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-private-${var.region}b"]
  }
}

data "aws_subnets" "private_subnet_3" {

  filter {
    name   = "tag:Name"
    values = ["${local.resource_prefix}-vpc-private-${var.region}c"]
  }
}
