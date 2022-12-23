# VPC
resource "google_compute_network" "vpc_network" {
  name = "gcpvpc"
}

# subnet
resource "google_compute_subnetwork" "public" {
  name          = "public-subnetwork"
  ip_cidr_range = "172.17.0.0/25"
  region        = "asia-northeast1"
  network       = google_compute_network.vpc_network.id
}

# firewall
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh"]
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "vm01"
  machine_type = "e2-micro"
  zone         = "asia-northeast1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Flask
  # metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.public.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
