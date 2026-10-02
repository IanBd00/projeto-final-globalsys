output "npm_public_ip" {
  description = "IP público do NPM (entrada da aplicação, UI do NPM em :81 e Grafana em :3000)."
  value       = module.compute["npm"].public_ip
}

output "jump_public_ip" {
  description = "IP público do jump server (único ponto de acesso administrativo)."
  value       = module.compute["jump"].public_ip
}

output "instances" {
  description = "Nome, IP privado e hostname interno de cada instância (base para o inventário)."
  value = {
    for k, m in module.compute : k => {
      name       = m.name
      private_ip = m.private_ip
      fqdn       = "${m.hostname_label}.${local.instances[k].subnet}.${var.vcn_dns_label}.oraclevcn.com"
    }
  }
}

output "nsg_ids" {
  description = "OCIDs das NSGs por chave."
  value       = module.nsg.ids
}
