variable "length" {
  description = "Length of the ID"
  default = "8"  
}

resource "random_id" "default" {
  byte_length = "${var.length}"
}

output "id" {
  value = "${random_id.default.hex}"
}
