variable "compartment_id" {
  type        = string
  description = "OCID do compartment onde o Load Balancer será criado."
}

variable "name" {
  type        = string
  description = "Nome de exibição do Load Balancer."
}

variable "subnet_ids" {
  type        = list(string)
  description = "OCIDs das subnets dos nós do Load Balancer."
}

variable "is_private" {
  type        = bool
  description = "true cria um Load Balancer privado; false cria um público."
  default     = false
}

variable "nsg_ids" {
  type        = list(string)
  description = "OCIDs das NSGs do Load Balancer."
  default     = []
}

variable "min_bandwidth" {
  type        = number
  description = "Largura de banda mínima em Mbps (shape flexible)."
  default     = 10
}

variable "max_bandwidth" {
  type        = number
  description = "Largura de banda máxima em Mbps (shape flexible)."
  default     = 10
}

variable "policy" {
  type        = string
  description = "Política de balanceamento: ROUND_ROBIN, LEAST_CONNECTIONS ou IP_HASH."
  default     = "ROUND_ROBIN"

  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_CONNECTIONS", "IP_HASH"], var.policy)
    error_message = "policy deve ser ROUND_ROBIN, LEAST_CONNECTIONS ou IP_HASH."
  }
}

variable "listener_port" {
  type        = number
  description = "Porta do listener."
  default     = 80
}

variable "backend_port" {
  type        = number
  description = "Porta usada no health check dos backends."
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Caminho HTTP do health check."
  default     = "/"
}

variable "backends" {
  type = map(object({
    ip_address = string
    port       = number
  }))
  description = "Mapa de backends (chave estática => IP privado e porta)."
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags livres aplicadas ao Load Balancer."
  default     = {}
}
