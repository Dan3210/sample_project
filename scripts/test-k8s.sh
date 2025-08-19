#!/bin/bash

# Kubernetes Testing Script for Sample App
# This script helps test the Kubernetes deployment

set -e

echo "🚀 Starting Kubernetes Testing for Sample App"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if cluster is accessible
print_status "Checking cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please ensure your cluster is running."
    exit 1
fi
print_success "Cluster is accessible"

# Check if namespace exists
print_status "Checking if namespace 'sample-app' exists..."
if kubectl get namespace sample-app &> /dev/null; then
    print_success "Namespace 'sample-app' exists"
else
    print_warning "Namespace 'sample-app' does not exist. Creating it..."
    kubectl apply -f k8s/namespace.yaml
    print_success "Namespace created"
fi

# Apply all Kubernetes resources
print_status "Applying Kubernetes resources..."
kubectl apply -f k8s/
print_success "Resources applied"

# Wait for deployments to be ready
print_status "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n sample-app
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n sample-app
print_success "Deployments are ready"

# Check pod status
print_status "Checking pod status..."
echo ""
kubectl get pods -n sample-app
echo ""

# Check services
print_status "Checking services..."
echo ""
kubectl get services -n sample-app
echo ""

# Check ingress
print_status "Checking ingress..."
echo ""
kubectl get ingress -n sample-app
echo ""

# Check configmap
print_status "Checking configmap..."
echo ""
kubectl get configmap -n sample-app
echo ""

# Test backend service
print_status "Testing backend service..."
BACKEND_POD=$(kubectl get pods -n sample-app -l app=backend -o jsonpath='{.items[0].metadata.name}')
if [ -n "$BACKEND_POD" ]; then
    print_status "Backend pod: $BACKEND_POD"
    kubectl exec -n sample-app $BACKEND_POD -- curl -s http://localhost:4000/api/items || print_warning "Backend health check failed"
else
    print_error "No backend pod found"
fi

# Test frontend service
print_status "Testing frontend service..."
FRONTEND_POD=$(kubectl get pods -n sample-app -l app=frontend -o jsonpath='{.items[0].metadata.name}')
if [ -n "$FRONTEND_POD" ]; then
    print_status "Frontend pod: $FRONTEND_POD"
    kubectl exec -n sample-app $FRONTEND_POD -- curl -s http://localhost:80/ || print_warning "Frontend health check failed"
else
    print_error "No frontend pod found"
fi

# Get service URLs (for Minikube)
print_status "Getting service URLs..."
echo ""
if command -v minikube &> /dev/null; then
    print_status "Minikube detected. Getting service URLs..."
    FRONTEND_URL=$(minikube service frontend-service -n sample-app --url 2>/dev/null || echo "Service not accessible via minikube")
    print_status "Frontend URL: $FRONTEND_URL"
    
    # Test external access
    if [ "$FRONTEND_URL" != "Service not accessible via minikube" ]; then
        print_status "Testing external frontend access..."
        curl -s "$FRONTEND_URL" | head -20 || print_warning "External frontend access failed"
    fi
fi

# Check resource usage
print_status "Checking resource usage..."
echo ""
kubectl top pods -n sample-app 2>/dev/null || print_warning "Metrics server not available"

# Check logs for any errors
print_status "Checking recent logs for errors..."
echo ""
kubectl logs -n sample-app -l app=backend --tail=10 | grep -i error || print_success "No recent backend errors"
kubectl logs -n sample-app -l app=frontend --tail=10 | grep -i error || print_success "No recent frontend errors"

# Check events
print_status "Checking recent events..."
echo ""
kubectl get events -n sample-app --sort-by='.lastTimestamp' | tail -10

echo ""
echo "🎉 Kubernetes Testing Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Access your application:"
echo "   - Frontend: $FRONTEND_URL"
echo "   - Or use: kubectl port-forward -n sample-app service/frontend-service 8080:80"
echo ""
echo "2. Monitor your application:"
echo "   - kubectl get pods -n sample-app -w"
echo "   - kubectl logs -n sample-app -l app=backend -f"
echo "   - kubectl logs -n sample-app -l app=frontend -f"
echo ""
echo "3. Scale your application:"
echo "   - kubectl scale deployment backend -n sample-app --replicas=5"
echo "   - kubectl scale deployment frontend -n sample-app --replicas=3"
echo ""
echo "4. Clean up:"
echo "   - kubectl delete -f k8s/"
echo "   - minikube stop"
