# assignment-s3-uploads: holds event photo uploads. Bucket ACLs stay blocked;
# only unauthenticated GetObject under uploads/* is allowed via bucket policy so
# images render in the browser, without allowing public listing or writes.
resource "terraform_data" "uploads" {
  input = var.bucket_name

  # The AWS provider reads object-lock configuration for every aws_s3_bucket.
  # The Academy account's SCP denies that read, so use the AWS CLI only for
  # bucket creation/deletion and keep the remaining bucket configuration in
  # native Terraform resources below.
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "aws s3api head-bucket --bucket '$BUCKET' >/dev/null 2>&1 || aws s3api create-bucket --bucket '$BUCKET' --region '$REGION'; aws s3api put-bucket-tagging --bucket '$BUCKET' --tagging \"TagSet=[{Key=Name,Value=$NAME}]\""

    environment = {
      BUCKET = var.bucket_name
      NAME   = "${var.name_prefix}-s3-uploads"
      REGION = data.aws_region.current.name
    }
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "aws s3 rm 's3://$BUCKET' --recursive >/dev/null 2>&1 || true; aws s3api delete-bucket --bucket '$BUCKET' --region '$REGION' >/dev/null 2>&1 || true"

    environment = {
      BUCKET = self.input
      REGION = "us-east-1"
    }
  }
}

data "aws_region" "current" {}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = terraform_data.uploads.output

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = terraform_data.uploads.output
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadEventImages"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${var.bucket_name}/${var.public_read_prefix}"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.uploads]
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = terraform_data.uploads.output

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}
