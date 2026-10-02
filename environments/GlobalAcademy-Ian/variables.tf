# --- Autenticação OCI ---------------------------------------------------------

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
  description = "Região OCI (ex.: sa-saopaulo-1)."
}

# --- Compartment existente ----------------------------------------------------

variable "compartment_id" {
  type        = string
  description = "OCID do compartment GlobalAcademy-Ian (já existente), onde todos os recursos serão criados."
}



# --- Rede ---------------------------------------------------------------------

variable "vcn_cidr" {
  type        = string
  description = "CIDR da VCN."
  default     = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  type        = string
  description = "Rótulo DNS da VCN."
  default     = "fpianbello"
}

variable "dmz_subnet_cidr" {
  type        = string
  description = "CIDR da subnet pública (DMZ), onde fica o NPM."
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR da subnet privada (apps web e monitoramento)."
  default     = "10.0.2.0/24"
}

variable "jump_subnet_cidr" {
  type        = string
  description = "CIDR da subnet pública de gestão, onde fica o jump server."
  default     = "10.0.3.0/24"
}

# --- Acesso administrativo ----------------------------------------------------

variable "admin_cidrs" {
  type        = list(string)
  description = "IPs públicos da Globalsys (CIDR, ex.: x.x.x.x/32) autorizados a acessar o SSH do jump (22), a UI do NPM (81) e o Grafana (3000)."

  validation {
    condition     = length(var.admin_cidrs) > 0 && !contains(var.admin_cidrs, "0.0.0.0/0")
    error_message = "Informe ao menos um CIDR e não use 0.0.0.0/0 (SSH, UI do NPM e Grafana não podem ficar abertos para a internet)."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "Chave pública SSH opcional. Se for null, o módulo gera uma chave única por instância."
  default     = null
}

# --- Compute ------------------------------------------------------------------

variable "image_id" {
  type        = string
  description = "OCID da imagem (Oracle Linux 8/9). Para A1.Flex use imagem aarch64."
}

variable "instance_shape" {
  type        = string
  description = "Shape das instâncias."
  default     = "VM.Standard.A1.Flex"
}

variable "availability_domain_index" {
  type        = number
  description = "Índice do Availability Domain (0 = primeiro AD da região)."
  default     = 0
}
