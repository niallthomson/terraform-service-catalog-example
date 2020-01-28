data "terraform_remote_state" "instance" {
  backend = "remote"
  config = {
    organization = "${var.terraform_organization}"
    workspaces = {
      name = "${var.terraform_instance_workspace}"
    }
  }
}

data "external" "cf_info" {
  program = ["bash", "${path.module}/cf.sh"]

  query = {
    opsman_host     = "${terraform_remote_state.instance.opsman_host}"
    opsman_password = "${terraform_remote_state.instance.opsman_password}"
  }
}

output "cf_password" {
  value = "${data.external.cf_info.result.cf_password}"
}