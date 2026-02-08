resource "aws_codecommit_repository" "this" {
  repository_name = var.repository_name
  description     = var.description

  tags = var.common_tags
}
