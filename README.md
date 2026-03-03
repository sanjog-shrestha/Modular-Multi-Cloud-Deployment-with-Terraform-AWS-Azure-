# 🌍 Multi-Cloud Infrastructure Deployment with Terraform (AWS + Azure)

## 📌 Overview

This project demonstrates a modular, production-style multi-cloud
infrastructure deployment using HashiCorp Terraform.

The same infrastructure pattern is deployed across:

-   Amazon Web Services (AWS)
-   Microsoft Azure

The design follows infrastructure-as-code best practices:

-   Separate Terraform modules per cloud provider
-   Root module orchestration
-   Conditional deployment logic
-   Remote backend state management
-   Reusable, maintainable infrastructure components

This project highlights cloud-agnostic design, infrastructure
modularity, and Terraform state consistency across providers.

------------------------------------------------------------------------

## 🏗 Architecture

The infrastructure is structured with a root module that conditionally
invokes cloud-specific modules.

Each cloud deployment includes networking and compute resources suitable
for hosting a simple web application.

![Architecture Diagram](images/architecture.png)

> Replace this image with your architecture diagram (draw.io,
> Lucidchart, etc.)

------------------------------------------------------------------------

## ☁ Cloud Deployments

### 🔹 AWS Deployment

Provisioned Resources: - VPC - Public Subnet - Security Group (HTTP
allowed) - EC2 Instance - Dockerized Nginx Web Server

AWS Console Screenshot:

![AWS Infrastructure](images/aws-console.png)

------------------------------------------------------------------------

### 🔹 Azure Deployment

Provisioned Resources: - Resource Group - Virtual Network (VNet) -
Subnet - Network Security Group - Virtual Machine

Azure Portal Screenshot:

![Azure Infrastructure](images/azure-console.png)

------------------------------------------------------------------------

## 📂 Repository Structure

    multi-cloud-terraform/
    │
    ├── modules/
    │   ├── aws/
    │   └── azure/
    │
    ├── backend.tf
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    ├── terraform.tfvars
    └── README.md

### Structure Explanation

-   **modules/aws** → AWS-specific infrastructure resources
-   **modules/azure** → Azure-specific infrastructure resources
-   **main.tf** → Root orchestration layer
-   **providers.tf** → Cloud provider configuration
-   **backend.tf** → Remote state backend configuration
-   **variables.tf** → Input variable definitions

------------------------------------------------------------------------

## ⚙ Terraform Design Approach

### 1️⃣ Modular Architecture

Each cloud provider is implemented as an independent Terraform module.\
This ensures:

-   Reusability
-   Clear separation of concerns
-   Easier maintenance
-   Cloud-specific customization without impacting other providers

------------------------------------------------------------------------

### 2️⃣ Conditional Deployment Logic

The root module uses boolean variables to control deployment:

    deploy_aws   = true
    deploy_azure = true

This allows:

-   AWS-only deployment
-   Azure-only deployment
-   Simultaneous multi-cloud deployment

Example:

    terraform apply -var="deploy_azure=false"

------------------------------------------------------------------------

### 3️⃣ Remote State Management

Terraform remote backend is configured to:

-   Maintain infrastructure consistency
-   Detect configuration drift
-   Enable controlled updates
-   Support rollback via state versioning

Example backend (S3):

    terraform {
      backend "s3" {
        bucket = "multi-cloud-tf-state"
        key    = "global/terraform.tfstate"
        region = "eu-west-2"
      }
    }

State management ensures reliable infrastructure lifecycle control
across providers.

------------------------------------------------------------------------

## 🚀 Deployment Instructions

### Initialize Terraform

    terraform init

### Validate Configuration

    terraform validate

### Review Execution Plan

    terraform plan

### Apply Infrastructure

    terraform apply

------------------------------------------------------------------------

## 🔍 Terraform Plan Output

![Terraform Plan](images/terraform-plan.png)

------------------------------------------------------------------------

## 🌐 Application Validation

Once deployed, access the public IP address of the provisioned instance
to verify the running web application.

![Application Running](images/app-running.png)

------------------------------------------------------------------------

## 📊 Multi-Cloud Comparison

  ------------------------------------------------------------------------
  Feature              AWS                      Azure
  -------------------- ------------------------ --------------------------
  Networking           VPC + Subnet             VNet + Subnet

  Security             Security Group           Network Security Group

  Compute              EC2 Instance             Virtual Machine

  Provisioning Tool    Terraform AWS Provider   Terraform AzureRM Provider
  ------------------------------------------------------------------------

------------------------------------------------------------------------

## 🧠 Key Concepts Demonstrated

-   Multi-provider Terraform configuration
-   Infrastructure modularization
-   Conditional module invocation
-   Remote backend state management
-   Cloud networking fundamentals
-   Secure infrastructure provisioning
-   Provider abstraction and portability

------------------------------------------------------------------------

## 🏁 Project Outcomes

This project demonstrates the ability to:

-   Architect cloud-agnostic infrastructure
-   Implement modular Terraform design patterns
-   Deploy infrastructure across multiple cloud providers
-   Manage state consistently across environments
-   Apply infrastructure-as-code best practices

------------------------------------------------------------------------

## 🔮 Future Improvements

Potential enhancements:

-   Load Balancer integration
-   DNS-based failover
-   Active-passive multi-cloud routing
-   Cost estimation with Terraform
-   Monitoring stack integration
-   Infrastructure tagging strategy
-   Production-grade security hardening

------------------------------------------------------------------------

## 📄 Author

Your Name\
DevOps / Cloud Engineer

------------------------------------------------------------------------

## 📜 License

This project is for educational and portfolio purposes.
