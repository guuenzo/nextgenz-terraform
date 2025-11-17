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

  repo_name   = "nextgenz"
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

variable "domain_name" {
  default = "cf.nginx.215726090298.realhandsonlabs.net"
}

resource "aws_acm_certificate" "cf_cert" {
  domain_name       = var.domain_name              # ex: "nginx.215726090298.realhandsonlabs.net"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

variable "hosted_zone_id" {
  default = "Z04262242EAI3Y5J4MQSR"
}

resource "aws_route53_record" "cf_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cf_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cf_cert_validation_complete" {
  certificate_arn         = aws_acm_certificate.cf_cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cf_cert_validation : r.fqdn]
}

resource "aws_wafv2_web_acl" "cf_global_waf" {
  name        = "nextgenz-cloudfront-waf"
  description = "Global WAF for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "nextgenz-cloudfront-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_cloudfront_distribution" "alb_frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront in front of ALB for nextgenz"
  default_root_object = ""

  aliases = [
    var.domain_name    # ex: "nginx.215726090298.realhandsonlabs.net"
  ]

  origin {
    domain_name = "k8s-nextgenz-nginxing-fddd085abb-436344691.us-east-1.elb.amazonaws.com"  # ex: "k8s-nextgenz-nginxing-fddd085abb-436344691.us-east-1.elb.amazonaws.com"
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"       # ou "https-only" se o ALB tiver HTTPS
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cf_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # associa a Web ACL Global
  web_acl_id = aws_wafv2_web_acl.cf_global_waf.arn

  price_class = "PriceClass_100"  # pode ajustar se quiser mais regiões edge
}

resource "aws_route53_record" "cf_alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name     # ex: "nginx.215726090298.realhandsonlabs.net"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.alb_frontend.domain_name
    zone_id                = aws_cloudfront_distribution.alb_frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "alb_cert" {
  domain_name       = "nginx.215726090298.realhandsonlabs.net"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "alb_cert_validation_complete" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for r in aws_route53_record.alb_cert_validation : r.fqdn]
}
