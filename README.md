# Terraform Labs

A hands-on learning repository for mastering Terraform on AWS. This project covers foundational to intermediate concepts through practical exercises using EC2, VPCs, and Auto Scaling Groups.

## 📚 Learning Path

### Phase 1: Fundamentals ✅

Master the basics of Terraform and AWS provisioning.

**Topics:**
- Basic EC2 provisioning with Terraform
- Variables and parameterization (terraform.tfvars)
- Outputs (retrieving resource values)
- Data sources (querying existing AWS resources)

**What You'll Build:**
- Simple EC2 instance deployment
- VPC with security groups
- Output EC2 details (IP, hostname, etc.)

### Phase 2: State Management ✅

Understand Terraform state and how to manage it in teams.

**Topics:**
- Local state inspection and analysis
- State locking (preventing concurrent applies)
- Remote backends with S3 + DynamoDB
- State recovery and drift management

**What You'll Build:**
- Remote state setup in AWS S3
- DynamoDB table for state locking
- State migration from local to remote
- Import existing resources into state

### Phase 3: Modules & Reusability ✅

Create reusable components for scalable infrastructure.

**Topics:**
- Module structure and variables
- Module outputs and composition
- Networking modules (VPC, subnets, security groups)
- Database modules (RDS basics)
- Registry modules (using community modules)

**What You'll Build:**
- VPC networking module
- EC2 instance module
- RDS database module
- Complete multi-tier architecture

### Phase 4: Advanced Workflows ✅

Optimize and manage Terraform deployments at scale.

**Topics:**
- Plan, apply, and destroy commands with flags
- Workspaces (dev/staging/prod environments)
- Loops with for_each and count
- Conditionals and dependencies

**What You'll Build:**
- Multi-environment setup using workspaces
- Dynamic resource creation with loops
- Conditional infrastructure provisioning
- Dependency management between resources

## 🚀 Getting Started

### Prerequisites

- AWS Account (with configured credentials)
- Terraform >= 1.0
- AWS CLI v2
- Git

### Setup

```bash
# Clone repository
git clone https://github.com/YOUR-USERNAME/terraform-labs.git
cd terraform-labs

# Configure AWS credentials
aws configure
# Enter your AWS Access Key ID and Secret Access Key

# Navigate to any phase folder
cd phase1-fundamentals

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Clean up resources
terraform destroy
```

## 📁 Directory Structure

```
terraform-labs/
├── phase1-fundamentals/        # EC2, variables, outputs, data sources
├── phase2-state-management/    # S3 backend, DynamoDB locks, state recovery
├── phase3-modules/
│   ├── main.tf                 # Root module
│   └── modules/
│       ├── ec2_instance/       # EC2 module
│       ├── vpc_setup/          # Networking module
│       └── rds_basic/          # Database module
└── phase4-advanced-workflows/  # Workspaces, loops, conditionals
```

## 🔑 Key Concepts Learned

| Phase | Core Concept | Real-World Use |
|-------|------|------|
| **1** | Infrastructure as Code | Define AWS resources in code instead of console |
| **2** | State Management | Team collaboration on shared infrastructure |
| **3** | Modules | Code reusability and DRY principles |
| **4** | Advanced Workflows | Production-grade deployments |

## 💡 Quick Reference

### Common Commands

```bash
# Validate configuration
terraform validate

# Format code properly
terraform fmt -recursive

# Check what will change
terraform plan

# Apply changes (requires confirmation)
terraform apply

# Auto-approve changes (CI/CD only)
terraform apply -auto-approve

# Destroy resources
terraform destroy

# Target specific resource
terraform apply -target=aws_instance.web

# Use workspace
terraform workspace select dev
```

### Important Files

- `main.tf` - Main configuration file (resources, providers)
- `variables.tf` - Input variables and defaults
- `outputs.tf` - Output values to display
- `terraform.tfvars` - Variable overrides (git-ignored)
- `backend.tf` - State backend configuration

## 🎯 Learning Outcomes

By completing this repository, you will:

✅ Understand Infrastructure as Code principles
✅ Manage AWS resources with Terraform
✅ Work with Terraform state and backends
✅ Create reusable, modular infrastructure
✅ Deploy multi-environment setups
✅ Use advanced Terraform features
✅ Be ready for DevOps roles

## 🔗 Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Language Documentation](https://www.terraform.io/language)
- [AWS Provider Registry](https://registry.terraform.io/providers/hashicorp/aws/latest)

## 📝 Notes

### Phase 1 Tips
- Always specify region in provider block
- Check AWS console to verify resources are created
- Use `terraform destroy` to clean up when done

### Phase 2 Tips
- Create S3 bucket before configuring backend
- DynamoDB table name must match backend configuration
- Use `terraform init -migrate-state` when switching backends

### Phase 3 Tips
- Keep modules focused on single responsibility
- Use descriptive variable names
- Module outputs should be explicit

### Phase 4 Tips
- Workspaces are folder-specific (not global)
- Use `terraform.workspace` variable for environment-specific settings
- Always test in non-production environments first

## ⚠️ Cost Awareness

This repository uses AWS resources that may incur charges:
- EC2 instances (use t3.micro for free tier eligibility)
- S3 buckets (minimal cost)
- DynamoDB tables (on-demand billing)

Always run `terraform destroy` when finished with a phase to avoid unexpected charges.

## 🤝 Contributing

This is a personal learning repository. Feel free to:
- Modify exercises for deeper understanding
- Add additional phases beyond Phase 4
- Experiment with different resource types
- Create variations for different use cases

## 📄 License

Open source - use freely for learning purposes.

---

**Happy learning! Master Terraform and unlock advanced DevOps skills.** 🚀
