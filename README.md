# 🌍 Modular Multi-Cloud Infrastructure Deployment with Terraform (AWS + Azure)

## 📌 Overview

This project demonstrates a **modular, production-style multi-cloud infrastructure deployment** using **HashiCorp Terraform** across two major cloud providers simultaneously:

- **Amazon Web Services (AWS)**
- **Microsoft Azure**

The design follows infrastructure-as-code best practices:
- Separate Terraform modules per cloud provider
- Root module orchestration with conditional deployment logic
- Remote backend state management (S3 with versioning, encryption, and DynamoDB state locking)
- HTTPS-enabled Application Load Balancer on AWS (via CloudFront) and Standard Load Balancer on Azure (NGINX TLS)
- Reusable, maintainable, and cloud-agnostic infrastructure components

This project highlights **cloud-agnostic design**, **infrastructure modularity**, **load balancer provisioning across providers**, and **Terraform state consistency** across cloud environments.

---

## 🏗️ Architecture

The infrastructure is structured with a root module that conditionally invokes cloud-specific modules.

Each cloud deployment provisions networking, compute, and load balancing resources suitable for hosting a web application — deployed in parallel with a single `terraform apply`.

```
Root Module (main.tf)
        │
        ├── var.deploy_aws = true
        │        └── modules/aws/
        │              ├── VPC + Subnets
        │              ├── Security Group (ALB + EC2)
        │              ├── EC2 Instance (Dockerized Nginx)
        │              └── Application Load Balancer (ALB)
        │
        └── var.deploy_azure = true
                 └── modules/azure/
                       ├── Resource Group
                       ├── Virtual Network (VNet) + Subnet
                       ├── Network Security Group (NSG)
                       ├── Virtual Machine
                       └── Standard Load Balancer (with Public IP)
```

> 📸 **Architecture Screenshot:**
<img width="1024" height="1536" alt="image" src="https://github.com/user-attachments/assets/761cb7cc-065d-4aa6-85e3-0e7ba92a63ea" />

---

## ☁️ Cloud Deployments

### 🔹 AWS Deployment

**Provisioned Resources:**

| Resource | Description |
|---|---|
| VPC | Custom network with DNS support enabled |
| Public Subnets (×2) | Multi-AZ subnets for ALB and EC2 |
| Security Group (ALB) | Allows HTTP (80) and HTTPS (443) from internet |
| Security Group (EC2) | Allows HTTP from ALB only |
| EC2 Instance | Ubuntu with Dockerized Nginx web server |
| Application Load Balancer | Internet-facing ALB across both public subnets |
| Target Group | HTTP target group with health check on `/` |
| ALB Listener | Forwards port 80 traffic to target group |

> 📸 **AWS Console Screenshot:**
<img width="1627" height="818" alt="image" src="https://github.com/user-attachments/assets/6a71af1d-bfff-40ed-85e5-df256022eae0" />

---

### 🔹 Azure Deployment

**Provisioned Resources:**

| Resource | Description |
|---|---|
| Resource Group | Container for all Azure resources |
| Virtual Network (VNet) | `10.0.0.0/16` address space |
| Subnet | `10.0.1.0/24` for VM placement |
| Network Security Group | Allows HTTP (80) and HTTPS (443) traffic |
| Virtual Machine | Web server in the VNet subnet |
| Public IP (Static) | Standard SKU static IP for the Load Balancer |
| Standard Load Balancer | Internet-facing LB with frontend IP configuration |
| Backend Address Pool | Pool for associating VMs/VMSS instances |
| Health Probe | HTTP probe on port 80 checking `/` |
| Load Balancing Rule | Maps frontend HTTP (port 80) to backend pool |

> 📸 **Azure Portal Screenshot:**
<img width="1187" height="882" alt="image" src="https://github.com/user-attachments/assets/420dca21-8d85-4a95-a1e8-7e2a83c8d7ed" />

---

## 🗄️ Remote State Backend

