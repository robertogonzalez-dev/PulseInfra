output "state_bucket" {
  description = "Put this in terraform/envs/dev/backend.hcl"
  value       = aws_s3_bucket.state.bucket
}

output "github_actions_role_arn" {
  description = "Save as the AWS_ROLE_ARN secret in the GitHub repo"
  value       = aws_iam_role.github_actions.arn
}
