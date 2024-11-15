// This connector allows the cloud function to make calls to the GKE cluster VPC
// gcloud compute networks vpc-access connectors describe ps-devsecops-vpc-conn --region us-central1
resource "google_vpc_access_connector" "connector" {
  provider       = google-beta
  project        = var.project_id
  name           = var.connector_id
  region         = var.region
  network        = "ps-devsecops-vpc"
  ip_cidr_range  = "10.9.0.0/28"
  //min_instances  = 2
  //max_instances  = 3
  //max_throughput = 300
}
