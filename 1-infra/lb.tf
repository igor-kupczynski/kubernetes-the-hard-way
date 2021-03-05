resource "google_compute_http_health_check" "kubernetes" {
  name = "${var.prefix}-http-health-check"

  host         = "kubernetes.default.svc.cluster.local"
  port         = 80
  request_path = "/healthz"
}

resource "google_compute_firewall" "kubernetes-the-hard-way-allow-health-check" {
  name = "${var.prefix}-kubernetes-the-hard-way-allow-health-check"

  network = google_compute_network.kubernetes-the-hard-way.id

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "209.85.152.0/22",
    "209.85.204.0/22",
    "35.191.0.0/16"
  ]
}

resource "google_compute_target_pool" "kubernetes-target-pool" {
  name = "${var.prefix}-kubernetes-target-pool"

  instances = google_compute_instance.controller.*.self_link

  health_checks = [
    google_compute_http_health_check.kubernetes.id
  ]
}


resource "google_compute_forwarding_rule" "kubernetes-forwarding-rule" {
  name = "${var.prefix}-kubernetes-forwarding-rule"

  target     = google_compute_target_pool.kubernetes-target-pool.id
  ip_address = google_compute_address.kubernetes-the-hard-way.address
  port_range = 6443
}