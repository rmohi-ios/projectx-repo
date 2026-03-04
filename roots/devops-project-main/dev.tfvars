project_name = "projectx_ubuntu25b"
cluster_name = "projectx_cluster_ubuntu25b"

vpc_cidr = "10.0.0.0/16"
azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
environment          = "dev"

ec2_types        = ["t3.medium", "t3a.medium", "t2.medium"]
k8s_version      = "1.34"
min_size         = 1
max_size         = 6
desired_capacity = 3
enable_addons    = true

# Grafana configs
grafana_admin_username      = "admin"
grafana_namespace           = "monitoring"
grafana_serviceaccount_name = "grafana-sa"

#DocumentDb (mongodb) configs
master_username         = "proshop_admin"
name_prefix             = "proshop"
mongo_db_instance_class = "db.t3.medium"
instance_count          = 1
tags_proshop = {
  Project     = "proshop"
  Environment = "dev"
}
