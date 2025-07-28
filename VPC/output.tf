output "vpc_id" {
    value = aws_vpc.app_vpc.id
}

output "alb_subnet_ids" {
    value = [aws_subnet.vpc_public_subnet.id, aws_subnet.vpc_public_subnet_two.id]
}

output "ecs_service_subnet_ids" {
    value = [aws_subnet.vpc_private_subnet.id, aws_subnet.vpc_private_subnet_two.id]
}


