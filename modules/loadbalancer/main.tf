resource "oci_load_balancer_load_balancer" "this" {
  compartment_id             = var.compartment_id
  display_name               = var.name
  shape                      = "flexible"
  subnet_ids                 = var.subnet_ids
  is_private                 = var.is_private
  network_security_group_ids = var.nsg_ids
  freeform_tags              = var.freeform_tags

  shape_details {
    minimum_bandwidth_in_mbps = var.min_bandwidth
    maximum_bandwidth_in_mbps = var.max_bandwidth
  }
}

resource "oci_load_balancer_backend_set" "this" {
  name             = "${var.name}-bes"
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  policy           = var.policy

  health_checker {
    protocol    = "HTTP"
    port        = var.backend_port
    url_path    = var.health_check_path
    return_code = 200
  }
}

resource "oci_load_balancer_listener" "this" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "${var.name}-listener"
  default_backend_set_name = oci_load_balancer_backend_set.this.name
  port                     = var.listener_port
  protocol                 = "HTTP"
}

resource "oci_load_balancer_backend" "this" {
  for_each = var.backends

  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.this.name
  ip_address       = each.value.ip_address
  port             = each.value.port
}
