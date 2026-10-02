output "id" {
  description = "OCID do Load Balancer."
  value       = oci_load_balancer_load_balancer.this.id
}

output "ip_address" {
  description = "IP público (ou privado) do Load Balancer."
  value       = oci_load_balancer_load_balancer.this.ip_address_details[0].ip_address
}
