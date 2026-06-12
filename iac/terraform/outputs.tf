output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.portal_prod.metadata[0].name
}

output "auth_service_name" {
  description = "Auth service name"
  value       = kubernetes_service.auth_service.metadata[0].name
}

output "result_service_name" {
  description = "Result service name"
  value       = kubernetes_service.result_service.metadata[0].name
}

output "grade_service_name" {
  description = "Grade service name"
  value       = kubernetes_service.grade_service.metadata[0].name
}

output "admin_service_name" {
  description = "Admin service name"
  value       = kubernetes_service.admin_service.metadata[0].name
}

output "configmap_name" {
  description = "ConfigMap name"
  value       = kubernetes_config_map.app_config.metadata[0].name
}