Terraform state is stored remotely in a **dedicated S3 bucket** provisioned and managed by Terraform (`s3-bucket.tf`), with concurrent write protection provided by a **DynamoDB lock table** (`dynamodb.tf`).

| Feature | Configuration |
|---|---|
| S3 Bucket | `multi-cloud-tf-state-19` (eu-west-2) |
| Versioning | Enabled — allows state rollback |
| Encryption | AES256 server-side encryption at rest |
| Public Access | Fully blocked — all public ACLs and policies denied |
| State Key | `terraform.tfstate` |
| State Locking | DynamoDB table `multi-cloud-tf-locks` — prevents concurrent apply conflicts |
| Lock Billing | PAY_PER_REQUEST — zero cost when idle |

```hcl
terraform {
  backend "s3" {
    bucket         = "multi-cloud-tf-state-19"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "multi-cloud-tf-locks"
    encrypt        = true
  }
}
```

> 📸 **S3 Backend Screenshot:**
<img width="1915" height="512" alt="image" src="https://github.com/user-attachments/assets/dcffa123-2590-4002-b8f3-647aea6a15d0" />

> 📸 **DynamoDB Lock Table Screenshot:**
<img width="1916" height="447" alt="Image" src="https://github.com/user-attachments/assets/1253b24e-d365-4455-8bec-03c93a0a89a2" />

---

## 📂 Repository Structure

```
multi-cloud-terraform/
│
├── backend.tf              # Remote S3 backend + DynamoDB locking + provider version constraints
├── providers.tf            # AWS and AzureRM provider configuration
├── variables.tf            # Root input variables (regions, deploy flags)
├── main.tf                 # Root module — conditional module invocation
├── outputs.tf              # Root outputs (ALB DNS, Azure LB IP, DynamoDB table name)
├── s3-bucket.tf            # S3 bucket for remote state (versioned + encrypted)
├── dynamodb.tf             # DynamoDB lock table for concurrent apply protection
│
├── modules/
│   ├── aws/
│   │   ├── main.tf         # VPC, subnets, EC2, security groups
│   │   ├── aws_alb.tf      # ALB, target group, listener, ALB security group
│   │   ├── variables.tf    # AWS module input variables
│   │   └── outputs.tf      # AWS module outputs (ALB DNS, EC2 IP)
│   │
│   └── azure/
│       ├── main.tf         # Resource group, VNet, subnet, NSG, VM
│       ├── azure_lb.tf     # Public IP, Load Balancer, backend pool, probe, rule
│       ├── variables.tf    # Azure module input variables
│       └── outputs.tf      # Azure module outputs (LB public IP, RG name)
```

### File Explanations

| File | Purpose |
|---|---|
| `backend.tf` | Configures S3 remote state backend with DynamoDB locking, pins AWS `~> 5.100.0` + AzureRM `~> 3.117.1` |
| `providers.tf` | Configures AWS and AzureRM providers with region variables |
| `variables.tf` | Root variables: `aws_region`, `azure_location`, `deploy_aws`, `deploy_azure` |
| `main.tf` | Conditionally calls AWS and Azure modules based on boolean flags |
| `s3-bucket.tf` | Provisions the S3 state bucket with versioning, encryption, and public access block |
| `dynamodb.tf` | Provisions the DynamoDB lock table with `prevent_destroy` and project tagging |
| `modules/aws/main.tf` | VPC, public subnets, EC2 with Nginx, security groups |
| `modules/aws/aws_alb.tf` | ALB, security group, target group with health check, HTTP listener |
| `modules/azure/main.tf` | Resource group, VNet, subnet |
| `modules/azure/azure_lb.tf` | Static public IP, Standard LB, backend pool, HTTP probe, LB rule |

---

## ⚙️ Terraform Design Approach

### 1️⃣ Modular Architecture

Each cloud provider is implemented as an independent Terraform module. This ensures:
- Reusability across environments and projects
- Clear separation of concerns per provider
- Cloud-specific customisation without impacting other providers
- Each module can be tested and deployed independently

### 2️⃣ Conditional Deployment Logic

The root module uses boolean variables to control which clouds are deployed:

