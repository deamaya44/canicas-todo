resource "aws_sns_topic" "this" {
  name = var.topic_name

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "this" {
  for_each = toset(var.emails)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}
