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
      additional_security_group_ids = ["${aws_security_group.node_sg_efs.id}"]
     
        
      }
  }



  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
resource "aws_security_group" "node_sg_efs" {
   name = "node_sg_efs"
   description= "Allos inbound efs traffic from ec2"
   vpc_id = module.jenkins_vpc.vpc_id

   ingress {
     security_groups = [aws_security_group.efs.id]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }     
        
   egress {
     security_groups = [aws_security_group.efs.id]
     from_port = 0
     to_port = 0
     protocol = "-1"
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

resource "aws_iam_policy" "autoscaler_policy" {
  name        = "${var.cluster_name}_autoscaler"
  description = "policy for autoscaler eks"

  policy = file("./policies/autoscaler_policy.json")
}

resource "null_resource" "service_accounts" {
  depends_on = [
    module.jenkins_eks
  ]
  provisioner "local-exec" {
    command = "chmod u+x ./scripts/service_accounts.sh && sh ./scripts/service_accounts.sh"
    environment = {
      CLUSTER_NAME = var.cluster_name
      LOADBALANCER_POLICY_ARN = aws_iam_policy.load_balancer_policy.arn
      EFS_POLICY_ARN = aws_iam_policy.efs_policy.arn
      AUTOSCALER_POLICY_ARN = aws_iam_policy.autoscaler_policy.arn
      NAMESPACE = "kube-system"
      REGION_NAME = var.aws_region_name
    }
  }
  
}

resource "aws_cloudwatch_metric_alarm" "node_autoscaling_cpu_alarm" {
  alarm_name                = "node_autoscaling_cpu_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = module.jenkins_eks.eks_managed_node_groups.default.node_group_resources[0].autoscaling_groups[0].name
  }
}