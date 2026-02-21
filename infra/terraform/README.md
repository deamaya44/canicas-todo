# Terraform Infrastructure

## Quick Start

### Deploy Everything (from scratch)
```bash
./deploy.sh
```

### Destroy Everything
```bash
./destroy-all.sh
```

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

### Destroy
```bash
terraform destroy -auto-approve
```

## Requirements

- AWS CLI configured
- Terraform installed
- SSM parameters configured

## Environment Variables

```bash
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
```

## Files

- `deploy.sh` - Deploy from scratch
- `destroy-all.sh` - Complete cleanup
- `main.tf` - Module calls
- `locals.tf` - All configuration
- `providers.tf` - Providers
- `outputs.tf` - Outputs
