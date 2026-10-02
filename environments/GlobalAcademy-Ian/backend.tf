# Backend parcial: bucket, namespace e credenciais são informados no init
# (-backend-config=backend.hcl). Veja backend.hcl.example.
terraform {
  backend "oci" {
    key = "GlobalAcademy-Ian/terraform.tfstate"
  }
}
