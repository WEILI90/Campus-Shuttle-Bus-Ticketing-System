output "bucket_id" {
  value = terraform_data.uploads.output
}

output "bucket_arn" {
  value = "arn:aws:s3:::${var.bucket_name}"
}

output "bucket_regional_domain_name" {
  value = "${var.bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com"
}
