resource "aws_s3_bucket" "bucket" {
  bucket = "instance-${var.service_instance_id}"
  acl    = "private"
  
  force_destroy = "true"
}

resource "aws_iam_user" "user" {
  name = "instance-${var.service_instance_id}"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user_policy" "policy" {
  name = "default"
  user = "${aws_iam_user.user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"]
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "key" {
  user = "${aws_iam_user.user.name}"
}

resource "vault_aws_secret_backend" "aws" {
  access_key = "${aws_iam_access_key.key.id}"
  secret_key = "${aws_iam_access_key.key.secret}"

  path       = "instance-${var.service_instance_id}-aws"
}

resource "vault_aws_secret_backend_role" "role" {
  backend = "${vault_aws_secret_backend.aws.path}"
  name    = "role"
  credential_type = "iam_user"

  policy_document = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["${aws_s3_bucket.bucket.arn}"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["${aws_s3_bucket.bucket.arn}/*"]
        }
    ]
}
EOT
}

output "bucket_name" {
  value = "${aws_s3_bucket.bucket.bucket}"
}

output "vault_aws_backend" {
  value = "${vault_aws_secret_backend.aws.path}"
}