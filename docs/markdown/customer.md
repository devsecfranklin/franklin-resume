---
title: customer
author: Franklin Diaz <fdiaz@paloaltonetworks.com>
header-includes: |
    \usepackage{fancyhdr}
    \pagestyle{fancy}
    \fancyfoot[CO,CE]{v 0.1 | 02/15/2024 | initial version}
    \fancyfoot[LE,RO]{\thepage}
abstract: This repository is a set of custom tools and documentation.
...

# Customer

## Proxy Configuration

1. Determine which proxy server to use, for example `153.2.227.107`
2. echo your username and pass to base64 then encrypt it, like so:
    `echo "username:password" | base64 | openssl enc -aes-128-cbc -a`
3. Export this to your shell environment.

### Proxy Issues

- Opened case 03028240 for proxy issues in sandbox.
  - [Configuration for update server when static update server is used in Firewall](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA14u0000001UtRCAU)

## Configure BASH for XML API

Export these environment variables to prepare for script execution.

NOTE: You may also specify USER and PAN_IP by passing flags to the script.

```sh
export USER=<the_name_of_the_firewall_administrator_account_you_configured> # OPTIONAL
export PASS=<the_password_of_the_firewall_administrator_account_you_configured>
export PAN_IP=<the_panorama_instance_ip_address> # OPTIONAL
```

### OPTIONAL BASH ENV VAR: USER

This is the username you created previously for the dedicated XML API user.

NOTE: You may also specify a user from the command line with the `-u` flag.

For the `USER` setting, the tool has a default value of `xml-api-user`. To override
this value, use the following command before running the tool:

```sh
export USER="my_new_username" # set the value
echo $USER # validate it was set properly
```

### BASH ENVIRONMENT VARIABLE: PASS

This is the password for the new XML API user that was created. It is important
that we do not hardcode any active passwords into the script.

For the `PASS` setting, the tool has a default value of `default`. To override
this value, use the following command before running the tool:

```sh
export PASS="my_secret password" # set the value
echo $PASS # validate it was set properly
set | grep $PASS # different way to validate
```

