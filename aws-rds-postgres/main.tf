provider "aws" {
  version = "~> 2.44.0"
}

resource "random_id" "password" {
  byte_length = 10
}

resource "aws_db_instance" "default" {
  name                     = "mydb"
  allocated_storage        = "${var.disk_size}"
  storage_type             = "gp2"
  engine                   = "postgres"
  engine_version           = "9.6.3"
  instance_class           = "${var.instance_class}"
  identifier               = "mydb-${var.service_instance_id}"
  port                     = 5432
  publicly_accessible      = true
  storage_encrypted        = true
  skip_final_snapshot      = true
  multi_az                 = "${var.multi_az}"
  username                 = "${var.user}"
  password                 = "${random_id.password.hex}"
  vpc_security_group_ids   = ["${aws_security_group.default.id}"]
}

resource "aws_security_group" "default" {
  name = "mydb-sg-${var.service_instance_id}"

  description = "RDS postgres servers (terraform-managed)"

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
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

output "uri" {
  value = "postgres://${var.user}:${random_id.password.hex}@${aws_db_instance.default.endpoint}/${aws_db_instance.default.name}"
}

output "jdbcUrl" {
  value = "jdbc:postgresql://${aws_db_instance.default.endpoint}/${aws_db_instance.default.name}?user=${var.user}&password=${random_id.password.hex}"
}
