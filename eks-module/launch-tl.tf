data "aws_ssm_parameter" "eks_worker_ami" {
  name = "/aws/service/eks/optimized-ami/${var.k8s_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

resource "aws_launch_template" "workers_lt" {
  name                   = "${var.cluster_name}-workers-lt"
  image_id               = data.aws_ssm_parameter.eks_worker_ami.value
  vpc_security_group_ids = [aws_security_group.eks_node_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.workers_instance_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(<<-EOT
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${var.cluster_name}
    apiServerEndpoint: ${aws_eks_cluster.projectx_cluster.endpoint}
    certificateAuthority: ${aws_eks_cluster.projectx_cluster.certificate_authority[0].data}
    cidr: ${aws_eks_cluster.projectx_cluster.kubernetes_network_config[0].service_ipv4_cidr}
  kubelet:
    config:
      clusterDNS:
        - 172.20.0.10
    flags:
      - --node-labels=node.kubernetes.io/lifecycle=normal
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                        = "${var.cluster_name}-instance"
      project_name                                = var.project_name
      environment                                 = var.environment
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"


    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      project_name                                = var.project_name
      environment                                 = var.environment
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  }

}

