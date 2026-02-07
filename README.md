### Recreate your secrets
You need to recreate the secrets that were lost. Run these commands (replace <value> with actual values):

##### Fleet secrets:

```bash
kubectl exec -it vault-0 -n vault -- vault kv put secret/fleet/production \
  MONGODB_URI="<value>" \
  JWT_SECRET="<value>" \
  ALLOWED_ORIGINS="<value>" \
  SMTP_HOST="<value>" \
  SMTP_PORT="587" \
  SMTP_USERNAME="<value>" \
  SMTP_PASSWORD="<value>" \
  SMTP_FROM_EMAIL="<value>" \
  SMTP_FROM_NAME="<value>" \
  ```

Investify secrets:

```bash
kubectl exec -it vault-0 -n vault -- vault kv put secret/investify/production \
  APP_KEY="<value>" \
  DB_HOST="<value>" \
  DB_PORT="5432" \
  DB_DATABASE="<value>" \
  DB_USERNAME="<value>" \
  DB_PASSWORD="<value>" \
  DATABASE_URL="<value>"
```

##### After Vault Pod Restarts
Vault will be sealed after restarts. Unseal with:

`kubectl exec -it vault-0 -n vault -- vault operator unseal <unseal-key>`

##### Verify ExternalSecrets sync
After creating secrets, verify sync:

`kubectl get externalsecret -n fleet`
`kubectl get externalsecret -n investify`


##### Trigger sync
- Force immediate sync for fleet
`kubectl annotate externalsecret fleet-production-external-secret -n fleet force-sync=$(date +%s) --overwrite`
- Force immediate sync for investify
`kubectl annotate externalsecret investify-production-external-secret -n investify force-sync=$(date +%s) --overwrite`
