# TempConverter DevOps Project

## Project Overview
Containerization and deployment of the tempconverter application using multiple orchestration systems.

## Task 1: Container Image

### Build the image
```bash
cd tempconverter
docker build -t tempconverter:latest .
```

### Verify the image
```bash
docker images | grep tempconverter
```

## Task 2: Push to Registry

### Docker Hub
```bash
docker login
docker tag tempconverter:latest YOUR_USERNAME/tempconverter:latest
docker push YOUR_USERNAME/tempconverter:latest
```

### Alternative: GitHub Container Registry
```bash
docker tag tempconverter:latest ghcr.io/YOUR_USERNAME/tempconverter:latest
docker push ghcr.io/YOUR_USERNAME/tempconverter:latest
```

## Task 3: Update Title and Create Dev Image

### Edit templates/index.html
Change line 4 from:
```html
<title>Celsius to Fahrenheit Converter</title>
```
to:
```html
<title>TempConverter</title>
```

### Build and push dev image
```bash
docker build -t tempconverter:dev .
docker tag tempconverter:dev YOUR_USERNAME/tempconverter:dev
docker push YOUR_USERNAME/tempconverter:dev
```

## Task 4: Local Deployment with Podman

### Using podman-compose
```bash
# Build image
podman build -t tempconverter:latest .

# Deploy with podman-compose
podman-compose -f podman-compose.yml up -d

# Check status
podman ps

# View logs
podman logs tempconverter_app_1
```

### Manual deployment
```bash
# Create network
podman network create tempconverter-net

# Start MySQL
podman run -d --name mysql \
  --network tempconverter-net \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=tempconverter \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  -v mysql_data:/var/lib/mysql \
  mysql:8

# Wait for MySQL to be ready
sleep 30

# Start application
podman run -d --name tempconverter \
  --network tempconverter-net \
  -p 5000:5000 \
  -e DB_USER=appuser \
  -e DB_PASS=apppass \
  -e DB_HOST=mysql \
  -e DB_NAME=tempconverter \
  -e STUDENT="Josip Stanešić" \
  -e COLLEGE="Algebra Bernays University" \
  tempconverter:latest
```

### Resource Usage Comparison: Container vs VM

| Resource | Container | VM (Typical) |
|----------|-----------|--------------|
| Memory | 50-150 MB | 512 MB - 2 GB |
| CPU | Shared, minimal overhead | Dedicated vCPUs |
| Disk | ~200 MB (image) | 10+ GB |
| Boot time | Seconds | Minutes |
| Isolation | Process-level | Hardware-level |

**Measuring resource usage:**
```bash
# Container stats
podman stats

# VM stats (if using VirtualBox)
VBoxManage metrics collect

# Compare memory usage
podman stats --no-stream
```

### CI/CD Pipeline
The project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that:
1. Runs unit tests on every push
2. Builds the container image
3. Tags images appropriately

## Task 5: Container Orchestration Choice

### Simple: Docker Swarm
**Why Docker Swarm?**
- Native Docker integration
- Simple setup and configuration
- Built-in load balancing
- Easy scaling with `docker service scale`
- Good for small to medium deployments

### Complex: Kubernetes
**Why Kubernetes?**
- Industry standard for container orchestration
- Advanced scheduling and self-healing
- Horizontal Pod Autoscaling
- Rich ecosystem (Helm, Operators)
- Better for production workloads

## Task 6: Docker Swarm Deployment

### Initialize Swarm
```bash
docker swarm init
```

### Deploy stack
```bash
docker stack deploy -c docker-stack.yml tempconverter
```

### Verify deployment
```bash
docker stack services tempconverter
docker service ps tempconverter_app
```

### Scale to 3 replicas
```bash
docker service scale tempconverter_app=3
```

### Access application
- Application: http://localhost
- Visualizer: http://localhost:8080

## Task 7 & 8: Kubernetes Deployment

### Apply all manifests
```bash
kubectl apply -f kubernetes/
```

### Or apply individually
```bash
kubectl apply -f kubernetes/mysql-secret.yaml
kubectl apply -f kubernetes/mysql-pvc.yaml
kubectl apply -f kubernetes/mysql-deployment.yaml
kubectl apply -f kubernetes/mysql-service.yaml
kubectl apply -f kubernetes/app-deployment.yaml
kubectl apply -f kubernetes/app-service.yaml
```

### Verify deployment
```bash
kubectl get pods
kubectl get services
kubectl logs -l app=tempconverter
```

### Scale to 3 replicas
```bash
kubectl scale deployment tempconverter --replicas=3
```

### Access application
```bash
# Get external IP (for cloud providers)
kubectl get service tempconverter

# For local testing (minikube)
minikube service tempconverter

# Port forwarding
kubectl port-forward service/tempconverter 8080:80
```

## OpenShift Deployment

### Using template
```bash
oc process -f kubernetes/openshift-template.yaml | oc apply -f -
```

### Or using oc new-app
```bash
oc new-app mysql:8 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=tempconverter \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass

oc new-app tempconverter:latest \
  -e DB_USER=appuser \
  -e DB_PASS=apppass \
  -e DB_HOST=mysql \
  -e DB_NAME=tempconverter \
  -e STUDENT="Josip Stanešić" \
  -e COLLEGE="Algebra Bernays University"

oc expose service/tempconverter
```

## Task 9: Reflection

### Docker Swarm
**Pros:**
- Easy to learn and use
- Native Docker integration
- Simple YAML configuration
- Good for development and small teams

**Cons:**
- Limited features compared to Kubernetes
- Smaller ecosystem
- Less community support

**Best for:** Small teams, development environments, simple applications

### Kubernetes
**Pros:**
- Industry standard
- Rich feature set
- Self-healing and auto-scaling
- Large ecosystem (Helm, Operators)
- Multi-cloud support

**Cons:**
- Steep learning curve
- Complex setup and maintenance
- Resource overhead

**Best for:** Production workloads, large teams, complex microservices

## Troubleshooting

### Database connection issues
```bash
# Check MySQL is running
kubectl logs -l app=mysql

# Check secrets
kubectl get secrets mysql-secret -o yaml

# Test connection from app pod
kubectl exec -it <app-pod> -- mysql -h mysql -u appuser -p
```

### Application not starting
```bash
# Check logs
kubectl logs -l app=tempconverter

# Check environment variables
kubectl exec -it <pod> -- env | grep DB
```

### Scaling issues
```bash
# Check node resources
kubectl describe nodes

# Check pod scheduling
kubectl get events --sort-by='.lastTimestamp'
```

## File Structure
```
tempconverter/
├── Dockerfile                    # Container image definition
├── docker-compose.yml            # Docker Compose for local dev
├── podman-compose.yml            # Podman Compose for local dev
├── docker-stack.yml              # Docker Swarm stack
├── kubernetes/
│   ├── mysql-secret.yaml         # MySQL credentials
│   ├── mysql-pvc.yaml            # Persistent storage
│   ├── mysql-deployment.yaml     # MySQL deployment
│   ├── mysql-service.yaml        # MySQL service
│   ├── app-deployment.yaml       # App deployment
│   ├── app-service.yaml          # App service
│   └── openshift-template.yaml   # OpenShift template
├── tests/
│   └── test_app.py               # Unit and integration tests
├── .github/
│   └── workflows/
│       └── ci.yml                # CI/CD pipeline
├── app.py                        # Flask application
├── requirements.txt              # Python dependencies
└── templates/
    └── index.html                # HTML template
```
