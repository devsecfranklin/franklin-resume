location             = "Norway East"
resource_group_name  = "ps-automation-dev"
vnet_name            = "ps-automation-dev-mgmt"
address_space        = ["10.10.16.0/21", "10.10.8.0/21"]
storage_account_name = "franklinxyz321"
tags = {
  ps-automation = "development",
  owner         = "Łukasz Stadnik"
}

subnet_names    = ["panorama_mgmt"]
subnet_prefixes = ["10.10.16.0/28"]

//Put your public IP address to access Panorama GUI
management_ips = {
  "68.38.137.81" : 100,
  //"34.99.247.242" : 101, // Łukasz Stadnik 
  "34.99.247.0/24" : 102,
}

/*
firewall_mgmt_prefixes = [
  "10.11.40.64/27", // Global Protect Mgmt subnet
  "10.11.40.192/27"
]
*/

enable_zones = true
p1_avzone    = "1"
p2_avzone    = "2"

//primary_panorama_private_ip_address   = "10.11.43.241"
//secondary_panorama_private_ip_address = "10.11.43.242"
