variable "service_instance_id" {

}

variable "user" {
  default = "masteruser"
}

variable "instance_class" {
  default = "db-f1-micro"
}

variable "disk_size" {
  default = "20"
}

variable "multi_az" {
  default = "false"
}