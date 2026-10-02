variable "parent_compartment_id" {
  type        = string
  description = "OCID do compartment pai (ou da tenancy) onde o novo compartment será criado."
}

variable "name" {
  type        = string
  description = "Nome do compartment."
}

variable "description" {
  type        = string
  description = "Descrição da finalidade do compartment."
  default     = "Compartment gerenciado via Terraform."
}

variable "enable_delete" {
  type        = bool
  description = "Se true, o `terraform destroy` exclui o compartment na OCI. Se false, ele apenas sai do state."
  default     = false
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags livres aplicadas ao recurso."
  default     = {}
}
