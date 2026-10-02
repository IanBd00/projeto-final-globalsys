locals {
  # Números de protocolo IANA aceitos pela OCI.
  protocol_numbers = {
    tcp  = "6"
    udp  = "17"
    icmp = "1"
    all  = "all"
  }

  # Achata nsgs => rules em um único mapa "<nsg>/<regra>".
  rules = merge([
    for nsg_key, nsg in var.nsgs : {
      for rule_key, rule in nsg.rules : "${nsg_key}/${rule_key}" => merge(rule, { nsg_key = nsg_key })
    }
  ]...)
}

resource "oci_core_network_security_group" "this" {
  for_each = var.nsgs

  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = each.value.display_name
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "this" {
  for_each = local.rules

  network_security_group_id = oci_core_network_security_group.this[each.value.nsg_key].id
  direction                 = each.value.direction
  protocol                  = local.protocol_numbers[each.value.protocol]
  stateless                 = each.value.stateless
  description               = each.value.description

  # Regras de entrada usam source; regras de saída usam destination.
  source      = each.value.direction == "INGRESS" ? (each.value.peer_type == "NSG" ? oci_core_network_security_group.this[each.value.peer].id : each.value.peer) : null
  source_type = each.value.direction == "INGRESS" ? (each.value.peer_type == "NSG" ? "NETWORK_SECURITY_GROUP" : "CIDR_BLOCK") : null

  destination      = each.value.direction == "EGRESS" ? (each.value.peer_type == "NSG" ? oci_core_network_security_group.this[each.value.peer].id : each.value.peer) : null
  destination_type = each.value.direction == "EGRESS" ? (each.value.peer_type == "NSG" ? "NETWORK_SECURITY_GROUP" : "CIDR_BLOCK") : null

  dynamic "tcp_options" {
    for_each = each.value.protocol == "tcp" && each.value.port_min != null ? [1] : []

    content {
      destination_port_range {
        min = each.value.port_min
        max = coalesce(each.value.port_max, each.value.port_min)
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "udp" && each.value.port_min != null ? [1] : []

    content {
      destination_port_range {
        min = each.value.port_min
        max = coalesce(each.value.port_max, each.value.port_min)
      }
    }
  }

  dynamic "icmp_options" {
    for_each = each.value.protocol == "icmp" && each.value.icmp_type != null ? [1] : []

    content {
      type = each.value.icmp_type
      code = each.value.icmp_code
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.peer_type != "NSG" || contains(keys(var.nsgs), each.value.peer)
      error_message = "A regra ${each.key} referencia a NSG \"${each.value.peer}\", que não existe em var.nsgs."
    }
  }
}
