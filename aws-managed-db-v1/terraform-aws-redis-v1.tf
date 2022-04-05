locals {
  redis_cluster_name = "${local.resource_prefix}-redis"
}

variable "redis_node_type" {
  default     = "cache.t3.small"
  description = "Redis instance type"
}

variable "redis_version" {
  default     = "6.x"
  description = "Redis version"
}

variable "redis_config" {
  default     = "default.redis6.x"
  description = "Redis config"
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = local.redis_cluster_name
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = var.redis_config
  engine_version       = var.redis_version
  port                 = 6379
}
