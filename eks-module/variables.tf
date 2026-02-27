variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "subnets" {
  type        = list(string)
  description = "Subnet IDs for EKS cluster and worker nodes"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
}

variable "environment" {
  type        = string
  description = "Environment name for tagging (e.g., dev, staging, prod)"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster (e.g., 1.34)"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 5
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "enable_addons" {
  type        = bool
  description = "Whether to install EKS managed add-ons (vpc-cni, coredns, kube-proxy, ebs-csi)"
  default     = false
}

variable "ec2_types" {
  type        = list(string)
  description = "Worker node instance types for ASG mixed instances policy"
}

variable "vpc_cidr" {
  type = string
}