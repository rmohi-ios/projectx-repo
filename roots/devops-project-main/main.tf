module "vpc-module" {
  source               = "../../vpc-module"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
  cluster_name         = var.cluster_name
}

module "eks-module" {
  source       = "../../eks-module"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc-module.vpc_id
  subnets      = module.vpc-module.public_subnet_ids_ordered

  vpc_cidr     = var.vpc_cidr
  ec2_types    = var.ec2_types
  project_name = var.project_name
  environment  = var.environment
  k8s_version  = var.k8s_version

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  enable_addons    = var.enable_addons
}