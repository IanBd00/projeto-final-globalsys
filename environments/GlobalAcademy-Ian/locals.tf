locals {
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[var.availability_domain_index].name

  # Convenção de nomes (mantida igual ao diagrama de arquitetura).
  names = {
    vcn = "VCN-ACADEMY-IAN"
  }

  # Regras que dependem da lista de IPs da Globalsys (admin_cidrs): uma regra por CIDR.
  admin_rules = {
    for port in [22, 81, 3000] : port => {
      for i, cidr in var.admin_cidrs : "${port}_${i}" => {
        direction = "INGRESS"
        protocol  = "tcp"
        peer_type = "CIDR"
        peer      = cidr
        port_min  = port
      }
    }
  }

  # --- Regras de rede: toda a política de acesso em um único lugar ------------
  # peer_type = "NSG" referencia a CHAVE de outra NSG (ver modules/nsg).
  nsgs = {
    npm = {
      display_name = "NSG-NPM"
      rules = merge(
        {
          http_in          = { direction = "INGRESS", protocol = "tcp", peer_type = "CIDR", peer = "0.0.0.0/0", port_min = 80, description = "HTTP público" }
          https_in         = { direction = "INGRESS", protocol = "tcp", peer_type = "CIDR", peer = "0.0.0.0/0", port_min = 443, description = "HTTPS público" }
          ssh_from_jump    = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "jump", port_min = 22, description = "SSH somente do jump" }
          metrics_from_mon = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "mon", port_min = 9100, description = "Prometheus coleta o node_exporter" }
          egress_all       = { direction = "EGRESS", protocol = "all", peer_type = "CIDR", peer = "0.0.0.0/0", description = "Saída liberada" }
        },
        { for k, r in local.admin_rules[81] : "ui_npm_${k}" => merge(r, { description = "UI do NPM somente do IP da Globalsys" }) },
        { for k, r in local.admin_rules[3000] : "grafana_${k}" => merge(r, { description = "Grafana (via NPM) somente do IP da Globalsys" }) },
      )
    }

    web = {
      display_name = "NSG-WEB"
      rules = {
        http_from_npm    = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "npm", port_min = 80, description = "HTTP somente do NPM" }
        http_from_mon    = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "mon", port_min = 80, description = "Probe HTTP do monitoramento" }
        ssh_from_jump    = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "jump", port_min = 22, description = "SSH somente do jump" }
        metrics_from_mon = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "mon", port_min = 9100, description = "Prometheus coleta o node_exporter" }
        egress_all       = { direction = "EGRESS", protocol = "all", peer_type = "CIDR", peer = "0.0.0.0/0", description = "Saída liberada (via NAT)" }
      }
    }

    mon = {
      display_name = "NSG-MONITORAMENTO"
      rules = {
        grafana_from_npm  = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "npm", port_min = 3000, description = "Grafana publicado pelo NPM" }
        grafana_from_jump = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "jump", port_min = 3000, description = "Grafana via túnel SSH pelo jump" }
        ssh_from_jump     = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "jump", port_min = 22, description = "SSH somente do jump" }
        egress_all        = { direction = "EGRESS", protocol = "all", peer_type = "CIDR", peer = "0.0.0.0/0", description = "Saída liberada (via NAT)" }
      }
    }

    jump = {
      display_name = "NSG-JUMP"
      rules = merge(
        {
          metrics_from_mon = { direction = "INGRESS", protocol = "tcp", peer_type = "NSG", peer = "mon", port_min = 9100, description = "Prometheus coleta o node_exporter" }
          egress_all       = { direction = "EGRESS", protocol = "all", peer_type = "CIDR", peer = "0.0.0.0/0", description = "Saída liberada" }
        },
        { for k, r in local.admin_rules[22] : "ssh_admin_${k}" => merge(r, { description = "SSH somente do IP da Globalsys" }) },
      )
    }
  }

  # --- Instâncias: adicionar uma VM = adicionar uma entrada aqui --------------
  instances = {
    npm = {
      name           = "SRV-IAN-NPM-PRD01"
      subnet         = "DMZ"
      nsg            = "npm"
      public_ip_mode = "ephemeral"
      fault_domain   = "FAULT-DOMAIN-1"
      ocpus          = 1
      memory_in_gbs  = 4
    }
    jump = {
      name           = "SRV-IAN-JUMP-PRD01"
      subnet         = "JUMP"
      nsg            = "jump"
      public_ip_mode = "ephemeral"
      fault_domain   = "FAULT-DOMAIN-3"
      ocpus          = 1
      memory_in_gbs  = 4
    }
    mon = {
      name           = "SRV-IAN-MONITORAMENTO-PRD01"
      subnet         = "PRIVATE"
      nsg            = "mon"
      public_ip_mode = "none"
      fault_domain   = "FAULT-DOMAIN-2"
      ocpus          = 1
      memory_in_gbs  = 6
    }
    app01 = {
      name           = "SRV-IAN-WEB-APP01"
      subnet         = "PRIVATE"
      nsg            = "web"
      public_ip_mode = "none"
      fault_domain   = "FAULT-DOMAIN-1"
      ocpus          = 1
      memory_in_gbs  = 2
    }
    app02 = {
      name           = "SRV-IAN-WEB-APP02"
      subnet         = "PRIVATE"
      nsg            = "web"
      public_ip_mode = "none"
      fault_domain   = "FAULT-DOMAIN-2"
      ocpus          = 1
      memory_in_gbs  = 2
    }
  }
}
