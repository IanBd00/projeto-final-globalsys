# Módulo loadbalancer

Load Balancer flexível da OCI com backend set, listener HTTP e backends. **Faz parte da biblioteca, mas não é usado pela solução atual** (a entrada é o NPM em DMZ). Fica disponível como alternativa gerenciada.

## Uso

```hcl
module "load_balancer" {
  source = "../../modules/loadbalancer"

  compartment_id = module.compartment.id
  name           = "LB-PUBLIC-EXEMPLO"
  subnet_ids     = [module.vcn.subnet_ids["dmz"]]
  nsg_ids        = [module.nsg.ids["lb"]]

  backends = {
    app01 = { ip_address = module.compute["app01"].private_ip, port = 80 }
    app02 = { ip_address = module.compute["app02"].private_ip, port = 80 }
  }
}
```

| Entrada | Padrão | Descrição |
|---|---|---|
| `compartment_id`, `name`, `subnet_ids`, `backends` | obrigatório | Dados básicos |
| `is_private` | `false` | LB privado ou público |
| `nsg_ids` | `[]` | NSGs do LB |
| `min_bandwidth`, `max_bandwidth` | `10` | Mbps (shape flexible) |
| `policy` | `ROUND_ROBIN` | `ROUND_ROBIN`, `LEAST_CONNECTIONS`, `IP_HASH` |
| `listener_port`, `backend_port` | `80` | Portas |
| `health_check_path` | `/` | Caminho do health check |
| `freeform_tags` | `{}` | Tags |

Saídas: `id`, `ip_address`.
