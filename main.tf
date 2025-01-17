terraform {
    #backend "s3" {
    #    bucket = "ecsfargate-state"
    #    key    = "terraform.tfstate"
    #    region = "us-east-1"
    #}   
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>5.0"
        }
    }
}

module "IAM" {
    source = "./IAM"
}

module "ECS" {
    source = "./ECS"
    subnet_id = module.VPC.subnet_id
    vpc_id = module.VPC.vpc_id
    ecs_task_execution_role = module.IAM.ecs_task_execution_role
}

module "VPC" {
    source = "./VPC"
}