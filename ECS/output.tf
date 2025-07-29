# # Output the internal domain
# output "internal_service_dns" {
#   value = aws_ecs_task_definition.ms_task.container_definitions + ".services.local"
# }