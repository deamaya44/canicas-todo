variable "origin_domain_name" {
  description = "S3 website endpoint"
  type        = string
}

variable "origin_id" {
  description = "Origin ID"
  type        = string
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "comment" {
  description = "Distribution comment"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Custom domain aliases"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