```hcl
deploy_aws   = true
deploy_azure = true
```

This allows:
- AWS-only deployment
- Azure-only deployment
- Simultaneous multi-cloud deployment

```bash
# Deploy to AWS only
terraform apply -var="deploy_azure=false"

# Deploy to Azure only
terraform apply -var="deploy_aws=false"

# Deploy to both clouds
terraform apply
```

### 3️⃣ Load Balancer Parity Across Providers

Both cloud deployments include a production-style load balancer in front of compute resources:

| Feature | AWS | Azure |
|---|---|---|
| Load Balancer Type | Application Load Balancer (ALB) | Standard Load Balancer |
| IP Type | Dynamic (DNS-based) | Static Public IP |
| Health Check | HTTP GET `/` — expects 200 | HTTP probe on port 80 hitting `/` |
| Target Registration | EC2 instance via Target Group | VM via Backend Address Pool |
| SKU | N/A (ALB is always standard) | Standard SKU |

### 4️⃣ Remote State Management (S3 + DynamoDB)

The S3 + DynamoDB backend provides a complete, production-safe state management solution:
- Centralised state for team collaboration
- State versioning for rollback capability
- AES256 encryption at rest and `encrypt = true` enforced in transit
- Fully blocked public access
- **DynamoDB locking prevents two concurrent applies from corrupting state** — the second operation reads the lock and exits immediately with a clear error identifying who holds it and when it was acquired
- Both the S3 bucket and the DynamoDB table are provisioned by Terraform itself — state infrastructure is fully code-managed

### 5️⃣ Consistent Tagging Strategy

Every resource across both clouds is tagged with `project = "multi-cloud-demo"`, enabling:
- Filtering all demo resources in a single AWS Console or Azure Portal view
- Cost allocation per project
- Easy cleanup — filter by tag and delete

---

## 🚀 Deployment Instructions

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with valid credentials
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) configured (`az login`)

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/sanjog-shrestha/Modular-Multi-Cloud-Deployment-with-Terraform-AWS-Azure-.git
cd Modular-Multi-Cloud-Deployment-with-Terraform-AWS-Azure-
```

**2. Create the DynamoDB lock table first**
```bash
terraform apply -target=aws_dynamodb_table.terraform_locks
```

> This must be done before `terraform init` so the lock table exists when the backend is initialised.

**3. Initialize Terraform**
```bash
terraform init
```

**4. Validate Configuration**
```bash
terraform validate
```

**5. Review Execution Plan**
```bash
terraform plan
```

**6. Apply Infrastructure**
```bash
terraform apply
```

> ⚠️ If you encounter `already exists` errors on Azure NSG rules, import the existing resources before applying:
```bash
terraform import module.azure[0].azurerm_network_security_rule.http "/subscriptions/<subscription-id>/resourceGroups/multi-cloud-rg/providers/Microsoft.Network/networkSecurityGroups/multi-cloud-nsg/securityRules/allow-http"

