# NAGP 2026 — Kubernetes, DevOps & FinOps Home Assignment
---

## 🔗 Important Links

| Resource | URL |
|---|---|
| **GitHub Repository** | https://github.com/shivani170293/nagp-k8s-assignment-shivani |
| **Docker Hub Image** | https://hub.docker.com/r/shivani170293/nagp-product-api |
| **API — All Products** | http://INGRESS_IP/api/products |
| **API — Health Check** | http://INGRESS_IP/api/health |
| **Screen Recording** | https://drive.google.com/YOUR_VIDEO_LINK |

> ⚠️ Replace `INGRESS_IP` with the actual external IP from:
> ```bash
> kubectl get svc ingress-nginx-controller -n ingress-nginx
> ```

---

## 🏗️ Architecture Overview

```
External User / Browser
        │
        │ HTTP request
        ▼
┌─────────────────────────┐
│   NGINX Ingress         │  ← External IP (GCP Load Balancer)
│   Controller            │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  product-api-service    │  ← Kubernetes Service (NodePort)
│  (NodePort :30080)      │
└────────────┬────────────┘
             │ Load balanced across 4 pods
     ┌───────┼───────┐───────┐
     ▼       ▼       ▼       ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│  API   │ │  API   │ │  API   │ │  API   │
│  Pod 1 │ │  Pod 2 │ │  Pod 3 │ │  Pod 4 │
│ :8080  │ │ :8080  │ │ :8080  │ │ :8080  │
└────────┘ └────────┘ └────────┘ └────────┘
     │           Spring Boot 3 / Java 17
     │     (Rolling Update | Self-Healing | HPA)
     │
     │ DNS: postgres-service (NOT pod IP)
     ▼
┌─────────────────────────┐
│  postgres-service       │  ← Kubernetes Service (ClusterIP)
│  (ClusterIP — internal) │     Internal only, no external access
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│   PostgreSQL Pod        │  ← 1 replica
│   postgres:15-alpine    │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│   PersistentVolumeClaim │  ← 1Gi storage
│   Data survives restart │     GKE Persistent Disk
└─────────────────────────┘
```

---

## 📁 Repository Structure

```
nagp-k8s-assignment-shivani/
├── src/
│   └── main/
│       ├── java/com/nagp/assignment/
│       │   ├── AssignmentApplication.java      # Spring Boot entry point
│       │   ├── controller/
│       │   │   └── ProductController.java      # REST endpoints
│       │   ├── model/
│       │   │   └── Product.java                # JPA Entity
│       │   ├── repository/
│       │   │   └── ProductRepository.java      # JPA Repository
│       │   └── config/
│       │       ├── DataSourceConfig.java       # HikariCP connection pool
│       └── resources/
│           └── application.properties
│           └── data.sql         
├── k8s/
│   ├── 00-namespace.yaml                       # nagp-app namespace
│   ├── 01-secret.yaml                          # DB password (base64)
│   ├── 02-configmap.yaml                       # DB host/port/name config
│   ├── 03-postgres-pvc.yaml                    # 1Gi PersistentVolumeClaim
│   ├── 04-postgres-deployment.yaml             # PostgreSQL + ClusterIP Service
│   ├── 05-api-deployment.yaml                  # Spring Boot API + NodePort Service
│   ├── 06-ingress.yaml                         # NGINX Ingress (external access)
│   └── 07-hpa.yaml                             # HorizontalPodAutoscaler
├── Dockerfile                                  # Multi-stage build
├── docker-compose.yml                          # Local testing
├── pom.xml
└── README.md
```

---

## ⚙️ Kubernetes Resources Summary

| Resource | Type | Purpose |
|---|---|---|
| `nagp-app` | Namespace | Isolates all resources |
| `db-secret` | Secret | Stores DB password (base64) |
| `db-config` | ConfigMap | DB host, port, name |
| `api-config` | ConfigMap | Spring profile, server port |
| `postgres-pvc` | PersistentVolumeClaim | 1Gi storage for DB data |
| `postgres` | Deployment | PostgreSQL, 1 replica |
| `postgres-service` | Service (ClusterIP) | Internal DB access only |
| `product-api` | Deployment | Spring Boot, 4 replicas |
| `product-api-service` | Service (NodePort) | Backend for Ingress |
| `api-ingress` | Ingress | External access via NGINX |
| `product-api-hpa` | HorizontalPodAutoscaler | Auto-scale 2–8 pods |

---

## 🚀 Deployment Guide

### Prerequisites
- GCP account with GKE cluster running
- `kubectl` connected to cluster
- `gcloud` CLI configured

### Deploy on GKE

```bash
# 1. Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# 2. Wait for NGINX to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# 3. Deploy all resources
kubectl apply -f k8s/

# 4. Watch pods come up
kubectl get pods -n nagp-app -w

# 5. Get Ingress IP
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

### Local Testing (Docker Compose)

```bash
docker compose up --build
curl http://localhost:8090/api/products
```

---

## 🎬 Screen Recording Demo Script

### 1️⃣ Show all objects deployed

```bash
kubectl get all -n nagp-app
```

### 2️⃣ API call retrieving records from database

```bash
curl http://INGRESS_IP/api/health
curl http://INGRESS_IP/api/products
```

### 3️⃣ Kill API pod — show self-healing

```bash
# Kill it
kubectl delete pod pod_name -n nagp-app

# Watch it regenerate
kubectl get pods -n nagp-app -w

# API still works!
curl http://INGRESS_IP/api/health
```

### 4️⃣ Kill database pod — show persistence

```bash
# Data before kill
curl http://INGRESS_IP/api/products

# Kill postgres pod

kubectl delete pod pod_name -n nagp-app

# Watch it regenerate
kubectl get pods -n nagp-app -w

# Data still there after restart!
curl http://INGRESS_IP/api/products
```

### 5️⃣ Rolling update demonstration

```bash
kubectl set image deployment/product-api \
  product-api=shivani170293/nagp-product-api:latest \
  -n nagp-app --record

kubectl rollout status deployment/product-api -n nagp-app
kubectl rollout history deployment/product-api -n nagp-app
```

### 6️⃣ HPA demonstration

```bash
kubectl get hpa -n nagp-app
kubectl describe hpa product-api-hpa -n nagp-app
```


## 💰 FinOps Optimizations

| # | Optimization | Implementation |
|---|---|---|
| 1 | Right-sized resource requests/limits | CPU: 100m–500m, Memory: 256Mi–512Mi per pod |
| 2 | HPA scales down at low load | minReplicas=4, maxReplicas=8 |
| 3 | Lightweight base images | `postgres:15-alpine`, `eclipse-temurin:17-jre` |
| 4 | Multi-stage Docker build | Only runtime artifacts in final image |
| 5 | Delete cluster after demo | Zero idle cost after submission |

---

## 🔧 Tech Stack

| Component | Technology |
|---|---|
| Microservice | Java 17 + Spring Boot 3.2 |
| Database | PostgreSQL 15 (Alpine) |
| Connection Pool | HikariCP |
| Container Runtime | Docker |
| Orchestration | Kubernetes (GKE Autopilot) |
| Ingress | NGINX Ingress Controller |
| Registry | Docker Hub |
| Cloud | Google Cloud Platform |
