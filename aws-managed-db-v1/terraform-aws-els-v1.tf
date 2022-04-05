locals {
  els_cluster_name = "${local.resource_prefix}-els"
}

variable "els_node_type" {
  default     = "t3.small.elasticsearch"
  description = "Elasticsearch instance type"
}

variable "els_version" {
  default     = "6.8"
  description = "Elasticsearch version"
}

variable "els_nodes_count" {
  default     = 3
  description = "Elasticsearch instance count"
}

variable "els_volume_size" {
  default     = 100
  description = "Elasticsearch volume size (GB)"
}

resource "aws_security_group" "els_clients_sg" {
  name        = "${local.resource_prefix}-els-clients-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow client nodes access to elasticsearch"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_iam_service_linked_role" "els" {
  aws_service_name = "es.amazonaws.com"
  custom_suffix    = random_string.random
  description      = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}

resource "aws_elasticsearch_domain" "pam_els" {
  domain_name           = local.els_cluster_name
  elasticsearch_version = var.els_version

  cluster_config {
    instance_type          = var.els_node_type
    instance_count         = var.els_nodes_count
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = var.els_volume_size
  }

  vpc_options {
    subnet_ids = [
      (length(data.aws_subnets.db_subnet_1.ids) > 0 ? data.aws_subnets.db_subnet_1.ids[0] : ""),
      (length(data.aws_subnets.db_subnet_2.ids) > 0 ? data.aws_subnets.db_subnet_2.ids[0] : ""),
      (length(data.aws_subnets.db_subnet_3.ids) > 0 ? data.aws_subnets.db_subnet_3.ids[0] : ""),
    ]
    security_group_ids = [aws_security_group.els_clients_sg.id]
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "<ElsMasterUser>"
      master_user_password = "<ElsMasterPassword>"
    }
  }

  tags = {
    cluster-name = local.els_cluster_name
  }
}
