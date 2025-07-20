# Sample Outputs

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "next_steps" {
  value = <<-EOT
  
  ✅ Backend created successfully!
  
  S3 Bucket: ${aws_s3_bucket.terraform_state.id}
  Region: ${var.aws_region}
  Locking: S3 native (use_lockfile = true)
  
  Next steps:
  1. Add an s3 backend block in another project, e.g.:
     backend "s3" {
       bucket        = "${aws_s3_bucket.terraform_state.id}"
       key           = "envs/dev/terraform.tfstate"
       region        = "${var.aws_region}"
       # S3 native locking (Terraform >=1.9) — no DynamoDB required
       use_lockfile  = true
     }
  2. terraform init -migrate-state (if migrating)
  3. terraform apply
  
  EOT
}


