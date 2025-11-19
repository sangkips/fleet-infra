#!/bin/bash

set -e

NAMESPACE="fleet"

# Read MongoDB Atlas connection string
echo "🔐 Enter MongoDB Atlas connection string:"
read -s MONGODB_URI

# Create secrets
kubectl create secret generic fleet-secrets \
  --namespace=$NAMESPACE \
  --from-literal=mongodb-uri="$MONGODB_URI" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secrets created successfully"