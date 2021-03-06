terraform {
  backend "s3" {
    bucket = "config-bucket-375226586260"
    key    = "terra/test.tfstate"
    region = "eu-west-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.2.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    
  }
}

provider "aws" {
  region = "eu-west-1"
}

# provider "kubernetes" {
#   alias = "eks"
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster.cluster.token
#   load_config_file       = false
#   # version = "2.8.0"
# }