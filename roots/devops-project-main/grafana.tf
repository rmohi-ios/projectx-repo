# Grafana: IRSA + Secret


# Convert issuer URL into the format IAM expects for condition keys:
# Example: https://oidc.eks.us-east-1.amazonaws.com/id/ABC -> oidc.eks.us-east-1.amazonaws.com/id/ABC
locals {
  eks_oidc_issuer_hostpath = replace(module.eks-module.cluster_oidc_issuer, "https://", "")
}

# IAM Role that Grafana pod will assume via IRSA (ServiceAccount annotation)
resource "aws_iam_role" "grafana" {
  name = "${var.cluster_name}-grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = module.eks-module.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.eks_oidc_issuer_hostpath}:aud" = "sts.amazonaws.com"
            "${local.eks_oidc_issuer_hostpath}:sub" = "system:serviceaccount:${var.grafana_namespace}:${var.grafana_serviceaccount_name}"
          }
        }
      }
    ]
  })
}

# Random admin password for Grafana (stored in Secrets Manager)
resource "random_password" "grafana_admin" {
  length           = 28
  special          = true
  override_special = "!#$%&*+-.:=?@_"
}

# Secrets Manager secret holding Grafana admin creds
resource "aws_secretsmanager_secret" "grafana_admin" {
  name        = "${var.cluster_name}-grafana-admin-creds"
  description = "Grafana admin credentials for ${var.cluster_name}"

  recovery_window_in_days = 7

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Component   = "grafana"
    ManagedBy   = "terraform"
  }
}

# Actual secret value (JSON) with username + password
resource "aws_secretsmanager_secret_version" "grafana_admin" {
  secret_id = aws_secretsmanager_secret.grafana_admin.id

  secret_string = jsonencode({
    username = var.grafana_admin_username
    password = random_password.grafana_admin.result
  })
}

# IAM policy so Grafana can read ONLY this secret
resource "aws_iam_role_policy" "grafana_secrets_access" {
  name = "${var.cluster_name}-grafana-secrets-policy"
  role = aws_iam_role.grafana.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.grafana_admin.arn
      }
    ]
  })
}

# Outputs you will copy into platform-tools Helm values later
output "grafana_irsa_role_arn" {
  description = "IRSA IAM Role ARN for Grafana ServiceAccount"
  value       = aws_iam_role.grafana.arn
}

output "grafana_admin_secret_name" {
  description = "Secrets Manager secret name that stores Grafana admin creds"
  value       = aws_secretsmanager_secret.grafana_admin.name
}