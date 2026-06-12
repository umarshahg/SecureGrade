terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.23"
    }
  }
}

# Kubernetes provider — connects to minikube
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# Helm provider
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

# Vault provider
provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}
