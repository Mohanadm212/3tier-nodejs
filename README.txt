
# NTI DevOps Final Project

**Completion Date:** June 17, 2025

This project demonstrates an end-to-end DevOps pipeline using AWS Cloud services, Kubernetes, Jenkins, Prometheus, and Grafana. Below is the full documentation of all implemented steps.

---

## 1. Terraform Infrastructure Setup

-  **EKS Cluster**
  - Created an EKS Cluster with 2 worker nodes using an Auto Scaling Group.
  - Configured Load Balancer (ELB) for external access to services.

-  **RDS Instance**
  - Provisioned MySQL RDS instance.
  - Stored username/password credentials in **AWS Secrets Manager** securely.

-  **Jenkins EC2 Instance**
  - Launched an EC2 instance dedicated to Jenkins CI/CD server.

- **Jenkins Backup**
  - Configured **AWS Backup Service** for daily snapshot of Jenkins EC2.

-  **S3 Logging**
  - Created an S3 bucket to store **ELB access logs**.

-  **ECR Registry**
  - Set up AWS ECR to store Docker images for both frontend and backend services.

- **SonarQube EC2 Instance**
  - Created an EC2 instance for SonarQube to run static code analysis.


---

## 2. Ansible Configuration

-  **Jenkins Setup**
  - Used Ansible to:
    - Install Jenkins.
    - Configure Jenkins with initial setup and required plugins.

-  **CloudWatch Agent**
  - Installed CloudWatch Agent on all EC2 instances for centralized log and metric collection.

- **SonarQube Setup**
 - Install SonarQube on its EC2 instance, ensuring Java 11 is used and Docker is installed to support it

---

## 3. Docker

-  **Docker Images**
  - Built Docker images for:
    - `frontend`
    - `backend`

-  **Docker Compose**
  - Created `docker-compose.yml` for local development and testing of the full stack.

---

## 4. Kubernetes (EKS)

-  **Manifests**
  - Created full set of K8s manifests for:
    - Deployment
    - Service
    - ConfigMap
    - Ingress

-  **Helm Charts**
  - Created Helm charts to simplify deployment of frontend and backend.

-  **Network Policies**
  - Applied Kubernetes Network Policies to enforce security best practices between services.

---

## 5. Jenkins Pipeline (CI/CD)

-  **Multi-Branch Pipeline**
  - Configured Jenkins to detect all branches from GitHub and trigger builds on each push.

-  **Pipeline Stages:**
  1. Run **SonarQube** quality checks (pipeline fails if Quality Gate fails).
  2. Build the Docker image using `Dockerfile`.
  3. Scan the image with **Trivy** for security vulnerabilities.
  4. Push the image to **AWS ECR**.
  5. Deploy the updated image to **EKS** using **Helm**.

---

## 6. Monitoring with Prometheus & Grafana

-  **Prometheus Stack Deployment**
  - Installed `kube-prometheus-stack` via Helm in the `monitoring` namespace.

-  **Service Discovery**
  - Configured to monitor all pods and nodes automatically using Kubernetes service discovery.

-  **Alerts**
  - Defined alerting rules to notify when:
    - **CPU** usage > 80%
    - **Memory** usage > 80%

-  **Grafana Dashboard**
  - Set up a custom Grafana dashboard to visualize:
    - Pod status
    - Node resource usage (CPU & memory)
    - Restarts
    - App performance

---

## Access Points

- **Grafana** (port-forward or ELB):  
  `http://localhost:3000` 

- **Prometheus** (port-forward):  
  `http://localhost:9090`

---

## Project Highlights

✅ Fully Automated CI/CD  
✅ Secure Infrastructure  
✅ Production-ready Kubernetes Deployment  
✅ Real-Time Monitoring and Alerts  
✅ Infrastructure as Code (IaC) via Terraform and Ansible

---

## Authors
- **Mohanad** (DevOps Engineer)

