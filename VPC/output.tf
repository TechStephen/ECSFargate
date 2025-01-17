output "vpc_id" {
    value = aws_vpc.app_vpc.id
}

output "subnet_id" {
    value = aws_subnet.vpc_public_subnet.id 
}