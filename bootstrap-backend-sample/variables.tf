# Sample Variables

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  # Change this to a globally-unique name before applying
  default     = "mah-bootstrap-tf-state-sample"
}