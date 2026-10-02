# Módulo compartment

Cria um compartment OCI com tags. Com `enable_delete = true`, o `terraform destroy` remove o compartment da tenancy.

## Uso

```hcl
module "compartment" {
  source = "../../modules/compartment"

  parent_compartment_id = var.tenancy_ocid
  name                  = "MEU-PROJETO"
  enable_delete         = true
  freeform_tags         = { project = "meu-projeto" }
}
```

| Entrada | Tipo | Padrão | Descrição |
|---|---|---|---|
| `parent_compartment_id` | string | obrigatório | Compartment pai ou tenancy |
| `name` | string | obrigatório | Nome |
| `description` | string | texto padrão | Descrição |
| `enable_delete` | bool | `false` | Exclui o compartment no destroy |
| `freeform_tags` | map(string) | `{}` | Tags |

| Saída | Descrição |
|---|---|
| `id` | OCID do compartment |
| `name` | Nome do compartment |
