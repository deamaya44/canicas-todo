terraform {
  backend "s3" {
    # Bucket name will be: tasks-3d-terraform-state-{AWS_ACCOUNT_ID}
    # Set via: terraform init -backend-config="bucket=tasks-3d-terraform-state-$(aws sts get-caller-identity --query Account --output text)"
    # Or use backend-config.hcl file
    key     = "cicd/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
