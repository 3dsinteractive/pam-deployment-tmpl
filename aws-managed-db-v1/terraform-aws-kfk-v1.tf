locals {
  kfk_cluster_name = "${local.resource_prefix}-kfk"
  kfk_config_name  = "${local.resource_prefix}-kfk-config"
}

variable "kfk_node_type" {
  default     = "kafka.t3.small"
  description = "Kafka instance type"
}

variable "kfk_version" {
  default     = "2.6.2"
  description = "Kafka version"
}

variable "kfk_node_count" {
  default     = 3
  description = "Kafka instance count"
}

variable "kfk_volume_size" {
  default     = 100
  description = "Kafka volume size (GB)"
}

resource "aws_security_group" "kfk_clients_sg" {
  name_prefix = "${local.resource_prefix}-kfk-clients-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow client nodes access to kafka"

  ingress {
    from_port = 9092
    to_port   = 9092
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_msk_configuration" "kafka_config" {
  kafka_versions = [var.kfk_version]
  name           = local.kfk_config_name

  server_properties = <<PROPERTIES
auto.create.topics.enable=false
default.replication.factor=2
min.insync.replicas=2
num.io.threads=8
num.network.threads=5
num.partitions=10
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=true
zookeeper.session.timeout.ms=18000
message.max.bytes=1000000
delete.topic.enable=true
PROPERTIES
}


resource "aws_msk_cluster" "kafka" {
  cluster_name           = local.kfk_cluster_name
  kafka_version          = var.kfk_version
  number_of_broker_nodes = var.kfk_node_count

  broker_node_group_info {
    instance_type   = var.kfk_node_type
    ebs_volume_size = var.kfk_volume_size

    client_subnets = [
      (length(data.aws_subnets.db_subnet_1.ids) > 0 ? data.aws_subnets.db_subnet_1.ids[0] : ""),
      (length(data.aws_subnets.db_subnet_2.ids) > 0 ? data.aws_subnets.db_subnet_2.ids[0] : ""),
      (length(data.aws_subnets.db_subnet_3.ids) > 0 ? data.aws_subnets.db_subnet_3.ids[0] : ""),
    ]
    security_groups = [aws_security_group.kfk_clients_sg.id]
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
      in_cluster    = true
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka_config.arn
    revision = aws_msk_configuration.kafka_config.latest_revision
  }
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.kafka.bootstrap_brokers_tls
}
