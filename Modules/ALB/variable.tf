variable "subnet_ids" {
  description = "The ID of the subnet to attach to the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC to attach to the ALB"
  type        = string
}