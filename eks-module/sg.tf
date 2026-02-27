resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}-cluster-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    project_name                                = var.project_name
    environment                                 = var.environment
  }
}

resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS self-managed nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    project_name                                = var.project_name
    environment                                 = var.environment
  }
}

resource "aws_security_group_rule" "node-to-node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
  description              = "Allow all traffic from worker nodes to each other"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_all_from_cluster" {
  security_group_id            = aws_security_group.eks_node_sg.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.cluster_sg.id
  description                  = "TESTING: allow all traffic from control plane SG to nodes"
}

resource "aws_security_group_rule" "internal_kubelet_access" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.eks_node_sg.id
  description       = "Allow access to kubelet from within the VPC (for Prometheus, Metrics Server, etc.)"
}

resource "aws_security_group_rule" "allow_control_plane_to_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.cluster_sg.id
  description              = "Allow EKS control plane to communicate with kubelet on worker nodes (for exec/logs/health checks)"
}