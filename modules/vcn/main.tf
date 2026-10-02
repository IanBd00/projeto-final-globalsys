locals {
  has_public_subnet  = anytrue([for s in var.subnets : s.type == "public"])
  has_private_subnet = anytrue([for s in var.subnets : s.type == "private"])
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  display_name   = var.name
  cidr_blocks    = [var.cidr_block]
  dns_label      = var.dns_label
  freeform_tags  = var.freeform_tags
}

# Gateways: criados apenas quando existe subnet que os utiliza.
resource "oci_core_internet_gateway" "this" {
  count = local.has_public_subnet ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-igw"
  enabled        = true
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "this" {
  count = local.has_private_subnet ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-nat"
  freeform_tags  = var.freeform_tags
}

# Route tables: a pública sai pelo IGW e a privada sai pelo NAT.
resource "oci_core_route_table" "public" {
  count = local.has_public_subnet ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-public-rt"
  freeform_tags  = var.freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this[0].id
    description       = "Saída para a internet via Internet Gateway"
  }
}

resource "oci_core_route_table" "private" {
  count = local.has_private_subnet ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-private-rt"
  freeform_tags  = var.freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this[0].id
    description       = "Saída para a internet via NAT Gateway"
  }
}

# Security List mínima, anexada às subnets para substituir a Default Security List
# da VCN (que libera SSH de 0.0.0.0/0). As regras de acesso vivem nas NSGs.
resource "oci_core_security_list" "minimal" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-sl-minimal"
  freeform_tags  = var.freeform_tags

  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "Path MTU Discovery (fragmentation needed)"

    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_subnet" "this" {
  for_each = var.subnets

  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  display_name               = coalesce(each.value.display_name, "${var.name}-${each.key}-subnet")
  cidr_block                 = each.value.cidr_block
  dns_label                  = each.value.dns_label
  prohibit_public_ip_on_vnic = each.value.type == "private"
  route_table_id             = each.value.type == "public" ? oci_core_route_table.public[0].id : oci_core_route_table.private[0].id
  security_list_ids          = [oci_core_security_list.minimal.id]
  freeform_tags              = var.freeform_tags
}
