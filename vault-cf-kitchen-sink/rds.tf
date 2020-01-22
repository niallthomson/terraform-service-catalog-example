provider "aws" {
  version = "~> 2.44.0"
}

resource "random_password" "password" {
  length = 16
  special = false
}

resource "aws_db_instance" "default" {
  name                     = "mydb"
  allocated_storage        = "${var.disk_size}"
  storage_type             = "gp2"
  engine                   = "mysql"
  engine_version           = "5.7"
  parameter_group_name     = "default.mysql5.7"
  instance_class           = "${var.instance_class}"
  identifier               = "mydb-${var.service_instance_id}"
  port                     = 3306
  publicly_accessible      = true
  storage_encrypted        = true
  skip_final_snapshot      = true
  multi_az                 = "${var.multi_az}"
  username                 = "${var.user}"
  password                 = "${random_password.password.result}"
  vpc_security_group_ids   = ["${aws_security_group.default.id}"]
}

resource "aws_security_group" "default" {
  name = "mydb-sg-${var.service_instance_id}"

  description = "RDS mysql servers (terraform-managed)"

  # Only postgres in
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

  # This is terrible and I'm just doing it so I can clean up
  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
set -e
if [ ! -f vault ]; then wget -O vault.zip -q ${local.vault_url} && unzip vault.zip && chmod +x vault && rm vault.zip; fi
./vault lease revoke -prefix ${vault_mount.db.path}/creds
EOT
  }
}

resource "vault_database_secret_backend_role" "role" {
  backend             = "${vault_mount.db.path}"
  name                = "role"
  db_name             = "${vault_database_secret_backend_connection.mysql.name}"
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON mydb.* TO '{{name}}'@'%';"]
}

output "jdbc" {
  value = "jdbc:mysql://${aws_db_instance.default.endpoint}/${aws_db_instance.default.name}"
}

output "vault_database_backend" {
  value = "${vault_mount.db.path}"
}