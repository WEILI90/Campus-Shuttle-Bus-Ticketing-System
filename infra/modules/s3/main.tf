<<<<<<< HEAD
resource "terraform_data" "uploads" {
  input = var.bucket_name

  provisioner "local-exec" {
    command = <<-EOT
      aws s3api create-bucket --bucket "${var.bucket_name}" --region us-east-1
      aws s3api put-bucket-tagging --bucket "${var.bucket_name}" --tagging "TagSet=[{Key=Name,Value=${var.name_prefix}-s3-uploads}]"
    EOT
  }

    provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      aws s3 rm "s3://${self.input}" --recursive
      aws s3api delete-bucket --bucket "${self.input}" --region us-east-1
    EOT
=======
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
>>>>>>> 402102546211c78b408ed13fbe182598a88b40e9
  }
}

data "aws_region" "current" {}

resource "aws_s3_bucket_public_access_block" "uploads" {
<<<<<<< HEAD
  bucket = var.bucket_name

  depends_on = [terraform_data.uploads]
=======
  bucket = terraform_data.uploads.output
>>>>>>> 402102546211c78b408ed13fbe182598a88b40e9

  block_public_acls       = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "public_read" {
<<<<<<< HEAD
  bucket = var.bucket_name
=======
  bucket = terraform_data.uploads.output
>>>>>>> 402102546211c78b408ed13fbe182598a88b40e9
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadEventImages"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
<<<<<<< HEAD
        Resource  = "${aws_s3_bucket.uploads.arn}/${var.public_read_prefix}"
=======
>>>>>>> 402102546211c78b408ed13fbe182598a88b40e9
        Resource  = "arn:aws:s3:::${var.bucket_name}/${var.public_read_prefix}"
      }
    ]
  })

  depends_on = [terraform_data.uploads, aws_s3_bucket_public_access_block.uploads]
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
<<<<<<< HEAD
  bucket = var.bucket_name

  depends_on = [terraform_data.uploads]
=======
  bucket = terraform_data.uploads.output
>>>>>>> 402102546211c78b408ed13fbe182598a88b40e9

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}