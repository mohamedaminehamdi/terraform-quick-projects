variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "gitops-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "application_namespace" {
  description = "Namespace for the three-tier demo workloads (must match manifests/kustomization.yaml)"
  type        = string
  default     = "three-tier-app-dev"
}

variable "gitops_repo_url" {
  description = <<-EOT
    HTTPS URL of the Git repository that contains the manifests directory (fork this repo and push).
    When non-empty, Terraform registers an Argo CD Application that syncs from this repo.
    Leave empty to only provision the cluster and Argo CD; apply an Application manually later.
  EOT
  type        = string
  default     = ""
}

variable "gitops_repo_path" {
  description = "Path from repo root to the Kustomize/manifest directory (e.g. argocd-drift-detection/manifests for this monorepo)"
  type        = string
  default     = "argocd-drift-detection/manifests"
}

variable "gitops_target_revision" {
  description = "Git branch, tag, or commit for Argo CD to track"
  type        = string
  default     = "main"
}
