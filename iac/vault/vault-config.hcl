# HashiCorp Vault Configuration
# SecureGrade Student Result Portal

# Storage backend
storage "file" {
  path = "/vault/data"
}

# Listener
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

# API address
api_addr = "http://127.0.0.1:8200"

# Disable mlock for development
disable_mlock = true

# UI enabled
ui = true

# Logging
log_level = "info"
log_file  = "/vault/logs/vault.log"
