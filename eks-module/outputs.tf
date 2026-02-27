output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.projectx_cluster.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.projectx_cluster.endpoint
}

output "cluster_oidc_issuer" {
  description = "EKS OIDC issuer URL (for IRSA)"
  value       = aws_eks_cluster.projectx_cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "cluster_security_group_id" {
  description = "AWS-managed EKS cluster security group ID"
  value       = aws_eks_cluster.projectx_cluster.vpc_config[0].cluster_security_group_id
}

output "control_plane_security_group_id" {
  description = "Custom control plane SG ID used in vpc_config.security_group_ids"
  value       = aws_security_group.cluster_sg.id
}

output "node_security_group_id" {
  description = "Worker node security group ID"
  value       = aws_security_group.eks_node_sg.id
}

output "workers_iam_role_arn" {
  description = "IAM role ARN used by worker nodes"
  value       = aws_iam_role.workers_role.arn
}

output "workers_asg_name" {
  description = "Worker nodes Auto Scaling Group name"
  value       = aws_autoscaling_group.workers_asg.name
}

output "workers_launch_template_id" {
  description = "Worker nodes launch template ID"
  value       = aws_launch_template.workers_lt.id
}