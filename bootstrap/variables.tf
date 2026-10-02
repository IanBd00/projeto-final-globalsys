variable "tenancy_ocid" {
  type        = string
  description = "OCID da tenancy."
}

variable "user_ocid" {
  type        = string
  description = "OCID do usuário IAM usado pela API."
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint da chave de API do usuário."
}

variable "private_key_path" {
  type        = string
  description = "Caminho da chave privada de API (.pem)."
}

variable "region" {
  type        = string
  description = "Região OCI do bucket (ex.: sa-saopaulo-1)."
}

variable "compartment_id" {
  type        = string
  description = "OCID do compartment GlobalAcademy-Ian (já existente), onde o bucket de state será criado."
}

variable "bucket_name" {
  type        = string
  description = "Nome do bucket de state."
  default     = "TFSTATE-GLOBALACADEMY-IAN"
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags livres aplicadas ao bucket."
  default = {
    project    = "FP-IAN"
    managed_by = "terraform"
  }
}
