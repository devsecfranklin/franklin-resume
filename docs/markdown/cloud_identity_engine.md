______________________________________________________________________

-title: NAT design
-author: Franklin Diaz <fdiaz@paloaltonetworks.com>
-header-includes: |

- \\usepackage{fancyhdr}
- \\pagestyle{fancy}
- \\fancyfoot\[CO,CE\]{v 0.1 | 02/20/2024 | initial version}
- \\fancyfoot\[LE,RO\]{\\thepage}
  -abstract: This is a DRAFT design for NAT of certain traffic between INTRANET and a secure LAN behind an HA pair of NGFW.
  -...

# Cloud Identity Engine

The Cloud Identity Engine provides both user identification and user authentication for a centralized
cloud-based solution in on-premise, cloud-based, or hybrid network environments. The Cloud Identity
Engine allows you to write security policy based on users and groups, not IP addresses, and helps secure
your assets by enforcing behavior-based security actions.

It also provides the flexibility to adapt to changing security needs and users by making it simpler to
configure an identity source or provider in a single unified source of user identity, allowing
scalability as needs change.

By continually syncing the information from your directories, whether they are on-premise, cloud-based,
or hybrid, ensures that your user information is accurate and up to date and policy enforcement
continues based on the mappings even if the cloud identity provider is temporarily unavailable.

To provide user, group, and computer information for policy or event context, Palo Alto Networks
cloud-based applications and services need access to your directory information. The Cloud Identity
Engine, a secure cloud-based infrastructure, provides Palo Alto Networks apps and services with
read-only access to your directory information for user visibility and policy enforcement.

The components of the Cloud Identity Engine deployment vary based on whether the Cloud Identity Engine
is accessing an on-premises directory (such as Active Directory) or a cloud-based directory
(such as Azure Active Directory).

The authentication component of the Cloud Identity Engine allows you to configure a profile for
a SAML 2.0-compliant identity provider (IdP) that authenticates users by redirecting their access
requests through the IdP before granting access. You can also configure a client certificate for
user authentication. When you configure an Authentication policy and the Authentication Portal on
the Palo Alto Networks firewall, users must log in with their credentials before they can access the resource.

## On-Premises Directory Configuration

To use the Cloud Identity Engine with an on-premises Active Directory or OpenLDAP-based directory, you need:

- to install the Cloud Identity agent on a Windows server (the agent host) and configure it to connect to your on-premises directory and the Cloud Identity Engine.
- access to the Cloud Identity Engine app on the hub so you can manage your Cloud Identity Engine tenants and Cloud Identity agents.

## Panorama Plugins

Use the [Azure Public Cloud plugin compatibility matrix](https://docs.paloaltonetworks.com/compatibility-matrix/panorama/plugins#id17C8A0XB0V8) to determine the version of plugins we should install on Panorama.

## Test Setup

### UPS Sandbox Lab Environment

- This is the preferred test environment.
  - Currently has some firewalls w/local auth set up.
  - OK if we "break" the environment while testing.

### Palo Lab Environment

- HA pair of Panorama running PANOS 10.2.7-h3
- The free tier of Azure offers AD service if needed.
- [Refer to the project paper for more details on lab configuration](https://docs.google.com/document/d/1v1l9HdITm2B55GBJQfv18UUPX-_cEr0d-t7MYGJKfl4/edit), project planning, etc.

## Install Steps

- [Configure Your Network to Allow Cloud Identity Agent Traffic](https://docs.paloaltonetworks.com/cloud-identity/cloud-identity-engine-getting-started/get-started-with-the-cloud-identity-engine/plan-the-cloud-identity-engine-deployment/configure-your-network-to-allow-cloud-identity-engine-traffic#id0947ba4b-3d5a-49f3-8698-feee03469d3b)

- [Install the Cloud Identity Agent](https://docs.paloaltonetworks.com/cloud-identity/cloud-identity-engine-getting-started/choose-directory-type/configure-an-on-premises-directory/install-the-cloud-identity-agent#id17CFA0U0B4X)

- After you have installed the Cloud Identity agent on the host, [Configure the Cloud Identity Agent](https://docs.paloaltonetworks.com/content/techdocs/en_US/cloud-identity/cloud-identity-engine-getting-started/choose-directory-type/configure-an-on-premises-directory/configure-the-cloud-identity-agent.html#id17CFA0ZN0XI) to communicate with both your directory and the Cloud Identity Engine.

- After configuring the agent, make sure to [Authenticate the Agent and the Cloud Identity Engine](https://docs.paloaltonetworks.com/content/techdocs/en_US/cloud-identity/cloud-identity-engine-getting-started/choose-directory-type/configure-an-on-premises-directory/authenticate-cloud-identity-agent-and-the-cloud-identity-engine.html#id17CKFM00EIA) to enable communication between the agent and the Cloud Identity Engine.

- For a comprehensive user identity and authentication solution, learn how to [Authenticate Users with the Cloud Identity Engine](https://docs.paloaltonetworks.com/content/techdocs/en_US/cloud-identity/cloud-identity-engine-getting-started/authenticate-users-with-the-cloud-identity-engine.html#id05626c4b-2f90-47b4-b9f4-c72fce41de02)
