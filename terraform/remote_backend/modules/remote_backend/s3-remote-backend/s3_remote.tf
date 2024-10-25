data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "remote_backend" {
  bucket = var.bucket_remote_backend_name

  lifecycle {
    prevent_destroy = "true"
  }

  tags = {
    Name        = "${var.bucket_remote_backend_name}"
    Terraformed = "true"
  }
}

resource "aws_s3_bucket_logging" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id

  target_bucket = aws_s3_bucket.remote_backend.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}