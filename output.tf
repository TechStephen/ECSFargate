output "app_url" {
  value = module.ALB.alb_url
}

# output "ms_url" {
#   value = module.ECS.internal_service_dns
# }

# Needed for Terratest HA test
output "alb_subnet_ids" {
  value = module.VPC.alb_subnet_ids
}