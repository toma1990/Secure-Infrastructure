output "ir_evidence_bucket_name" {
  description = "Name of the IR evidence S3 bucket"
  value       = aws_s3_bucket.ir_evidence.id
}

