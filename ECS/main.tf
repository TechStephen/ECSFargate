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
  desired_count = 4 # how many containers we want deployed
  launch_type = "FARGATE"

  network_configuration {
    subnets = var.subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false # private subnets for best practices
  }

  load_balancer {
    target_group_arn = var.asg_tg_arn
    container_name   = "my-container" # Match the name in your task definition
    container_port   = 80 # Match the port exposed in your task definition
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
        image = "767398032512.dkr.ecr.us-east-1.amazonaws.com/ecs-fe:latest" # encode if prod
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
  vpc_id      = var.vpc_id

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

########### MS Task Definition and Service Discovery for Private Endpoint ###########

# Cloud Map Namespace (private)
resource "aws_service_discovery_private_dns_namespace" "local_ns" {
  name        = "services.local"
  description = "Private namespace for internal microservices"
  vpc         = var.vpc_id
}

# Service Discovery Service
resource "aws_service_discovery_service" "my_ms_discovery" {
  name = "my-microservice"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.local_ns.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# ECS Task Definition for Microservice
resource "aws_ecs_task_definition" "ms_task" {
  family                   = "my-microservice"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name  = "my-microservice"
      image = "767398032512.dkr.ecr.us-east-1.amazonaws.com/ecs-ms:latest" # add docker image
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ],
      essential = true
    }
  ])
}

# ECS Service for Microservice with Service Discovery
resource "aws_ecs_service" "ms_service" {
  name            = "my-microservice"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.ms_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.microservice_sg.id]
    assign_public_ip = false
  }

  service_registries { # what links your service with cloud map (service discovery) and gives the .local internal domain
    registry_arn = aws_service_discovery_service.my_ms_discovery.arn
  }

  depends_on = [aws_service_discovery_service.my_ms_discovery]

  tags = {
    Name    = "ECS-Fargate-Microservice-Service"
    Project = "ECS-Fargate"
  }
}

resource "aws_security_group" "microservice_sg" {
  name        = "microservice-sg"
  description = "Allow traffic from frontend ECS service"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow frontend service to call microservice"
    from_port        = 80                    # Change if your microservice listens on a different port
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "microservice-sg"
    Project = "ECS-Fargate"
  }
}

