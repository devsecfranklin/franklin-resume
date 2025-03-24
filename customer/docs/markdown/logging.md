---
title: "Enterprise Logging with Palo Alto Networks"
subtitle: "Customer Logging Configuration"
author: [Franklin Diaz <fdiaz@paloaltonetworks.com>]
abstract: Instructions on configuration of TLS for an important account.
date: "March 24, 2025"
keywords: [logging, syslog, tls]
lang: "en"
book: true
classoption: [twoside]
toc: true
toc-own-page: true
titlepage: true
titlepage-text-color: "FFFFFF"
titlepage-rule-color: "360049"
titlepage-rule-height: 0
header-left: "\\hspace{1cm}"
header-center: "\\leftmark"
header-right: "Page \\thepage"
footer-left: "\\thetitle"
footer-center: "This is \\LaTeX{}"
footer-right: "\\theauthor"
...

# Introduction

![an image showing the logging infra](docs/images/customer/diagram1-logging.png "Logging Infrastructure")

## Prerequisites

* Make available the TCP ports as shown in the document [Strata Logging Service](https://docs.paloaltonetworks.com/strata-logging-service/administration/planning/ports-and-fqdns)
* Use the support portal to create a Device Certificate on all Panorama and Firewall devices, and have Telemetry enabled.

## Import TLS Certificates

The TLS certificates must be provided by the customer. Pleas take great care when handling sensitive
files such as keys, pem files, certificates, etc. It is good practice to set ownership to
owner/read-only at all times. For exmaple `chmod 400 *.pem`.

* For each desired service, [generate or import a certificate on the firewall](https://docs.paloaltonetworks.com/pan-os/11-1/pan-os-admin/certificate-management/obtain-certificates/import-a-certificate-and-private-key#ide2b67a64-7100-4fa3-8304-48dbe64bcaa4)
* You can also use OCSP like so: [Obtain a Certificate from an External CA](https://docs.paloaltonetworks.com/pan-os/11-1/pan-os-admin/certificate-management/obtain-certificates/obtain-a-certificate-from-an-external-ca)

## Configure SSL/TLS Service Profile

Making a service profile on the Panorama is the first step.

* [Configure an SSL/TLS Service Profile (PAN-OS & Panorama)](https://docs.paloaltonetworks.com/pan-os/11-1/pan-os-admin/certificate-management/configure-an-ssltls-service-profile/configure-an-ssltls-service-profile-pan-os)
* Navigate to `Panorama` -> `Certificate Management` -> `SSL/TLS Service Profile`
  * set min TLS version to 1.2, max to 1.3
  * Reference the Certificate you imported/created for logging.

## Configure Syslog Server Profile

This step is only needed for SYSLOG configuration. The details about each remote SYSLOG server are captured
in these steps.

* Navigate to `Panorama` -> `Server Profiles` -> `SYSLOG` and create each logging profile as desired.
  * The TCP profile" for splunk testing is server 10.228.96.182, transport TCP, port 8642, format IETF
  * The TLS profile" for splunk testing is server 10.228.96.182, transport TLS, port 8643. format IETF
* We do not usually change any settings on the `Custom Log Format` tab.

## Configure Log Settings

* Navigate to `Panorama` -> `Log Settings` -> `System`
* Add the new SYSLOG profiles here with the `All Logs` filter.

### QRadar

The QRadar server is at `qrocvip-mah.xxx.com` with IP `153.2.226.136` on TCP port 514.

### Syslog Client Configuration

Syslog is configured in two places on the Panorama. Once in the Panorama tab for the Panorama itself,
and again in the Device Templates for the Firewall devices.

To configure firewall SYSLOG from the Panorama console:

* From the Global Template: `device -> server profiles -> syslog`
  * This makes the firewalls aware of all the SYSLOG servers.
* For SYSLOG coming from the Panorama(s) you should also check `Panorama -> server profiles -> syslog`
* NOTE: SYSLOG is system configuration logging, which is different from the traffic
  log forwarding.
* Make sure the IP address of the jump host or other test host is in the permitted
  mgmt IP address list.
* You could also try tcpdump from `Panorama > Managed Devices > Troubleshooting`

Validate the basic connectivity between Panorama and SYSLOG server. These example commands
are meant to be run from the CLI.

```sh
debug syslog-params show
ping host <IP address of syslog server>
traceroute host <IP address of syslog server>
```

* Check the TCP connection between the firewall and the syslog server.
* Replace TCP port if not using TCP/514, for exmaple 8642 or 8643.

```sh
show netstat numeric-hosts yes numeric-ports yes all yes | match 514
show netstat numeric-hosts yes numeric-ports yes all yes | match 8642
```

* On Panorama Template, check permitted IP addresses
  * `Device > Setup > Interfaces > Management > Permitted IP Addresses`
  * The IP address for each SYSLOG collector should be listed in the permitted list.

### Cortex Data Lake

* Capture and describe the settings for CDL here.
* Note that CDL does not work without a valid device certificate on the host.
