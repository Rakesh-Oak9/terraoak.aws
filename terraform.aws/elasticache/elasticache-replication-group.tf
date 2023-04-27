resource "aws_elasticache_replication_group" "sac_replication_group_redis" {
  preferred_cache_cluster_azs = ["us-east-2b", "us-east-2c"]
  replication_group_id        = "sac-testing-replication-group-redis"
  description                 = "sac testing replication group"
  node_type                   = "cache.t3.small"
  num_cache_clusters          = 2
  parameter_group_name        = "default.redis7"
  port                        = 6379
  multi_az_enabled = false
  automatic_failover_enabled  = true
  at_rest_encryption_enabled = false
  transit_encryption_enabled = true
}