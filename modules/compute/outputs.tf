output "id" {
  description = "OCID da instância."
  value       = oci_core_instance.this.id
}

output "name" {
  description = "Nome de exibição da instância."
  value       = oci_core_instance.this.display_name
}

output "private_ip" {
  description = "IP privado da VNIC primária."
  value       = oci_core_instance.this.private_ip
}

output "public_ip" {
  description = "IP público (reservado ou efêmero). Null quando public_ip_mode = none."
  value = (
    var.public_ip_mode == "reserved" ? one(oci_core_public_ip.reserved[*].ip_address) :
    var.public_ip_mode == "ephemeral" ? oci_core_instance.this.public_ip :
    null
  )
}

output "hostname_label" {
  description = "Hostname DNS da instância dentro da VCN."
  value       = var.hostname_label
}

output "fault_domain" {
  description = "Fault Domain onde a instância foi alocada."
  value       = oci_core_instance.this.fault_domain
}

output "private_key_pem" {
  description = "Chave privada PEM gerada para esta instância."
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}