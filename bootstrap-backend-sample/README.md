# Bootstrap Backend Sample

Replicates the S3 backend bootstrap from `decentral-kube-infra/terraform/bootstrap` as a self-contained sample.

## What this does

- Creates a secure S3 bucket for Terraform remote state
- Enables versioning and SSE (AES256)
- Blocks public access
- Uses S3 native lockfile (no DynamoDB table required on Terraform >= 1.9)

## Usage

1. Ensure AWS credentials are configured.
2. Update `variables.tf` → `state_bucket_name` to a globally unique bucket name.
3. Initialize and apply:

```bash
terraform init
terraform apply -auto-approve
```

## Using the backend from another project

Add a backend block to the other project's `terraform {}`:

```hcl
terraform {
  backend "s3" {
    bucket       = "<your-unique-bucket>"
    key          = "envs/dev/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}
```

Then run:

```bash
terraform init
```

> If migrating an existing local state, use `terraform init -migrate-state`.

## Notes

- This sample intentionally excludes any `terraform.tfstate` from version control.
- The previous DynamoDB-based locking approach is considered legacy for this sample.
