output "vault_addr" {
  value = "${data.terraform_remote_state.instance.vault_addr}"
}

output "vault_cf_role" {
  value = "${local.role_name}"
}

output "vault_cf_backend" {
  value = "${var.cf_backend}"
}

output "vault_role" {
  value = "${data.terraform_remote_state.instance.vault_role}"
}

output "vault_transit_backend" {
  value = "${data.terraform_remote_state.instance.vault_transit_backend}"
}

output "vault_transit_key" {
  value = "${data.terraform_remote_state.instance.vault_transit_key}"
}

output "vault_aws_backend" {
  value = "${data.terraform_remote_state.instance.vault_aws_backend}"
}

output "bucket_name" {
  value = "${data.terraform_remote_state.instance.bucket_name}"
}

output "vault_database_backend" {
  value = "${data.terraform_remote_state.instance.vault_database_backend}"
}

output "jdbc_uri" {
  value = "${data.terraform_remote_state.instance.jdbc}"
}