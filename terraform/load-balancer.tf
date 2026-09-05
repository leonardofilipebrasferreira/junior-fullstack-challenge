resource "aws_security_group" "alb" {
  name        = "junior-fullstack-alb-sg"
  description = "Security group for the public Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP from the Internet"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS from the Internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_eks" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = module.eks.node_security_group_id

  from_port   = 30080
  to_port     = 30080
  ip_protocol = "tcp"

  description = "Allow the ALB to reach the frontend NodePort"
}

resource "aws_lb" "application" {
  name               = "junior-fullstack-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_from_alb" {
  security_group_id = module.eks.node_security_group_id

  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 30080
  to_port     = 30080
  ip_protocol = "tcp"

  description = "Allow the ALB to reach the frontend NodePort"
}

resource "aws_lb_target_group" "frontend" {
  name        = "junior-fullstack-frontend"
  port        = 30080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_autoscaling_attachment" "frontend" {
  autoscaling_group_name = module.eks.eks_managed_node_groups["application"].node_group_autoscaling_group_names[0]
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}

resource "tls_private_key" "alb" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "alb" {
  private_key_pem = tls_private_key.alb.private_key_pem

  dns_names = [
    aws_lb.application.dns_name
  ]

  subject {
    organization = "Junior Full Stack Challenge"
  }

  validity_period_hours = 720

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "aws_acm_certificate" "alb" {
  private_key      = tls_private_key.alb.private_key_pem
  certificate_body = tls_self_signed_cert.alb.cert_pem

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.application.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}