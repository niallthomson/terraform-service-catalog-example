output "bucket_name" {
  value = "${data.terraform_remote_state.instance.bucket_name}"
}

output "bucket_arn" {
  value = "${data.terraform_remote_state.instance.bucket_arn}"
}

output "access_key_id" {
  value = "${aws_iam_access_key.key.id}"
}

output "secret_access_key" {
  value = "${aws_iam_access_key.key.secret}"
}