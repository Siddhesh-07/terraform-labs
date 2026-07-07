# Phase 3.4: Terraform Registry Modules

## Overview

Use **pre-built modules from Terraform Registry** instead of writing your own.

---

## What Is Terraform Registry?

Marketplace of community-built, ready-to-use modules.

**Example:** Instead of writing VPC module from scratch, download `terraform-aws-modules/vpc/aws`

---

## What We Did

Created same infrastructure as Phase 3.1-3.3, but using Registry modules:

- **VPC Module:** `terraform-aws-modules/vpc/aws`
- **EC2 Module:** `terraform-aws-modules/ec2-instance/aws`
- **Security Group:** Custom (simple resource)

---

## Custom vs Registry

| Aspect | Custom (Phase 3.1-3.3) | Registry (Phase 3.4) |
|--------|---|---|
| **Code** | 200+ lines (we wrote) | 10 lines (pre-built) |
| **Features** | Basic | Many advanced features |
| **Maintenance** | You maintain | Community maintains |
| **Best Practices** | We implemented | Built-in |

---

## How Registry Modules Work

**Install from Registry:**
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0"
}
```

Terraform automatically downloads the module on `terraform init`.

---

## Example Code

```hcl
# VPC from Registry
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name = "registry-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]
}

# EC2 from Registry
module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "5.0"

  name           = "registry-instance"
  ami            = "ami-06067086cf86c58e6"
  instance_type  = "t3.micro"
  subnet_id      = module.vpc.public_subnets[0]
}
```

---

## Key Learning

✅ Registry modules save time (no need to write common modules)
✅ Higher quality (tested, maintained by community)
✅ Best practices built-in
✅ Use for common infrastructure (VPC, RDS, security groups)
✅ Write custom modules for company-specific needs

---

## When to Use Each

| Use Case | Custom Module | Registry Module |
|----------|---|---|
| Standard AWS resources (VPC, EC2, RDS) | ❌ | ✅ |
| Company-specific setup | ✅ | ❌ |
| Learning how modules work | ✅ | ❌ |
| Production deployment (fast) | ❌ | ✅ |

---

## Real-World Practice

In jobs:
- **70%** Registry modules (faster, proven)
- **30%** Custom modules (company-specific)

---

## Files Created

```
phase3.4-registry-modules/
├── main.tf      (uses Registry modules)
├── outputs.tf   (exports VPC ID, EC2 public IP)
└── variables.tf (minimal)
```

---

**Phase 3.4 Complete! ✅**

**Phase 3 (all sub-sections) Complete! ✅✅✅**
