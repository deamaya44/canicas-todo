# Terraform Infrastructure

## Quick Start

### Deploy Everything
```bash
./deploy.sh
```

This will:
1. Auto-import any existing resources
2. Apply Terraform configuration
3. Show outputs

### Destroy Everything
```bash
./destroy-all.sh
```

This will:
1. Run `terraform destroy`
2. Clean up any orphaned resources
3. Ensure complete cleanup

## Manual Operations

### Initialize
```bash
terraform init
```

### Plan
```bash
terraform plan
```

### Apply
```bash
terraform apply -auto-approve
```

### Import Existing Resources
```bash
./auto-import.sh
```

## Requirements

- AWS CLI configured with profile
- Terraform installed
- SSM parameters configured (see main README)

## Environment Variables

```bash
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
```

## Files

- `deploy.sh` - Full deployment with auto-import
- `destroy-all.sh` - Complete destruction and cleanup
- `auto-import.sh` - Import existing resources
- `main.tf` - Module calls
- `locals.tf` - All configuration
- `providers.tf` - Provider configuration
- `outputs.tf` - Output values
