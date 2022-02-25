output "locdbalancer_policy_arn" {
  value = aws_iam_policy.load_balancer_policy.arn

}
output "efs_policy_arn" {
  value = aws_iam_policy.efs_policy.arn
  
}