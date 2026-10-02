# Módulo compute

Cria uma instância OCI com VNIC, NSGs, tags e, opcionalmente, IP público efêmero ou reservado.

- `public_ip_mode`: `none` (padrão), `ephemeral` ou `reserved`. O IP reservado sobrevive à recriação da VM.
- `hostname_label`: hostname DNS resolvível dentro da VCN (exige `dns_label` na subnet).
- `user_data`: script cloud-init em texto puro (o módulo aplica base64), para configurar a VM no primeiro boot.
- Mudança de versão da imagem não recria a VM (`ignore_changes` em `source_id`).
- Shape `A1.Flex` é ARM: a imagem precisa ser aarch64.

## Uso

```hcl
module "compute" {
  source = "../../modules/compute"

  compartment_id      = module.compartment.id
  availability_domain = local.availability_domain
  name                = "SRV-EXEMPLO-PRD01"
  hostname_label      = "srv-exemplo-prd01"
  shape               = "VM.Standard.A1.Flex"
  shape_config        = { ocpus = 1, memory_in_gbs = 4 }
  subnet_id           = module.vcn.subnet_ids["private"]
  nsg_ids             = [module.nsg.ids["web"]]
  image_id            = var.image_id
  ssh_public_key      = var.ssh_public_key
}
```

| Entrada | Tipo | Padrão | Descrição |
|---|---|---|---|
| `compartment_id`, `availability_domain`, `name`, `shape`, `subnet_id`, `image_id`, `ssh_public_key` | string | obrigatório | Dados básicos |
| `fault_domain` | string | `null` | Fault Domain |
| `hostname_label` | string | `null` | Hostname DNS interno |
| `shape_config` | object | `null` | `ocpus` e `memory_in_gbs` (shapes flex) |
| `nsg_ids` | list(string) | `[]` | NSGs da VNIC |
| `public_ip_mode` | string | `none` | `none`, `ephemeral`, `reserved` |
| `boot_volume_size_in_gbs` | number | `null` | Tamanho do boot volume |
| `user_data` | string | `null` | cloud-init em texto puro |
| `extra_metadata` | map(string) | `{}` | Metadados adicionais |
| `freeform_tags` | map(string) | `{}` | Tags livres opcionais (vazio = só as tags padrão da Oracle) |

| Saída | Descrição |
|---|---|
| `id`, `name` | OCID e nome |
| `private_ip` | IP privado |
| `public_ip` | IP público (null se `none`) |
| `hostname_label`, `fault_domain` | Hostname e Fault Domain |
