resource "google_sql_database_instance" "master" {
  name             = "instance-${var.service_instance_id}"
  database_version = "POSTGRES_9_6"

  settings {
    tier = "${var.instance_class}"

    availability_type = "${var.multi_az ? "REGIONAL" : "ZONAL"}"

    disk_size        = "${var.disk_size}"
    disk_autoresize  = false

    ip_configuration {
        ipv4_enabled        = true
        authorized_networks {
            value           = "0.0.0.0/0"
        }
    }
  }
}

resource "google_sql_database" "database" {
  name     = "mydb"
  instance = "${google_sql_database_instance.master.name}"

  depends_on = ["google_sql_user.user"]
}

resource "random_password" "password" {
  length = 16
  special = false
}

resource "google_sql_user" "user" {
  name     = "${var.user}"
  instance = "${google_sql_database_instance.master.name}"
  password = "${random_password.password.result}"
}

output "uri" {
  value = "postgres://${var.user}:${random_password.password.result}@${google_sql_database_instance.master.public_ip_address}:5432/${google_sql_database.database.name}"
}

output "jdbcUrl" {
  value = "jdbc:postgresql://${google_sql_database_instance.master.public_ip_address}:5432/${google_sql_database.database.name}?user=${var.user}&password=${random_password.password.result}"
}