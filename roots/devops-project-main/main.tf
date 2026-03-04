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

locals {
  private_subnet_ids = module.vpc-module.private_subnet_ids_ordered
  vpc_id             = module.vpc-module.vpc_id
  eks_node_sg_id     = module.eks-module.node_security_group_id
}


module "documentdb" {
  source                  = "../../mongodb-module"
  vpc_id                  = local.vpc_id
  private_subnet_ids      = local.private_subnet_ids
  node_security_group_id  = local.eks_node_sg_id
  environment             = var.environment
  name_prefix             = var.name_prefix
  instance_count          = var.instance_count
  mongo_db_instance_class = var.mongo_db_instance_class
  tags_proshop            = var.tags_proshop
  master_username         = var.master_username
}
