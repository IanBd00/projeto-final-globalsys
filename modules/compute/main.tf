resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  fault_domain        = var.fault_domain
  display_name        = var.name
  shape               = var.shape
  freeform_tags       = var.freeform_tags

  dynamic "shape_config" {
    for_each = var.shape_config != null ? [var.shape_config] : []

    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id              = var.subnet_id
    nsg_ids                = var.nsg_ids
    hostname_label         = var.hostname_label
    assign_public_ip       = var.public_ip_mode == "ephemeral"
    skip_source_dest_check = false
    freeform_tags          = var.freeform_tags
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = merge(
    { 
      ssh_authorized_keys = coalesce(var.ssh_public_key, tls_private_key.ssh.public_key_openssh) 
    },
    var.user_data != null ? { user_data = base64encode(var.user_data) } : {},
    var.extra_metadata,
  )

  is_pv_encryption_in_transit_enabled = true
  preserve_boot_volume                = false

  lifecycle {
    # Uma nova versão da imagem não deve recriar a VM em produção.
    ignore_changes = [source_details[0].source_id]
  }
}

# IP público reservado: sobrevive a recriações da VM e mantém o mesmo endereço no DNS.
data "oci_core_private_ips" "primary" {
  count = var.public_ip_mode == "reserved" ? 1 : 0

  ip_address = oci_core_instance.this.private_ip
  subnet_id  = var.subnet_id
}

resource "oci_core_public_ip" "reserved" {
  count = var.public_ip_mode == "reserved" ? 1 : 0

  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = "${var.name}-public-ip"
  private_ip_id  = data.oci_core_private_ips.primary[0].private_ips[0].id
  freeform_tags  = var.freeform_tags
}
