
resource "google_compute_firewall" "lab-ingress" {
  name        = "franklin-lab-ingress"
  project     = var.project_id
  network     = "ps-devsecops-mgmt" # google_compute_network.vpc.name
  description = "Default rule restrict ingress traffic"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "2049", "3978", "8443", "28270", "28443", "28769"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  direction = "INGRESS"
  source_ranges = [
    "10.199.0.0/21",     # Azure common subnet
    "20.22.238.55/32",   # azure testing - markel
    "20.22.238.56/32",   # azure testing markel
    "20.126.113.103/32", # azure markel
    "20.126.113.109/32", # AZURE MARKEL
    "52.165.18.208/32",  # azure markel
    "52.165.18.223/32",  # azure markel
    "68.219.104.166/32", # Azure markel
    "74.234.110.238/32", # Azure Markel
    "34.66.44.164/32",   # gke cluster
    "34.136.90.64/32",   # ps-devsecops-panorama-two-10-0-4  
    "34.134.31.136/32",  # ps-devsecops-panorama-three-10-0-4 
    "35.232.129.131/32", # gcp ps-devsecops-fw01
    "52.151.200.84/32",  # Azure lab firewall number one
    "52.151.200.150/32", # Azure lab firewall number two
    "52.151.200.153/32", # azure MTA 3
    "52.151.200.97/32",  # azure MTA 4
    "68.38.137.81/32",   # Franklin lab
    "137.83.195.1/32",   # Palo Corp Global Protect
    "137.83.195.2/32",   # Palo Corp Global Protect
    "137.83.195.96/32",  # Palo Corp Global Protect
    "174.160.179.231/32" # Raneesh Nair
  ]
}
