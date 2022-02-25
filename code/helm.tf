provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    # load_config_file       = false
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace = "kube-system"
#   version    = "1.0.2"

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller "
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
#   set {
#     name  = "serviceAccount[0].annotations.eks.amazonaws.com/role-arn:"
#     value = aws_iam_policy.load_balancer.arn
#   }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }
  set {
    name  = "region"
    value = var.aws_region_name
  }
  set {
    name  = "vpcId"
    value = module.jenkins_vpc.vpc_id
  }

}

resource "helm_release" "aws-efs-csi-driver" {
  name       = "aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  namespace = "kube-system"
#   version    = "1.0.2"

  set {
    name  = "serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
#   set {
#     name  = "serviceAccount[0].annotations.eks.amazonaws.com/role-arn:"
#     value = aws_iam_policy.load_balancer.arn
#   }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/aws-efs-csi-driver"
  }
  set {
    name  = "region"
    value = var.aws_region_name
  }
  set {
    name  = "vpcId"
    value = module.jenkins_vpc.vpc_id
  }

}