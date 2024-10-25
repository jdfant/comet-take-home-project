data "aws_iam_policy_document" "s3_full_access" {
  count = var.enable_s3_bucket_policy ? 1 : 0

  statement {
    sid    = "S3ReadPermissions"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]

    resources = ["arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.remote_backend}"]
  }

  statement {
    sid    = "S3WritePermissions"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]

    resources = ["arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.remote_backend.id}/*"]
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "S3ReadPermissions"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]

    principals {
      type        = "AWS"
      identifiers = compact(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"])
    }

    resources = ["arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.remote_backend.id}"]
  }

  statement {
    sid    = "S3WritePermissions"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]

    principals {
      type        = "AWS"
      identifiers = compact(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"])
    }

    resources = ["arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.remote_backend.id}/*"]
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.remote_backend.id}",
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.remote_backend.id}/*"
    ]
  }
}