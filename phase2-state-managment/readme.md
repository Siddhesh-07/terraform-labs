# Phase 2: State Management

---

## **Phase 2 Overview**

Phase 2 teaches you how Terraform **tracks infrastructure** (state files) and how to **manage it safely** in teams.

**4 sub-sections:**
- 2.1: Local state inspection
- 2.2: State locking
- 2.3: Remote backend setup
- 2.4: State recovery

---

## **2.1 - Local State Inspection**

### **What we did:**
- Created EC2 instance with Terraform
- Inspected `terraform.tfstate` (JSON file with all resource details)
- Used `terraform state list` to see resources
- Used `terraform state show` to see resource details
- Manually changed instance tag in AWS console (created drift)
- Ran `terraform plan` to detect the drift
- Ran `terraform apply` to fix it (reconcile state with AWS)

### **Key Learning:**
- State file = Terraform's memory of what exists in AWS
- `terraform state list/show` = inspect state
- Drift detection = Terraform catches changes made outside Terraform
- State is the **source of truth**



## **2.2 - State Locking Simulation**

### **What we did:**
- Opened 2 terminals (simulating 2 team members)
- In Terminal 1: Started `terraform apply` but didn't confirm
- In Terminal 2: Tried `terraform plan` while Terminal 1 was applying
- Terminal 2 got **blocked** with lock error
- Confirmed in Terminal 1, lock released
- Terminal 2 could now run successfully

### **Key Learning:**
- State locking prevents **concurrent modifications**
- When one person applies, others are blocked
- Lock is automatic (local state uses `.terraform.tflock.hcl`)
- Prevents state corruption from simultaneous changes

### **Real-world scenario:**
- Person A and Person B both try to apply at same time
- Without locking: Both changes applied → state corrupted
- With locking: Person B blocked → waits for Person A → then applies safely

### **How It Works**

When you run `terraform apply`:
1. Terraform creates a lock file (`.terraform.tflock.hcl`)
2. Other Terraform operations detect this lock
3. They are blocked with error: "Error acquiring the state lock"
4. When apply finishes, lock is automatically released
5. Others can now proceed

---

## **2.3 - Remote Backend Setup (S3 + DynamoDB)** ⭐ IMPORTANT

### **Problem it solves:**
- Local state (`terraform.tfstate` on your computer) doesn't scale
- Team members have different state files → conflicts
- **Solution:** Store state in S3 (cloud) so everyone shares the same state

### **What we did:**

#### **1. Created S3 Bucket**
```powershell
aws s3 mb s3://terraform-state-siddhesh-XXXXXX
```
- S3 = Cloud file storage
- Stores `terraform.tfstate` in the cloud (not locally)
- Everyone can access the same state file

#### **2. Created DynamoDB Table**
```powershell
aws dynamodb create-table `
  --table-name terraform-locks `
  --attribute-definitions AttributeName=LockID,AttributeType=S `
  --key-schema AttributeName=LockID,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --region us-east-1
```
- DynamoDB = Cloud database for storing locks
- **Purpose:** Prevent 2 people from applying at the same time
- When you apply, it creates a lock entry in DynamoDB
- Others see the lock and are blocked
- When apply finishes, lock is deleted

#### **3. Created `backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-siddhesh-XXXXXX"
    key            = "phase2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```
- Tells Terraform: "Use S3 for state, use DynamoDB for locking"
- `bucket` = where state file lives
- `key` = path inside S3
- `dynamodb_table` = where locks are recorded
- `encrypt` = encrypt state in S3 (security)

#### **4. Ran `terraform init -migrate-state`**
- Moved state from local computer to S3
- Confirmed: local `terraform.tfstate` is now in S3
- Now your state is in the cloud, accessible to team

### **Key Learning - How DynamoDB Locking Works:**

