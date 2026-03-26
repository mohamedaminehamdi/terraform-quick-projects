# GitOps on EKS with Argo CD and Kustomize

Terraform provisions a VPC, an Amazon EKS cluster, the **Amazon EBS CSI driver** add-on (for Postgres PVCs), and **Argo CD** via the official [Helm chart](https://github.com/argoproj/argo-helm). Kubernetes manifests under `manifests/` describe a small three-tier sample app (frontend, API, Postgres). You can sync that folder with Argo CD from **your own Git repository** so changes are declarative and **drift** (manual `kubectl` edits) can be detected and optionally reverted with **self-heal**.

## Architecture

- **Frontend**: sample container (port 3000), `LoadBalancer` service for browser access
- **Backend**: sample API (port 8080), `ClusterIP`
- **Database**: PostgreSQL 15 with a PVC (EBS-backed when the CSI driver and storage class align)

## Repository layout

```text
├── terraform/
│   ├── terraform.tf             # Terraform + provider versions
│   ├── providers.tf             # AWS, Helm, kubectl
│   ├── variables.tf             # Region, cluster, GitOps repo settings
│   ├── main.tf                 # VPC, EKS, EBS CSI, Argo CD, optional Application
│   ├── outputs.tf
│   ├── argocd-application.tftpl # Argo CD Application manifest template
│   └── terraform.tfvars.example
└── manifests/                   # Kustomize base (synced by Argo CD)
    ├── kustomization.yaml
    ├── namespace.yaml
    ├── secret.yaml
    ├── postgres.yaml
    ├── backend.yaml
    └── frontend.yaml
```

## Prerequisites

- AWS credentials with permission to create VPC, EKS, IAM, and ELB resources
- Terraform **>= 1.0**
- `kubectl` and `aws` CLI
- Optional: [Argo CD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) for `argocd app sync`

## What the Terraform stack uses

| Piece | Choice |
|--------|--------|
| EKS | `terraform-aws-modules/eks/aws` **~> 20.x**, Kubernetes **1.30** |
| VPC | `terraform-aws-modules/vpc/aws` **~> 5.x** |
| Argo CD | `argo-cd` chart from `https://argoproj.github.io/argo-helm`, server `Service` type `LoadBalancer` |
| GitOps app | Optional `kubectl_manifest` from `argocd-application.tftpl` when `gitops_repo_url` is set |

Providers: **AWS**, **Helm**, **kubectl** (GavinBunney).

## Drift and self-heal

With `syncPolicy.automated.selfHeal: true` in the Application, Argo CD can revert live objects that diverge from Git. With **prune** enabled, resources removed from Git can be deleted in the cluster. This demo is intended for learning, not production hardening.

## Deploy infrastructure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set gitops_repo_url to YOUR fork that contains this path.
terraform init
terraform plan
terraform apply
```

If you leave `gitops_repo_url` empty, Terraform still installs Argo CD; register an Application yourself (UI, CLI, or GitOps) pointing at your `manifests/` path.

**Typical monorepo path** (this repo): `argocd-drift-detection/manifests`.

After apply, credentials and DNS names are not written to Terraform state; use the outputs (or the commands below).

## Configure kubectl

```bash
aws eks update-kubeconfig --region "$(terraform output -raw cluster_region)" --name "$(terraform output -raw cluster_name)"
```

## Argo CD UI

Initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo
```

LoadBalancer hostname (wait until AWS assigns an address):

```bash
kubectl get svc argocd-server -n argocd
# or
kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
```

Port-forward alternative:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open `https://localhost:8080`, user **admin**, password from above.

## Application ingress

After Argo CD syncs the `manifests/` application:

```bash
kubectl get svc frontend -n three-tier-app-dev
```

## Kustomize

Render locally:

```bash
kubectl kustomize manifests/
```

Replicas and image tags are centralized in `manifests/kustomization.yaml`.

## Namespace and Terraform variable

The workload namespace is **`three-tier-app-dev`** in the YAML. If you change `application_namespace` in Terraform, update `manifests/kustomization.yaml` and every manifest namespace to match, or Argo CD will target the wrong namespace.

## Clean up

```bash
# If Terraform created the Application:
terraform destroy

# Or delete the Application first, then destroy:
kubectl delete application three-tier-gitops-app -n argocd
cd terraform && terraform destroy
```

## Troubleshooting

```bash
kubectl get applications -n argocd
kubectl describe application three-tier-gitops-app -n argocd
kubectl logs -f deployment/backend -n three-tier-app-dev
kubectl logs -f deployment/frontend -n three-tier-app-dev
kubectl logs -f deployment/postgres -n three-tier-app-dev
```

Manual sync (CLI):

```bash
argocd app sync three-tier-gitops-app
```

## Notes

- Postgres credentials are plain `Secret` manifests for demo only; use something like External Secrets or Secrets Manager in real environments.
- Demo container images in `kustomization.yaml` are public examples; replace with your own images for anything serious.
- The PVC uses storage class `gp2`; if your cluster only exposes `gp3` (or another class), edit `manifests/postgres.yaml` accordingly.
