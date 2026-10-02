variable "compartment_id" {
  type        = string
  description = "OCID do compartment onde a VCN e seus componentes serão criados."
}

variable "name" {
  type        = string
  description = "Nome de exibição da VCN. Também é usado como prefixo dos demais recursos de rede."
}

variable "cidr_block" {
  type        = string
  description = "Bloco CIDR da VCN (ex: 10.0.0.0/16)."

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block deve ser um CIDR IPv4 válido."
  }
}

variable "dns_label" {
  type        = string
  description = "Rótulo DNS da VCN (alfanumérico, até 15 caracteres)."
  default     = null
}

variable "subnets" {
  type = map(object({
    cidr_block   = string
    type         = string # "public" ou "private"
    dns_label    = optional(string)
    display_name = optional(string)
  }))
  description = "Mapa de subnets. A chave identifica a subnet nos outputs. type=public usa IGW e permite IP público; type=private usa NAT e proíbe IP público."

  validation {
    condition     = alltrue([for s in var.subnets : contains(["public", "private"], s.type)])
    error_message = "O campo type de cada subnet deve ser \"public\" ou \"private\"."
  }

  validation {
    condition     = alltrue([for s in var.subnets : can(cidrhost(s.cidr_block, 0))])
    error_message = "Todas as subnets devem ter cidr_block IPv4 válido."
  }
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags livres aplicadas a todos os recursos do módulo."
  default     = {}
}
