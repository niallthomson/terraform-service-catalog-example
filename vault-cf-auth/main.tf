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

# We have to do this with a null_resouce since the Vault provider doesnt support CF operations yet
resource "null_resource" "cf_role" {
  provisioner "local-exec" {
    command = <<EOT
set -e
wget -q https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip && unzip vault_1.3.1_linux_amd64.zip && chmod +x vault
./vault write auth/cf/roles/instance-${var.service_instance_id} \
bound_space_ids=${var.space_guid} \
policies=${vault_policy.policy.name} \
disable_ip_matching=true
EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
set -e
wget -q https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip && unzip vault_1.3.1_linux_amd64.zip && chmod +x vault
./vault delete auth/cf/roles/instance-${var.service_instance_id}
EOT
  }
}

data "external" "example" {
  program = ["bash", "${path.module}/addr.sh"]
}

output "mount" {
    value = "${vault_mount.kv.path}"
}

output "vault_addr" {
    value = "${data.external.example.result.vault_addr}"
}

output "role" {
    value = "instance-${var.service_instance_id}"
}