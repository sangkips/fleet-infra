#!/bin/bash
set -e

APP_NAME="${1:-fleet-production}"

echo "🔄 Syncing $APP_NAME..."

# Sync application
argocd app sync $APP_NAME

# Wait for sync to complete
argocd app wait $APP_NAME --health

echo "✅ $APP_NAME synced successfully!"