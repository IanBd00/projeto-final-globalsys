module "vcn" {
  source = "../../modules/vcn"

  compartment_id = var.compartment_id
  name           = local.names.vcn
  cidr_block     = var.vcn_cidr
  dns_label      = var.vcn_dns_label

  subnets = {
    DMZ = {
      cidr_block = var.dmz_subnet_cidr
      type       = "public"
      dns_label  = "dmz"
    }
    JUMP = {
      cidr_block = var.jump_subnet_cidr
      type       = "public"
      dns_label  = "jump"
    }
    PRIVATE = {
      cidr_block = var.private_subnet_cidr
      type       = "private"
      dns_label  = "private"
    }
  }
}

module "nsg" {
  source = "../../modules/nsg"

  compartment_id = var.compartment_id
  vcn_id         = module.vcn.id
  nsgs           = local.nsgs
}

module "compute" {
  source   = "../../modules/compute"
  for_each = local.instances

  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain
  fault_domain        = each.value.fault_domain
  name                = each.value.name
  hostname_label      = lower(each.value.name)
  shape               = var.instance_shape
  shape_config        = { ocpus = each.value.ocpus, memory_in_gbs = each.value.memory_in_gbs }
  subnet_id           = module.vcn.subnet_ids[each.value.subnet]
  nsg_ids             = [module.nsg.ids[each.value.nsg]]
  public_ip_mode      = each.value.public_ip_mode
  image_id            = var.image_id
  ssh_public_key      = var.ssh_public_key
}

resource "local_file" "private_keys" {
  for_each        = module.compute
  content         = each.value.private_key_pem
  filename        = "${path.module}/keys/${each.value.name}.pem"
  file_permission = "0600"
}