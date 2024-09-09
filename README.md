# Infrastructure Design, Provisioning and Security Measures (Deliverable 1)

## Overview

The infrastructure design can be seen here: https://github.com/Hakeemog/regtech/blob/master/Screenshot%202024-09-08%20011301.png

This Terraform configuration provisions a secure infrastructure using AWS services. The key components include:

1. Amazon Virtual Private Cloud (VPC): A secure network environment.
2. Amazon Elastic Kubernetes Service (EKS): A managed Kubernetes cluster with private and public access control.
3. Amazon Elastic Container Registry (ECR): A secure repository for Docker images.
     
# Steps to Provision the Infrastructure

## Prerequisites
- Terraform (v1.0+)
- AWS CLI with proper credentials
- kubectl installed and configured
- AWS IAM roles and permissions to create VPC, EKS, and other AWS resources
  
### Step 1: Clone the Repository
###   Step 2: Initialize Terraform
See response:  https://github.com/Hakeemog/regtech/blob/screenshot/terraform-init.png
 https://github.com/Hakeemog/regtech/blob/screenshot/terraform-init-2.png
### Step 3: Plan the Infrastructure:  https://github.com/Hakeemog/regtech/blob/screenshot/terraform-plan
Execute the plan command to review the infrastructure that Terraform will provision. After reviewing the plan, apply the configuration to provision the infrastructure using terraform apply --auto-approve.
All the infrastructure highlighted in th plan are then provisioned
### Step 4: Access the EKS Cluster
After provisioning the EKS cluster, configure kubectl to access it using the AWS CLI with the command: aws eks --region us-east-2 update-kubeconfig --name regtech-eks
see provisioned cluster: https://github.com/Hakeemog/regtech/blob/screenshot/eks-cluster.png
### Step 5: Verify the Cluster: https://github.com/Hakeemog/regtech/blob/screenshot/nodes.png

## Additional Information 
Scaling: The EKS cluster is set up with autoscaling enabled via the Cluster Autoscaler module.
Horizontal Pod Autoscaling (HPA) is also set up in the deployment config

# Security Measures (Deliverable 3)
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
## To ensure the infrastructure is compliant with GDPR and PCI-DSS.
- I set up TLS (Transport Layer Security) in the ingress.yaml. With TLS settings, the following security measures are achieved with TLS

### Data Encryption:
TLS encrypts the data transmitted between the client (such as a web browser) and the server (your application). This ensures that sensitive information, such as login credentials, personal data, or payment details, is protected from eavesdropping or interception by malicious actors.

### Data Integrity:
TLS ensures that the data sent over the network is not tampered with or altered during transmission. If any data modification is attempted, the connection will be flagged as insecure, and the transmission will be terminated.

### Authentication:
The TLS configuration uses a certificate (associated with secretName: regtech-app-tls) that proves the identity of the server to the client. This prevents "man-in-the-middle" attacks where an attacker might try to impersonate the server to steal data.
Protection Against Man-in-the-Middle (MITM) Attacks:
With TLS, clients can verify the authenticity of the server they are connecting to. This helps protect against MITM attacks where an attacker tries to intercept and possibly alter the communication between a client and a server.

### Compliance with Security Standards:
Many security standards and regulations, such as GDPR, HIPAA, and PCI-DSS, require encryption of data in transit. Enabling TLS in the Ingress helps meet these compliance requirements.

### Improved User Trust:
Websites and applications that use TLS (with HTTPS) are seen as more trustworthy by users. Modern browsers will flag sites without TLS as "Not Secure," potentially leading to a loss of user trust and traffic.


# Monitoring (Deliverable 4)

To enable monitoring, I integrated Prometheus, grafana and loki into the cluster
## Procedures
### Step 1:
- Install helm:                                                                                                                                                     $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
### step 2:
We need to add the Helm Stable Charts for your local client. Execute the below command:
helm repo add stable https://charts.helm.sh/stable

### Step3: Add Prometheus Helm repo, then create a prometheus namespace where prometheus would be installed
- helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
- kubectl create namespace prometheus
The above command is used to install kube-Prometheus-stack. The helm repo kube-stack-Prometheus comes with a Grafana deployment embedded ( as the default one ).
See response: https://github.com/Hakeemog/regtech/blob/screenshot/prometheus.png
- To check whether Prometheus is installed or not use the command: kubectl get pods -n prometheus
  see response: https://github.com/Hakeemog/regtech/blob/screenshot/prometheus-pods.png
- To check the services file (svc) of the Prometheus: kubectl get svc -n prometheus
  see response:  https://github.com/Hakeemog/regtech/blob/screenshot/prometheus-svc.png
  From the above image, it is seen that grafana comes along with Prometheus as the stable version. This output is conformation that our Prometheus is installed 
  successfully there is no need of installing Grafana as a separate tool it comes along with Prometheus
  ### Step 4: Let’s expose Prometheus and Grafan to the external world
- There are 2 ways to expose which are through Node Port and through LoadBalancer. I am going to use the LoadBalancer to expose. To attach the load balancer I'll 
  change from ClusterIP to LoadBalancer by editing the service with the command
  kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
  see response: https://github.com/Hakeemog/regtech/blob/master/svc-edited.png
                https://github.com/Hakeemog/regtech/blob/screenshot/clusterIP-svc.png
                https://github.com/Hakeemog/regtech/blob/screenshot/loadbalancer-svc.png
- After changing to loadbalancer, prometheus is accessible in the ui using the loadbalancer link
  see response: https://github.com/Hakeemog/regtech/blob/screenshot/prometheus-board.png
- we can use a Prometheus UI for monitoring the EKS but the UI of Prometheus is not user friendly.Grafana is integrated and will extract the matrix from the 
  Prometheus UI and show it in a user-friendly manner. So I'll edit the svc of grafana to loadbalancer as above so I can access the UI
  See response:   https://github.com/Hakeemog/regtech/blob/screenshot/grafana-svc-clusterIP.png
                  https://github.com/Hakeemog/regtech/blob/screenshot/grafana-svc-loadbalancer.png
- The Grafana LoadBalancer is also exposed and the link accessed
  See response:  https://github.com/Hakeemog/regtech/blob/screenshot/grafana-ui.png
- Obtained the login password with the command. Note that the username is admin:                                                                                                          
  kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo              


