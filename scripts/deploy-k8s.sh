#!/bin/bash

echo "Deploying to Kubernetes..."

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Deploy backend
kubectl apply -f k8s/backend-deployment.yaml

# Deploy frontend
kubectl apply -f k8s/frontend-deployment.yaml

# Create services
kubectl apply -f k8s/services.yaml

# Create ingress
kubectl apply -f k8s/ingress.yaml

# Create HPA
kubectl apply -f k8s/hpa.yaml

echo "Deployment completed!"
echo "Check status with: kubectl get all -n sample-app"


