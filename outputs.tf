output "IP" {
  value = google_compute_instance.tf_VM_instance.network_interface.0.access_config.0.nat_ip
}