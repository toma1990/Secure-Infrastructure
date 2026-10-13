# S3 Security Baseline Module
# Blocks public access at the account level - prevents any bucket
# from being accidentally made public regardless of bucket settings

resource "aws_s3_account_public_access_block" "main" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Evidence bucket for the automated IR system
resource "aws_s3_bucket" "ir_evidence" {
  bucket        = "${var.project_name}-ir-evidence-${var.account_id}"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "Incident response evidence storage"
  }
}

# Block public access on evidence bucket
resource "aws_s3_bucket_public_access_block" "ir_evidence" {
  bucket = aws_s3_bucket.ir_evidence.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt evidence at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "ir_evidence" {
  bucket = aws_s3_bucket.ir_evidence.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versioning on evidence bucket - preserves evidence integrity
resource "aws_s3_bucket_versioning" "ir_evidence" {
  bucket = aws_s3_bucket.ir_evidence.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle policy - move old evidence to cheaper storage after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "ir_evidence" {
  bucket = aws_s3_bucket.ir_evidence.id

  rule {
    id     = "archive-old-evidence"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}
