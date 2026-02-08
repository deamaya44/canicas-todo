variable "topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "emails" {
  description = "List of email addresses for notifications"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
