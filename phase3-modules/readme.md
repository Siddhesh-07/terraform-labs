# Phase 3: Modules & Reusability (3.1 - 3.3)

## Overview

Phase 3 teaches you how to organize Terraform code into **reusable modules** and compose them into real-world infrastructure.

---

## **3.1 - Simple EC2 Module**

### What We Did

Created a **reusable EC2 module** that can be called multiple times with different values.

### Module Structure

```
modules/ec2_instance/
├── main.tf       (the EC2 resource)
├── variables.tf  (input variables)
└── outputs.tf    (output values)
```

### How It Works

**Define the module** (what it does):
```hcl
# modules/ec2_instance/main.tf
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids
  
  tags = {
    Name = var.instance_name
  }
}
```

**Use the module** (how to call it):
```hcl
# phase3-modules/main.tf
module "ec2_instance_1" {
  source = "./modules/ec2_instance"
  
  ami_id             = "ami-06067086cf86c58e6"
  instance_type      = "t3.micro"
  instance_name      = "app-server-1"
  security_group_ids = []
}

module "ec2_instance_2" {
  source = "./modules/ec2_instance"
  
  ami_id             = "ami-06067086cf86c58e6"
  instance_type      = "t3.small"
  instance_name      = "app-server-2"
  security_group_ids = []
}
```

Same module, called **twice with different values** → **2 instances created**

### Key Learning

✅ Module = reusable code block
✅ Variables = inputs (what you pass)
✅ Outputs = what you get back
✅ DRY principle (Don't Repeat Yourself)

---

## **3.2 - Networking Module**

### What We Did

Created a **networking module** that encapsulates VPC, subnets, internet gateway, route tables, and security groups.

### What It Creates

```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24)
├── Internet Gateway
├── Route Table (routes to IGW)
└── Security Group (allows SSH, HTTP, HTTPS)
```

### Module Structure

```
modules/vpc_setup/
├── main.tf       (VPC, subnet, IGW, route table, SG)
├── variables.tf  (VPC name, CIDR, subnet CIDR, AZ)
└── outputs.tf    (VPC ID, subnet ID, SG ID)
```

### How It Works

**Call networking module:**
```hcl
module "networking" {
  source = "./modules/vpc_setup"
  
  vpc_name             = "phase3-vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  availability_zone    = "us-east-1a"
}
```

**Use outputs in EC2 module:**
```hcl
module "ec2_instance_1" {
  source = "./modules/ec2_instance"
  
  security_group_ids = [module.networking.security_group_id]  # ← From networking!
  subnet_id          = module.networking.public_subnet_id     # ← From networking!
  ...
}
```

### Key Learning

✅ Modules expose data via outputs
✅ Outputs from one module → inputs to another
✅ Modules communicate through outputs/inputs
✅ Security group now properly attached to correct VPC

---

## **3.3 - Module Composition (VPC + EC2 + RDS)**

### What We Did

Connected **3 modules together** into a complete, production-ready architecture:
- **Networking module** (creates VPC, subnets, security groups)
- **EC2 module** (creates application servers)
- **RDS module** (creates PostgreSQL database)

### The Architecture

```
AWS Account
└── VPC (10.0.0.0/16)
    ├── Public Subnet (10.0.1.0/24)
    │   ├── EC2 Instance 1 (accessible from internet)
    │   └── EC2 Instance 2 (accessible from internet)
    │
    ├── Private Subnet 1 (10.0.2.0/24)
    │   └── RDS Database (NOT accessible from internet)
    │
    ├── Private Subnet 2 (10.0.3.0/24)
    │   └── RDS Backup/Failover
    │
    └── Internet Gateway
        └── Allows public subnet to reach internet
```

### Data Flow

```
Internet User
    ↓
Internet Gateway (public entry point)
    ↓
Public Subnet (EC2 instances)
    ↓ (EC2 talks to DB internally)
Private Subnet (RDS Database - hidden from internet)
    ↓
Back to EC2
    ↓
Internet Gateway
    ↓
Internet User
```

**Key:** Users can reach EC2 servers, but **cannot directly reach database** (secure!).

### How Modules Connect

**Networking module creates and exports:**
```hcl
output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "private_subnet_id" { value = aws_subnet.private.id }
output "private_subnet_2_id" { value = aws_subnet.private_2.id }
output "security_group_id" { value = aws_security_group.main.id }
```

**EC2 module uses networking outputs:**
```hcl
module "ec2_instance_1" {
  source = "./modules/ec2_instance"
  
  security_group_ids = [module.networking.security_group_id]
  subnet_id          = module.networking.public_subnet_id
  ...
}
```

**RDS module uses networking outputs:**
```hcl
module "database" {
  source = "./modules/rds_basic"
  
  security_group_ids = [module.networking.security_group_id]
  subnet_ids         = [
    module.networking.private_subnet_id,
    module.networking.private_subnet_2_id
  ]
  ...
}
```

### Why 2 Private Subnets?

RDS requires **at least 2 subnets in different availability zones** for:
- **High availability:** Database doesn't go down if one AZ fails
- **Automatic failover:** Switches to backup if primary fails
- **AWS requirement:** Multi-AZ deployments need multiple subnets

### Key Learning

✅ Module composition = multiple modules working together
✅ Outputs from one module → inputs to others
✅ Real-world architecture: public + private tiers
✅ Security: database isolated from internet
✅ Redundancy: multiple subnets for failover

---

## **Phase 3.1-3.3 Summary**

| Phase | What | Output |
|-------|------|--------|
| **3.1** | Reusable EC2 module | 2 EC2 instances from 1 module |
| **3.2** | Networking module | VPC, subnets, security groups |
| **3.3** | Composition | VPC + 2 EC2s + RDS database connected |

---

## **Real-World Usage**

This is how **production infrastructure** works:

1. **Public tier** (load balancers, web servers) - customers interact here
2. **Private tier** (databases, caches) - hidden, highly secured
3. **Modules manage each** - reusable, testable, maintainable

Your code now represents **enterprise-grade infrastructure**!

---

## **Commands Reference**

```bash
# Initialize modules
terraform init

# Preview changes
terraform plan

# Create infrastructure
terraform apply

# View outputs
terraform output

# Destroy everything
terraform destroy
```

---

## **Files Created**

```
phase3-modules/
├── main.tf                  (root configuration)
├── variables.tf             (root variables)
├── outputs.tf               (root outputs)
└── modules/
    ├── ec2_instance/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── vpc_setup/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── rds_basic/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## **Key Concepts**

| Concept | Meaning |
|---------|---------|
| **Module** | Reusable code block (folder with TF files) |
| **Module Input** | Variables passed when calling module |
| **Module Output** | Data exported from module for others to use |
| **Module Source** | Where module code lives (local path or Registry) |
| **Composition** | Multiple modules working together |
| **DRY** | Don't Repeat Yourself - write once, use many times |

---

## **Next Steps**

Phase 3 covers reusable infrastructure code. Next:
- **Phase 3.4:** Using pre-built Registry modules
- **CI/CD Capstone:** Automate deployment with GitHub Actions
- **Phase 4+:** Advanced patterns (workspaces, loops, conditionals)

---

## **Tips**

1. Always name modules clearly (e.g., `ec2_instance`, not `server`)
2. Export all useful data via outputs
3. Use consistent variable naming
4. Document module purpose in README
5. Test modules separately before composing

---

**Phase 3.1-3.3 Complete! ✅**