| Step | What Happens |
|------|--------------|
| Person A runs `terraform apply` | Terraform creates lock entry in DynamoDB: `LockID = "phase2/terraform.tfstate"` |
| Person B tries `terraform apply` | Terraform checks DynamoDB, sees lock entry, blocks Person B with error |
| Person A finishes apply | Lock entry is deleted from DynamoDB |
| Person B retries | No lock found, can now apply |

### **Real-world analogy:**
- S3 bucket = Shared document in cloud
- DynamoDB lock = Sign on bathroom door ("occupied" or "vacant")
- Without lock: 2 people try to edit same doc → corrupted
- With lock: Only 1 person edits at a time → safe

### **Setup Steps**

1. Create S3 bucket for state storage
2. Create DynamoDB table for locking
3. Create `backend.tf` with S3 and DynamoDB configuration
4. Run `terraform init -migrate-state` to move state to S3
5. Verify state is in S3: `aws s3 ls s3://your-bucket/phase2/`
6. Verify DynamoDB table exists: `aws dynamodb list-tables --region us-east-1`

### **Verification Commands**

Check S3 has state file:
```powershell
aws s3 ls s3://terraform-state-siddhesh-XXXXXX/phase2/
```

Check DynamoDB table exists:
```powershell
aws dynamodb list-tables --region us-east-1
```

Download state from S3 to inspect:
```powershell
aws s3 cp s3://terraform-state-siddhesh-XXXXXX/phase2/terraform.tfstate . --sse AES256
```

Check for locks during apply:
```powershell
aws dynamodb scan --table-name terraform-locks --region us-east-1
```

---

## **2.4 - State Recovery & Inspection** ⭐ IMPORTANT

### **Problem it solves:**
- What if state gets corrupted or out of sync?
- How do you recover?

### **What we did:**

#### **1. Inspected State**
```powershell
terraform state list                    # See all resources
terraform state show aws_instance.phase2 # See resource details
```

#### **2. Simulated Corruption - Removed Resource from State**
```powershell
terraform state rm aws_instance.phase2
```
- Removed instance from state (but NOT from AWS)
- Now state says "no instances" but AWS still has one running
- **State and AWS are out of sync**

#### **3. Terraform Wanted to Recreate It**
```powershell
terraform plan
```
- Terraform: "I don't know about this instance, I'll create a new one"
- Would have created duplicate instance if we applied

#### **4. Recovered Using `terraform import`**
```powershell
terraform import aws_instance.phase2 i-0123456789abcdef0
```
- Told Terraform about the existing instance in AWS
- Added it back to state
- Now state and AWS are in sync again

#### **5. Verified Recovery**
```powershell
terraform plan
```
- Shows "no changes" — state and AWS match again

### **Key Learning:**

| Scenario | Solution |
|----------|----------|
| Deleted resource from state by mistake | `terraform import` to add it back |
| Want to stop Terraform from managing a resource | `terraform state rm` (keep AWS resource, just remove from state) |
| Inherited someone else's infrastructure | `terraform import` to bring it under Terraform management |
| State file corrupted | Reimport resources to rebuild state |
| Want to see what Terraform knows | `terraform state list/show` |

### **State Recovery Steps**

1. List resources in state: `terraform state list`
2. Remove from state if corrupted: `terraform state rm <resource>`
3. Get AWS resource ID: `aws <service> describe-<resources> --query 'Resources[0].Id'`
4. Import back to state: `terraform import <type> <id>`
5. Verify recovery: `terraform plan` (should show "no changes")

### **State Commands Reference**

List all resources:
```powershell
terraform state list
```

Show resource details:
```powershell
terraform state show aws_instance.phase2
```

Remove resource from state (dangerous!):
```powershell
terraform state rm aws_instance.phase2
```

Import existing AWS resource:
```powershell
terraform import aws_instance.phase2 i-0123456789abcdef0
```

Manually inspect state file:
```powershell
cat terraform.tfstate
```

---

## **Why 2.3 & 2.4 Are Critical**

