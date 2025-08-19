#!/bin/bash

echo "Building Docker images..."

# Build backend image
echo "Building backend image..."
docker build -t sample-app-backend:latest ./backend

# Build frontend image
echo "Building frontend image..."
docker build -t sample-app-frontend:latest ./frontend

echo "Images built successfully!"
echo "Backend: sample-app-backend:latest"
echo "Frontend: sample-app-frontend:latest"


