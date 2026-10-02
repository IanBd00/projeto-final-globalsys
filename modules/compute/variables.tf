variable "compartment_id" {
  type        = string
  description = "OCID do compartment onde a instância será criada."
}

variable "availability_domain" {
  type        = string
  description = "Nome do Availability Domain da instância."
}

variable "fault_domain" {
  type        = string
  description = "Fault Domain (ex.: FAULT-DOMAIN-1). Use domínios diferentes para VMs redundantes. Null deixa a OCI escolher."
  default     = null
}

variable "name" {
  type        = string
  description = "Nome de exibição da instância."
}

variable "hostname_label" {
  type        = string
  description = "Hostname DNS da VNIC dentro da VCN (exige dns_label na subnet). Null desativa."
  default     = null
}

variable "shape" {
  type        = string
  description = "Shape da instância (ex.: VM.Standard.A1.Flex)."
}

variable "shape_config" {
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  description = "OCPUs e memória para shapes flexíveis. Null para shapes fixos."
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "OCID da subnet da VNIC primária."
}

variable "nsg_ids" {
  type        = list(string)
  description = "OCIDs das NSGs associadas à VNIC."
  default     = []
}

variable "public_ip_mode" {
  type        = string
  description = "none: sem IP público. ephemeral: IP público efêmero. reserved: IP público reservado (mantém o endereço entre recriações)."
  default     = "none"

  validation {
    condition     = contains(["none", "ephemeral", "reserved"], var.public_ip_mode)
    error_message = "public_ip_mode deve ser none, ephemeral ou reserved."
  }
}

variable "image_id" {
  type        = string
  description = "OCID da imagem do SO. Deve ser compatível com a arquitetura do shape (A1.Flex exige imagem aarch64)."
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Tamanho do boot volume em GB. Null usa o padrão da imagem."
  default     = null
}

variable "ssh_public_key" {
  type        = string
  description = "Chave SSH pública autorizada no usuário padrão da imagem. Se null, uma chave única é gerada automaticamente."
  default     = null
}

variable "user_data" {
  type        = string
  description = "Script cloud-init em texto puro (o módulo aplica base64). Null não envia user_data."
  default     = null
}

variable "extra_metadata" {
  type        = map(string)
  description = "Metadados adicionais mesclados ao metadata da instância."
  default     = {}
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags livres opcionais para instância, VNIC e IP reservado. Padrão vazio: somente as tags padrão da Oracle."
  default     = {}
}
