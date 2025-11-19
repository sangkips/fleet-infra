#!/bin/bash
set -e

NAMESPACE="fleet"

echo "🔐 Setting up Kubernetes secrets..."

# First, create the namespace if it doesn't exist
echo "📁 Creating namespace $NAMESPACE if it doesn't exist..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Read MongoDB Atlas connection string securely
echo "Enter MongoDB Atlas connection string:"
read -s MONGODB_URI

# Create or update secrets in the correct namespace
kubectl create secret generic app-secrets \
  --namespace=$NAMESPACE \
  --from-literal=mongodb-uri="$MONGO_URI" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secrets configured successfully in namespace: $NAMESPACE"

# Verify the secret was created
echo "🔍 Verifying secret creation..."
kubectl get secrets -n $NAMESPACE