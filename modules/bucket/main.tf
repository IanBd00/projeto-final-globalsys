data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "this" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = var.name
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  versioning     = var.versioning
  freeform_tags  = var.freeform_tags
}
