output "region" {
  description = "Region remote backend bucket created in."
  value       = aws_s3_bucket.remote_backend.region
}

output "url" {
  description = "URL to the remote backend S3 bucket."
  value       = "https://s3-${aws_s3_bucket.remote_backend.region}.amazonaws.com/${aws_s3_bucket.remote_backend.id}"
}

output "bucket_full_access_policy_arn" {
  description = "ARN of IAM policy that grants access to the bucket."
  value       = aws_iam_policy.bucket_full_access.*.arn
}

output "bucket_arn" {
  description = "ARN of remote backend bucket."
  value       = aws_s3_bucket.remote_backend.arn
}

output "bucket_id" {
  description = "Id of remote backend bucket."
  value       = aws_s3_bucket.remote_backend.id
}