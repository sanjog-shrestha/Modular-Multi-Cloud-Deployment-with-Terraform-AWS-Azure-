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

<img width="1024" height="1536" alt="image" src="https://github.com/user-attachments/assets/a1ec8c52-c026-4590-bb8f-51d4e2ec8080" />


------------------------------------------------------------------------

## ☁ Cloud Deployments

### 🔹 AWS Deployment

Provisioned Resources: - VPC - Public Subnet - Security Group (HTTP
allowed) - EC2 Instance - Dockerized Nginx Web Server

AWS Console Screenshot:

<img width="1546" height="622" alt="image" src="https://github.com/user-attachments/assets/6f3c9f9b-66dc-40ea-8aea-e317b15a300a" />


------------------------------------------------------------------------

### 🔹 Azure Deployment

Provisioned Resources: - Resource Group - Virtual Network (VNet) -
Subnet - Network Security Group - Virtual Machine

Azure Portal Screenshot:

<img width="1918" height="683" alt="image" src="https://github.com/user-attachments/assets/e8465192-17e5-4101-a30d-4c2d57ffed74" />


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

<img width="642" height="892" alt="image" src="https://github.com/user-attachments/assets/3bc8f8ec-f59a-4b89-b0f9-22d36cbd6582" />
<img width="723" height="762" alt="image" src="https://github.com/user-attachments/assets/1221d06c-e9ef-4747-af2c-66bb750a5efa" />
<img width="992" height="978" alt="image" src="https://github.com/user-attachments/assets/91979765-a122-431d-8c10-bc77ab4f76d9" />
<img width="732" height="948" alt="image" src="https://github.com/user-attachments/assets/d0edc276-223d-47bb-8afc-2e1941f49ae0" />
<img width="807" height="955" alt="image" src="https://github.com/user-attachments/assets/99bcd47f-df95-4886-8b4f-0062f72f60c3" />
<img width="821" height="598" alt="image" src="https://github.com/user-attachments/assets/734fcda4-14d7-426c-bc31-e5ba6feca2cb" />


------------------------------------------------------------------------

## 🌐 Application Validation

Once deployed, access the public IP address of the provisioned instance
to verify the running web application.
<img width="962" height="143" alt="image" src="https://github.com/user-attachments/assets/f03f7c83-194d-48ca-a53b-62eb94a4a03a" />
<img width="1917" height="1002" alt="image" src="https://github.com/user-attachments/assets/c0ada7ce-53f9-4711-80da-dc289128072f" />
<img width="863" height="925" alt="image" src="https://github.com/user-attachments/assets/f1dd56a7-33e6-4959-815e-63cc76213b36" />
<img width="582" height="122" alt="image" src="https://github.com/user-attachments/assets/c531803d-2c7b-439b-91eb-c39a399237cf" />



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

Sanjog Shrestha

------------------------------------------------------------------------

## 📜 License

This project is for educational and portfolio purposes.
