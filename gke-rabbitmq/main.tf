provider "google" {
  
}

data "google_client_config" "current" {}

resource "google_compute_network" "default" {
  name                    = "instance-${var.service_instance_id}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "instance-${var.service_instance_id}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  private_ip_google_access = true
}

data "google_container_engine_versions" "default" {

}

resource "google_container_cluster" "default" {
  name               = "i${var.service_instance_id}"
  initial_node_count = 2
  min_master_version = "${data.google_container_engine_versions.default.latest_master_version}"
  network            = "${google_compute_subnetwork.default.name}"
  subnetwork         = "${google_compute_subnetwork.default.name}"

  // Use legacy ABAC until these issues are resolved: 
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = "destroy"
    command = "sleep 90"
  }
}