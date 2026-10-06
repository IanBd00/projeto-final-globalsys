# GlobalAcademy-Ian: Infraestrutura OCI com Terraform (Globalsys)

Ambiente web na OCI: aplicação em duas VMs privadas, publicada por um proxy NPM em uma DMZ, monitoramento com Prometheus e Grafana em VM privada, e acesso administrativo por um jump server. SSH, UI do NPM e Grafana são liberados apenas para o IP da Globalsys. O acesso é feito pelo IP do NPM, sem domínio. Toda a infraestrutura é declarada em Terraform, com módulos reutilizáveis. Os recursos são criados no compartment **GlobalAcademy-Ian**, que já existe.

> Status: módulos, backend remoto e pipeline prontos. Configuração das VMs, monitoramento e relatório técnico entram nas próximas partes.

## Estrutura

```
.
├── .github/workflows/terraform.yml   # pipeline: validate, plan (automático) e apply (manual)
├── bootstrap/                        # execução única: cria o bucket do state remoto
├── modules/                          # biblioteca de módulos reutilizáveis
│   ├── compartment/  vcn/  nsg/  compute/  bucket/  loadbalancer/
└── environments/
    └── GlobalAcademy-Ian/                  # composição dos módulos = o ambiente
        ├── versions.tf  providers.tf  backend.tf  variables.tf  data.tf
        ├── locals.tf                 # nomes, tags, regras de NSG e lista de instâncias
        ├── main.tf                   # chamadas dos módulos
        └── outputs.tf
```

## Catálogo de módulos

| Módulo | Função | Destaques |
|---|---|---|
| `compartment` | Cria um compartment | Na biblioteca, mas **não usado aqui**: o compartment GlobalAcademy-Ian já existe e é informado por OCID |
| `vcn` | VCN, subnets, gateways, route tables | Subnets por mapa (`public`/`private`); IGW e NAT só se necessários; substitui a Default Security List |
| `nsg` | NSGs e regras por mapa | Regras podem ter outra NSG como origem (sem IPs); valida referências |
| `compute` | Instância OCI | IP público `none`/`ephemeral`/`reserved`, `user_data`, hostname DNS, Fault Domain |
| `bucket` | Bucket privado no Object Storage | Versionamento habilitado; guarda o state remoto |
| `loadbalancer` | OCI Load Balancer flexível | Alternativa disponível, não usada nesta solução |

As VMs são criadas sem tags livres (somente as tags padrão da Oracle). Cada módulo tem `README.md`, `versions.tf` (provider `oracle/oci ~> 8.0`), variáveis com descrição e validação, e outputs com descrição.

## Arquitetura resumida

| Componente | Subnet | IP público | Recursos | NSG |
|---|---|---|---|---|
| SRV-NPM-PRD01 | DMZ 10.0.1.0/24 (pública) | Efêmero | 1 OCPU, 4 GB | NSG-NPM |
| SRV-JUMP-PRD01 | JUMP 10.0.3.0/24 (pública) | Efêmero | 1 OCPU, 4 GB | NSG-JUMP |
| SRV-MONITORAMENTO-PRD01 | Privada 10.0.2.0/24 | Não | 1 OCPU, 6 GB | NSG-MONITORAMENTO |
| SRV-IANWEB-APP01 e APP02 | Privada 10.0.2.0/24 | Não | 1 OCPU, 2 GB cada | NSG-WEB |

Regras principais:

| NSG | Entrada permitida |
|---|---|
| NSG-NPM | 80 e 443 de qualquer origem; 81 (UI do NPM) e 3000 (Grafana, via NPM) **somente do IP da Globalsys**; 22 do jump; 9100 do monitoramento |
| NSG-JUMP | 22 somente do IP da Globalsys; 9100 do monitoramento |
| NSG-WEB | 80 do NPM e do monitoramento (probe); 22 do jump; 9100 do monitoramento |
| NSG-MONITORAMENTO | 3000 do NPM; 22 do jump |

Monitoramento: o Prometheus coleta métricas do `node_exporter` (porta 9100) nas 5 VMs e o `blackbox_exporter` testa a disponibilidade HTTP das apps e da URL pública. O Grafana exibe os dashboards.

## Pré-requisitos

