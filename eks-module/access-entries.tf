resource "aws_eks_access_entry" "nodes_entry" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = aws_iam_role.workers_role.arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_entry" "sso_admin" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::383585068161:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_b18a1488d07743cc"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "sso_admin_cluster_admin" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::383585068161:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_b18a1488d07743cc"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.sso_admin]
}

resource "aws_eks_access_entry" "github_terraform" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::383585068161:role/GitHubActionsTerraformIAMrole"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_terraform_cluster_admin" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::383585068161:role/GitHubActionsTerraformIAMrole"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.github_terraform]
}

resource "aws_eks_access_entry" "github_eks_deploy" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::383585068161:role/GitHubActionsEKSDeploymentRole"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_eks_deploy_cluster_admin" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::383585068161:role/GitHubActionsEKSDeploymentRole"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.github_eks_deploy]
}
