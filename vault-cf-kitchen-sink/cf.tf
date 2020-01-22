locals {
  vault_url = "https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip"
}

# We have to do this with a null_resouce since the Vault provider doesnt support CF operations yet
resource "null_resource" "cf_role" {
  provisioner "local-exec" {
    command = <<EOT
set -e
if [ ! -f vault ]; then wget -O vault.zip -q ${local.vault_url} && unzip vault.zip && chmod +x vault && rm vault.zip; fi
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
if [ ! -f vault ]; then wget -O vault.zip -q ${local.vault_url} && unzip vault.zip && chmod +x vault && rm vault.zip; fi
./vault delete auth/cf/roles/instance-${var.service_instance_id}
EOT
  }
}

output "vaultcfrole" {
  value = "instance-${var.service_instance_id}"
}