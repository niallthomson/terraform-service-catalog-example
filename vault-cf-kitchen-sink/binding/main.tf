data "terraform_remote_state" "instance" {
  backend = "remote"
  config = {
    organization = "${var.terraform_organization}"
    workspaces = {
      name = "${var.terraform_instance_workspace}"
    }
  }
}

locals {
  vault_url = "https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip"
  role_name = "instance-${var.service_binding_id}"
}

# We have to do this with a null_resouce since the Vault provider doesnt support CF operations yet
resource "null_resource" "cf_role" {
  provisioner "local-exec" {
    command = <<EOT
set -e
wget -O vault.zip -q ${local.vault_url} && unzip -o vault.zip && chmod +x vault && rm vault.zip

./vault write auth/${var.cf_backend}/roles/${local.role_name} \
  bound_application_ids=${var.application_guid} \
  policies=${data.terraform_remote_state.instance.vault_policy_name} \
  disable_ip_matching=true

EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
set -e
wget -O vault.zip -q ${local.vault_url} && unzip -o vault.zip && chmod +x vault && rm vault.zip

./vault delete auth/${var.cf_backend}/roles/${local.role_name}

EOT
  }
}