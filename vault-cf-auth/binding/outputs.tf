output "role" {
  value = "instance-${var.service_binding_id}"
}

output "mount" {
  value = "${data.terraform_remote_state.instance.mount}"
}

output "vault_addr" {
  value = "${data.terraform_remote_state.instance.vault_addr}"
}