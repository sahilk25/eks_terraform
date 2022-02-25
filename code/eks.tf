module "jenkins_eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.7.2"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
  # iam_role_additional_policies = [aws_iam_policy.load_balancer.arn]

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_efs = {
      description = "efs ingress"
      protocol    = "tcp"
      from_port   = 2049
      to_port     = 2049
      type        = "ingress"
      cidr_blocks = [module.jenkins_vpc.vpc_cidr_block]
      
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }


  vpc_id     = module.jenkins_vpc.vpc_id
  subnet_ids = module.jenkins_vpc.private_subnets

  



  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    # ami_type               = "AL2_x86_64"
    disk_size              = 20
    instance_types         = ["t2.small"]
    
    # vpc_security_group_ids = [aws_security_group.additional.id]
  }
  
  eks_managed_node_groups = {
    
    default = {
      iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
      create_launch_template = false
      launch_template_name   = ""
      min_size     = 1
      max_size     = 3
      desired_size = 2
      
    }
  }



  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_iam_policy" "load_balancer_policy" {
  name        = "${var.cluster_name}_load_balancer"
  description = "Worker policy for the ALB Ingress"

  policy = file("./policies/loadbalancer_policy.json")
}
resource "aws_iam_policy" "efs_policy" {
  name        = "${var.cluster_name}_efs"
  description = "policy for efs eks"

  policy = file("./policies/elasticcache_policy.json")
}