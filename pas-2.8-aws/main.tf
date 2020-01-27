resource "random_id" "name" {
  byte_length = 4
}

module "paasify" {
  source       = "github.com/nthomson-pivotal/pcf-paasify//terraform/aws?ref=2.8"

  env_name     = "${random_id.name.hex}"
  dns_suffix   = "${var.dns_suffix}"
  pivnet_token = "${var.pivnet_token}"

  auto_apply   = "1"

  compute_instance_count = "1"

  tiles        = []
}

output "opsman_ssh_private_key" {
  value = "${module.paasify.opsman_ssh_private_key}"
}

output "opsman_host" {
  value = "${module.paasify.opsman_host}"
}

output "opsman_user" {
  value = "admin"
}

output "opsman_password" {
  value = "${module.paasify.opsman_password}"
}

output "cf_api_endpoint" {
  value = "${module.paasify.cf_api_endpoint}"
}