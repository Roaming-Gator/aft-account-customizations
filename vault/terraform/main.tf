locals {
  # how many nodes to run in the cluster (must be an odd number)
  instance_count = 3
  # number of subnets to deploy (will deploy one per AZ)
  subnet_count     = 3
  ecs_cluster_name = "vault-cluster"
  app_name         = "vault"
}
