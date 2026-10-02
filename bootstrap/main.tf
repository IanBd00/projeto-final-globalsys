# Execução única (state local): cria o bucket que guardará o state do ambiente.
# Depois disso, o ambiente usa o backend "oci" apontando para este bucket.
module "state_bucket" {
  source = "../modules/bucket"

  compartment_id = var.compartment_id
  name           = var.bucket_name
  freeform_tags  = var.freeform_tags
}
