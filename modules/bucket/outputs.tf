output "name" {
  description = "Nome do bucket."
  value       = oci_objectstorage_bucket.this.name
}

output "namespace" {
  description = "Namespace do Object Storage da tenancy."
  value       = oci_objectstorage_bucket.this.namespace
}
