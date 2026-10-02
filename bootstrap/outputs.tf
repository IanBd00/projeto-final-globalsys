output "bucket" {
  description = "Nome do bucket de state."
  value       = module.state_bucket.name
}

output "namespace" {
  description = "Namespace do Object Storage (usar no backend)."
  value       = module.state_bucket.namespace
}
