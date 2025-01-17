# Create ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "ECS-Fargate-Cluster"

  tags = {
    Name = "ECS-Fargate-Cluster"
    Project = "ECS-Fargate"
  }
}

# Create ECS Service (Orchestrator)
resource "aws_ecs_service" "my_service" {
  name = "my-service"
  cluster = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count = 3 # how many containers we want deployed
  launch_type = "FARGATE"

  network_configuration {
    subnets = [var.subnet_id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name = "ECS-Fargate-Service"
    Project = "ECS-Fargate"
  }
}

# Create ECS Task Definition (Containers)
resource "aws_ecs_task_definition" "task_definition" {
  family = "my-task-family"
  requires_compatibilities = ["FARGATE"] # Enabled Fargate
  cpu = "256" # 0.25 vCPU   
  memory = "512" # 0.5 GB
  network_mode = "awsvpc" # Required for Fargate
  execution_role_arn = var.ecs_task_execution_role

  # Define Container(s)
  container_definitions = jsonencode([
    {
        name = "my-container"
        image = "767398032512.dkr.ecr.us-east-1.amazonaws.com/nextjs_docker_app:latest" # encode if prod
        cpu = 256
        memory = 512
        essential = true
        portMappings = [{
                containerPort = 80
                hostPort = 80
                protocol = "tcp"
            }
        ]
        command = ["yarn", "start", "--port", "80"], // dockerfile starts to port 3000, to avoid updating we have to specify
    }
  ])

  tags = {
    Name = "ECS-Fargate-Tast-Definition"
    Project = "ECS-Fargate"
  }
}


# Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-service-sg"
  description = "Allow traffic for ECS service"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS-Fargate-SG"
    Project = "ECS-Fargate"
  }
}