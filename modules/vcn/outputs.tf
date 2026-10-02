output "id" {
  description = "OCID da VCN."
  value       = oci_core_vcn.this.id
}

output "cidr_block" {
  description = "CIDR da VCN."
  value       = var.cidr_block
}

output "subnet_ids" {
  description = "Mapa chave da subnet => OCID."
  value       = { for k, s in oci_core_subnet.this : k => s.id }
}

output "subnet_cidrs" {
  description = "Mapa chave da subnet => CIDR."
  value       = { for k, s in oci_core_subnet.this : k => s.cidr_block }
}

output "internet_gateway_id" {
  description = "OCID do Internet Gateway (null se não houver subnet pública)."
  value       = one(oci_core_internet_gateway.this[*].id)
}

output "nat_gateway_id" {
  description = "OCID do NAT Gateway (null se não houver subnet privada)."
  value       = one(oci_core_nat_gateway.this[*].id)
}

output "security_list_id" {
  description = "OCID da Security List mínima anexada às subnets."
  value       = oci_core_security_list.minimal.id
}
