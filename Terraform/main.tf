terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Auto-generate RDS password
resource "random_password" "rds_password" {
  length  = 16
  special = true
  override_special = "!#$%^&*()-_=+[]{}<>?~"
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "nti-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.14.0"

  cluster_name    = "nti-eks"
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
      subnet_ids     = module.vpc.private_subnets
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
  }
}

# Secrets Manager for RDS Credentials
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds_credentials_test9"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds_password.result
  })
}

# RDS Instance
resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "mydb" {
  identifier           = "my-rds-instance"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "mydb"
  username             = "admin"
  password             = random_password.rds_password.result
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  skip_final_snapshot  = true
  publicly_accessible  = false
}

# EC2 Key Pair
resource "aws_key_pair" "nti_key" {
  key_name   = "nti-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDClBVNQBycjAXuygQPnQNX/NBQfdOdyEz0kMpzWU61orQ/J8njg4B2xud46EAkw3WXVPGlg2IJ/RxLJGhHPeWfLsanVOp0a3HK12PmMiOdc2YnBRaYpK50zk29SIFPwSFBrdALoDh6IYBSlcI18UmBzBObErXoo64qfUDiaGbIQGM1FSvVXuko72ncu3JkNTun8ZZaycbrLUJ7k6yynibDFqrClgt9bg/3cOJqAZzBM11fTJtvJMAblA2WCr7CJYxI1hHjCnRo3OyEvC+8MUQZsMxTZlQO38765wP5KJ3nGtTI3H7wEG7k04kzlR7yQFK1o9MM3zqMJFdDuSrFPcCJ"
}

# Global EC2 Security Group
resource "aws_security_group" "nti_ec2_sg" {
  name   = "nti-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP (Jenkins, SonarQube, etc)"
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nti-global-ec2-sg"
  }
}

# Jenkins EC2
resource "aws_instance" "jenkins_ec2" {
  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = aws_key_pair.nti_key.key_name
  vpc_security_group_ids      = [aws_security_group.nti_ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "jenkins"
  }
}

# SonarQube EC2
resource "aws_instance" "sonarqube_ec2" {
  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.medium"
  subnet_id                   = module.vpc.public_subnets[1]
  key_name                    = aws_key_pair.nti_key.key_name
  vpc_security_group_ids      = [aws_security_group.nti_ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "sonarqube"
  }
}

# Monitoring EC2 (Prometheus + Grafana)
resource "aws_instance" "monitoring_ec2" {
  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.medium"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = aws_key_pair.nti_key.key_name
  vpc_security_group_ids      = [aws_security_group.nti_ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "monitoring"
  }
}

# Backup Jenkins
resource "aws_backup_vault" "jenkins_vault" {
  name = "jenkins-backup-vault"
}

resource "aws_backup_plan" "jenkins_plan" {
  name = "daily-jenkins-backup"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.jenkins_vault.name
    schedule          = "cron(0 5 * * ? *)"
    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_backup_selection" "jenkins_backup" {
  name         = "jenkins-backup-selection"
  iam_role_arn = "arn:aws:iam::359329123577:role/service-role/AWSBackupDefaultServiceRole"

  resources = [
    aws_instance.jenkins_ec2.arn
  ]

  plan_id = aws_backup_plan.jenkins_plan.id
}

# ELB Logs Bucket
resource "aws_s3_bucket" "elb_logs" {
  bucket = "nti-elb-logs-unique-001"
}

# ECR Repo
resource "aws_ecr_repository" "app_repo" {
  name = "nti-app"
}

# DynamoDB Table
resource "aws_dynamodb_table" "todos" {
  name         = "Todos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "Todos"
  }
}


