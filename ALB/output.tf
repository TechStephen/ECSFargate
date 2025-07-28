output "asg_tg_arn" {
  value = aws_lb_target_group.alb_tg.arn
}

output "alb_url" {
  value = aws_lb.app_lb.dns_name
}