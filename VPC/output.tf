output "vpc_id" {
    value = aws_vpc.app_vpc.id
}

output "subnet_id_one" {
    value = aws_subnet.vpc_public_subnet.id 
}

output "subnet_id_two" {
    value = aws_subnet.vpc_public_subnet_two.id 
}