resource "aws_lb" "app_lb" {
  name = "ecs-fargate-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.security_group_id]
  subnets = [var.subnet_ids[0], var.subnet_ids[1]]

  enable_deletion_protection = false

  tags = {
    Name = "ECSFargateALB"
    Project = "ECS-Fargate"
  }
}

resource "aws_lb_target_group" "alb_tg" {
    name = "alb-tg"
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id
    
    health_check {
        path = "/"
        port = "traffic-port"
        protocol = "HTTP"
        matcher = "200"
    }
    
    tags = {
        Name = "ECSFargateTG"
        Project = "ECS-Fargate"
    }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward" # should forward to target group 
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}