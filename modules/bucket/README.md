# Módulo bucket

Cria um bucket privado no Object Storage (`NoPublicAccess`, tier Standard) com versionamento habilitado por padrão. Usado para guardar o state remoto do Terraform.

## Uso

```hcl
module "state_bucket" {
  source = "../modules/bucket"

  compartment_id = var.tenancy_ocid
  name           = "tfstate-meu-projeto"
}
```

| Entrada | Tipo | Padrão | Descrição |
|---|---|---|---|
| `compartment_id` | string | obrigatório | Compartment do bucket |
| `name` | string | obrigatório | Nome do bucket |
| `versioning` | string | `Enabled` | `Enabled`, `Suspended` ou `Disabled` |
| `freeform_tags` | map(string) | `{}` | Tags |

| Saída | Descrição |
|---|---|
| `name` | Nome do bucket |
| `namespace` | Namespace do Object Storage |
