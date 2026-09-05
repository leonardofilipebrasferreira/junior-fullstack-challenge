resource "aws_sns_topic" "alerts" {
  name = "junior-fullstack-alerts"

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "high_button_clicks" {
  alarm_name        = "junior-fullstack-high-button-clicks"
  alarm_description = "Triggers when the application receives at least 5 button clicks in one minute"

  namespace   = "JuniorFullStackChallenge"
  metric_name = "ButtonClicks"

  statistic = "Sum"
  period    = 60

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 5

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}