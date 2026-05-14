#!/bin/bash

# Kubernetes Deployment Script

echo "=== Deploying TempConverter to Kubernetes ==="

# Create namespace (optional)
# kubectl create namespace tempconverter

# Apply all manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f kubernetes/mysql-secret.yaml
kubectl apply -f kubernetes/mysql-pvc.yaml
kubectl apply -f kubernetes/mysql-deployment.yaml
kubectl apply -f kubernetes/mysql-service.yaml

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
kubectl rollout status deployment/mysql --timeout=120s

# Deploy application
kubectl apply -f kubernetes/app-deployment.yaml
kubectl apply -f kubernetes/app-service.yaml

# Wait for app to be ready
echo "Waiting for application to be ready..."
kubectl rollout status deployment/tempconverter --timeout=120s

# Show status
echo ""
echo "=== Deployment Status ==="
kubectl get pods
kubectl get services

echo ""
echo "=== Scaling Instructions ==="
echo "To scale app to 3 replicas:"
echo "  kubectl scale deployment tempconverter --replicas=3"
echo ""
echo "To access the application:"
echo "  kubectl port-forward service/tempconverter 8080:80"
echo "  Then open: http://localhost:8080"
