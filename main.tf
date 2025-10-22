#CHAMADA DOS MODULES

module "waf" {
  source = "./modules/security/WAF"

  waf_name = "next-gen-z-waf"
  waf_metric_name = "next-gen-z-waf-metric"
  waf_scope = "REGIONAL"
  
  
}