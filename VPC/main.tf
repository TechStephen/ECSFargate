
# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ECS-Fargate-VPC"
    Project = "ECS-Fargate"
  }
}

###################### EIPs ############################

# Create EIP for NAT Gateway 1a
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "ECSFargateNATEIP"
    Project = "ECS-Fargate"
  }
}

# Create EIP for NAT Gateway 1b
resource "aws_eip" "nat_eip_two" {
  domain = "vpc"
  tags = {
    Name = "ECSFargateNATEIPTwo"
    Project = "ECS-Fargate"
  }
}

###################### ALB Public Subnets 1a and 1b ############################

# Create Public Subnet 1a (ALB)
resource "aws_subnet" "vpc_public_subnet" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ECSFargatePublicSubnet"
    Project = "ECS-Fargate"
  }
}

# Create Public Subnet 1b (ALB)
resource "aws_subnet" "vpc_public_subnet_two" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ECSFargatePublicSubnetTwo"
    Project = "ECS-Fargate"
  }
}

###################### ECS Service Private Subnets 1a and 1b ############################

# Create Private Subnet 1a (ECS Service)
resource "aws_subnet" "vpc_private_subnet" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ECSFargatePrivateSubnet"
    Project = "ECS-Fargate"
  }
}

# Create Private Subnet 1b (ECS Service)
resource "aws_subnet" "vpc_private_subnet_two" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ECSFargatePrivateSubnetTwo"
    Project = "ECS-Fargate"
  }
}

###################### NAT Gateway Public Subnets 1a and 1b ############################

# Create Public Subnet 1a (NAT Gateway)
resource "aws_subnet" "vpc_public_subnet_nat" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ECSFargatePublicSubnetNAT"
    Project = "ECS-Fargate"
  }
}

# Create Public Subnet 1a (NAT Gateway)
resource "aws_subnet" "vpc_public_subnet_nat_two" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ECSFargatePublicSubnetNATTwo"
    Project = "ECS-Fargate"
  }
}

###################### NAT Gateways 1a and 1b ############################


# Create NAT Gateway (1a)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.vpc_public_subnet_nat.id
  tags = {
    Name = "ECSFargateNATGateway"
    Project = "ECS-Fargate"
  }
}

# Create NAT Gateway (1b)
resource "aws_nat_gateway" "nat_gw_two" {
  allocation_id = aws_eip.nat_eip_two.id
  subnet_id = aws_subnet.vpc_public_subnet_nat_two.id
  tags = {
    Name = "ECSFargateNATGatewayTwo"
    Project = "ECS-Fargate"
  }
}

###################### Public Route Table for NAT Gateways ############################

# Create Public Route Table
resource "aws_route_table" "ebs_vpc_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "ECSFargatePublicRouteTable"
    Project = "ECS-Fargate"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "ECSFargateInternetGateway"
    Project = "ECS-Fargate"
  }
}

# Create Route for Internet
resource "aws_route" "public_internet_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.ebs_vpc_route_table.id
  gateway_id = aws_internet_gateway.igw.id
}

# Create Route Table Association for Public Subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id = aws_subnet.vpc_public_subnet.id
  route_table_id = aws_route_table.ebs_vpc_route_table.id
}

# Create Route Table Association for Public Subnet Two
resource "aws_route_table_association" "public_rta_two" {
  subnet_id = aws_subnet.vpc_public_subnet_two.id
  route_table_id = aws_route_table.ebs_vpc_route_table.id
}

###################### Private Route Table for ECS Services - Links to NAT Gateway (ECS Subnet 1a) ############################

# Create Private Route Table 1a
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "ECSFargatePrivateRouteTable"
    Project = "ECS-Fargate"
  }
}

# Create Route for Private Subnet 1a
resource "aws_route" "private_subnet_route_1a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.private_route_table.id
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}

# RTAs for Both Subnets 1a and 1b
resource "aws_route_table_association" "private_rta_1a" {
  subnet_id = aws_subnet.vpc_private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

###################### Private Route Table for ECS Services - Links to NAT Gateway (ECS Subnet 1b) ############################

# Create Private Route Table 1b
resource "aws_route_table" "private_route_table_two" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "ECSFargatePrivateRouteTableTwo"
    Project = "ECS-Fargate"
  }
}

# Create Route for Private Subnet 1b
resource "aws_route" "private_subnet_route_1b" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.private_route_table_two.id
  nat_gateway_id = aws_nat_gateway.nat_gw_two.id
}

resource "aws_route_table_association" "private_rta_1b" {
  subnet_id = aws_subnet.vpc_private_subnet_two.id
  route_table_id = aws_route_table.private_route_table_two.id
}