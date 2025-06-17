# NTI DevOps Final Project - Full Documentation

**Project Completion Date: June 17, 2025  
**Done by:** Mohanad Mahmoud  

This document provides a comprehensive, step-by-step overview of the NTI  Final Project (end to end 3tier-nodejs). It covers Infrastructure as Code using Terraform and Ansible, containerization with Docker, orchestration via Kubernetes on AWS EKS, CI/CD with Jenkins, static analysis using SonarQube, security scanning using Trivy, and monitoring via Prometheus and Grafana.

---

## 1. Terraform: Infrastructure Provisioning

### 1.1 EKS Cluster
- Created an **EKS cluster** with two worker nodes using `aws_eks_cluster`, `aws_eks_node_group`.
- Configured nodes via **Auto Scaling Group** to handle dynamic load.
- Used **AWS IAM roles** for service and node permissions.
- Output the EKS cluster endpoint and kubeconfig.

### 1.2 Load Balancer (ELB)
- Provisioned a **Kubernetes LoadBalancer service**.
- Configured **access logging** to send logs to an S3 bucket.

### 1.3 RDS (MySQL) + Secrets Manager
- Created an **RDS MySQL instance** with subnet group, security groups, and backups enabled.
- Stored database **credentials in AWS Secrets Manager**.

### 1.4 Jenkins EC2
- Launched a **dedicated EC2 instance** for Jenkins.
- Enabled inbound rules for SSH and Jenkins (port 8080).
- Created an **AWS Backup Vault** and plan to snapshot Jenkins EC2 daily.

### 1.5 SonarQube EC2
- Provisioned a separate **EC2 instance for SonarQube**.
- Configured with Java 11 and Docker runtime (Ansible-managed).

### 1.6 ECR (Elastic Container Registry)
- Created two ECR repositories for:
  - `frontend`
  - `backend`
- Configured IAM policies for Jenkins to push to ECR.

### 1.7 S3 Bucket
- Created a secure **S3 bucket** to store **ELB access logs**.

---

## 2. Ansible: Server Configuration and Automation

### 2.1 Jenkins Setup
- Used an Ansible playbook to:
  - Install Jenkins (latest LTS).
  - Add Jenkins repository, install Java, and start Jenkins service.
  - Configure plugins (Git, Blue Ocean, Docker, SonarQube, etc.).
  - Open required firewall ports.

### 2.2 CloudWatch Agent
- Installed **CloudWatch Agent** on all EC2 instances (Jenkins, SonarQube, etc.).
- Configured log collection and metric streaming to CloudWatch.

### 2.3 SonarQube Setup
- Installed:
  - **Java 11** using `adoptopenjdk`.
  - **Docker** and started the daemon.
- Pulled and ran SonarQube Docker image.
- Ensured service persistence and port configuration.

---

## 3. Docker: Application Containerization

### 3.1 Docker Images
- Built custom Docker images for:
  - `frontend` (React)
  - `backend` (Node.js)
- Added `.dockerignore` and optimized multi-stage builds.

### 3.2 Docker Compose
- Created `docker-compose.yml` to:
  - Run full app stack locally.
  - Link backend, frontend, and any databases.

---

## 4. Kubernetes (EKS): Deployment and Networking

### 4.1 Kubernetes Manifests
- Created manifests for:
  - **Deployments** (frontend, backend)
  - **Services** (ClusterIP, LoadBalancer)
  - **ConfigMaps** (for app environment configs)
  - **Ingress** (ALB Ingress Controller)

### 4.2 Helm Charts
- Developed custom Helm charts:
  - Parameterized `values.yaml`
  - Used `templates/` for deployments and services
  - Managed Helm releases via Jenkins

### 4.3 Network Policies
- Applied **Kubernetes NetworkPolicies** to:
  - Restrict traffic between frontend and backend only.
  - Deny external access to internal services.

---

## 5. Jenkins: CI/CD Pipeline

### 5.1 Multi-Branch Pipeline
- Configured Jenkins with:
  - **GitHub webhook integration**
  - **Multibranch Pipeline Job**
  - Jenkinsfile stored in repo root

### 5.2 Jenkinsfile Stages:
1. **SonarQube Analysis**
   - `sonar-scanner` used
   - Pipeline halts on failing quality gate

2. **Docker Build**
   - Builds image using Dockerfile in repo

3. **Trivy Scan**
   - Security scan for known CVEs
   - Results published to Jenkins

4. **Push to ECR**
   - Jenkins authenticates using IAM role or AWS credentials plugin

5. **Deploy via Helm**
   - Updates Helm release with new image tag
   - Uses `helm upgrade` to apply changes

---

## 6. Monitoring: Prometheus and Grafana

### 6.1 Prometheus Stack
- Installed via **Helm `kube-prometheus-stack`**
- Includes:
  - Prometheus
  - Grafana
  - Node Exporter
  - Kube State Metrics

### 6.2 Service Discovery
- Enabled **auto-discovery** for pods, nodes, services.
- Added custom annotations for better visibility.

### 6.3 Alerts
- Created alert rules:
  - CPU usage > 80%
  - Memory usage > 80%


### 6.4 Grafana Dashboard
- Created dashboards with panels for:
  - Pod health & restarts
  - CPU and memory usage
  - Request latency
  - Uptime metrics

---

## Access Points

| Service     | Access Method           | URL                              |
|-------------|-------------------------|-----------------------------------|
| Jenkins     | EC2 Public IP + Port    | `http://<ec2-ip>:8080`           |
| SonarQube   | EC2 Public IP + Port    | `http://<ec2-ip>:9000`           |
| Grafana     | Port Forward/ELB        | `http://localhost:3000`          |
| Prometheus  | Port Forward            | `http://localhost:9090`

---

## Final Summary

| Component     | Tool                | Purpose                                         |
|---------------|---------------------|--------------------------------------------------|
| IaC           | Terraform, Ansible  | Provision AWS infra, configure EC2              |
| CI/CD         | Jenkins              | Automate build, scan, and deployment             |
| Code Quality  | SonarQube            | Ensure code passes quality gates                 |
| Security      | Trivy                | Detect container image vulnerabilities           |
| Containerization | Docker           | Build and run application containers             |
| Orchestration | Kubernetes (EKS)     | Run and manage microservices                    |
| Monitoring    | Prometheus, Grafana  | Observe system and raise alerts on thresholds    |

---

## Author
**Mohanad Mahmoud**  
DevOps Engineer  
June 2025
