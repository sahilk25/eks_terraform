resource "aws_efs_file_system" "efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EFS"
   }
 }


resource "aws_efs_mount_target" "efs-mt" {
   count = length(module.jenkins_vpc.private_subnets)
   file_system_id  = aws_efs_file_system.efs.id
   subnet_id = module.jenkins_vpc.private_subnets[count.index]
   security_groups = [aws_security_group.efs.id]
 }

resource "aws_efs_access_point" "jenkins" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 1000 # jenkins
      owner_uid   = 1000 # jenkins
      permissions = "755"
    }
  }
  
}
resource "aws_security_group" "efs" {
   name = "efs-sg"
   description= "Allos inbound efs traffic from ec2"
   vpc_id = module.jenkins_vpc.vpc_id

   ingress {
     security_groups = [module.jenkins_eks.node_security_group_id]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }     
        
   egress {
     security_groups = [module.jenkins_eks.node_security_group_id]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
 }
provider "kubernetes" {
  config_path    = "~/.kube/config"
  # config_context = "my-context"
}
resource "kubernetes_namespace" "jenkins" {
  metadata {
    annotations = {
      name = "jenkins"
    }

    name = "jenkins"
  }
}

# resource "kubernetes_storage_class_v1" "efs" {
#   metadata {
#     name = "efs-sc"
#   }
#   storage_provisioner = "efs.csi.aws.com"
# }
# resource "kubernetes_persistent_volume" "efs-pv" {
#   metadata {
#     name = "efs-pv"
#     # namespace = "jenkins"
#   }
#   spec {
#     capacity = {
#       storage = "5Gi"
#     }
#     volume_mode = "Filesystem"
#     persistent_volume_reclaim_policy = "Retain"
#     access_modes = ["ReadWriteMany"]
#     persistent_volume_source {
#         csi {
#           driver = "efs.csi.aws.com"
#           volume_handle = "${aws_efs_file_system.efs.id}::${aws_efs_access_point.jenkins.id}"
#         }
#     }
#   }
# }

# resource "kubernetes_persistent_volume_claim" "efs-claim" {
#   metadata {
#     name = "efs-claim"
#     namespace =  "jenkins"
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     resources {
#       requests = {
#         storage = "5Gi"
#       }
#     }
#     storage_class_name = "efs-sc"
#     volume_name = "persistentvolume/${kubernetes_persistent_volume.efs-pv.metadata.0.name}"
#   }
# }