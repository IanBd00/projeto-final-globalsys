output "ids" {
  description = "Mapa chave da NSG => OCID."
  value       = { for k, n in oci_core_network_security_group.this : k => n.id }
}
