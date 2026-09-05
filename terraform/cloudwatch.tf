resource "aws_iam_role" "cloudwatch_observability" {
  name = "junior-fullstack-cloudwatch-role"

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

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_observability.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/containerinsights/${module.eks.cluster_name}/application"
  retention_in_days = 7

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = "v6.6.0-eksbuild.1"

  configuration_values = jsonencode({
    containerLogs = {
      enabled = true
    }

    containerInsights = {
      enabled = false
    }

    otelContainerInsights = {
      enabled = false
    }

    manager = {
      applicationSignals = {
        autoMonitor = {
          monitorAllServices = false
        }
      }
    }
  })

  pod_identity_association {
    service_account = "cloudwatch-agent"
    role_arn        = aws_iam_role.cloudwatch_observability.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_agent,
    aws_cloudwatch_log_group.application
  ]

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_metric_filter" "button_click" {
  name           = "junior-fullstack-button-clicks"
  log_group_name = aws_cloudwatch_log_group.application.name

  pattern = "{ $.log_processed.event = \"button_click\" }"

  metric_transformation {
    name      = "ButtonClicks"
    namespace = "JuniorFullStackChallenge"
    value     = "1"
    unit      = "Count"
  }
}