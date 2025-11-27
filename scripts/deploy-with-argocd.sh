#!/bin/bash
set -e

VERSION="${1:-latest}"
APP_NAME="fleet-app"

echo "🚀 Deploying version $VERSION via Argo CD"

# Simply update the image tag in Argo CD
kubectl patch app $APP_NAME -n argocd --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/source/helm/parameters/1",
    "value": {
      "name": "goApi.image.tag",
      "value": "'$VERSION'"
    }
  },
  {
    "op": "replace", 
    "path": "/spec/source/helm/parameters/2",
    "value": {
      "name": "nextjsFrontend.image.tag",
      "value": "'$VERSION'"
    }
  }
]'

echo "✅ Argo CD will deploy version: $VERSION"