variable "compartment_id" {
  type        = string
  description = "OCID do compartment onde as NSGs serão criadas."
}

variable "vcn_id" {
  type        = string
  description = "OCID da VCN das NSGs."
}

variable "nsgs" {
  type = map(object({
    display_name = string
    rules = map(object({
      direction   = string # INGRESS | EGRESS
      protocol    = string # tcp | udp | icmp | all
      peer_type   = string # CIDR | NSG (origem em INGRESS, destino em EGRESS)
      peer        = string # CIDR, ou chave de outra NSG deste mesmo mapa
      port_min    = optional(number)
      port_max    = optional(number) # padrão: igual a port_min
      icmp_type   = optional(number)
      icmp_code   = optional(number)
      stateless   = optional(bool, false)
      description = optional(string)
    }))
  }))
  description = <<-EOT
    Mapa de NSGs e suas regras. A chave da NSG é usada nos outputs e nas referências entre NSGs.
    Quando peer_type = "NSG", peer recebe a CHAVE de outra NSG do mapa (não o OCID), o que permite
    referências cruzadas (ex.: mon <-> web) sem depender de IPs ou de ordem de criação.
  EOT

  validation {
    condition     = alltrue(flatten([for n in var.nsgs : [for r in n.rules : contains(["INGRESS", "EGRESS"], r.direction)]]))
    error_message = "direction deve ser INGRESS ou EGRESS."
  }

  validation {
    condition     = alltrue(flatten([for n in var.nsgs : [for r in n.rules : contains(["tcp", "udp", "icmp", "all"], r.protocol)]]))
    error_message = "protocol deve ser tcp, udp, icmp ou all."
  }

  validation {
    condition     = alltrue(flatten([for n in var.nsgs : [for r in n.rules : contains(["CIDR", "NSG"], r.peer_type)]]))
    error_message = "peer_type deve ser CIDR ou NSG."
  }
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags livres aplicadas às NSGs."
  default     = {}
}
