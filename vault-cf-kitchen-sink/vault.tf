provider "vault" {

}

resource "vault_policy" "policy" {
  name = "instance-${var.service_instance_id}"

  policy = <<EOT
## MySQL
path "${vault_mount.db.path}/creds/role" {
  capabilities = ["read"]
}

## AWS
path "${vault_aws_secret_backend.aws.path}/creds/role" {
  capabilities = ["read"]
}

## Transit
path "${vault_mount.transit.path}/encrypt/default_key" {
  capabilities = ["create", "update", "read"]
}

path "${vault_mount.transit.path}/decrypt/default_key" {
  capabilities = ["create", "update", "read"]
}

path "${vault_mount.transit.path}/rotate/default_key" {
  capabilities = ["create", "update", "read"]
}

path "${vault_mount.transit.path}/rewrap/default_key" {
  capabilities = ["create", "update", "read"]
}
EOT
}

data "external" "vault_addr" {
  program = ["bash", "${path.module}/addr.sh"]
}

###### MySQL
resource "vault_mount" "db" {
  path = "instance-${var.service_instance_id}-db"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = "${vault_mount.db.path}"
  name          = "mysql"
  allowed_roles = ["role"]

  mysql {
    connection_url = "${var.user}:${random_password.password.result}@tcp(${aws_db_instance.default.endpoint})/"
  }
}

resource "vault_database_secret_backend_role" "role" {
  backend             = "${vault_mount.db.path}"
  name                = "role"
  db_name             = "${vault_database_secret_backend_connection.mysql.name}"
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON mydb.* TO '{{name}}'@'%';"]
}

###### AWS
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
            "Resource": ["arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"]
        }
    ]
}
EOT
}

###### Transit
resource "vault_mount" "transit" {
  path                      = "instance-${var.service_instance_id}-transit"
  type                      = "transit"
}

resource "vault_transit_secret_backend_key" "key" {
  backend          = "${vault_mount.transit.path}"
  name             = "default_key"
  deletion_allowed = true
}

output "vaultaddr" {
  value = "${data.external.vault_addr.result.vault_addr}"
}

output "vaultrole" {
  value = "role"
}

output "databasebackend" {
  value = "${vault_mount.db.path}"
}

output "awsbackend" {
  value = "${vault_aws_secret_backend.aws.path}"
}

output "transitbackend" {
  value = "${vault_mount.transit.path}"
}

output "keyname" {
  value = "${vault_transit_secret_backend_key.key.name}"
}