resource "aws_db_subnet_group" "database" {
  name       = "junior-fullstack-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_security_group" "database" {
  name        = "junior-fullstack-db-sg"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "database_from_eks" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = module.eks.node_security_group_id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "PostgreSQL access from EKS nodes"
}

resource "aws_db_instance" "database" {
  identifier = "junior-fullstack-postgres"

  engine         = "postgres"
  engine_version = "17.11"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "challenge_db"
  username = "appuser"
  port     = 5432

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.database.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1

  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately = true

  tags = {
    Project     = "junior-fullstack-challenge"
    Environment = "dev"
  }
}