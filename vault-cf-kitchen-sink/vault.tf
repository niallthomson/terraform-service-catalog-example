provider "vault" {

}

locals {
  vault_url = "https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip"
}

resource "vault_policy" "policy" {
  name = "instance-${var.service_instance_id}"

  policy = <<EOT
## MySQL
path "${vault_mount.db.path}/creds/role" {
  capabilities = ["read"]
}

## AWS
path "${vault_aws_secret_backend.aws.path}/creds/role" {
  capabilities = ["read"]
}

## Transit
path "${vault_mount.transit.path}/encrypt/default_key" {
  capabilities = ["create", "update", "read"]
}

path "${vault_mount.transit.path}/decrypt/default_key" {
  capabilities = ["create", "update", "read"]
}

path "${vault_mount.transit.path}/rotate/default_key" {
  capabilities = ["create", "update", "read"]
}

path "${vault_mount.transit.path}/rewrap/default_key" {
  capabilities = ["create", "update", "read"]
}
EOT
}

data "external" "vault_addr" {
  program = ["bash", "${path.module}/addr.sh"]
}

output "vault_addr" {
  value = "${data.external.vault_addr.result.vault_addr}"
}

output "vault_role" {
  value = "role"
}

output "vault_policy_name" {
  value = "${vault_policy.policy.name}"
}