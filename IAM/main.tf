# IAM Policy For ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
    
    tags = {
        Name = "ECS-Fargate-Task-Execution-Role"
        Project = "ECS-Fargate"
    }
}

# Attach Policy to ECS Task Execution Role
resource "aws_iam_policy_attachment" "policy_attachment" {
  name = "ecsTaskExecutionRoleAttachment"
  roles = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}