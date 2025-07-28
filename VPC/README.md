# ECS Fargate VPC Setup

This Terraform project sets up a network for running Amazon ECS Fargate tasks. It makes the setup safe and highly available (HA). That means your app will keep working even if one part of AWS has problems.

## What This Does

- Makes a **VPC** (Virtual Private Cloud) to hold everything.
- Adds **subnets** (pieces of the network):
  - **Public subnets**: Used by the Load Balancer (ALB).
  - **Private subnets**: Used by your ECS containers. These are not open to the internet.
  - **Public subnets for NAT**: Special public subnets that help private containers connect to the internet.

- Adds **NAT Gateways** (1 per zone) so private containers can go out to the internet (for updates, APIs, etc).
- Adds an **Internet Gateway** so the Load Balancer can be reached from outside.
- Sets up **route tables** to control where network traffic goes.

## Subnets Used

| Name                     | Type     | Zone        | Purpose                         |
|--------------------------|----------|-------------|---------------------------------|
| vpc_public_subnet        | Public   | us-east-1a  | For Load Balancer (ALB)         |
| vpc_public_subnet_two    | Public   | us-east-1b  | For Load Balancer (ALB)         |
| vpc_private_subnet       | Private  | us-east-1a  | For ECS Fargate containers      |
| vpc_private_subnet_two   | Private  | us-east-1b  | For ECS Fargate containers      |
| vpc_public_subnet_nat    | Public   | us-east-1a  | Holds NAT Gateway 1a            |
| vpc_public_subnet_nat_two| Public   | us-east-1b  | Holds NAT Gateway 1b            |

## Gateways

- **Internet Gateway**: Lets public things (like the Load Balancer) talk to the internet.
- **NAT Gateways**: Let private containers talk to the internet without being seen from the outside.

## Route Tables

- Public subnets use a route table that goes to the Internet Gateway.
- Each private subnet uses a route table that goes to a NAT Gateway in the same zone.

## High Availability (HA)

Everything is made in **two zones** (us-east-1a and us-east-1b). If one zone breaks, the other keeps working. This is good for apps that need to be up all the time.

## Notes
