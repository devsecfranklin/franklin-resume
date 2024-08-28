/* Cloud NAT

- The could nat should allow egress from mgmt and public subnets
- You can have both Public NAT and Private NAT gateways offering NAT services to the same subnet in a VPC network.

Public NAT lets Google Cloud resources that do not have public IP addresses communicate
with the internet. These VMs use a set of shared public IP addresses to connect to the
internet. Public NAT does not rely on proxy VMs. Instead, a Public NAT gateway allocates
a set of external IP addresses and source ports to each VM that uses the gateway to
create outbound connections to the internet.

*/

## Create Nat Gateway
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  name    = "${var.name_prefix}-cloud-router"
  project = var.project_id
  network = data.google_compute_network.mgmt-vpc.name
  region  = var.region

  nats = [{
    name                               = "${var.name_prefix}-cloud-nat"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  }]
}

resource "google_compute_subnetwork" "gke-subnet" {
  name                     = "${var.name_prefix}-gke-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = data.google_compute_network.mgmt-vpc.name
  ip_cidr_range            = "10.249.0.0/25"
  private_ip_google_access = true

  /* A named secondary range is mandatory for a private cluster

  While using a secondary IP range is recommended in order to to separate
  cluster master and pod IPs, when using a network in the same project as
  your GKE cluster you can specify a blank range name to draw alias IPs
  from your subnetwork's primary IP range. If using a shared VPC network
  (a network from another GCP project) using an explicit secondary range is
  required.
  */
  secondary_ip_range = [
    {
      ip_cidr_range = "10.12.0.0/16"
      range_name    = "gke-lab-franklin-gke-pods-f23f12d3"
    },
    {
      ip_cidr_range = "10.13.0.0/22"
      range_name    = "gke-lab-franklin-gke-services-f23f12d3"
    },

  ]
}

/*
module "nginx" {
  source              = "./modules/nginx"
  nginx_chart_version = "4.0.18"
  nginx_namespace     = kubernetes_namespace.nginx.metadata[0].name
}
*/
