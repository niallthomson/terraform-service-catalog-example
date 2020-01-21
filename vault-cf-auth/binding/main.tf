data "terraform_remote_state" "instance" {
  backend = "remote"
  config = {
    organization = "${var.terraform_organization}"
    workspaces = {
      name = "${var.terraform_instance_workspace}"
    }
  }
}

# We have to do this with a null_resouce since the Vault provider doesnt support CF operations yet
resource "null_resource" "cf_role" {
  provisioner "local-exec" {
    command = <<EOT
set -e
wget -q https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip && unzip vault_1.3.1_linux_amd64.zip && chmod +x vault
./vault write auth/cf/roles/instance-${var.service_binding_id} \
bound_application_ids=${var.application_guid} \
policies=${data.terraform_remote_state.instance.policy_name} \
disable_ip_matching=true
EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
set -e
wget -q https://releases.hashicorp.com/vault/1.3.1/vault_1.3.1_linux_amd64.zip && unzip vault_1.3.1_linux_amd64.zip && chmod +x vault
./vault delete auth/cf/roles/instance-${var.service_binding_id}
EOT
  }
}