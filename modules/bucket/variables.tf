variable "compartment_id" {
  type        = string
  description = "OCID do compartment onde o bucket será criado."
}

variable "name" {
  type        = string
  description = "Nome do bucket (único dentro do namespace da tenancy)."
}

variable "versioning" {
  type        = string
  description = "Versionamento de objetos: Enabled, Suspended ou Disabled. Para state do Terraform, mantenha Enabled (permite recuperar versões anteriores)."
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning)
    error_message = "versioning deve ser Enabled, Suspended ou Disabled."
  }
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags livres aplicadas ao bucket."
  default     = {}
}
