variable "bucket_remote_backend_name" {
  description = "the remote backend bucket name"
  type        = string
}

variable "versioning" {
  description = "enables versioning for objects in the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_s3_bucket_policy" {
  description = "creates IAM policy to access remote backend bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}