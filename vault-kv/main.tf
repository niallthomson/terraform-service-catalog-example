provider "vault" {

}

resource "vault_mount" "kv" {
  path        = "kv-instance-${var.service_instance_id}"
  type        = "kv"
  description = "Key/Value backend provisioned through Terraform service broker"
}

resource "vault_policy" "policy" {
  name = "instance-${var.service_instance_id}"

  policy = <<EOT
path "${vault_mount.kv.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "${vault_mount.kv.path}/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_token" "token" {
  policies = ["${vault_policy.policy.name}"]

  ttl = "8760h"
}

data "external" "example" {
  program = ["bash", "${path.module}/addr.sh"]
}

output "token" {
    value = "${vault_token.token.client_token}"
}

output "mount" {
    value = "${vault_mount.kv.path}"
}

output "vault_addr" {
    value = "${data.external.example.result.vault_addr}"
}