### **2.3 (Remote Backend + Locking)**
- Enables **team collaboration** (everyone shares same state)
- Prevents **state conflicts** (DynamoDB locking)
- Keeps state **safe in cloud** (S3 backup)
- Production-ready infrastructure management

### **2.4 (State Recovery)**
- Handles **mistakes** (accidentally removed from state)
- Enables **disaster recovery** (reimport resources)
- Gives you **control** over state (not locked into Terraform forever)
- Teaches you that **state is recoverable**

---

## **Phase 2 Complete Deliverables**

✅ `backend.tf` - S3 + DynamoDB remote backend configuration
✅ EC2 instance managed with remote state
✅ Understanding of state locking mechanism
✅ Knowledge of state recovery using `terraform import`
✅ Safe state file in S3 (not local)

---

## **Key Concepts Summary**

| Component | Purpose |
|-----------|---------|
| **State File** | Terraform's memory of what exists in AWS |
| **S3 Bucket** | Remote storage for state (team-accessible) |
| **DynamoDB Table** | Lock mechanism (prevents concurrent applies) |
| **backend.tf** | Configuration to use S3 + DynamoDB |
| **terraform state list** | See what Terraform is managing |
| **terraform state show** | See details of a resource |
| **terraform state rm** | Remove resource from state (dangerous!) |
| **terraform import** | Add existing resource to state |

---

## **Phase 2 Complete! ✅**

**Next: Phase 3 (Modules & Reusability)** - Build reusable infrastructure blocks.

---


## **Troubleshooting**

**Q: State file still shows locally after init?**
A: Run `terraform init -migrate-state` to force migration to S3

**Q: Getting lock errors when applying?**
A: Another process has the lock. Wait for it to finish or check DynamoDB table

**Q: Want to remove a resource but keep it in AWS?**
A: Use `terraform state rm` then recreate the resource manually or import it back

**Q: State file disappeared from S3?**
A: Check S3 bucket name and key path in `backend.tf`

**Q: How to recover from state corruption?**
A: Use `terraform import` to re-add resources to state one by one

---

## **Best Practices for Phase 2**

1. **Always use remote backends** for production (never local state)
2. **Enable encryption** in S3 backend configuration
3. **Use DynamoDB** for locking to prevent conflicts
4. **Backup state files** regularly (S3 versioning helps)
5. **Never manually edit** `terraform.tfstate` unless absolutely necessary
6. **Document your backend** configuration in version control
7. **Test state recovery** before you need it in production
8. **Use descriptive key paths** in S3 (e.g., `env/project/terraform.tfstate`)

---

## **What State File Contains**

```json
{
  "version": 4,
  "terraform_version": "1.15.7",
  "serial": 5,
  "lineage": "unique-id",
  "outputs": {},
  "resources": [
    {
      "type": "aws_instance",
      "name": "phase2",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "id": "i-0123456789abcdef0",
            "ami": "ami-06067086cf86c58e6",
            "instance_type": "t3.micro",
            "tags": {
              "Name": "phase2-instance"
            },
            ...
          }
        }
      ]
    }
  ]
}
```

**Each resource stored with:**
- Resource type (`aws_instance`)
- Resource name (`phase2`)
- All attributes (id, ami, tags, etc.)
- Schema version
- Metadata for recovery

---

## **State vs Code**

| Aspect | Code (main.tf) | State (terraform.tfstate) |
|--------|---|---|
| **What it contains** | Desired infrastructure | Actual infrastructure |
| **Who edits it** | You (developers) | Terraform (automatically) |
| **Format** | HCL | JSON |
| **Location** | GitHub/version control | Local or S3 (remote) |
| **Purpose** | Source of truth for config | Source of truth for resources |

Terraform's job: **Make state match code**

---

## **Moving Forward**

Phase 2 is now complete. You understand:
- How Terraform tracks infrastructure (state)
- How to prevent conflicts (locking)
- How to share state with teams (remote backends)
- How to recover from problems (import/rm)

**Phase 3 (Modules)** builds on this foundation by teaching you how to organize and reuse code.
