#!/bin/bash
# Vault Setup Script for Investify
# Run this after Vault is deployed to configure secrets

set -e

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-root}"  # Dev mode token

echo "🔐 Vault Setup for Investify"
echo "============================"
echo "Vault Address: $VAULT_ADDR"
echo ""

# Check if vault CLI is available
if ! command -v vault &> /dev/null; then
    echo "❌ Vault CLI not found. Install it from https://www.vaultproject.io/downloads"
    echo ""
    echo "Alternatively, use kubectl to port-forward to Vault:"
    echo "  kubectl port-forward svc/vault -n vault 8200:8200"
    echo ""
    echo "Then run this script with:"
    echo "  VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=root ./setup-vault-secrets.sh"
    exit 1
fi

export VAULT_ADDR
export VAULT_TOKEN

# Enable KV v2 secrets engine if not already enabled
echo "📁 Enabling KV v2 secrets engine..."
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "   (already enabled)"

# Create Vault token secret in Kubernetes for ESO
echo "🔑 Creating Vault token secret in Kubernetes..."
kubectl create namespace vault 2>/dev/null || true
kubectl create secret generic vault-token \
    --namespace=vault \
    --from-literal=token="$VAULT_TOKEN" \
    --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "📝 Now let's add your Investify secrets to Vault"
echo "================================================"
echo ""

# Prompt for secrets
read -p "Enter APP_KEY (Laravel key, e.g., base64:xxx): " APP_KEY
read -p "Enter DB_HOST (e.g., db.xxx.supabase.co): " DB_HOST
read -p "Enter DB_PORT [5432]: " DB_PORT
DB_PORT="${DB_PORT:-5432}"
read -p "Enter DB_DATABASE [postgres]: " DB_DATABASE
DB_DATABASE="${DB_DATABASE:-postgres}"
read -p "Enter DB_USERNAME [postgres]: " DB_USERNAME
DB_USERNAME="${DB_USERNAME:-postgres}"
read -sp "Enter DB_PASSWORD: " DB_PASSWORD
echo ""
read -p "Enter DATABASE_URL (optional, press enter to skip): " DATABASE_URL

# Write secrets to Vault
echo ""
echo "💾 Writing secrets to Vault..."

# Production secrets
vault kv put secret/investify/production \
    APP_KEY="$APP_KEY" \
    DB_CONNECTION="pgsql" \
    DB_HOST="$DB_HOST" \
    DB_PORT="$DB_PORT" \
    DB_DATABASE="$DB_DATABASE" \
    DB_USERNAME="$DB_USERNAME" \
    DB_PASSWORD="$DB_PASSWORD" \
    DATABASE_URL="$DATABASE_URL"

echo "✅ Production secrets written to: secret/investify/production"

# Ask about staging/develop
read -p "Do you want to copy these secrets to staging and develop? [y/N]: " COPY_ENVS
if [[ "$COPY_ENVS" =~ ^[Yy]$ ]]; then
    vault kv put secret/investify/staging \
        APP_KEY="$APP_KEY" \
        DB_CONNECTION="pgsql" \
        DB_HOST="$DB_HOST" \
        DB_PORT="$DB_PORT" \
        DB_DATABASE="$DB_DATABASE" \
        DB_USERNAME="$DB_USERNAME" \
        DB_PASSWORD="$DB_PASSWORD" \
        DATABASE_URL="$DATABASE_URL"
    
    vault kv put secret/investify/develop \
        APP_KEY="$APP_KEY" \
        DB_CONNECTION="pgsql" \
        DB_HOST="$DB_HOST" \
        DB_PORT="$DB_PORT" \
        DB_DATABASE="$DB_DATABASE" \
        DB_USERNAME="$DB_USERNAME" \
        DB_PASSWORD="$DB_PASSWORD" \
        DATABASE_URL="$DATABASE_URL"
    
    echo "✅ Staging secrets written to: secret/investify/staging"
    echo "✅ Develop secrets written to: secret/investify/develop"
fi

echo ""
echo "🎉 Vault setup complete!"
echo ""
echo "Next steps:"
echo "1. Deploy Vault:              kubectl apply -f argocd/infrastructure/vault.yaml"
echo "2. Deploy External Secrets:   kubectl apply -f argocd/infrastructure/external-secrets.yaml"
echo "3. Deploy Investify:          kubectl apply -f argocd/apps/production/apps.yaml"
echo ""
echo "To verify secrets are synced:"
echo "  kubectl get externalsecret -n investify"
echo "  kubectl get secret investify-secrets -n investify -o yaml"