Alternatively, you may choose to use a combination of the
[direnv](https://direnv.net/) and [pass](https://www.passwordstore.org/) tools
to make the management of these variables slightly easier.

### OPTIONAL BASH ENV VAR: PAN_IP

This is the IPv4 address of the active Panorama.

NOTE:

- You may specify TESTNET Panorama IP from the command line with the `-t` flag.
- You may specify PRODUCTION Panorama IP from the command line with the `-p` flag.

For the `PAN_IP` setting, the tool has a default value of `34.134.31.136`. To override
this value, use the following command before running the tool:

```sh
export PAN_IP="10.2.3.4" # example, set the value
echo $PAN_IP # validate it was set properly
set | grep $PAN_IP # another way to validate
```

## Panorama XML API

In order to allow the BASH script to communicate with Panorama via the
XML API, you need to [enable the API access](https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-panorama-api/get-started-with-the-pan-os-xml-api/enable-api-access.html).

__As best practice, set up a separate admin account for the XML API access.__

1. Configure an Admin Role Profile:

   - Select `Device` > `Admin Roles` and click `Add`.
   - Enter a `Name` to identify the role.
   - Select the `Role` scope.
   - In the `XML API` tab, click the icon for each functional
     area to toggle it to the desired setting: `Enable` or `Disable`.
   - Click `OK` to save the profile.
   - Assign the role to an administrator - complete the
     `Configure a Firewall Administrator Account` step.

2. Configure a Firewall Administrator Account:

   - Select `Device` > `Administrators` and click `Add`.
   - Enter a user `Name` to identify the account.
     If the firewall uses a local user database to authenticate the account, enter the
     name that you specified for the account in the database.
   - Select an `Authentication Profile` or sequence if you configured either for the administrator.
     If the firewall uses `Local Authentication` without a local user database for the
     account, select `None` (default) and enter a `Password`.
   - Select the `Administrator Type` > `Custom Panorama Admin`.
   - Select the `Admin Role` you created for this account in the `Profile` section.
   - Click `OK` and `Commit`.

NOTE: You must create the admin role and XML user in two places.
The Panorama and the FW template/template stack must both have the role and dedicated XML user added.

### Validate XML API configuration

To check if the `XML API` has been enabled, run the following code snippet:

```sh
curl -k -X GET 'https://$PAN_IP//api/?type=keygen&user=$USER&password=$PASS'
```

If everything was configured correctly, a response status `success` should be returned
together with an API key for the specified account.

### CLI Dev

- [Use the CLI to Find XML API Syntax](https://docs.paloaltonetworks.com/pan-os/11-0/pan-os-panorama-api/get-started-with-the-pan-os-xml-api/explore-the-api/use-the-cli-to-find-xml-api-syntax)

## SCRIPT: `bin/status_panorama.sh`

### Disk Status

The script should be updated to check disk status of log collectors.

```sh
tail follow yes  mp-log vld-1-0.log
tail follow yes  mp-log vld-2-0.log
show system disk-space
less mp-log vldmgr.log
less mp-log logd.log
less mp-log configd.log | match Error
show logging-status all
show system software status | match "elasticsearch\|es-"
show system raid detail
debug log-collector log-collection-stats show incoming-logs
request log-fwd-ctrl device 010108010490 action start-from-lastack
```

## SCRIPT: `bin/daily.sh`

- [Back Up Configuration and Device State from the CLI](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000ClJ9CAK)

## SCRIPT: `bin/deploy_fw_gcp.sh`

- Test without using a public IP. The target environment does not use public IP.
- wait about 10 minutes after script run, login as: `ssh admin@34.67.40.130`

## SCRIPT: `bin/stage_release.sh`

The following list can be generated by calling the script with the `-h` flag.

```sh
franklin@ups:~/bin$ ./stage_release.sh -h

stage_release script.

Syntax: stage_release.sh [-f|-h|-i|-p|-r|-t|-u|-v]
options:
-f     Specify a file with FW IPv4 addresses, one per line.
-h     Print this Help.
-i     Install release
-p     Use PROD environment
-r     Specify a sofwtware release to download/install (ex: 10.2.0)
-t     Use TESTNET environment
-u     Specify a USER for the Panorama
-v     Enable verbose (debug) mode.
```

### Execution

Create a text file and add in IP addresses, one per line.
This will allow you to specify exactly which firewalls to operate on.

Example:

```sh
3.233.53.199
44.216.25.244
34.206.152.182
52.55.185.160
```

To run the script with a list of serials in a file, type the command `./stage_release.sh -f my_ip_list.txt`

To run the script against all firewalls that are managed by this Panorama, type the command `stage_release.sh`

### Dev Notes

- Use `pandoc` to generate documentation

```sh
sudo apt install pandoc
cd docs && pandoc stage_release.md -o stage_release.pdf
```

## Jump Host Setup

RHEL/CentOS

```sh
sudo yum install -y epel-release pandoc git
sudo yum install -y gpg2 # for signing commits, encrypting passwords, etc.
sudo yum install -y direnv # manage env vars
```

### pass

the `pass` command as described in this article:
<https://www.redhat.com/sysadmin/management-password-store>

### development environment

Run the command: sudo yum group install "Development Tools"
Because I would like to configure the development env as detailed here:
CentOS / RHEL 7: Install GCC (C and C++ Compiler) and Development Tools - nixCraft (cyberciti.biz)

### Services

- nginx
- postfix/sendmail
- crontab

## Google Cloud

- Add detail about GCP traffic flows.

### GCP Production

![gcp-prod](docs/images/diagram1-GCP-PROD.png)

### GCP Testnet

![gcp-test](docs/images/diagram1-GCP-TESTNET.png)

### SSO Testing in GCP

![gcp-sand](docs/images/diagram1-sandbox.png)

## PROD and TESTNET

### New Jersey

![prod-newjersey](docs/images/diagram1-New\ Jersey.png)

### Georgia

![prod-georgia](docs/images/diagram1-Georgia.png)

## Github

### Franklin

### customer internal

## Certificates

Ensure SSL/TLS service profile is configured under `Setup > Management > General settings`. The server
certificate defined here is used to authenticate Admin users accessing firewall management. Certificate
expiration check should be enabled too. For very strong security one should typically replace vendor
provided certificates with their certificates from their PKI system.

- [An ACME Shell script: acme.sh](https://github.com/PaloAltoNetworks/acme.sh)
- [ACME wiki](https://github.com/acmesh-official/acme.sh/wiki)

```sh
curl https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh | sh -s -- --install-online -m  franklin@dead10c5.org
show device-certificate status
show device-certificate info
```

## Logging

![an image showing the logging infra](docs/images/diagram1-logging.png "Logging Infrastructure")

### QRadar

The QRadar server is at `qrocvip-mah.xxx.com` with IP `153.2.226.136` on TCP port 514.

### Syslog

Syslog is configured in two places on the Panorama. Once in the Panorama tab for the Panorama itself,
and again in the Device template.

- From the Global Template: `device -> server profiles -> syslog`
  - This makes the firewalls aware of all the SYSLOG servers.
- For SYSLOG coming from the Panorama(s) you should also check `Panorama -> server profiles -> syslog`

### Cortex Data Lake

Capture and describe the settings for CDL here.

### Troubleshooting

#### Firewall Log Forwarding

- The log forwaring profiles are managed for each Device Group under `Objects > Log Forwarding`
  - Be sure to select the desired Device Group from the drop down menu.
- Should the "Enable enhanced application logging to Cortex Data Lake" button be checked?

#### Firewall Syslog Template

- Note that SYSLOG is different from the traffic log forwarding mentioned in the previous section.
- Make sure the IP address of the jump host or other test host is in the permitted mgmt IP address list.
- view details from the firewall using these command below
- You could also try tcpdump from `Panorama > Managed Devices > Troubleshooting`

```sh
debug syslog-params show
ping host <IP address of syslog server>
traceroute host <IP address of syslog server>
```

- Check the TCP connection between the firewall and the syslog server.
- Replace TCP port if not using TCP/514

```sh
show netstat numeric-hosts yes numeric-ports yes all yes | match 514
```

- On Panorama Template, check permitted IP addresses: `Device > Setup > Interfaces > Management > Permitted IP Addresses`
  - The IP address for each SYSLOG collector should be listed in the permitted list.
