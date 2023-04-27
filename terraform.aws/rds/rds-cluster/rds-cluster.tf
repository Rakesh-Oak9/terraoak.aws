resource "aws_rds_cluster" "sac_rds_cluster" {
  cluster_identifier      = "sac-testing-rds-cluster"
  database_name           = "sacrdsdatabase"
  engine                  = "aurora-mysql"
  master_username         = "sacMasterUsername"
  master_password         = "randomlydecidedpassword41characters"
  backup_retention_period = 1
  final_snapshot_identifier = "DELETE"
  skip_final_snapshot = true
  deletion_protection     = false
  db_subnet_group_name = aws_db_subnet_group.sac_rds_subnet_group.name
  
  engine_version          = "8.0.mysql_aurora.3.03.0"
  storage_encrypted   = false
  iam_database_authentication_enabled = false
}

resource "aws_vpc" "rds_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "sac-rds-vpc"
  }
}

resource "aws_subnet" "rds_subnet_1" {
  vpc_id     = aws_vpc.rds_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "rds_subnet_2" {
  vpc_id     = aws_vpc.rds_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Main"
  }
}

resource "aws_iam_role" "db_proxy_role" {
  name = "rds_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    key = "tag-value"
  }
}

resource "aws_secretsmanager_secret" "sac_secrets_manager" {
  name                    = "sac-testing-secrets-manager-3"
  description             = "Default config2"
  kms_key_id = aws_kms_key.sac_kms_key.id
  recovery_window_in_days = 10 
  
  tags = {
    Env = "dev"
  }
}

resource "aws_secretsmanager_secret_policy" "sac_secrets_manager_policy" {
  secret_arn = aws_secretsmanager_secret.sac_secrets_manager.arn

  policy = <<POLICY
  # oak9: Secrets policy allows any action using * (wildcards)
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableAnotherAWSAccountToReadTheSecret",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_kms_key" "sac_kms_key" {
  description             = "This key is used to encrypt dynamoDB objects"
  deletion_window_in_days = 10
  enable_key_rotation = true
  key_usage = "ENCRYPT_DECRYPT"

  tags = {
    Name        = "kms-key-1"
  }
}