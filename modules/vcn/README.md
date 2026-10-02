# Módulo vcn

Cria VCN, subnets (mapa), route tables, gateways e uma Security List mínima.

- Subnet `public`: sai pelo Internet Gateway e aceita IP público.
- Subnet `private`: sai pelo NAT Gateway e proíbe IP público.
- IGW e NAT só são criados se houver subnet que os use.
- A Security List mínima (somente ICMP path MTU) substitui a Default Security List da VCN, que libera SSH de 0.0.0.0/0. As regras de acesso ficam nas NSGs (módulo `nsg`).

## Uso

```hcl
module "vcn" {
  source = "../../modules/vcn"

  compartment_id = module.compartment.id
  name           = "VCN-MEU-PROJETO"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "meuprojeto"

  subnets = {
    dmz     = { cidr_block = "10.0.1.0/24", type = "public", dns_label = "dmz" }
    private = { cidr_block = "10.0.2.0/24", type = "private", dns_label = "private" }
  }
}
```

| Entrada | Tipo | Padrão | Descrição |
|---|---|---|---|
| `compartment_id` | string | obrigatório | Compartment |
| `name` | string | obrigatório | Nome da VCN e prefixo dos recursos |
| `cidr_block` | string | obrigatório | CIDR da VCN (validado) |
| `dns_label` | string | `null` | Rótulo DNS da VCN |
| `subnets` | map(object) | obrigatório | `cidr_block`, `type` (`public`/`private`), `dns_label`, `display_name` |
| `freeform_tags` | map(string) | `{}` | Tags |

| Saída | Descrição |
|---|---|
| `id` | OCID da VCN |
| `cidr_block` | CIDR da VCN |
| `subnet_ids` | Mapa chave => OCID da subnet |
| `subnet_cidrs` | Mapa chave => CIDR da subnet |
| `internet_gateway_id`, `nat_gateway_id` | OCIDs (null se não criados) |
| `security_list_id` | Security List mínima |
