resource "aws_iam_role" "backend_pod" {
  name = "junior-fullstack-backend-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_iam_role_policy" "backend_secret_access" {
  name = "read-rds-secret"
  role = aws_iam_role.backend_pod.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_db_instance.database.master_user_secret[0].secret_arn
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "backend" {
  cluster_name    = module.eks.cluster_name
  namespace       = "default"
  service_account = "backend"
  role_arn        = aws_iam_role.backend_pod.arn
}