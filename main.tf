terraform {
  #backend "s3" {
  #    bucket = "ecsfargate-state"
  #    key    = "terraform.tfstate"
  #    region = "us-east-1"
  #    encrypt = true
  #    use_lockfile = true
  #}   
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

module "VPC" {
  source = "./Modules/VPC"
}

module "IAM" {
  source = "./Modules/IAM"
}

module "ALB" {
  source     = "./Modules/ALB"
  subnet_ids = module.VPC.alb_subnet_ids
  vpc_id     = module.VPC.vpc_id

  depends_on = [module.VPC]
}

module "ECS" {
  source                  = "./Modules/ECS"
  subnet_ids              = module.VPC.ecs_service_subnet_ids
  vpc_id                  = module.VPC.vpc_id
  ecs_task_execution_role = module.IAM.ecs_task_execution_role
  asg_tg_arn              = module.ALB.asg_tg_arn

  depends_on = [
    module.ALB, module.VPC, module.IAM
  ]
}