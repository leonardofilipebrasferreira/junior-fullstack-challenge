variable "aws_region" {
  description = "AWS region used to deploy the infrastructure"
  type        = string
  default     = "eu-south-2"
}

variable "notification_email" {
  description = "Email address used to receive CloudWatch alarm notifications"
  type        = string
  sensitive   = true
}