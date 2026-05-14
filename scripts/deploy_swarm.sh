#!/bin/bash

# Docker Swarm Deployment Script

echo "=== Deploying TempConverter to Docker Swarm ==="

# Check if swarm is initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "Initializing Docker Swarm..."
    docker swarm init
fi

# Deploy the stack
echo "Deploying stack..."
docker stack deploy -c docker-stack.yml tempconverter

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Show service status
echo ""
echo "=== Service Status ==="
docker stack services tempconverter

echo ""
echo "=== Scaling Instructions ==="
echo "To scale app to 3 replicas:"
echo "  docker service scale tempconverter_app=3"
echo ""
echo "To view running tasks:"
echo "  docker service ps tempconverter_app"
echo ""
echo "Access the application at: http://localhost"
echo "Access the visualizer at: http://localhost:8080"
