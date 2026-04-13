resource "aws_s3_bucket" "ssm_session_logs" {
  bucket = "terraform-ansible-baseline-ssm-dougops"

  tags = {
    Name      = "terraform-ansible-baseline-ssm-dougops"
    Purpose   = "ssm-session-logs"
    ManagedBy = "terraform"
    Project   = "terraform-ansible-baseline"
  }
}

resource "aws_s3_bucket_versioning" "ssm_session_logs" {
  bucket = aws_s3_bucket.ssm_session_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssm_session_logs" {
  bucket = aws_s3_bucket.ssm_session_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ssm_session_logs" {
  bucket = aws_s3_bucket.ssm_session_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "ssm_session_logs_bucket_policy" {
  statement {
    sid    = "AllowSSMSessionManagerToWriteLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.ssm_session_logs.arn}/*"
    ]
  }

  statement {
    sid    = "AllowSSMSessionManagerToGetBucketLocation"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.ssm_session_logs.arn
    ]
  }
}

resource "aws_s3_bucket_policy" "ssm_session_logs" {
  bucket = aws_s3_bucket.ssm_session_logs.id
  policy = data.aws_iam_policy_document.ssm_session_logs_bucket_policy.json
}
