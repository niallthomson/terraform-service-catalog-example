resource "vault_mount" "transit" {
  path                      = "instance-${var.service_instance_id}-transit"
  type                      = "transit"
}

resource "vault_transit_secret_backend_key" "key" {
  backend          = "${vault_mount.transit.path}"
  name             = "default_key"
  deletion_allowed = true
}

output "vault_transit_backend" {
  value = "${vault_mount.transit.path}"
}

output "vault_transit_key" {
  value = "${vault_transit_secret_backend_key.key.name}"
}