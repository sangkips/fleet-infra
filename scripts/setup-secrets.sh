#!/bin/bash
set -e

NAMESPACE="fleet"
SECRET_NAME="app-secrets"

echo "🔐 Setting up Kubernetes secrets in namespace: $NAMESPACE"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Read all required environment variables
echo "Enter MongoDB Atlas connection string:"
read -s MONGO_URI

echo "Enter JWT Secret:"
read -s JWT_SECRET

echo "Enter Redis URL (or press enter to disable Redis):"
read -s REDIS_URL

# Set domains for CORS
ALLOWED_ORIGINS="https://telematics.autoscaleops.com,https://api.autoscaleops.com,http://localhost:3000,http://localhost:5173"

echo "Using ALLOWED_ORIGINS: $ALLOWED_ORIGINS"

# Set defaults if empty
if [ -z "$REDIS_URL" ]; then
    REDIS_URL="redis://localhost:6379"
fi

echo "🛠️ Creating/updating secret with all required variables..."
kubectl create secret generic $SECRET_NAME \
  --namespace=$NAMESPACE \
  --from-literal=mongodb-uri="$MONGODB_URI" \
  --from-literal=jwt-secret="$JWT_SECRET" \
  --from-literal=redis-url="$REDIS_URL" \
  --from-literal=allowed-origins="$ALLOWED_ORIGINS" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secret '$SECRET_NAME' created/updated successfully!"