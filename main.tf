module "networking" {
  source  = "app.terraform.io/tcc_senai/networking/aws"
  version = "1.0.0"
  # insert required variables here
  vpc_name       = "nextgenz"
  vpc_cidr       = "172.16.0.0/16"
  public_a_cidr  = "172.16.1.0/24"
  public_b_cidr  = "172.16.2.0/24"
  private_a_cidr = "172.16.3.0/24"
  private_b_cidr = "172.16.4.0/24"
  az_a           = "${var.aws_region}a"
  az_b           = "${var.aws_region}b"
  environment    = "prod"
}

module "iam" {
  source  = "app.terraform.io/tcc_senai/iam/aws"
  version = "1.0.0"
  # insert required variables here
  cluster_role_name = "ClusterRole"
  node_role_name    = "NodeRole"
}

# module "eks" {
#   source  = "app.terraform.io/tcc_senai/eks/aws"
#   version = "1.0.0"
#   # insert required variables here
#   cluster_name          = "nextgenz"
#   cluster_subnet_ids    = [module.networking.public_sub_a_id, module.networking.public_sub_b_id, module.networking.private_sub_a_id, module.networking.private_sub_b_id]
#   cluster_sg_id         = module.networking.cluster_sg_id
#   k8s_cluster_role_arn  = module.iam.cluster_role_arn
#   k8s_version           = "1.33"
#   node_group_role_arn   = module.iam.node_role_arn
#   node_group_subnet_ids = [module.networking.private_sub_a_id, module.networking.private_sub_b_id]
#   environment           = "prod"

#   depends_on = [module.networking, module.iam]
# }

# module "alb_controller" {
#   source  = "app.terraform.io/tcc_senai/alb_controller/helm"
#   version = "1.0.0"
#   # insert required variables here
#   cluster_name                = module.eks.cluster_name
#   aws_region                  = var.aws_region
#   vpc_id                      = module.networking.vpc_id
#   eks_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url

#   depends_on = [module.eks, module.iam]
# }

# module "argocd" {
#   source  = "app.terraform.io/tcc_senai/argocd/helm"
#   version = "1.0.0"

#   depends_on = [module.eks]
# }

# module "keda" {
#   source  = "app.terraform.io/tcc_senai/keda/helm"
#   version = "1.0.0"

#   depends_on = [module.eks]
# }

# module "metrics_server" {
#   source  = "app.terraform.io/tcc_senai/metrics_server/helm"
#   version = "1.0.0"

#   depends_on = [module.eks]
# }

module "ecr" {
  source = "./modules/docker"

  repo_name   = "nextgenZ"
  environment = "prod"
}

module "waf" {
  source = "./modules/security/waf"

  waf_webacl_name = "next-gen-z-waf_web_acl"
  waf_metric_name = "next-gen-z-waf-metric"
  waf_scope       = "REGIONAL"
  aws_region      = var.aws_region
  aws_profile     = var.aws_profile
  environment     = "prod"
}

module "secretsmanager" {
  source = "./modules/security/secretsmanager"

  secret_name = "nextgenz-rds"
  username    = var.username
  password    = var.db_password
  environment = "prod"
}

module "database" {
  source = "./modules/database"

  instance_identifier     = "nextgenz"
  db_name                 = "nextgenzdb"
  backup_retention_period = 7
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  engine_version          = "10.11.8"
  subnet_ids              = [module.networking.private_sub_a_id, module.networking.private_sub_b_id]
  db_sg_id                = module.networking.db_sg_id
  db_username             = var.username
  db_password             = var.db_password
  environment             = "prod"

  depends_on = [module.secretsmanager]
}