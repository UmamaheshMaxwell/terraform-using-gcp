/*
  * Provider for creating resources in google cloud
*/
provider "google" {
  #project = "gcp-training-377619"
  project = var.project
  region = var.region
  credentials = file("accounts.json")
}

/*
  * Create a Auto VPC
*/

resource "google_compute_network" "tf_vpc_network" {
  name = "terraform-vpc"
}

/*
  * Create a custom VPC
*/

resource "google_compute_network" "tf_custom_vpc_network" {
  name = "terraform-custom-vpc"
  auto_create_subnetworks= false
}

/*
  * Create a subnet
  & Subnet Name
  & Region
  & CIDR Range
  & Network
*/

resource "google_compute_subnetwork" "tf_subnet_a" {
  name          = "subnet-a"
  ip_cidr_range = "10.2.0.0/16"
  region        =var.region
  network       = google_compute_network.tf_custom_vpc_network.id
  #network = "terraform-custom-vpc"
}

/*
  * Create a firewall rule
*/
resource "google_compute_firewall" "tf_firewall" {
  name = "terraform-firewall-rules"
  network = google_compute_network.tf_custom_vpc_network.id

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["22","80", "1000-2000"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web"]
}

/*
  * Create a VM
*/

resource "google_compute_instance" "tf_VM_instance" {
  name = "terraform-vm"
  machine_type = "f1-micro"
  zone = var.zone
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.tf_vpc_network.name
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}

/*
  * Create a static IP
*/

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

/*
  * Create a GCS Bucket
*/

resource "google_storage_bucket" "tf_gcs_bucket" {
  name = "uma-bucket-${random_id.bucket_id.dec}"
  location = "EU"
  storage_class = "coldline"
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

terraform {
  backend "gcs" {
    bucket  = "uma-bucket-6344478412385366227"
    prefix  = "terraform/state"
    credentials = "accounts.json"
  }
}
