data "aws_availability_zones" "avz_list" {
  state = "available"

  filter {
    name   = "region-name"
    values = toset([var.aws_region_name])
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.jenkins_eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.jenkins_eks.cluster_id
}