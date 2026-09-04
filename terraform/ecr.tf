resource "aws_ecr_repository" "frontend" {
  name                 = "junior-fullstack-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "junior-fullstack-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}