# Playbook

- Created a new VPC with an example web application in `sandbox.tf`

- Comment out SSH key name on line one of `terraform.tfavrs`
- Update the name of the S3 bucket in `terraform/providers.tf` line 21 and 29.
  - verify other settings in `terraform/providers.tf`
- Update `transit_gateway_name` on line 202 of terraform.tfvars. 
  - Note that `create_tgw` should be set to `false` in terraform.tfavrs on line 205.
- Update the `vm-auth-key` on line 118 and 139 of `terraform.tfvars`

## Terraform

Perform these steps on call with PS engineer.

```sh
# say yes to preserve existing state by copying to new S3 backend. 
terraform init --migrate-state 
terraform validate
terraform plan -out njcourts.plan -var-file=terraform.tfvars
terraform apply "njcourts.plan" 
```

- This will create a new test instance in the Security VPC as requested.
- Also a new web app VPC will be created for testing GWLB and routing.

## Ubuntu Instance

- We now create a "test" ec2 instance in `testing.tf` via Terraform.
- Verify that you can log in to the new Ubuntu instance in the Security VPC.
- Make sure there is a rule in security group `nj-courts-fw-mgmt` for traffic originating from `10.243.146.0/23`

```sh
ssh ubuntu@54.90.57.165 -i ~/.ssh/id_rsa
sudo apt update && sudo apt upgrade -y
# attempt to ping mgmt interface of fw1 from test instance
ping -c1 10.243.146.14
```

## Panorama

### Template

These steps may be completed prior to our meeting time.

- Create one new Baseline template (panorama -> templates)
  - suggest name: `TPL-GWLB`
- Create a Virtual Router in the network template (Templates -> Network -> Virtual Routers)
  - The VR is will be "empty", no routes will be set in the VR.
  - (unless you are doing overlay routing, overlay routing not in reference architecture and not recommended)
- Make sure the correct template is selected from the drop down.
- Create the zones.

| Zone Name | Interface  | Type |
|---|---|---|
| GWLB      | Int 1/1    | L3   |
| INBOUND   | Int 1/1.10 | L3   |
| OUTBOUND  | Int 1/1.20 | L3   |
| EASTWEST  | Int 1/1.30 | L3   |

- Create interfaces in the network template (template -> network - interfaces)
  - You must have a Virtual router and a zone to create a sub-interface.
  - Once you assign the sub-interfaces to the VR, they populate the routing.
  - In the IPv4 tab, select the DHCP radio button.
  - This should be assigned to the new virtual router.
  - Note the example tag numbers. Tag numbers are required.

Example:

![example](../docs/images/interfaces.png)

## Sandbox Networking

- Create an application load balancer like `nj-courts-alb`
  - Create a target group like `nj-courts-tg` pointing to IP address of web host in web b subnet.
- Associate the web app security group with the ALB.
- Verify a listener exists for port 80.
- Ensure an inbound SG rule exists for 0.0.0.0/0 port 80.

### Sandbox Subnets

| Subnet Name | CIDR | Route Table |
| --- |  --- | --- |
| app1_gwlbea | 10.243.148.32/28 | app1_gwlbea |
| app1_gwlbeb | 10.243.149.32/28 | app1_gwlbeb |
| app1_alba | 10.243.148.0/28 | app1_alba |
| app1_albb | 10.243.149.0/28 | app1_albb |
| app1_weba | 10.243.148.64/28 | app1_weba |
| app1_webb | 10.243.149.64/28 | app1_webb |

### Endpoints & Edge RT

Internet gateway `NetworkTeam-Sandbox-Test-VPC-igw` has an edge association with route table
`NetworkTeam-Sandbox-Test-VPC-igw`.

| VPC Endpoint | Subnet |
| --- |  --- |
| NetworkTeam-Sandbox-Test-VPC-gwlb-endpointa | 10.243.148.0/28 |
| NetworkTeam-Sandbox-Test-VPC-gwlb-endpointa | 10.243.148.64/28 |
| NetworkTeam-Sandbox-Test-VPC-gwlb-endpointb | 10.243.149.0/28	|
| NetworkTeam-Sandbox-Test-VPC-gwlb-endpointb | 10.243.149.64/28 |

- Install VM series AWS plug-in from the UI of each firewall.
  - (We have an open feature request to get this updated)
  - Fraom Panorama (templates -> device -> vm-series , select template, AWS tab. COmmit and push)


```sh
admin@nj-courts-fw-02> show plugins vm_series aws 
> gwlb   Show AWS Gateway Load Balancer settings
> ha     ha 

admin@nj-courts-fw-02> show plugins vm_series aws gwlb

    GWLB enabled    :    True
    Overlay Routing :    False
    ================================================
    VPC endpoint              Interface      
    ================================================

admin@nj-courts-fw-02> 
```

- Find the GWLB in AWS console `security-gwlb`
- Determine the VPC endpoints, gather from AZ A and AZ B
  - In AWS console: VPC -> endpoints -> endpoint ID
- Create endpoints in the AWS console if needed, find by service name.
  - This configuration may not have been part of the automated deployment we did to bring up FWs.
- Edit this set of CLI commands. Run the whole set directly on CLI of both firewalls:

```sh
# INBOUND
request plugins vm_series aws gwlb associate vpc-endpoint vpce-094fb5891fe8c375c interface ethernet1/1.10
request plugins vm_series aws gwlb associate vpc-endpoint vpce-09bc0a9060c0ece67 interface ethernet1/1.10
# OUTBOUND
request plugins vm_series aws gwlb associate vpc-endpoint vpce-0684c619325b27e9b interface ethernet1/1.20
request plugins vm_series aws gwlb associate vpc-endpoint vpce-0cbffacdc1557bf36 interface ethernet1/1.20
# EASTWEST
request plugins vm_series aws gwlb associate vpc-endpoint vpce-08ea8c967cc2d9c05 interface ethernet1/1.30
request plugins vm_series aws gwlb associate vpc-endpoint vpce-0d306321a02403377 interface ethernet1/1.30
```

