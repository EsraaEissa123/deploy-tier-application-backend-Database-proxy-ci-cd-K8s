# 🚀 3-Tier Application CI/CD Pipeline on Kubernetes

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%232C5263.svg?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Go](https://img.shields.io/badge/go-%2300ADD8.svg?style=for-the-badge&logo=go&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)

A complete **CI/CD pipeline** for deploying a **3-tier web application** (Backend, Database, Proxy) on **Kubernetes** using **Jenkins** for automated builds, testing, and deployments.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Technologies Used](#-technologies-used)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Installation & Setup](#-installation--setup)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Deployment](#-deployment)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Educational Outcomes](#-educational-outcomes)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Project Overview

This project demonstrates a **production-ready CI/CD pipeline** that:

- ✅ Runs **Jenkins as a Pod** inside Kubernetes (not as an external server)
- ✅ Uses **dynamic Jenkins agents** (Pods) for each pipeline stage
- ✅ Builds **Docker images** for Backend, Proxy, and Database
- ✅ Pushes images to **DockerHub**
- ✅ Deploys to **Kubernetes** with zero-downtime rolling updates
- ✅ Performs **automated smoke tests** after deployment
- ✅ Follows **cloud-native** and **DevOps** best practices

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                        │
│                                                              │
│  ┌──────────────┐      ┌──────────────┐                    │
│  │   Jenkins    │      │   Dev NS     │                    │
│  │  Namespace   │      │  Namespace   │                    │
│  │              │      │              │                    │
│  │ ┌──────────┐ │      │ ┌──────────┐ │                    │
│  │ │ Jenkins  │ │      │ │ Backend  │ │                    │
│  │ │ Master   │ │      │ │   Pod    │ │                    │
│  │ └──────────┘ │      │ └──────────┘ │                    │
│  │              │      │              │                    │
│  │ ┌──────────┐ │      │ ┌──────────┐ │                    │
│  │ │ Agent    │ │      │ │ Database │ │                    │
│  │ │ Pod (1)  │ │      │ │   Pod    │ │                    │
│  │ └──────────┘ │      │ └──────────┘ │                    │
│  │              │      │              │                    │
│  └──────────────┘      │ ┌──────────┐ │                    │
│                        │ │  Proxy   │ │                    │
│                        │ │   Pod    │ │                    │
│                        │ └──────────┘ │                    │
│                        └──────────────┘                    │
│                                                              │
│  GitHub Webhook ──────────► Jenkins Pipeline                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │                          │
         │                          │
         ▼                          ▼
    DockerHub                  Application
   (Registry)                   Accessible
```

### Application Components

1. **Backend (Go Application)**
   - REST API built with Go
   - Connects to MySQL database
   - Exposes `/health` endpoint for monitoring
   - Port: 8000

2. **Database (MySQL 8.0)**
   - Stores application data
   - Persistent storage using PVC
   - Secured with Kubernetes Secrets

3. **Proxy (Nginx)**
   - SSL/TLS termination
   - Routes traffic to backend
   - Load balancing
   - Port: 443 (HTTPS)

---

## 🛠️ Technologies Used

| Category | Technology | Version |
|----------|-----------|---------|
| **Container Orchestration** | Kubernetes | 1.28+ |
| **CI/CD** | Jenkins | 2.x |
| **Containerization** | Docker | 20.x+ |
| **Backend** | Go (Golang) | 1.21 |
| **Database** | MySQL | 8.0 |
| **Proxy** | Nginx | Alpine |
| **Package Manager** | Helm | 3.x |
| **Version Control** | Git/GitHub | - |
| **Registry** | DockerHub | - |

---

## 📦 Prerequisites

Before starting, ensure you have:

### Required Tools

```bash
# Kubernetes Cluster (Choose one)
- Minikube (Local)
- Kind (Local)
- EKS/GKE/AKS (Cloud)

# Command-line Tools
- kubectl (v1.28+)
- docker (v20+)
- helm (v3+)
- git (v2.30+)
```

### Accounts & Credentials

- ✅ GitHub account
- ✅ DockerHub account
- ✅ Kubernetes cluster with admin access

### System Requirements

- **CPU:** 4+ cores
- **RAM:** 8GB+ available
- **Disk:** 20GB+ free space

---

## 📂 Project Structure

```
.
├── backend/
│   ├── Dockerfile              # Backend container definition
│   ├── main.go                 # Go application code
│   ├── go.mod                  # Go dependencies
│   └── go.sum                  # Dependency checksums
│
├── nginx/
│   ├── Dockerfile              # Nginx proxy container
│   ├── nginx.conf              # Nginx configuration
│   ├── nginx-selfsigned.crt    # SSL certificate
│   └── nginx-selfsigned.key    # SSL private key
│
├── database/
│   └── init.sql                # Database initialization
│
├── k8s/
│   ├── backend-deployment.yaml # Backend K8s resources
│   ├── database-deployment.yaml # Database K8s resources
│   ├── proxy-deployment.yaml   # Proxy K8s resources
│   └── secrets.yaml            # Kubernetes Secrets
│
├── Jenkinsfile                 # CI/CD Pipeline definition
└── README.md                   # This file
```

---

## 🚀 Installation & Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/EsraaEissa123/deploy-tier-application-backend-Database-proxy-ci-cd-K8s.git
cd deploy-tier-application-backend-Database-proxy-ci-cd-K8s
```

### Step 2: Start Kubernetes Cluster

**Option A: Minikube (Recommended for local development)**

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --driver=docker

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

**Option B: Using existing cluster**

```bash
# Configure kubectl context
kubectl config use-context <your-cluster-context>

# Verify connectivity
kubectl get nodes
```

### Step 3: Create Namespaces

```bash
# Create Jenkins namespace
kubectl create namespace jenkins

# Create application namespace
kubectl create namespace dev

# Verify
kubectl get namespaces
```

### Step 4: Install Jenkins on Kubernetes

#### 4.1 Add Jenkins Helm Repository

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

#### 4.2 Install Jenkins using Helm

```bash
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=NodePort \
  --set controller.nodePort=32000 \
  --set controller.admin.username=admin \
  --set controller.admin.password=admin123 \
  --wait
```

#### 4.3 Access Jenkins

```bash
# Get Jenkins URL (Minikube)
minikube service jenkins -n jenkins

# Or get the NodePort URL
echo "http://$(minikube ip):32000"
```

**Login Credentials:**
- Username: `admin`
- Password: `admin123`

### Step 5: Configure Jenkins

#### 5.1 Install Required Plugins

Navigate to: **Manage Jenkins** → **Plugins** → **Available plugins**

Install these plugins:
- ✅ Kubernetes Plugin
- ✅ Docker Pipeline
- ✅ Git Plugin
- ✅ Pipeline Plugin
- ✅ Credentials Binding Plugin

Click **Install** and restart Jenkins.

#### 5.2 Add DockerHub Credentials

1. Go to: **Manage Jenkins** → **Credentials** → **(global)** → **Add Credentials**
2. Fill in:
   ```
   Kind: Username with password
   Scope: Global
   Username: <your-dockerhub-username>
   Password: <your-dockerhub-password-or-token>
   ID: docker-hub-esraa
   Description: DockerHub Login
   ```
3. Click **Create**

#### 5.3 Configure Kubernetes Cloud

1. Go to: **Manage Jenkins** → **Clouds** → **New cloud**
2. Name: `kubernetes`
3. Type: **Kubernetes**
4. Configure:
   ```
   Kubernetes URL: https://kubernetes.default.svc.cluster.local
   Kubernetes Namespace: jenkins
   Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
   Jenkins tunnel: jenkins-agent.jenkins.svc.cluster.local:50000
   ```
5. Click **Test Connection** → Should show "Connected to Kubernetes"
6. Click **Save**

### Step 6: Create Database Secret

```bash
# Create MySQL password secret
kubectl create secret generic mysql-secret \
  --from-literal=password=StrongP@ssw0rd2024 \
  -n dev

# Create db-secret (used by database deployment)
kubectl create secret generic db-secret \
  --from-literal=db-password=StrongP@ssw0rd2024 \
  -n dev

# Verify
kubectl get secrets -n dev
```

### Step 7: Deploy Initial Application Resources

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/ -n dev

# Verify deployments
kubectl get all -n dev
```

### Step 8: Create Jenkins Pipeline

1. In Jenkins Dashboard → **New Item**
2. Name: `3-tier-app-cicd`
3. Type: **Pipeline**
4. Click **OK**

**Configure Pipeline:**

- **General:**
  - ✅ GitHub project
  - Project URL: `https://github.com/EsraaEissa123/deploy-tier-application-backend-Database-proxy-ci-cd-K8s`

- **Build Triggers:**
  - ✅ Poll SCM
  - Schedule: `H/5 * * * *` (check every 5 minutes)

- **Pipeline:**
  - Definition: **Pipeline script from SCM**
  - SCM: **Git**
  - Repository URL: `https://github.com/EsraaEissa123/deploy-tier-application-backend-Database-proxy-ci-cd-K8s`
  - Branch: `*/main`
  - Script Path: `Jenkinsfile`

Click **Save**

---

## 🔄 CI/CD Pipeline

### Pipeline Stages

The `Jenkinsfile` defines a 5-stage pipeline:

```groovy
Pipeline Stages:
├── 📥 Checkout         # Pull code from GitHub
├── 🔨 Build Images     # Build Docker images
├── 📤 Push to DockerHub # Push images to registry
├── 🚀 Deploy to K8s    # Update deployments
└── 🧪 Smoke Test       # Health check verification
```

### Pipeline Flow Diagram

```
┌─────────────┐
│   GitHub    │
│   Commit    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Jenkins detects change (SCM Poll)  │
└──────────────┬──────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Create Jenkins Agent Pod            │
│  (docker, kubectl containers)        │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Stage 1: Checkout Code              │
│  - Clone repository                  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Stage 2: Build Docker Images        │
│  - Build backend:${BUILD_NUMBER}     │
│  - Build proxy:${BUILD_NUMBER}       │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Stage 3: Push to DockerHub          │
│  - Push backend images               │
│  - Push proxy images                 │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Stage 4: Deploy to Kubernetes       │
│  - kubectl set image (rolling update)│
│  - Wait for rollout completion       │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Stage 5: Smoke Test                 │
│  - curl http://backend-service:8000  │
│  - Verify 200 OK response            │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Cleanup & Notifications             │
│  - Delete agent pod                  │
│  - Send success/failure notification │
└──────────────────────────────────────┘
```

### Trigger Pipeline

**Manual Trigger:**
```bash
# In Jenkins UI
Click "Build Now"
```

**Automatic Trigger:**
```bash
# Make a code change and push to GitHub
git add .
git commit -m "Update application"
git push origin main

# Jenkins will automatically detect changes within 5 minutes
```

---

## 🌐 Deployment

### Access the Application

#### Get Application URL

```bash
# Get proxy service URL
minikube service proxy -n dev --url

# Or manually
echo "https://$(minikube ip):30001"
```

#### Test Backend API

```bash
# Health check
curl http://$(minikube ip):30001/health

# Get blog posts
curl http://$(minikube ip):30001/
```

**Expected Response:**
```json
["Blog post #0","Blog post #1","Blog post #2","Blog post #3","Blog post #4"]
```

### Verify Deployment

```bash
# Check pod status
kubectl get pods -n dev

# Check services
kubectl get svc -n dev

# Check deployments
kubectl get deployments -n dev

# View logs
kubectl logs deployment/backend-deployment -n dev
kubectl logs deployment/proxy-deployment -n dev
```

---

## 🧪 Testing

### Manual Smoke Test

```bash
# Test from inside cluster
kubectl run test-pod \
  --image=curlimages/curl \
  --rm -i --restart=Never \
  -n dev \
  -- curl -s http://backend-service:8000/
```

### Load Testing (Optional)

```bash
# Install hey (HTTP load generator)
# macOS
brew install hey

# Run load test
hey -n 1000 -c 10 http://$(minikube ip):30001/
```

### Database Connection Test

```bash
# Connect to MySQL
kubectl exec -it deployment/database-deployment -n dev -- mysql -u root -pStrongP@ssw0rd2024 -e "SHOW DATABASES;"
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### 1. Jenkins Pod Not Starting

```bash
# Check pod status
kubectl get pods -n jenkins

# View logs
kubectl logs -l app.kubernetes.io/name=jenkins -n jenkins

# Describe pod for events
kubectl describe pod -l app.kubernetes.io/name=jenkins -n jenkins
```

**Solution:** Ensure sufficient resources (CPU/Memory) are available.

#### 2. Backend Pod CrashLoopBackOff

```bash
# Check logs
kubectl logs deployment/backend-deployment -n dev

# Common causes:
# - Database connection refused
# - Wrong password
# - Missing secrets
```

**Solution:**
```bash
# Verify secrets exist
kubectl get secrets -n dev

# Check database is running
kubectl get pods -n dev -l app=database

# Verify service names match code
kubectl get svc -n dev
```

#### 3. Pipeline Fails at Build Stage

```bash
# Error: Dockerfile COPY path not found
```

**Solution:** Ensure Dockerfile uses relative paths:
```dockerfile
# ❌ Wrong
COPY backend/go.mod ./

# ✅ Correct
COPY go.mod go.sum ./
```

#### 4. Deployment Image Not Updating

```bash
# Force pod recreation
kubectl rollout restart deployment/backend-deployment -n dev
kubectl rollout restart deployment/proxy-deployment -n dev
```

#### 5. Smoke Test Fails

```bash
# Check backend service endpoint
kubectl get endpoints backend-service -n dev

# Test manually
kubectl run debug-pod --image=curlimages/curl -i --rm --restart=Never -n dev -- curl -v http://backend-service:8000/health
```

### Debugging Commands

```bash
# Get all resources in namespace
kubectl get all -n dev

# Describe deployment
kubectl describe deployment backend-deployment -n dev

# Get pod events
kubectl get events -n dev --sort-by='.lastTimestamp'

# Execute into pod
kubectl exec -it deployment/backend-deployment -n dev -- sh

# Port forward for local testing
kubectl port-forward svc/backend-service 8000:8000 -n dev
```

---

## 📚 Educational Outcomes

By completing this project, you will learn:

### DevOps Skills
- ✅ CI/CD pipeline design and implementation
- ✅ Infrastructure as Code (IaC) principles
- ✅ Automated testing and deployment strategies
- ✅ GitOps workflow

### Kubernetes
- ✅ Pod, Service, Deployment concepts
- ✅ Namespace isolation
- ✅ ConfigMaps and Secrets management
- ✅ Rolling updates and rollbacks
- ✅ Service discovery and networking

### Jenkins
- ✅ Jenkins on Kubernetes (cloud-native CI/CD)
- ✅ Pipeline as Code (Jenkinsfile)
- ✅ Dynamic agent provisioning
- ✅ Credentials management
- ✅ Plugin ecosystem

### Docker
- ✅ Multi-stage builds
- ✅ Image optimization
- ✅ Registry operations
- ✅ Container networking

### Best Practices
- ✅ Separation of concerns (3-tier architecture)
- ✅ Security (secrets, least privilege)
- ✅ Monitoring and health checks
- ✅ Scalability and high availability

---

## 🔐 Security Considerations

### Implemented Security Measures

1. **Secrets Management**
   - Database passwords stored in Kubernetes Secrets
   - DockerHub credentials in Jenkins credentials store
   - No hardcoded passwords in code

2. **Network Policies**
   - Namespace isolation
   - Service-to-service communication only within cluster

3. **RBAC**
   - Jenkins ServiceAccount with limited permissions
   - Principle of least privilege

4. **SSL/TLS**
   - HTTPS enabled on proxy
   - Self-signed certificates (replace with Let's Encrypt in production)

### Production Recommendations

```bash
# Use external secrets manager
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault

# Implement network policies
kubectl apply -f network-policies.yaml

# Enable Pod Security Standards
kubectl label namespace dev pod-security.kubernetes.io/enforce=baseline

# Use image scanning
trivy image esraaeissa81/backend:latest
```

---

## 🚀 Future Enhancements

- [ ] Add Prometheus monitoring
- [ ] Integrate Grafana dashboards
- [ ] Implement Horizontal Pod Autoscaling (HPA)
- [ ] Add integration tests
- [ ] Set up GitHub webhooks for instant triggers
- [ ] Implement blue-green deployments
- [ ] Add Slack/email notifications
- [ ] Use Helm charts for deployment
- [ ] Implement GitOps with ArgoCD
- [ ] Add log aggregation (ELK/Loki)

---

## 📖 References & Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Helm Documentation](https://helm.sh/docs/)

### Tutorials
- [Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/)
- [Jenkins Pipeline Tutorial](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)

---

## 👥 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Esraa Eissa**

- GitHub: [@EsraaEissa123](https://github.com/EsraaEissa123)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/your-profile)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- Jenkins Community for the Kubernetes plugin
- Kubernetes project and maintainers
- Docker community
- All contributors to open-source projects used

---

## 📊 Project Status

**Status:** ✅ Production Ready

**Last Updated:** November 2025

**Version:** 1.0.0

---

<div align="center">

### ⭐ If you found this project helpful, please give it a star!

Made with ❤️ by Esraa Eissa

</div>