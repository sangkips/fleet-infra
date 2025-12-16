#!/bin/bash
# Script to store Fleet secrets in Vault
# Run this script after setting up Vault and before deploying Fleet with External Secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Fleet Secrets Setup for Vault ===${NC}"
echo ""

# Check if vault CLI is available
if ! command -v vault &> /dev/null; then
    echo -e "${RED}Error: vault CLI is not installed${NC}"
    echo "Please install it from: https://www.vaultproject.io/downloads"
    exit 1
fi

# Check if VAULT_ADDR is set
if [ -z "$VAULT_ADDR" ]; then
    echo -e "${YELLOW}VAULT_ADDR not set. Using default...${NC}"
    export VAULT_ADDR="http://127.0.0.1:8200"
fi

echo -e "${GREEN}Vault Address: ${VAULT_ADDR}${NC}"
echo ""

# Prompt for secrets
echo -e "${YELLOW}Please provide the following secrets:${NC}"
echo ""

read -p "MongoDB URI: " MONGODB_URI
read -p "JWT Secret (generate with: openssl rand -hex 32): " JWT_SECRET
read -p "Allowed Origins: " ALLOWED_ORIGINS
read -p "App URL: " APP_URL

echo ""
echo -e "${YELLOW}SMTP Configuration:${NC}"
read -p "SMTP Host (e.g., smtp.gmail.com): " SMTP_HOST
read -p "SMTP Port (default: 587): " SMTP_PORT
SMTP_PORT=${SMTP_PORT:-587}
read -p "SMTP Username: " SMTP_USERNAME
read -s -p "SMTP Password: " SMTP_PASSWORD
echo ""
read -p "SMTP From Email: " SMTP_FROM_EMAIL
read -p "SMTP From Name: " SMTP_FROM_NAME

echo ""
echo -e "${GREEN}Storing secrets in Vault at: secret/fleet/production${NC}"

# Store secrets in Vault
vault kv put secret/fleet/production \
    MONGODB_URI="$MONGODB_URI" \
    JWT_SECRET="$JWT_SECRET" \
    ALLOWED_ORIGINS="$ALLOWED_ORIGINS" \
    APP_URL="$APP_URL" \
    SMTP_HOST="$SMTP_HOST" \
    SMTP_PORT="$SMTP_PORT" \
    SMTP_USERNAME="$SMTP_USERNAME" \
    SMTP_PASSWORD="$SMTP_PASSWORD" \
    SMTP_FROM_EMAIL="$SMTP_FROM_EMAIL" \
    SMTP_FROM_NAME="$SMTP_FROM_NAME"

echo ""
echo -e "${GREEN}✓ Secrets stored successfully!${NC}"
echo ""
echo -e "${YELLOW}Verify with:${NC}"
echo "  vault kv get secret/fleet/production"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Deploy or sync the fleet ArgoCD application"
echo "  2. Check ExternalSecret status: kubectl get externalsecret -n fleet"
echo "  3. Verify secret was created: kubectl get secret app-secrets -n fleet"
