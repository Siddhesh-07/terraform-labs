# Phase 4: Advanced Workflows (4.1 - 4.2)

## 4.1 - Plan/Apply/Destroy Commands

### Key Commands

**Apply specific resource only:**
```bash
terraform apply -target=aws_instance.web
```

**Skip confirmation prompt:**
```bash
terraform apply -auto-approve
```

**Destroy specific resource:**
```bash
terraform destroy -target=aws_instance.db
```

**Speed up with parallelism:**
```bash
terraform apply -parallelism=10
```

### Key Learning

✅ `plan` = preview changes (non-destructive)
✅ `plan -out` = save for reproducibility
✅ `-target` = operate on specific resource
✅ `-auto-approve` = skip yes prompt (useful in CI/CD)
✅ `-parallelism` = create N resources in parallel

---

## 4.2 - Workspaces (Dev/Staging/Prod)

### What Are Workspaces?

Separate **state files** for different environments using the **same code**.

```
Folder: phase4-workflows/
├── terraform.tfstate (default workspace)
├── terraform.tfstate.d/dev/terraform.tfstate (dev workspace)
├── terraform.tfstate.d/staging/terraform.tfstate (staging workspace)
└── terraform.tfstate.d/prod/terraform.tfstate (prod workspace)
```

Same code, different environments = different infrastructure.

---

### How It Works

**Add to main.tf:**
```hcl
locals {
  environment = terraform.workspace
  
  instance_type = {
    default = "t3.micro"
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

resource "aws_instance" "web" {
  instance_type = local.instance_type[local.environment]
  
  tags = {
    Name = "web-server-${local.environment}"
    Environment = local.environment
  }
}
```

**What happens:**
- `terraform.workspace` = current workspace name (automatically set by Terraform)
- `local.environment` = shorthand for workspace name
- `instance_type[local.environment]` = pick instance type based on workspace

---

### Workspace Commands

**List all workspaces:**
```bash
terraform workspace list
```

**Create new workspace:**
```bash
terraform workspace new dev
```

**Switch to workspace:**
```bash
terraform workspace select staging
```

**Check current workspace:**
```bash
terraform workspace show
```

**Delete workspace:**
```bash
terraform workspace delete dev
```

---

### Example Workflow

**Create dev environment:**
```bash
terraform workspace new dev
terraform apply -auto-approve
# Creates web-server-dev (t3.micro), db-server-dev (t3.micro)
```

**Create staging environment:**
```bash
terraform workspace new staging
terraform apply -auto-approve
# Creates web-server-staging (t3.small), db-server-staging (t3.small)
```

**Create prod environment:**
```bash
terraform workspace new prod
terraform apply -auto-approve
# Creates web-server-prod (t3.medium), db-server-prod (t3.medium)
```

**Switch between environments:**
```bash
terraform workspace select dev
terraform output  # See dev infrastructure

terraform workspace select staging
terraform output  # See staging infrastructure
```

**All 6 instances exist simultaneously** in AWS, but managed separately.

---

### Key Learning

✅ Workspaces = separate state files per environment
✅ `terraform.workspace` = built-in variable (current workspace name)
✅ `local.environment` = shorthand reference (cleaner code)
✅ Same code, different configs per workspace
✅ Production-ready way to manage dev/staging/prod

---

## Phase 4.1-4.2 Summary

| Feature | Use Case |
|---------|----------|
| **Plan commands** | Preview, save, target specific resources |
| **Apply flags** | Control behavior (-auto-approve, -parallelism) |
| **Workspaces** | Manage multiple environments with same code |
| **terraform.workspace** | Built-in variable (current workspace) |
| **locals** | Create reusable variables in code |

---

## Important Rule

**Always run terraform commands INSIDE the folder where main.tf is.**

```
✅ CORRECT:
cd phase4-workflows
terraform workspace new dev

❌ WRONG:
cd terraform-labs
terraform workspace new dev
```

Workspaces are folder-specific, not global.

---

**Phase 4.1-4.2 Complete! ✅**
