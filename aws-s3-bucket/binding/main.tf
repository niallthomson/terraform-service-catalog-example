data "terraform_remote_state" "instance" {
  backend = "remote"
  config = {
    organization = "${var.terraform_organization}"
    workspaces = {
      name = "${var.terraform_instance_workspace}"
    }
  }
}

resource "aws_iam_access_key" "key" {
  user = "${data.terraform_remote_state.instance.user}"
}