# Phase 1: Terraform Fundamentals

This phase covers the core concepts of Terraform: basic resource provisioning, parameterization, outputs, and data sources.

## Overview

Phase 1 consists of 4 sub-sections that build progressively:
- **1.1**: Basic EC2 provisioning (hardcoded values)
- **1.2**: Variables & parameterization (reusable code)
- **1.3**: Outputs (extracting resource data)
- **1.4**: Data sources (querying existing resources)

---

## 1.1 - Basic EC2 Provisioning

### What We Did

Created a simple Terraform configuration to provision an EC2 instance with hardcoded values.

**Files Created:**
- `main.tf` - AWS provider and EC2 resource definition

**Configuration Includes:**
- AWS provider block (region: us-east-1)
- EC2 resource with hardcoded:
  - AMI ID (Amazon Linux 2023)
  - Instance type (t3.micro)
  - Name tag

### Terraform Workflow

```bash
terraform init      # Download AWS provider plugin
terraform plan      # Preview what will be created
terraform apply     # Actually create the EC2 instance
terraform destroy   # Delete the instance
```

### Key Learnings

- Terraform creates real AWS infrastructure from code
- `plan` shows what changes will happen
- `apply` executes the changes
- `destroy` removes created resources

---

## 1.2 - Variables & Parameterization

### What We Did

Made the code reusable by replacing hardcoded values with variables.

**Files Created/Updated:**
- `variables.tf` - Define input variables
- `terraform.tfvars` - Provide actual values
- `main.tf` - Updated to use variables

**Variables Defined:**
- `instance_type` - EC2 instance type (default: t3.micro)
- `instance_name` - Name tag for the instance
- `ami_id` - AMI ID for the instance

### File Structure

```hcl
# variables.tf
variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

# terraform.tfvars
instance_type = "t3.micro"
instance_name = "terraform-lab-instance"
ami_id        = "ami-06067086cf86c58e6"

# main.tf (uses variables)
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = var.instance_name
  }
}
```

### Key Learnings

- Separate variable **definitions** (variables.tf) from **values** (terraform.tfvars)
- Same code can be used for different environments by changing tfvars
- `.gitignore` prevents committing `.tfvars` files (keeps secrets safe)
- Variables make code reusable and maintainable

### Testing Parameterization

```bash
# Edit terraform.tfvars with new values
instance_type = "t3.small"

# See Terraform wants to update the instance
terraform plan

# Apply the change
terraform apply
```

---

## 1.3 - Outputs

### What We Did

Extracted and displayed useful data from the created EC2 instance.

**Files Created:**
- `outputs.tf` - Define output values

**Outputs Defined:**
- `instance_id` - EC2 instance ID
- `public_ip` - Public IP address
- `availability_zone` - AZ where instance runs
- `instance_state` - Current state (running, stopped, etc.)

### File Structure

```hcl
# outputs.tf
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}
```

### Viewing Outputs

```bash
# View all outputs after apply
terraform apply

# View outputs anytime (without re-applying)
terraform output

# View specific output
terraform output instance_id

# View as JSON
terraform output -json
```

### Key Learnings

- **Output names** are your choice (`output "instance_id"`)
- **Output values** reference AWS attributes (`.id`, `.public_ip`, `.private_ip`)
- Outputs display important information to users
- Can be used to pass data between modules (Phase 3)
- Outputs don't require re-running apply to view

---

## 1.4 - Data Sources

### What We Did

Queried existing AWS resources (VPC, security group, subnet) without creating them.

**Files Created:**
- `data.tf` - Define data sources

**Data Sources Defined:**
- `data "aws_vpc" "vpc1"` - Query existing VPC named "vpc1"
- `data "aws_security_group" "server-sg"` - Query security group "server-sg"
- `data "aws_subnet" "public-subnet"` - Query subnet "public-subnet"

### File Structure

```hcl
# data.tf
data "aws_vpc" "vpc1" {
  filter {
    name   = "tag:Name"
    values = ["vpc1"]
  }
}

data "aws_security_group" "server-sg" {
  vpc_id = data.aws_vpc.vpc1.id
  name   = "server-sg"
}

data "aws_subnet" "public-subnet" {
  vpc_id = data.aws_vpc.vpc1.id
  filter {
    name   = "tag:Name"
    values = ["public-subnet"]
  }
}
```

### Using Data Sources in Resources

```hcl
# main.tf
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.server-sg.id]
  subnet_id              = data.aws_subnet.public-subnet.id
  
  tags = {
    Name = var.instance_name
  }
}
```

### Query Methods

| Resource | Method | Code |
|----------|--------|------|
| VPC | Filter by tag | `filter { name = "tag:Name", values = ["vpc1"] }` |
| Security Group | Direct name | `name = "server-sg"` |
| Subnet | Filter by tag | `filter { name = "tag:Name", values = ["public-subnet"] }` |

### Key Learnings

- **Data sources** read existing infrastructure (no creation)
- Useful for integrating with pre-existing AWS resources
- Different resources have different query methods
- Data sources can be referenced in resources and outputs
- Reference syntax: `data.aws_vpc.vpc1.id`

---

## Phase 1 Complete Files

After Phase 1, your `phase1-basics/` folder contains:

```
phase1-basics/
├── main.tf              (EC2 resource using variables and data sources)
├── variables.tf         (Input variable definitions)
├── terraform.tfvars     (Variable values specific to your setup)
├── outputs.tf           (Output definitions)
├── data.tf              (Data source definitions)
├── .gitignore           (Prevents committing sensitive files)
└── README.md            (This file or project-specific documentation)
```

---

## Common Commands

```bash
# Initialize Terraform (download plugins)
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Preview changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# Destroy resources
terraform destroy

# View state
terraform state list
terraform state show aws_instance.main
```

---

## Key Concepts Summary

| Concept | Definition | Example |
|---------|-----------|---------|
| **Provider** | Service to connect to (AWS, Azure, GCP) | `provider "aws" { region = "us-east-1" }` |
| **Resource** | Infrastructure to create | `resource "aws_instance" "main" { ... }` |
| **Variable** | Input parameter (your choice of name) | `variable "instance_type" { ... }` |
| **Output** | Extracted data (your choice of name) | `output "public_ip" { value = aws_instance.main.public_ip }` |
| **Data Source** | Query existing resources (read-only) | `data "aws_vpc" "vpc1" { ... }` |
| **State** | Terraform's record of created resources | `terraform.tfstate` (keep safe!) |

---

## Next Steps

Phase 1 covers fundamentals. Next phases:
- **Phase 2**: State management (remote backends, locking)
- **Phase 3**: Modules (reusable infrastructure blocks)
- **Phase 4+**: Advanced workflows, multi-environment setups

---

## Tips

1. Always run `terraform plan` before `apply` to preview changes
2. Keep `.tfvars` files out of Git (use `.gitignore`)
3. Use descriptive names for variables and outputs
4. Data sources are read-only and don't cost anything to query
5. State files are critical—back them up if using local state

---

## Troubleshooting

**AMI ID not found:**
- AMI IDs are region-specific
- Use AWS Console → EC2 → AMI Catalog to find correct ID

**Multiple resources matched:**
- Be more specific in data source filters
- Use tags (Name tags preferred)
- Combine filters for precision

**Variable not overriding default:**
- Check `terraform.tfvars` filename (case-sensitive on Linux)
- Verify variable name matches in both files
- Run `terraform plan -var="key=value"` to test

---

## Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Language Docs](https://www.terraform.io/language)
- [AWS EC2 Instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
