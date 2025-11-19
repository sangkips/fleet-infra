#!/bin/bash
set -e

RELEASE_NAME="fleet"                    
NAMESPACE="fleet"                      
CHART_DIR="./charts/fleet"             
TAG="${1:-latest}"
DOCKERHUB_USER="sangkips"

echo "🚀 Starting deployment process..."
echo "📦 Using image tag: $TAG"
echo "📁 Chart directory: $CHART_DIR"
echo "🏷️  Release name: $RELEASE_NAME"
echo "📛 Namespace: $NAMESPACE"

# Verify chart directory exists
if [ ! -d "$CHART_DIR" ]; then
    echo "❌ Error: Chart directory not found at $CHART_DIR"
    echo "📂 Current directory: $(pwd)"
    echo "📂 Available charts: $(ls -la charts/)"
    exit 1
fi

# Pull latest images from DockerHub
echo "📥 Pulling latest Docker images..."
docker pull $DOCKERHUB_USER/fleet-go-backend:$TAG || echo "⚠️  Could not pull go-api image, will use existing"
docker pull $DOCKERHUB_USER/fleet-nextjs-frontend:$TAG || echo "⚠️  Could not pull nextjs-frontend image, will use existing"

# Create namespace if it doesn't exist
echo "📁 Ensuring namespace exists..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Verify we can access the cluster
echo "🔧 Checking cluster access..."
kubectl cluster-info

# Deploy using Helm
echo "🛠️  Deploying with Helm..."
echo "📋 Helm command: helm upgrade --install $RELEASE_NAME $CHART_DIR --namespace $NAMESPACE --set goApi.image.tag=$TAG --set nextjsFrontend.image.tag=$TAG --wait --timeout 10m"

helm upgrade --install $RELEASE_NAME $CHART_DIR \
  --namespace $NAMESPACE \
  --set goApi.image.tag=$TAG \
  --set nextjsFrontend.image.tag=$TAG \
  --timeout 10m

echo "✅ Deployment completed successfully!"

# Display status
echo ""
echo "📊 Current deployment status:"
kubectl get pods -n $NAMESPACE

echo ""
echo "🌐 Services:"
kubectl get services -n $NAMESPACE

echo ""
echo "🔗 Ingress:"
kubectl get ingress -n $NAMESPACE

echo ""
echo "🎉 Deployment complete! Your app should be available soon."