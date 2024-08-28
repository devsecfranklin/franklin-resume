---
title: NAT design
author: Franklin D.
header-includes: |
    \usepackage{fancyhdr}
    \pagestyle{fancy}
    \fancyfoot[CO,CE]{v 0.1 | 02/20/2024 | initial version}
    \fancyfoot[LE,RO]{\thepage}
abstract: This is a DRAFT design for NAT of certain traffic between INTRANET and a secure LAN behind an HA pair of NGFW.
...

# NAT Design

## INBOUND to secure LAN

* [Here are the configuration steps for Source DIPP NAT Using Floating IP Addresses](https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-admin/high-availability/set-up-activeactive-ha/determine-your-activeactive-use-case/use-case-configure-activeactive-ha-with-source-dipp-nat-using-floating-ip-addresses)

### INBOUND Traffic Flow

1. Traffic originates from an "external" host, the greater internal network in this example. It
is assumed traffic from the Internet will not be permitted at any time.
2. Traffic reaches the HA pair of VM series FW.
3. NAT rules are applied to the traffic based on (zone? IP?)
4. Traffic is forwarded to the destination RDP server 2 on the secure LAN.

## OUTBOUND from secure LAN

* Design goal 1: prevent the "external world" from seeing the true IP of the servers
inside the protected network.

Source NAT is typically used by internal users to access the Internet; the source
address is translated and thereby kept private.

* [Source NAT IP Documentation for 10.2](https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-networking-admin/nat/source-nat-and-destination-nat/source-nat)

### Dynamic IP and Port (DIPP)

This is one of the three types of NAT available in PANOS.

DIPP allows multiple hosts to have their source IP addresses translated to the same
public IP address with different port numbers. The dynamic translation is to the
next available address in the NAT address pool, which you configure as a Translated Address
pool be to an IP address, range of addresses, a subnet, or a combination of these.

For our purposes we will have the two internal RDP servers IP address "hidden behind" a
single IPv4 address that is "visible" to the INTRANET and beyond.

* [Here are the configuration steps for Source DIPP NAT](https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-networking-admin/nat/configure-nat/translate-internal-client-ip-addresses-to-your-public-ip-address-source-dipp-nat)

### OUTBOUND Traffic Flow

1. User on one of the RDP server wants to connect to a site that is not in the secure LAN.
2. Traffic is sent to the VM series FW.
3. NAT policy is applied to the traffic flow.
4. Traffic is sent on to the destination with a new IP address from the VM series FW.
