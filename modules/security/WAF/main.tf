resource "aws_wafv2_web_acl" "main" {
name = "${var.waf_webacl_name}-${var.environment}-webacl"
scope = var.waf_scope
default_action {
  allow { }
}
visibility_config {
  cloudwatch_metrics_enabled = true
  metric_name = var.waf_metric_name
  sampled_requests_enabled = true
}
rule {
  name = "AWS-AWSManagedRulesAdminProtectionRuleSet"
  priority = 10
  override_action {
  none {}
 }
 statement {
   managed_rule_group_statement {
     vendor_name = "AWS"
     name = "AWSManagedRulesAdminProtectionRuleSet"
   }
 }

 visibility_config {
   cloudwatch_metrics_enabled = true
   metric_name = "awsadminprotectmetric"
   sampled_requests_enabled = true
 }
}
rule {
  name = "AWS-AWSManagedRulesAmazonIpReputationList"
  priority = 20
  override_action {
  none {}
}
 statement {
   managed_rule_group_statement {
     vendor_name = "AWS"
     name = "AWSManagedRulesAmazonIpReputationList"
   }
 }

 visibility_config {
   cloudwatch_metrics_enabled = true
   metric_name = "awsIpReputationmetric"
   sampled_requests_enabled = true
 }
}
rule {
  name = "AAWS-AWSManagedRulesAnonymousIpList"
  priority = 30
  override_action {
  none {}
}
 statement {
   managed_rule_group_statement {
     vendor_name = "AWS"
     name = "AWSManagedRulesAnonymousIpList"
   }
 }
 visibility_config {
   cloudwatch_metrics_enabled = true
   metric_name = "awsIpAnonymousmetric"
   sampled_requests_enabled = true
 }
}
rule {
  name = "AWS-AWSManagedRulesCommonRuleSet"
  priority = 40 
  override_action {
  none {}
  }
  statement {
    managed_rule_group_statement {
      vendor_name = "AWS"
      name = "AWSManagedRulesCommonRuleSet"
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true 
    metric_name = "awsCommonRulesmetric"
    sampled_requests_enabled = true
  }
}
rule {
  name = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
  priority = 50
  override_action {
  none {}
}
 statement {
   managed_rule_group_statement {
     vendor_name = "AWS"
     name = "AWSManagedRulesKnownBadInputsRuleSet"
   }
 }
 visibility_config {
   cloudwatch_metrics_enabled = true
   metric_name = "awsKnownBadInputsmetrics"
   sampled_requests_enabled = true
 }
}
rule {
  name = "AWS-AWSManagedRulesLinuxRuleSet"
  priority = 60
  override_action {
  none {}
  }
  statement {
    managed_rule_group_statement {
      vendor_name = "AWS"
      name = "AWSManagedRulesLinuxRuleSet"
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name = "awsLinuxRulesmetric"
    sampled_requests_enabled = true
  }
}
 rule {
  name = "AWS-AWSManagedRulesSQLiRuleSet"
  priority = 70
  override_action {
  none {}
  }
  statement {
    managed_rule_group_statement {
      vendor_name = "AWS"
      name = "AWSManagedRulesSQLiRuleSet"
    }
  } 
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name = "awsSQLiRulesmetrics"
    sampled_requests_enabled = true
  }
 }

 tags = {
   Name = "${var.waf_webacl_name}-${var.environment}-webacl"
   Environment = var.environment
 }
}