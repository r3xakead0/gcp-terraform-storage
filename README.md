# GCP Terraform Storage

Terraform configuration that provisions a Google Cloud Storage bucket with versioning, lifecycle rules, and a remote GCS backend for state.

## Prerequisites
- Terraform >= 1.0
- Google Cloud project and Service Account with Storage Admin + Storage Object Admin (and permissions to use the backend bucket).
- Service Account JSON key available locally (path set in `main.tf` as `~/terraform-key.json`, adjust if needed).

## Create Service Account

```sh
# Create service account
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account"

# Assign necessary roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

# Create and download JSON key
gcloud iam service-accounts keys create ~/GCP_SA.json \
    --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```


## Backend (remote state)
The backend is configured in `versions.tf` to use the bucket `bootcamp-478214-tfstate` with prefix `terraform/state`. Create it once before the first `terraform init`:
```sh
gsutil mb -p bootcamp-478214 -l us-central1 gs://bootcamp-478214-tfstate
```

## Configure variables
Defaults live in `terraform.tfvars`:
```hcl
project_id  = "bootcamp-478214"
region      = "us-central1"
bucket_name = "bootcamp-478214-bucket-terraform"
```
You can override via `terraform.tfvars` or `TF_VAR_*` env vars.

## Local workflow
```sh
terraform init      # first time, after backend bucket exists
terraform plan
terraform apply -auto-approve
```
Destroy locally if needed:
```sh
terraform destroy -auto-approve
```

## GitHub Actions
- `.github/workflows/terraform.yml` runs plan on PRs and apply on `main`.
- `.github/workflows/terraform-destroy.yml` can be triggered manually (`workflow_dispatch`) and requires typing `DESTROY` to proceed.
Set the following in repo settings:
- Secret: `GCP_SA` (Service Account JSON)
- Vars: `GCP_PROJECT_ID`, `GCP_REGION`, `GCP_BUCKET_NAME`

## Bucket configuration
The bucket is created with:
- Uniform bucket-level access
- Versioning enabled
- Lifecycle rule: delete objects older than 30 days
- `force_destroy = true` (bucket purged on destroy)
