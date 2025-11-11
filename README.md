
# 🌐 Three-Tier Blog API Deployment

This project demonstrates the deployment of a **robust three-tier Blog API system** using **Go**, **MySQL**, and **Nginx**, fully containerized with Docker and orchestrated using **Kubernetes (K8s)** for a production-like environment.

---

## 🏗️ Project Architecture

The application is structured into three distinct layers, ensuring **high cohesion** and **low coupling**:

| Tier | Component | Technology | Role | Access |
| :--- | :--- | :--- | :--- | :--- |
| **Backend** | Go API | Go 1.22+ | REST API server, handles business logic and serves blog titles. | Internal Port **8000** (HTTP) |
| **Database** | Data Storage | MySQL 8.0 | Persistent storage for blog data. Credentials managed via K8s **Secrets**. | Internal Port **3306** (TCP) |
| **Proxy** | Reverse Proxy | Nginx | Exposes the API securely over **HTTPS**, handles SSL termination, and routes traffic to the Backend. | External (NodePort **3xxxx**, HTTPS) |

---

## 🛠️ Prerequisites

You’ll need the following tools installed to build, deploy, and interact with the application:

* **Docker** – for building component images
* **Minikube / Kind** – local Kubernetes cluster environment
* **kubectl** – command-line tool for managing Kubernetes clusters
* **Go (1.22+)** – for building the backend API image

---

## 🚀 Local Deployment (Docker Compose)

For rapid development and testing, you can launch the entire stack using **Docker Compose**.

### 1️⃣ Generate a Self-Signed SSL Certificate

The Nginx proxy requires an SSL certificate. Run the provided script:

```bash
./nginx/generate-ssl.sh
````

### 2️⃣ Build and Run the Stack

Build the images and start all services:

```bash
docker-compose up --build -d
```

### 3️⃣ Access the Application

Once running, visit your local deployment via **HTTPS**. Because a self-signed certificate is used, you’ll need to accept the security warning in your browser.

-----

## ⚙️ Kubernetes Deployment

The full stack is deployed using declarative K8s manifests located in the `K8S/` directory.

### 🧩 Deployment Steps

#### 1️⃣ Start Minikube

```bash
minikube start
```

#### 2️⃣ Generate SSL Certificates & Build Docker Images

Make sure the images are built and accessible to Minikube:

```bash
eval $(minikube docker-env)
docker build -t project1/blog-backend:latest ./backend
docker build -t project1/blog-proxy:latest ./nginx
```

#### 3️⃣ Apply Database Secrets & Persistent Volume

```bash
kubectl apply -f K8S/db-secret.yaml
kubectl apply -f K8S/db-data-pv.yaml
kubectl apply -f K8S/db-data-pvc.yaml
```

#### 4️⃣ Deploy All Components

```bash
kubectl apply -f K8S/database_deployment.yaml
kubectl apply -f K8S/db_alias_service.yaml   # Fix for DNS alias (db)
kubectl apply -f K8S/db-service.yaml
kubectl apply -f K8S/backend_deployment.yaml
kubectl apply -f K8S/backend_service.yaml
kubectl apply -f K8S/proxy_deployment.yaml
kubectl apply -f K8S/proxy_nodeport.yaml
```

#### 5️⃣ Verify Pods

Wait until all pods show `READY 1/1` and `STATUS Running`:

```bash
kubectl get pods
```

-----

## 🌍 Accessing the Application

To access the deployed API via HTTPS:

1.  **Get the external URL of the proxy:**

    ```bash
    minikube service proxy-nodeport --url -n dev
    ```

2.  **Open the resulting URL in your browser (example):**

    ```
    [https://192.168.49.2:30443/](https://192.168.49.2:30443/)
    ```

> ⚠️ **You must use `https://`, not `http://`**

-----

## 💡 Key Learnings & Problem Solving

| Error / Challenge | Solution Implemented | Technical Detail |
| :--- | :--- | :--- |
| **Init Container Stuck (DB Wait)** | Corrected Service Selector Mismatch for DB. | الـ Pod يحمل Label `app: database` بينما الـ Service كان يبحث عن `app: database-deployment`. تم تعديل الـ Service ليطابق الـ Pod. |
| **Proxy Service Unreachable** | Corrected Service Selector Mismatch for Proxy. | تم تعديل الـ `proxy service` لتبحث عن الـ Label الصحيحة `app: blog-proxy` لضمان ربط الـ Pods بالخدمة وإظهار Endpoints. |
| **Database Connection Failure** | Created a service alias for the database. | Go backend expected hostname `db`, but service was named `db-service`. Added a ClusterIP alias service named `db`. |
| **502 Bad Gateway / 400 Bad Request** | Corrected Nginx proxy configuration. | Ensured `proxy_pass http://backend;` used **HTTP** (not HTTPS) for internal communication on port **8000**. |
| **Client Protocol Mismatch** | Enforced client-side HTTPS. | Nginx only listens on its HTTPS port. Client must use `https://` to establish SSL handshake. |
| **SSL Certificate Problem (Testing)** | Used insecure flag for testing. | Testing with `curl` on HTTPS required the `-k` (insecure) flag to bypass the self-signed certificate warning. |

-----

## 🧠 Summary

This project showcases a production-grade three-tier architecture, including:

  * ✅ **Secure communication** using Nginx HTTPS reverse proxy
  * ✅ **Persistent MySQL storage** with Kubernetes PV/PVC
  * ✅ **Resilient Go backend API** with environment-based configuration
  * ✅ **Modular and scalable** Kubernetes deployment

<!-- end list -->

```
```