# Variables for the vpc-module
variable "project_name" {
  type        = string
  description = "Used for naming/tagging resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (ex: 10.0.0.0/16)"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "azs" {
  type        = list(string)
  description = "List of AZs to place subnets in (3 items)"

  validation {
    condition     = length(var.azs) == 3
    error_message = "azs must contain exactly 3 AZs."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for public subnets (3 items)"

  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "public_subnet_cidrs must contain exactly 3 CIDRs."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for private subnets (3 items)"

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "private_subnet_cidrs must contain exactly 3 CIDRs."
  }
}

variable "environment" {
  type        = string
  description = "Environment for the resources (ex: dev, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# variables for the eks-module

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
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

############################################
# Grafana (IRSA + Secrets Manager)
############################################

variable "grafana_admin_username" {
  type        = string
  description = "Grafana admin username stored in Secrets Manager"
  default     = "admin"
}

variable "grafana_namespace" {
  type        = string
  description = "Namespace where Grafana runs"
  default     = "monitoring"
}

variable "grafana_serviceaccount_name" {
  type        = string
  description = "Grafana ServiceAccount name (must match Helm chart SA)"
  default     = "grafana-sa"
}

# DocumentDB Module Variables
variable "name_prefix" {
  type = string
}
variable "mongo_db_instance_class" {
  type = string
}
variable "tags_proshop" {
  type = map(string)
}
variable "master_username" {
  type = string
}

variable "instance_count" {
  type = number
}

