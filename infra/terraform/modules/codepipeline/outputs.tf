output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.this.name
}

output "pipeline_arn" {
  description = "CodePipeline ARN"
  value       = aws_codepipeline.this.arn
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.this.arn
}
