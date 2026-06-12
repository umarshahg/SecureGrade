# ============================================
# Vault Policies for SecureGrade Portal
# ============================================

# Auth Service Policy
path "secret/data/securegarde/auth/*" {
  capabilities = ["read", "list"]
}

path "secret/data/securegarde/database" {
  capabilities = ["read"]
}

path "secret/data/securegarde/redis" {
  capabilities = ["read"]
}

path "secret/data/securegarde/jwt" {
  capabilities = ["read"]
}

# Result Service Policy
path "secret/data/securegarde/result/*" {
  capabilities = ["read", "list"]
}

path "secret/data/securegarde/database" {
  capabilities = ["read"]
}

# Grade Service Policy
path "secret/data/securegarde/grade/*" {
  capabilities = ["read", "list"]
}

# Admin Service Policy
path "secret/data/securegarde/admin/*" {
  capabilities = ["read", "list"]
}

# Deny all other paths
path "secret/*" {
  capabilities = ["deny"]
}
