output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "aws_region" {
  description = "AWS region where the infrastructure is deployed"
  value       = var.aws_region
}

output "frontend_ecr_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "database_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = aws_db_instance.database.address
}

output "database_secret_arn" {
  description = "ARN of the RDS master credentials secret"
  value       = aws_db_instance.database.master_user_secret[0].secret_arn
}

output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.application.dns_name
}

output "application_https_url" {
  description = "HTTPS URL of the application"
  value       = "https://${aws_lb.application.dns_name}"
}