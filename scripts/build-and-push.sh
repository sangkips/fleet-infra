#!/bin/bash

set -e

# Configuration
DOCKERHUB_USER="sangkips"
GO_API_REPO="https://github.com/sangkips/vehicle-telematics"
NEXTJS_FRONTEND_REPO="https://github.com/sangkips/telematics"
TAG="${1:-latest}"

echo "🚀 Building and pushing Docker images with tag: $TAG"

# Build and push Go API
echo "📦 Building Go API..."
cd $GO_API_REPO
docker build -t $DOCKERHUB_USER/go-api:$TAG .
docker push $DOCKERHUB_USER/go-api:$TAG
echo "✅ Go API pushed successfully"

# Build and push Next.js frontend
echo "📦 Building Next.js frontend..."
cd $NEXTJS_FRONTEND_REPO
docker build -t $DOCKERHUB_USER/nextjs-frontend:$TAG .
docker push $DOCKERHUB_USER/nextjs-frontend:$TAG
echo "✅ Next.js frontend pushed successfully"

echo "🎉 All images built and pushed successfully!"