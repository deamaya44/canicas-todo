output "repository_name" {
  description = "Repository name"
  value       = aws_codecommit_repository.this.repository_name
}

output "arn" {
  description = "Repository ARN"
  value       = aws_codecommit_repository.this.arn
}

output "clone_url_http" {
  description = "HTTP clone URL"
  value       = aws_codecommit_repository.this.clone_url_http
}

output "clone_url_ssh" {
  description = "SSH clone URL"
  value       = aws_codecommit_repository.this.clone_url_ssh
}
