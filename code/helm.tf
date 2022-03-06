provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    # load_config_file       = false
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  depends_on = [
    module.jenkins_eks,
    null_resource.service_accounts
  ]
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
  depends_on = [
    module.jenkins_eks,
    null_resource.service_accounts
  ]
  name       = "aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  namespace = "kube-system"
#   version    = "1.0.2"

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
  set {
    name  = "controller.serviceAccount.create"
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
# Issue in official jenkins chart
# resource "helm_release" "jenkins" {
#   depends_on = [
#     module.jenkins_eks,
#     null_resource.service_accounts
#     # kubernetes_persistent_volume_claim.efs-claim
#   ]
#   name       = "jenkins"
#   repository = "https://charts.jenkins.io"
#   chart      = "jenkins"
#   namespace = "jenkins"

#   values = [
#     "${file("./jenkins/jenkins_helm_values.yaml")}"
#   ]

#   set_sensitive {
#     name  = "controller.adminUser"
#     value = data.aws_ssm_parameter.jenkins_user_name.value
#   }
#   set_sensitive {
#     name = "controller.adminPassword"
#     value = data.aws_ssm_parameter.jenkins_user_name.value
#   }
#   set_sensitive {
#     name = "adminPassword"
#     value = data.aws_ssm_parameter.jenkins_password.value
#   }
# }
resource "helm_release" "cert-manager" {
  depends_on = [
    module.jenkins_eks,
    null_resource.service_accounts
  ]
  name       = "jetstack"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace = "cert-manager"
  set {
    name  = "create_namespace"
    value = "true"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "prometheus.enabled"
    value = "false"
  }
}