#!/bin/bash

echo "Starting containers..."

# Create a custom network
docker network create app-network 2>/dev/null || echo "Network already exists"

# Start backend container
echo "Starting backend..."
docker run -d --name backend \
  --network app-network \
  -p 4000:4000 \
  -v $(pwd)/backend/data:/app/data \
  sample-app-backend:latest

# Wait a moment for backend to start
sleep 3

# Start frontend container
echo "Starting frontend..."
docker run -d --name frontend \
  --network app-network \
  -p 3000:80 \
  sample-app-frontend:latest

echo "Containers started!"
echo "Frontend: http://localhost:3000"
echo "Backend API: http://localhost:4000/api/items"
echo ""
echo "To stop containers:"
echo "docker stop frontend backend"
echo "docker rm frontend backend"
