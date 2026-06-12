# ============================================
# SecureGrade Student Result Portal
# Terraform Infrastructure as Code
# ============================================

locals {
  app_labels = {
    app         = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# NAMESPACE
# ============================================
resource "kubernetes_namespace" "portal_prod" {
  metadata {
    name = var.namespace
    labels = {
      name                                          = var.namespace
      "pod-security.kubernetes.io/enforce"          = "restricted"
      "pod-security.kubernetes.io/audit"            = "restricted"
      "pod-security.kubernetes.io/warn"             = "restricted"
    }
  }
}

resource "kubernetes_namespace" "data" {
  metadata {
    name = "data"
    labels = {
      name = "data"
    }
  }
}

resource "kubernetes_namespace" "security" {
  metadata {
    name = "security"
    labels = {
      name = "security"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

# ============================================
# CONFIGMAP
# ============================================
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  data = {
    DB_HOST    = "postgres.data.svc.cluster.local"
    DB_PORT    = "5432"
    DB_NAME    = "securegarde"
    DB_USER    = "auth_service_user"
    REDIS_HOST = "redis.data.svc.cluster.local"
    REDIS_PORT = "6379"
    NODE_ENV   = "production"
  }
}

# ============================================
# SECRETS
# ============================================
resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  data = {
    DB_PASSWORD    = var.db_password
    REDIS_PASSWORD = var.redis_password
  }

  type = "Opaque"
}

# ============================================
# AUTH SERVICE DEPLOYMENT
# ============================================
resource "kubernetes_deployment" "auth_service" {
  metadata {
    name      = "auth-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
    labels    = merge(local.app_labels, { service = "auth" })
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "auth-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "auth-service"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 1000
          fs_group        = 1000
        }

        container {
          name              = "auth-service"
          image             = "securegarde-auth-service:latest"
          image_pull_policy = "Never"

          port {
            container_port = 3001
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000

            capabilities {
              drop = ["ALL"]
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }

          env {
            name  = "PORT"
            value = "3001"
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "DB_PASSWORD"
              }
            }
          }

          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "REDIS_PASSWORD"
              }
            }
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "200m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3001
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3001
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

# ============================================
# AUTH SERVICE
# ============================================
resource "kubernetes_service" "auth_service" {
  metadata {
    name      = "auth-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  spec {
    selector = {
      app = "auth-service"
    }

    port {
      port        = 3001
      target_port = 3001
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# ============================================
# RESULT SERVICE DEPLOYMENT
# ============================================
resource "kubernetes_deployment" "result_service" {
  metadata {
    name      = "result-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
    labels    = merge(local.app_labels, { service = "result" })
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "result-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "result-service"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 1000
          fs_group        = 1000
        }

        container {
          name              = "result-service"
          image             = "securegarde-result-service:latest"
          image_pull_policy = "Never"

          port {
            container_port = 3002
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000

            capabilities {
              drop = ["ALL"]
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }

          env {
            name  = "PORT"
            value = "3002"
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "DB_PASSWORD"
              }
            }
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "200m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3002
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "result_service" {
  metadata {
    name      = "result-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  spec {
    selector = {
      app = "result-service"
    }

    port {
      port        = 3002
      target_port = 3002
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# ============================================
# GRADE SERVICE DEPLOYMENT
# ============================================
resource "kubernetes_deployment" "grade_service" {
  metadata {
    name      = "grade-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
    labels    = merge(local.app_labels, { service = "grade" })
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "grade-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "grade-service"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 1000
          fs_group        = 1000
        }

        container {
          name              = "grade-service"
          image             = "securegarde-grade-service:latest"
          image_pull_policy = "Never"

          port {
            container_port = 3003
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000

            capabilities {
              drop = ["ALL"]
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }

          env {
            name  = "PORT"
            value = "3003"
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "DB_PASSWORD"
              }
            }
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "200m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3003
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "grade_service" {
  metadata {
    name      = "grade-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  spec {
    selector = {
      app = "grade-service"
    }

    port {
      port        = 3003
      target_port = 3003
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# ============================================
# ADMIN SERVICE DEPLOYMENT
# ============================================
resource "kubernetes_deployment" "admin_service" {
  metadata {
    name      = "admin-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
    labels    = merge(local.app_labels, { service = "admin" })
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "admin-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "admin-service"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 1000
          fs_group        = 1000
        }

        container {
          name              = "admin-service"
          image             = "securegarde-admin-service:latest"
          image_pull_policy = "Never"

          port {
            container_port = 3004
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000

            capabilities {
              drop = ["ALL"]
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }

          env {
            name  = "PORT"
            value = "3004"
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "DB_PASSWORD"
              }
            }
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "200m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3004
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "admin_service" {
  metadata {
    name      = "admin-service"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  spec {
    selector = {
      app = "admin-service"
    }

    port {
      port        = 3004
      target_port = 3004
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# ============================================
# NETWORK POLICIES
# ============================================
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_auth" {
  metadata {
    name      = "allow-auth-ingress"
    namespace = kubernetes_namespace.portal_prod.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = "auth-service"
      }
    }

    ingress {
      ports {
        port     = "3001"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "5432"
        protocol = "TCP"
      }
      ports {
        port     = "6379"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress", "Egress"]
  }
}
