# Infrastructure Provisioning and Security Measures

## Overview

This Terraform configuration provisions a secure infrastructure using AWS services. The key components include:

1. Amazon Virtual Private Cloud (VPC): A secure network environment.
2. Amazon Elastic Kubernetes Service (EKS): A managed Kubernetes cluster with private and public access control.
3. Amazon Elastic Container Registry (ECR): A secure repository for Docker images.
   
##Security Measures
1. Private and Public Subnets
- Private Subnets: Only accessible via internal networking and NAT Gateway for outbound internet access. These subnets are designed to host sensitive resources like the EKS worker nodes.
- Public Subnets: These are exposed to the internet and are used for resources like the EKS control plane or load balancers.
2. NAT Gateway
- A single NAT Gateway is enabled to route outbound traffic from the private subnets to the internet, enhancing security by limiting direct internet exposure of private resources.
3. Security Groups
- EKS worker nodes are secured with specific ingress rules to allow traffic from the EKS control plane only on certain ports, such as port 15017 for Istio webhooks.
4. DNS Support and Hostnames
- DNS support and hostnames are enabled within the VPC, which facilitates communication between resources using domain names rather than IP addresses, improving manageability.
5. IAM Roles for Service Accounts (IRSA)
- IRSA is enabled for the EKS cluster, allowing the Kubernetes pods to assume IAM roles securely, which minimizes the need for providing long-lived AWS credentials in the application code.
6. Cluster Endpoint Access Control
- The EKS cluster is configured with private access to ensure sensitive management operations can only be performed within the VPC.
- Public access is allowed for specific operations, but private access remains the primary control.
7. Tagging for Resource Management
- Resources such as subnets and EKS clusters are tagged with environment identifiers (e.g., production) to improve resource tracking and cost allocation.
  
# Steps to Provision the Infrastructure

## Prerequisites
- Terraform (v1.0+)
- AWS CLI with proper credentials
- kubectl installed and configured
- AWS IAM roles and permissions to create VPC, EKS, and other AWS resources
  
### Step 1: Clone the Repository
###   Step 2: Initialize Terraform
See response:  https://github.com/Hakeemog/regtech/blob/screenshot/terraform-init.png
### Step 3: Plan the Infrastructure:  https://github.com/Hakeemog/regtech/blob/screenshot/terraform-plan
Execute the plan command to review the infrastructure that Terraform will provision. After reviewing the plan, apply the configuration to provision the infrastructure using terraform apply --auto-approve.
All the infrastructure highlighted in th plan are then provision
### Step 4: Access the EKS Cluster
After provisioning the EKS cluster, configure kubectl to access it using the AWS CLI with the command: aws eks --region us-east-2 update-kubeconfig --name regtech-eks
see provisioned cluster: https://github.com/Hakeemog/regtech/blob/screenshot/eks-cluster.png?raw=true
### Step 5: Verify the Cluster: https://github.com/Hakeemog/regtech/blob/screenshot/nodes.png?raw=true

## Additional Information
Scaling: The EKS cluster is set up with autoscaling enabled via the Cluster Autoscaler module.

# Monitoring: 

To enable monitoring, I integrated Prometheus and graana into the cluster