- Verify on each firewall CLI using the command `show plugins vm_series aws gwlb`. No `commit` is required.

Example output: 

```sh
admin@nj-courts-fw-02> show plugins vm_series aws gwlb                                                          
    GWLB enabled    :    True
    Overlay Routing :    False
    ================================================
    VPC endpoint              Interface      
    ================================================
    vpce-0cbffacdc1557bf36    ethernet1/1.20 
    vpce-09bc0a9060c0ece67    ethernet1/1.10 
    vpce-094fb5891fe8c375c    ethernet1/1.10 
    vpce-08ea8c967cc2d9c05    ethernet1/1.30 
    vpce-0684c619325b27e9b    ethernet1/1.20 
    vpce-0d306321a02403377    ethernet1/1.30 

admin@nj-courts-fw-02> 
```

### Sandbox VPC Routes

| Route Table | next hop| Subnet |
| --- |  --- | --- |
| app1_alba | local | 10.243.148.0/23 |
| app1_alba | vpce | 0.0.0.0/0 |
| app1_albb | local | 10.243.148.0/23 |
| app1_albb | vpce | 0.0.0.0/0 |
| app1_gwlbea | local | 10.243.148.0/23 |
| app1_gwlbea | igw | 0.0.0.0/0 |
| app1_gwlbeb | local | 10.243.148.0/23 |
| app1_gwlbeb | igw | 0.0.0.0/0 |
| app1_weba | local | 10.243.148.0/23 |
| app1_weba | tgw | 0.0.0.0/0 |
| app1_webb | local| 10.243.148.0/23 |
| app1_webb | tgw | 0.0.0.0/0 |

### Route Tables

| Route Table | next hop| Subnet |
| --- |  --- | --- |
| main (unnamed) | local | 10.243.148.0/23 |
| from-gwlbe-to-igw | igw_as_next_hop_set | app1_gwlbe |
| from-web-to-tgw | app1_transit_gateway_attachment | app1_web |
| from-alb-to-gwlbe | app1_gwlbe_inbound | app1_alb |

## TGW Route Tables

Perform these steps on call with PS engineer.

- A route table is created by Terraform for the security and web app VPC.
- The value of the variable `prefix_name_tag` is prepended to the name of the route tables.
  - This is set in `variables.tf` and often overridden in `terraform.tfvars` so be sure to check both places.
- The route tables are declared in `terraform.tfvars` like so:

```hcl
transit_gateway_route_tables = {
  "from_security_vpc" = {
    create = true
    name   = "from_security"
  }
  "from_spoke_vpc" = {
    create = true
    name   = "from_spokes"
  }
}
```

| TGW Route Table | Propagation |
| --- |  --- |
| nj-courts-from_security | app vpc |
| nj-courts-from_spokes | security vpc |

### From Spoke VPC - Associations and Propagations

Note that TGW RT's are found under TGW rather than the usual Route Table section.

1. Find the `nj-courts-from_spokes` TGW route table.
1. Under the associations tab, Verify you see a TGW attachment named `NetworkTeam-Sandbox-Test-VPC-TGW-Attach` or similar.
1. In the propagations tab, create a propagation for `NetworkTeam-Sandbox-Test-VPC-TGW-Attach`.

### From Security VPC - Associations and Propagations

Note that TGW RT's are found under TGW rather than the usual Route Table section.

1. Find the `nj-courts-from_security` TGW route table.
1. Under the associations tab, Verify you see a TGW attachment named `security-vpc` or similar.
1. In the propagations tab, create a propagation for `NetworkTeam-Sandbox-Test-VPC-TGW-Attach`.

## NAT Gateways

Two NAT Gateways are created in the Network Security VPC, one in each AZ.

- Each NAT GW is assigned a private IP from the `nj-courts-natgwa` or `nj-courts-natgwb` subnet, respectively.
- Each NAT GW is assigned an EIP.

## Sandbox Instance

There are two availability zones in the VPC. An application load balancer is meant to
distribute traffic across the application servers, simple web servers in this case.

You can temporarily add a route for the EIP in the main route table for SSH into the Sandbox
VPC during initial configuration, but the desired end state is to have most traffic passed to
the security VPC for inspection. Traffic that originates from certain trusted internal sources
may not need to be sent to the Security VPC for inspection, but these cases should be considered
exceptional.

- Edit the inbound security group rules for `app1_web`
  - Note that you can make a more permanent change in Terraform if you add your IP as a /32 in the `ssh-from-inet` under the `app1_vpc_security_groups` section in `terraform.tfvars` file.
- Attempt to SSH to the instance. 

```sh
ssh 54.159.222.214 -l ubuntu -i ~/.ssh/id_rsa
```

### Install Nginx on App Servers

You can make a test web server on this instance.

## Health Checks

### Create Management Profile

[Create Management Profile](https://docs.paloaltonetworks.com/pan-os/9-1/pan-os-admin/networking/configure-interfaces/use-interface-management-profiles-to-restrict-access.html)

- Make sure the correct template is selected
- In Panorama go to Network - Network Profiles -> Interface Mgmt and click Add.
- Name "AWS-HEALTH-CHECKS"
- Allow HTTP
- Edit permitted IP addresses.
- Save it and assign it to the main/data network interface (not sub interfaces) ethernet 1/1
- Push and commit.

### Verify

- Underneath load balancers in EC2 -> Target Groups -> "nj-courts-security-gwlb"
- The details tab will show "healthy" after a few minutes.
