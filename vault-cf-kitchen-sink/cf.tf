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
rm vault vault_1.3.1_linux_amd64.zip
EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
set -e
wget -q https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip && unzip vault_1.3.1_linux_amd64.zip && chmod +x vault
./vault delete auth/cf/roles/instance-${var.service_instance_id}
rm vault vault_1.3.1_linux_amd64.zip
EOT
  }
}

output "vaultcfrole" {
  value = "instance-${var.service_instance_id}"
}