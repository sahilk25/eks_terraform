module "jenkins_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.avz_list.zone_ids
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets= [for i in range(length(data.aws_availability_zones.avz_list.zone_ids)): "10.0.${i+1}.0/24"]
  public_subnets  = [for i in range(length(data.aws_availability_zones.avz_list.zone_ids)): "10.0.${i+100}.0/24"]

  enable_dhcp_options = true 
  enable_dns_hostnames = true
  dhcp_options_domain_name = "eu-west-1.compute.internal"

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false


  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}