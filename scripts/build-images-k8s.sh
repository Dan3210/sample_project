#!/bin/bash

# Build and Load Docker Images for Kubernetes
# This script builds the images and loads them into Minikube

set -e

echo "🐳 Building and Loading Docker Images for Kubernetes"
echo "===================================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if minikube is running
if ! minikube status | grep -q "Running"; then
    print_status "Starting Minikube..."
    minikube start --driver=docker
fi

# Set docker environment to use minikube's docker daemon
print_status "Setting up Docker environment for Minikube..."
eval $(minikube docker-env)

# Build backend image
print_status "Building backend image..."
docker build -t sample-app-backend:latest ./backend
print_success "Backend image built"

# Build frontend image
print_status "Building frontend image..."
docker build -t sample-app-frontend:latest ./frontend
print_success "Frontend image built"

# Verify images are available
print_status "Verifying images..."
docker images | grep sample-app

print_success "All images built and loaded into Minikube!"
echo ""
echo "Next steps:"
echo "1. Run the Kubernetes test script: ./scripts/test-k8s.sh"
echo "2. Or manually apply resources: kubectl apply -f k8s/"
