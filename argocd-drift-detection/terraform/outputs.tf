output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_region" {
  description = "AWS region"
  value       = var.region
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "argocd_server_hostname_command" {
  description = "Command to print Argo CD server LoadBalancer hostname (when ready)"
  value       = "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{\"\\n\"}'"
}

output "argocd_admin_password_command" {
  description = "Command to get Argo CD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "application_frontend_hostname_command" {
  description = "Command to print frontend LoadBalancer hostname after sync (uses default namespace three-tier-app-dev; change -n if you overrode var.application_namespace)"
  value       = "kubectl get svc frontend -n three-tier-app-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{\"\\n\"}'"
}

output "gitops_application_note" {
  description = "Whether Terraform registered the Argo CD Application"
  # Derive from the counted resource instead of var.gitops_repo_url so editors/terraform-ls
  # still resolve this when analyzing outputs.tf alone; behavior matches (count uses the same condition).
  value = length(kubectl_manifest.gitops_application) > 0 ? "Argo CD Application 'three-tier-gitops-app' was applied by Terraform." : <<-EOT
    gitops_repo_url was empty: configure kubectl, then create an Application that points at your Git repo. Example:
    terraform apply -var='gitops_repo_url=https://github.com/ORG/REPO.git' -var='gitops_repo_path=argocd-drift-detection/manifests'
  EOT
}
