# Módulo nsg

Cria várias NSGs e suas regras a partir de um único mapa. Uma regra pode ter como origem/destino um CIDR ou **outra NSG do mesmo mapa**, referenciada pela chave. Isso dispensa IPs de instâncias e permite referências cruzadas (ex.: mon <-> web) sem dependência circular.

## Uso

```hcl
module "nsg" {
  source = "../../modules/nsg"

  compartment_id = module.compartment.id
  vcn_id         = module.vcn.id

  nsgs = {
    web = {
      display_name = "NSG-WEB"
      rules = {
        http_from_npm = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "npm", port_min = 80 }
        egress_all    = { direction = "EGRESS", protocol = "all", peer_type = "CIDR", peer = "0.0.0.0/0" }
      }
    }
    npm = { display_name = "NSG-NPM", rules = {} }
  }
}
```

Campos de cada regra: `direction` (`INGRESS`/`EGRESS`), `protocol` (`tcp`/`udp`/`icmp`/`all`), `peer_type` (`CIDR`/`NSG`), `peer`, `port_min`, `port_max` (padrão = `port_min`), `icmp_type`, `icmp_code`, `stateless`, `description`.

Validações: direção, protocolo, tipo de peer e existência da NSG referenciada (falha no plan com mensagem clara).

| Saída | Descrição |
|---|---|
| `ids` | Mapa chave da NSG => OCID |
