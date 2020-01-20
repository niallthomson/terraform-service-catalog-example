resource "null_resource" "trigger" {
  # Make sure this rebuilds on every run
  triggers = {
    timestmap = "${timestamp()}"
  }
}