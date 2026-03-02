# Expense Tracker — Kubernetes Deployment Guide

This guide covers how to build Docker images, deploy all resources, verify the pods, and access the Expense Tracker app on Kubernetes.

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| `docker` | Build container images |
| `kubectl` | Manage Kubernetes resources |
| `minikube` (or any K8s cluster) | Run a local cluster |

### Start Minikube
```bash
minikube start
```

---

## Step 1 — Build Docker Images

> If using **Minikube**, run the following first so Docker images are available inside the cluster:
> ```bash
> eval $(minikube docker-env)
> ```

Build both images from the project root (`Expense_Tracker_App/`):

```bash
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend
```

---

## Step 2 — Deploy to Kubernetes

Apply all manifests in the correct order:

```bash
# 1. Create the namespace first
kubectl apply -f k8s/namespace.yaml

# 2. Create ConfigMap + Secrets
kubectl apply -f k8s/app-config.yaml

# 3. Provision database storage
kubectl apply -f k8s/postgres-pv-pvc.yaml

# 4. Deploy the database
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml

# 5. Deploy the backend API
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

# 6. Deploy the frontend
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

Or apply everything at once:
```bash
kubectl apply -f k8s/
```

---

## Step 3 — Verify All Pods Are Running

```bash
kubectl get pods -n expense-tracker
```

Expected output (all pods should show `Running`):
```
NAME                                   READY   STATUS    RESTARTS
postgres-deployment-xxxx               1/1     Running   0
backend-deployment-xxxx                1/1     Running   0
frontend-deployment-xxxx               1/1     Running   0
```

Check services:
```bash
kubectl get services -n expense-tracker
```

---

## Step 4 — Access the App

### Using Minikube
```bash
minikube service frontend-service -n expense-tracker
```
This automatically opens the app in your browser.

### Using Node IP (any cluster)
```bash
# Get the node's external IP
kubectl get nodes -o wide
```
Then open: `http://<NODE_IP>:30000`

---

## Architecture Overview

```
Internet (port 30000)
       │
       ▼
frontend-service  [NodePort]
       │
       ▼
frontend-deployment  (React, port 3000)
       │  REACT_APP_API_URL → backend-service:5000
       ▼
backend-service   [ClusterIP]
       │
       ▼
backend-deployment   (Flask, port 5000)
       │  DATABASE_URL → postgres-service:5432
       ▼
postgres-service  [ClusterIP]
       │
       ▼
postgres-deployment  (PostgreSQL 13)
       │
       ▼
PersistentVolumeClaim (1Gi data persistence)
```

---

## Useful Debug Commands

```bash
# View logs for a pod
kubectl logs -n expense-tracker <pod-name>

# Describe a pod (events, errors)
kubectl describe pod -n expense-tracker <pod-name>

# Shell into a pod
kubectl exec -it -n expense-tracker <pod-name> -- /bin/sh
```

---

## Tear Down

```bash
kubectl delete namespace expense-tracker
kubectl delete pv postgres-pv
```

> **Note:** Deleting the namespace removes all pods, services, and claims. The PersistentVolume must be deleted separately as it is cluster-scoped.
