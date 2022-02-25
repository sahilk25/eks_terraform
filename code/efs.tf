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