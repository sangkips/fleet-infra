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

if ! command -v vault &> /dev/null; then
    echo "❌ Vault CLI not found."
    echo "Use kubectl to port-forward to Vault first:"
    echo "  kubectl port-forward svc/vault -n vault 8200:8200"
    echo ""
    echo "Then run this script with:"
    echo "  VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=root ./setup-glitchtip-vault.sh"
    exit 1
fi

export VAULT_ADDR
export VAULT_TOKEN

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

vault kv put secret/glitchtip/production \
    SECRET_KEY="$SECRET_KEY"

echo "✅ GlitchTip secret written successfully."

echo ""
echo "🎉 Vault setup complete!"
echo "Next step: Deploy GlitchTip via ArgoCD"
echo "  kubectl apply -f argocd/infrastructure/glitchtip.yaml"
