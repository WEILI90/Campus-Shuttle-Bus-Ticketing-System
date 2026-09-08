output "bucket_id" {
<<<<<<< HEAD
  value = var.bucket_name
=======
  value = terraform_data.uploads.output
>>>>>>> 402102546211c78b408ed13fbe182598a88b40e9
}

output "bucket_arn" {
  value = "arn:aws:s3:::${var.bucket_name}"
}

output "bucket_regional_domain_name" {
<<<<<<< HEAD
  value = "${var.bucket_name}.s3.amazonaws.com"
=======
  value = "${var.bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com"
>>>>>>> 402102546211c78b408ed13fbe182598a88b40e9
}
