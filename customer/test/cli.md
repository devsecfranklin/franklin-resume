# CLI

## Management Configuration

```sh
set deviceconfig system hostname lab-franklin-gcp-fw-three # set the hostname
set deviceconfig system timezone America/New_York # set the time zone
set deviceconfig system dns-setting servers primary 8.8.8.8
set deviceconfig system dns-setting servers secondary 8.8.4.4
set deviceconfig system ntp-servers primary-ntp-server ntp-server-address 1.pool.ntp.org
set deviceconfig system ntp-servers secondary-ntp-server ntp-server-address 2.pool.ntp.org
```

### Add Static Management IP

The default mgmt IP is DCHP. You can change here if desired.

```sh
delete deviceconfig system type dhcp-client
set deviceconfig system type static
set deviceconfig system ip-address 192.168.3.5 # static IP for management
set deviceconfig system netmask 255.255.255.0
set deviceconfig system default-gateway 192.168.3.1
set deviceconfig system permitted-ip 192.168.3.0/24 # whitelist access
```

### Service Route Configuration

The default behavior is, NGFW will send all management services request to management interface.
For example, licenses retrieval will be through management interface as per default settings.

- If there is no internet connectivity in your mgmt interface, you will not be able to retrieve
licenses from Palo Alto Networks support portal.
- Change route for PaloAlto Network Services from management interface to OUTSIDE interface.

```sh
set deviceconfig system route service paloalto-networks-services source interface ethernet1/1
set deviceconfig system route service paloalto-networks-services source address 192.168.0.159/24
```

## Adding interface using CLI

```sh
set network interface ethernet ethernet1/1 layer3 ip 10.236.20.18/24
set network interface ethernet ethernet1/1 comment TRUST
set zone public network layer3 ethernet1/1
set network interface ethernet ethernet1/2 layer3 ip 10.236.20.26/24
set network interface ethernet ethernet1/2 comment UNTRUST
set zone private network layer3 ethernet1/2
show network interface ethernet
commit
```

## Virtual Router Configuration with default Static route

```sh
set network virtual-router default interface [ ethernet1/1 ethernet1/2 ]
set network virtual-router default routing-table ip static-route default interface ethernet1/1192.168.0.1
set network virtual-router default routing-table ip static-route default nexthop ip-address 35.209.129.157
set network virtual-router default routing-table ip static-route default destination 0.0.0.0/0
show network virtual-router default
commit
```

## Policy Configuration

```sh
set rulebase security rules PRIVATE-TO-PUBLIC to public
set rulebase security rules PRIVATE-TO-PUBLIC from private
set rulebase security rules PRIVATE-TO-PUBLIC source 10.236.20.16/29
set rulebase security rules PRIVATE-TO-PUBLIC destination any
set rulebase nat rules OUTBOUND-NAT description EGRESS from private to public service any source 10.236.20.16/29 destination any source-translation dynamic-ip-and-port interface-address interface ethernet1/2 
# delete rulebase nat rules OUTBOUND-NAT
```

## Show and Test

Show the current config

```sh
show deviceconfig system dns-setting servers
show network interface ethernet
show network virtual-router default
show rulebase
show running nat-policy 
```

Test the current config

```sh
set network profiles interface-management-profile mgmt ping yes
set network interface ethernet ethernet1/1 layer3 interface-management-profile mgmt
set network interface ethernet ethernet1/2 layer3 interface-management-profile mgmt
```

## Cleanup

```sh
delete network virtual-router default interface # will remove all interface from virtual router
```

## Reference

- [How to Configure a Layer 3 Interface to act as a Management Port via CLI](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000ClMfCAK)
