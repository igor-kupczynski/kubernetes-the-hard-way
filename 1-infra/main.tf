provider "google" {
  project = var.project
  region  = "us-west1"
  zone    = "us-west1-c"
}

resource "google_compute_network" "kubernetes-the-hard-way" {
  name                    = "${var.prefix}-kubernetes-the-hard-way"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kubernetes" {
  name          = "${var.prefix}-kubernetes"
  ip_cidr_range = "10.240.0.0/24"
  network       = google_compute_network.kubernetes-the-hard-way.id
}

resource "google_compute_firewall" "kubernetes-the-hard-way-allow-internal" {
  name    = "${var.prefix}-kubernetes-the-hard-way-allow-internal"
  network = google_compute_network.kubernetes-the-hard-way.id

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "10.240.0.0/24",
    "10.200.0.0/16"
  ]
}

resource "google_compute_firewall" "kubernetes-the-hard-way-allow-external" {
  name    = "${var.prefix}-kubernetes-the-hard-way-allow-external"
  network = google_compute_network.kubernetes-the-hard-way.id

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_address" "kubernetes-the-hard-way" {
  name = "${var.prefix}-kubernetes-the-hard-way"
}

resource "google_compute_instance" "controller" {
  count = "3"

  name         = "${var.prefix}-controller-${count.index}"
  machine_type = "e2-standard-2"

  tags = ["kubernetes-the-hard-way", "controller"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.kubernetes.id
    network_ip = "10.240.0.1${count.index}"
    access_config {}
  }

  service_account {
    scopes = [
      "compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"
    ]
  }
}