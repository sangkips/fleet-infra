#!/bin/bash
# Vault Setup Script for GlitchTip
# Run this to configure the GlitchTip secret key

set -e

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-root}"

echo "🔐 Vault Setup for GlitchTip"
echo "============================"
echo "Vault Address: $VAULT_ADDR"
echo ""

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl CLI not found."
    exit 1
fi

# Generate a random 50-character secret key for Django
SECRET_KEY=$(LC_ALL=C tr -dc 'a-zA-Z0-9!@#$%^&*()' < /dev/urandom | head -c 50 || true)
if [ -z "$SECRET_KEY" ]; then
    # Fallback to pure alphanumeric if tr fails on some systems
    SECRET_KEY=$(openssl rand -base64 40 | tr -dc 'a-zA-Z0-9' | head -c 50)
fi

echo "📝 Adding GlitchTip secrets to Vault"
echo "===================================="

# Write secret to Vault
echo "💾 Writing secret to Vault at secret/glitchtip/production..."

kubectl exec -i vault-0 -n vault -- vault kv put secret/glitchtip/production \
    SECRET_KEY="$SECRET_KEY"

echo "✅ GlitchTip secret written successfully."

echo ""
echo "🎉 Vault setup complete!"
echo "Next step: Deploy GlitchTip via ArgoCD"
echo "  kubectl apply -f argocd/infrastructure/glitchtip.yaml"