- Terraform >= 1.12 (o backend `oci` exige 1.12 ou superior)
- Usuário OCI com chave de API e permissão no compartment GlobalAcademy-Ian
- IP(s) público(s) da Globalsys que poderão acessar o jump por SSH
- OCID do compartment GlobalAcademy-Ian (console OCI: Identity > Compartments)
- Imagem Oracle Linux compatível com o shape (A1.Flex exige aarch64)

## O que é a pasta `bootstrap`

O state do Terraform fica em um bucket do Object Storage, e o bucket precisa existir antes do `terraform init` do ambiente. A pasta `bootstrap` cria esse bucket uma única vez, com state local. Depois disso ela não é mais usada, e o bucket não é destruído junto com o ambiente. Se preferir, o bucket também pode ser criado manualmente no console e a pasta ignorada.

## Execução manual

1. **Bucket do state (uma única vez):**

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # preencher os valores
terraform init && terraform apply              # anote os outputs bucket e namespace
```

2. **Ambiente:**

```bash
cd environments/GlobalAcademy-Ian
cp terraform.tfvars.example terraform.tfvars   # preencher os valores
cp backend.hcl.example backend.hcl             # bucket, namespace e credenciais
terraform init -backend-config=backend.hcl
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Depois do primeiro `init`, versione o `.terraform.lock.hcl`. Para valer no GitHub e nas máquinas da equipe:
`terraform providers lock -platform=linux_amd64 -platform=windows_amd64 -platform=darwin_arm64`.

## Pipeline (GitHub Actions)

Arquivo: `.github/workflows/terraform.yml`. Um único job, com três etapas:

| Etapa | Quando roda |
|---|---|
| 1. Validate (fmt e validate) | Sempre |
| 2. Plan | Sempre |
| 3. Apply | **Somente manual:** Actions > Terraform > Run workflow |

Push na `main` e pull requests rodam só as etapas 1 e 2. O apply usa o plan gerado no mesmo run.

**Configuração no repositório (Settings > Secrets and variables > Actions):**

| Tipo | Nome | Conteúdo |
|---|---|---|
| Secret | `OCI_TENANCY_OCID`, `OCI_USER_OCID`, `OCI_FINGERPRINT` | Dados da chave de API |
| Secret | `OCI_PRIVATE_KEY` | Conteúdo do `.pem` da chave de API |
| Variable | `OCI_REGION`, `OCI_NAMESPACE`, `TF_STATE_BUCKET` | Região, namespace e bucket do state |
| Variable | `OCI_COMPARTMENT_ID` | OCID do compartment GlobalAcademy-Ian |
| Variable | `OCI_IMAGE_ID` | Imagem das VMs |
| Variable | `ADMIN_CIDRS` | Lista JSON, ex.: `["203.0.113.10/32"]` |

Permissões OCI (ponto de partida, ajustar com o administrador): gerenciar `virtual-network-family` e `instance-family` no compartment, e `manage objects` no bucket de state.

## Acesso à aplicação e às interfaces (sem domínio)

Todo o acesso usa o IP público do NPM (output `npm_public_ip`):

| O quê | Como | Quem acessa |
|---|---|---|
| Aplicação | `http://<npm_public_ip>` (80) e `https://<npm_public_ip>` (443, certificado autoassinado, pois não há domínio) | Qualquer origem |
| UI do NPM | `http://<npm_public_ip>:81` | Somente o IP da Globalsys |
| Grafana | `http://<npm_public_ip>:3000` (encaminhado pelo NPM para o monitoramento) | Somente o IP da Globalsys |

O NPM balanceia o tráfego 80/443 entre SRV-IANWEB-APP01 e APP02.

## Acesso administrativo (jump server)

O único ponto de entrada SSH é o **SRV-JUMP-PRD01**, com IP público e porta 22 liberada somente para os IPs da Globalsys (`admin_cidrs`). As demais VMs só aceitam SSH vindo do jump. O IP do jump aparece no output `jump_public_ip`. O usuário padrão da imagem Oracle Linux é `opc`.

> Desenho de laboratório: o jump tem IP público para facilitar o acesso. Em produção, o ideal é que ele fique em subnet privada e seja alcançado por VPN IPSec (DRG e CPE).

## Destruição do ambiente

```bash
cd environments/GlobalAcademy-Ian
terraform destroy
```

Remove somente os recursos criados pelo Terraform. O compartment GlobalAcademy-Ian e o bucket de state não são afetados.
