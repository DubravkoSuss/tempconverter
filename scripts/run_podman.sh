#!/bin/bash
# Task 4: Deploy app locally using podman
# Creates a pod with MySQL and tempconverter containers

set -e

POD_NAME="tempconverter-pod"
NETWORK="tempconverter-net"

echo "=== Deploying TempConverter locally with Podman ==="

# Create network
podman network create $NETWORK 2>/dev/null || echo "Network already exists"

# Start MySQL container
echo "Starting MySQL..."
podman run -d \
  --name tempconverter-db \
  --network $NETWORK \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=tempconverter \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  -v mysql_data:/var/lib/mysql \
  mysql:8

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
until podman exec tempconverter-db mysqladmin ping -h localhost --silent 2>/dev/null; do
  sleep 2
done
echo "MySQL is ready."

# Start app container
echo "Starting TempConverter app..."
podman run -d \
  --name tempconverter-app \
  --network $NETWORK \
  -p 5000:5000 \
  -e DB_USER=appuser \
  -e DB_PASS=apppass \
  -e DB_HOST=tempconverter-db \
  -e DB_NAME=tempconverter \
  -e STUDENT="Dubravko Posavac" \
  -e COLLEGE="Algebra Bernays University" \
  tempconverter:latest

echo ""
echo "=== Deployment complete ==="
echo "Application running at: http://localhost:5000"
echo ""
echo "Useful commands:"
echo "  podman ps                          # list running containers"
echo "  podman stats --no-stream           # resource usage"
echo "  podman logs tempconverter-app      # app logs"
echo "  podman stop tempconverter-app tempconverter-db  # stop"
echo "  podman rm tempconverter-app tempconverter-db    # remove"
