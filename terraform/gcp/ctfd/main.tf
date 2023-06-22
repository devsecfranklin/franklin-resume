/*
gcloud compute network-endpoint-groups list
*/
resource "google_compute_backend_service" "ctfd-backed-service" {
  provider                        = google-beta
  name                            = "ctfd-backend-service"
  enable_cdn                      = true
  timeout_sec                     = 10
  connection_draining_timeout_sec = 10

  //custom_request_headers  = ["host: ${google_compute_global_network_endpoint.proxy.fqdn}"]
  //custom_response_headers = ["X-Cache-Hit: {cdn_cache_status}"]

  //backend {
  //  group = google_compute_global_network_endpoint_group.external_proxy.id
  //}
  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  name = "health-check"
  http_health_check {
    port = 80
  }
}

/*
Make sure the firewall ports are open between LB and NEG nodes. This can be achieved with the below command.
Since I know I will be having only two targetPorts in services, which will be on 80 and 8080, I am exposing those ports only.

gcloud compute firewall-rules create fw-allow-health-check-and-proxy \
 --network=default \
 --action=allow \
 --direction=ingress \
 --target-tags=gke-goseccon-cluster-6d21d830-node\
 --source-ranges=130.211.0.0/22,35.191.0.0/16 \
 --rules="tcp:80,tcp:8080"
 */
 