#!/bin/bash
# Vault Initialization Script for SecureGrade Portal

echo "=== Starting Vault ==="
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root-token'

# Start Vault in dev mode
vault server -dev -dev-root-token-id="root-token" &
VAULT_PID=$!
sleep 3

echo "=== Enabling KV Secrets Engine ==="
vault secrets enable -path=secret kv-v2

echo "=== Storing Secrets ==="

# Database credentials
vault kv put secret/securegarde/database \
  username="auth_service_user" \
  password="SecurePass123!" \
  host="localhost" \
  port="5432" \
  dbname="securegarde"

# Redis credentials
vault kv put secret/securegarde/redis \
  password="RedisPass123!" \
  host="localhost" \
  port="6379"

# JWT keys
vault kv put secret/securegarde/jwt \
  private_key="$(cat ~/securegarde/keys/private.pem)" \
  public_key="$(cat ~/securegarde/keys/public.pem)"

# Auth service secrets
vault kv put secret/securegarde/auth/config \
  jwt_expiry="15m" \
  bcrypt_rounds="12" \
  max_login_attempts="5"

echo "=== Creating Policies ==="

# Auth service policy
vault policy write auth-service - <<EOF
path "secret/data/securegarde/database" {
  capabilities = ["read"]
}
path "secret/data/securegarde/redis" {
  capabilities = ["read"]
}
path "secret/data/securegarde/jwt" {
  capabilities = ["read"]
}
EOF

# Result service policy
vault policy write result-service - <<EOF
path "secret/data/securegarde/database" {
  capabilities = ["read"]
}
path "secret/data/securegarde/jwt" {
  capabilities = ["read"]
}
EOF

# Grade service policy
vault policy write grade-service - <<EOF
path "secret/data/securegarde/database" {
  capabilities = ["read"]
}
path "secret/data/securegarde/jwt" {
  capabilities = ["read"]
}
EOF

# Admin service policy
vault policy write admin-service - <<EOF
path "secret/data/securegarde/database" {
  capabilities = ["read"]
}
path "secret/data/securegarde/jwt" {
  capabilities = ["read"]
}
EOF

echo "=== Creating Service Tokens ==="
vault token create -policy=auth-service -ttl=24h
vault token create -policy=result-service -ttl=24h
vault token create -policy=grade-service -ttl=24h
vault token create -policy=admin-service -ttl=24h

echo "=== Vault Setup Complete ==="
echo "Vault UI: http://127.0.0.1:8200/ui"
echo "Token: root-token"
