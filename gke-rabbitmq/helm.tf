variable "helm_version" {
  default = "v2.9.1"
}

provider "helm" {
  tiller_image = "gcr.io/kubernetes-helm/tiller:${var.helm_version}"

  kubernetes {
    host                   = "${google_container_cluster.default.endpoint}"
    token                  = "${data.google_client_config.current.access_token}"
    client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "google_compute_address" "default" {
  name   = "instance-${var.service_instance_id}"
}

resource "random_password" "password" {
  length = 16
  special = false
}

resource "helm_release" "rabbitmq" {
  name  = "rabbitmq"
  chart = "stable/rabbitmq-ha"

  values = [<<EOF
rabbitmqUsername: ${var.user}
rabbitmqPassword: ${random_password.password.result}
service:
  clusterIP: ""
  type: LoadBalancer
  loadBalancerIP: ${google_compute_address.default.address}
EOF
  ]
}

output "uri" {
  value = "amqp://${var.user}:${random_password.password.result}@${google_compute_address.default.address}:5672/"
}