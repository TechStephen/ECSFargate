variable "ecs_task_execution_role" {
  description = "value of the ECS task execution role ARN"
  type = string
}

variable "vpc_id" {
  description = "value of the VPC ID"
  type = string
}

variable "subnet_ids" {
  description = "value of the subnet ID"
  type = list(string)
}

variable "asg_tg_arn" {
  description = "value of the ASG target group ARN"
  type = string
}