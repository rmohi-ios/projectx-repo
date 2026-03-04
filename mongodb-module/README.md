# **DocumentDB Terraform Module**

## **Overview**

This repository provisions an **AWS DocumentDB (MongoDB-compatible)** cluster using Terraform.

It is structured with a **root module** for environment configuration and a reusable **DocumentDB child module** that encapsulates all database-related resources.

The module is designed to be used with multiple environments (dev, staging, production) and integrates with AWS Secrets Manager for secure credential storage.

---

## **Repository Structure**

```
.
├── documentdb-module/
│   ├── main.tf
│   ├── network.tf
│   ├── outputs.tf
│   └── variables.tf
│
├── main.tf
├── providers.tf
├── variables.tf
├── dev.tfvars
├── staging.tfvars
├── production.tfvars
```

---

## **Root Module**

The root module is responsible for:

- Provider configuration
- Backend configuration (S3 state)
- Passing environment-specific values to the DocumentDB module

### **Root**

### **main.tf**

### **(example)**

```
module "documentdb" {
  source = "../../documentdb-module"

  environment          = var.environment
  name_prefix          = var.name_prefix
  vpc_id               = var.vpc_id
  private_subnet_ids   = var.private_subnet_ids
  eks_node_sg_id       = var.eks_node_sg_id
  instance_class       = var.instance_class
  instance_count       = var.instance_count
  master_username      = var.master_username
  tags                 = var.tags
}
```

---

## **Environment Configuration**

Each environment uses its own .tfvars file.

### **Example:**

### **dev.tfvars**

```
environment        = "dev"
name_prefix        = "proshop"
vpc_id             = "vpc-xxxxxxxx"
private_subnet_ids = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
eks_node_sg_id     = "sg-xxxxxxxx"

instance_class  = "db.t3.medium"
instance_count  = 1
master_username = "proshop_admin"

tags = {
  Project     = "proshop"
  Environment = "dev"
}
```

---

## **DocumentDB Module**

### **What the module creates**

- AWS DocumentDB cluster
- One or more cluster instances (primary + replicas)
- Custom cluster parameter group (TLS disabled)
- Subnet group using private subnets
- Security group allowing access from EKS worker nodes
- Randomly generated master password
- AWS Secrets Manager secret with credentials and connection string

---

## **TLS Configuration**

TLS is disabled at the **cluster parameter group** level:

```
resource "aws_docdb_cluster_parameter_group" "docdb_tls_disabled" {
  name   = "${var.name_prefix}-${var.environment}-docdb-param-group"
  family = "docdb5.0"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
```

This parameter group is explicitly attached to the cluster:

```
db_cluster_parameter_group_name =
  aws_docdb_cluster_parameter_group.docdb_tls_disabled.name
```

> Note: A cluster restart may be required for parameter group changes to take effect.
> 

---

## **Secrets Management**

### **Stored in AWS Secrets Manager**

The module creates a secret containing:

- username
- password
- engine
- host
- port
- MONGO_URI

Example secret payload:

```
{
  "username": "proshop_admin",
  "password": "********",
  "engine": "documentdb",
  "host": "cluster.endpoint.amazonaws.com",
  "port": 27017,
  "MONGO_URI": "mongodb://proshop_admin:<password>@<endpoint>:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false&directConnection=true"
}
```

### **Secret naming strategy**

A random suffix is added to the secret name to avoid conflicts with secrets scheduled for deletion:

```
proshop-dev-docdb-secret-<random_suffix>
```

This prevents failures during frequent terraform destroy / apply cycles.

---

## **Secret Rotation**

Automatic secret rotation is **not enabled by default**.

Reason:

- AWS does not provide a managed rotation Lambda for DocumentDB.
- Rotation requires a custom Lambda with VPC access and password coordination logic.

The module is designed so that rotation can be added later without changing the application.

Manual rotation can be performed by:

- Updating the password via Terraform
- Reapplying the configuration
- Allowing the application to re-read the secret

---

## **Security**

- DocumentDB is deployed into **private subnets**
- Access is restricted via a security group allowing traffic only from EKS worker nodes
- Credentials are never hardcoded
- Secrets are stored securely in AWS Secrets Manager

---

## **Terraform Usage**

### **Initialize**

```
terraform init
```

### **Plan**

```
terraform plan -var-file=dev.tfvars
```

### **Apply**

```
terraform apply -var-file=dev.tfvars
```

### **Destroy (dev/staging only)**

```
terraform destroy -var-file=dev.tfvars
```

---

## **Backend State**

Terraform state is stored in an **S3 backend** (configured in providers.tf).

This ensures:

- Shared state across team members
- State locking
- Safe collaboration

---

## **Notes & Best Practices**

- Use dev and staging for frequent destroy/apply cycles
- Avoid destroying production resources
- Keep .terraform.lock.hcl committed
- Do not commit .tfstate files

---

## **Future Improvements**

- Add optional automatic secret rotation using a custom Lambda
- Enable storage encryption with KMS
- Add CloudWatch alarms for cluster health
- Support TLS-enabled environments via a module toggle

---
If anyone really read this, please smile. You’re clearly a good person who pays attention to details and has a DevOps mindset. Sending you best wishes.