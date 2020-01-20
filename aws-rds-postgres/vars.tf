variable "service_instance_id" {

}

variable "multi_az" {
  default = "false"
}

variable "user" {
  default = "masteruser"
}

variable "instance_class" {
  default = "db.t2.large"
}

variable "disk_size" {
  default = "20"
}