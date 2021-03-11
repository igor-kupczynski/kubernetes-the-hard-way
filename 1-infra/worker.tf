resource "google_compute_instance" "worker" {
  count = "3"

  name      = "${var.prefix}-worker-${count.index}"
  tags      = ["kubernetes-the-hard-way", "worker"]

  machine_type = "e2-standard-2"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.kubernetes.id
    network_ip = "10.240.0.2${count.index}"
    access_config {}
  }

  service_account {
    scopes = [
      "compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"
    ]
  }

  metadata = {
    "pod-cidr" = "10.200.${count.index}.0/24"
  }
}

resource "google_compute_route" "kubernetes-worker-cidr-route" {
  count = 3

  name = "${var.prefix}-kubernetes-route-10-200-${count.index}-0-24"

  network = google_compute_network.kubernetes-the-hard-way.id

  # TODO: read from worker.*
  next_hop_ip = "10.240.0.2${count.index}"
  dest_range  = "10.200.${count.index}.0/24"
}
