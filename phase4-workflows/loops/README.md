# Phase 4: Advanced Workflows (4.3 - 4.4)

## 4.3 - for_each and count (Loops)

### What Problem Does This Solve?

Create multiple identical resources without repeating code.

---

### `for_each` - Loop Over List/Map

```hcl
resource "aws_instance" "web" {
  for_each = toset(["web1", "web2", "web3"])
  
  tags = {
    Name = each.value  # "web1", "web2", "web3"
  }
}
```

Creates 3 instances with different names.

**Access:** `aws_instance.web["web1"].public_ip`

---

### `count` - Loop N Times

```hcl
resource "aws_instance" "db" {
  count = 2
  
  tags = {
    Name = "db-server-${count.index}"  # 0, 1
  }
}
```

Creates 2 identical instances (db-server-0, db-server-1).

**Access:** `aws_instance.db[0].public_ip`

---

### When to Use Each

| Use | for_each | count |
|-----|----------|-------|
| **Named resources** | ✅ | ❌ |
| **Identical copies** | ❌ | ✅ |
| **Safe to remove** | ✅ | ❌ |

---

### Key Learning

✅ `for_each` = loop over named items (safer, clearer)
✅ `count` = loop N times (simpler, identical)
✅ `each.value`, `each.key` = access item in for_each
✅ `count.index` = access index (0, 1, 2...)
✅ DRY = write once, create many

---

## 4.4 - Conditionals and Dependencies

### Conditionals: Create If/Then

```hcl
variable "create_web_server" {
  type    = bool
  default = true
}

resource "aws_instance" "web" {
  count = var.create_web_server ? 1 : 0
  # Create 1 if true, 0 if false
}
```

**Usage:** `terraform apply -var="create_web_server=false"`

---

### Explicit Dependencies

```hcl
resource "aws_instance" "db" {
  depends_on = [aws_instance.web]
  # Don't create DB until web is created
}
```

Terraform usually figures out dependencies automatically, but `depends_on` forces explicit order.

---

### Key Learning

✅ Conditionals: `condition ? if_true : if_false`
✅ `count = var.condition ? 1 : 0` = create conditionally
✅ `depends_on` = force creation order
✅ Implicit dependencies = Terraform auto-detects
✅ Explicit dependencies = you control order

---

## Phase 4.3-4.4 Summary

| Feature | Purpose |
|---------|---------|
| **for_each** | Loop over named items, create multiple resources |
| **count** | Loop N times, create N identical resources |
| **Conditionals** | Create resource only if condition is true |
| **depends_on** | Force explicit dependency between resources |

---

## Note

These are **advanced features**, useful to know but:
- Rarely asked in interviews
- Used in ~10% of real-world code
- Not critical for job switch

---

**Phase 4.3-4.4 Complete! ✅**

**Phase 4 Complete! ✅✅✅**
