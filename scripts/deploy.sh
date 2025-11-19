#!/bin/bash

set -e

# Configuration
RELEASE_NAME="fleet"
NAMESPACE="fleet"
CHART_PATH="../charts/fleet"
VALUES_FILE="values-production.yaml"
TAG="${1:-latest}"

echo "🚀 Deploying $RELEASE_NAME to namespace: $NAMESPACE"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy using Helm
helm upgrade --install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --values $CHART_PATH/$VALUES_FILE \
  --set goApi.image.tag=$TAG \
  --set nextjsFrontend.image.tag=$TAG \
  --wait \
  --timeout 10m

echo "✅ Deployment completed!"

# Display status
echo "📊 Deployment status:"
kubectl get pods -n $NAMESPACE
echo ""
echo "🌐 Services:"
kubectl get services -n $NAMESPACE
echo ""
echo "🔗 Ingress:"
kubectl get ingress -n $NAMESPACE