terraform import module.azure[0].azurerm_network_security_rule.lb_health_probe "/subscriptions/<subscription-id>/resourceGroups/multi-cloud-rg/providers/Microsoft.Network/networkSecurityGroups/multi-cloud-nsg/securityRules/allow-lb-health-probe"
```

---

## 🔍 Terraform Apply Output

> 📸 **Apply Screenshot:**
<img width="746" height="137" alt="image" src="https://github.com/user-attachments/assets/9c4c0908-7836-4b3b-80ec-d05ffa016c22" />

---

## 🌐 Application Validation

Once deployed, Terraform outputs the public endpoints for both clouds:

```
aws_alb_dns          = "multi-cloud-alb-xxxxxxxxxxxx.eu-west-2.elb.amazonaws.com"
azure_lb_ip          = "xx.xx.xx.xx"
dynamodb_lock_table  = "multi-cloud-tf-locks"
```

Open each in your browser to verify the web application is running and load-balanced correctly on both clouds.

> 📸 **App Validation Screenshot:**
<img width="1918" height="637" alt="image" src="https://github.com/user-attachments/assets/c956b41e-5995-4140-b2f4-2af7feb60b82" />

---

## 📊 Multi-Cloud Comparison

| Feature | AWS | Azure |
|---|---|---|
| Networking | VPC + Public Subnets | VNet + Subnet |
| Security | Security Groups (ALB + EC2) | Network Security Group (NSG) |
| Compute | EC2 Instance (Ubuntu + Nginx) | Virtual Machine |
| Load Balancer | Application Load Balancer (ALB) | Standard Load Balancer |
| LB Public IP | DNS-based (dynamic) | Static Public IP (Standard SKU) |
| Health Check | Target Group HTTP probe | LB HTTP probe on `/` |
| State Backend | S3 (versioned + encrypted) + DynamoDB lock | — (shared S3 + DynamoDB backend) |
| Provisioning Tool | Terraform AWS Provider `~> 5.100.0` | Terraform AzureRM Provider `~> 3.117.1` |

---

## 🧠 Key Concepts Demonstrated

- Multi-provider Terraform configuration (AWS + Azure simultaneously)
- Infrastructure modularisation with per-cloud module separation
- Conditional module invocation via boolean deployment flags
- Application Load Balancer (AWS) and Standard Load Balancer (Azure) provisioning
- Remote backend state management with S3 (versioned, encrypted, public-access-blocked)
- **DynamoDB state locking to prevent concurrent apply conflicts**
- **`prevent_destroy` lifecycle rule to protect critical shared infrastructure**
- **`terraform apply -target` for controlled incremental provisioning**
- **`terraform import` for bringing existing resources under Terraform management**
- S3 state bucket and DynamoDB lock table both provisioned and managed by Terraform itself
- Consistent cross-cloud tagging strategy for resource grouping and cost tracking
- Cloud networking fundamentals across both providers
- Provider abstraction and infrastructure portability

---

## 🏁 Project Outcomes

This project demonstrates the ability to:

- Architect cloud-agnostic infrastructure deployable across multiple providers
- Implement modular Terraform design patterns with clean module separation
- Deploy load-balanced infrastructure simultaneously on AWS and Azure
- Manage remote state securely with versioning, encryption, and concurrent write protection
- Apply consistent tagging and naming conventions across cloud providers
- Use conditional logic to control multi-cloud deployment scope
- **Protect shared Terraform state with DynamoDB locking for safe team and CI/CD use**
- **Recover from state drift using `terraform import` for out-of-band resources**

---

## 🔮 Future Improvements

Potential enhancements:

- [x] HTTPS enabled on both AWS (CloudFront + ALB) and Azure (NGINX TLS behind Load Balancer) ✅
- [ ] DNS-based failover with Route 53 and Azure Traffic Manager
- [ ] Active-passive multi-cloud routing for disaster recovery
- [x] ~~DynamoDB state locking to prevent concurrent apply conflicts~~ ✅ Completed
- [ ] GCP module addition for true three-cloud deployment
- [ ] Cost estimation with Infracost integration
- [ ] Monitoring stack (CloudWatch + Azure Monitor)
- [ ] CI/CD pipeline with GitHub Actions deploying both clouds

---

## 📄 Author

**Sanjog Shrestha**

---

## 📜 License

This project is intended for educational and portfolio purposes.


---

## 🔐 HTTPS Implementation Details

This project implements HTTPS differently across cloud providers, demonstrating real-world architectural differences:

### AWS
- HTTPS is handled via **CloudFront distribution**
- TLS termination occurs at the edge (CDN layer)
- ALB operates behind CloudFront
- Provides global low-latency secure access

### Azure
- Azure Standard Load Balancer operates at **Layer 4 (TCP)**
- TLS is handled directly by **NGINX running on the VM**
- Load balancer forwards encrypted traffic (port 443)
- Custom `/health` endpoint ensures proper backend health checks

This demonstrates the difference between:
- **Layer 7 (AWS ALB + CloudFront)**
- **Layer 4 (Azure LB + application-level TLS)**

