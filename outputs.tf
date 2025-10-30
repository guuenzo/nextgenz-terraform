output "cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_repo_url" {
  value = module.ecr.repo_uri
}

output "db_instance_endpoint" {
  value = module.database.rds_endpoint
}

output "secret_name" {
  value = module.secretsmanager.secret_name
}

output "cluster_role_name" {
  value = module.iam.cluster_role_name
}

output "node_role_name" {
  value = module.iam.node_role_names
}