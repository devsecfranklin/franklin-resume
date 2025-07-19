SSH
===

.. code-block:: sh

   ssh -K -l franklin -o PubkeyAuthentication=no blowfish

The following table summarizes the key ssh_config directives essential for optimizing franklin's client configuration for passwordless SSH with Kerberos. Each entry includes the recommended value, its purpose, and relevant supporting information. This table serves as a quick reference for implementing the proposed changes.

| Directive | Recommended Value | Purpose/Benefit | Relevant Snippet IDs |
| --- | --- | --- | --- |
| GSSAPIAuthentication| yes |Enables Kerberos-based authentication via GSSAPI, fundamental for passwordless access. | 1 |
| GSSAPIDelegateCredentials| yes | Allows delegation of Kerberos tickets to the remote host, enabling "double-hop" SSO for accessing other Kerberos services from the remote server. | 2 |
| PreferredAuthentications|gssapi-with-mic,publickey,keyboard-interactive,password|Prioritizes GSSAPI authentication, ensuring SSH attempts Kerberos first for passwordless access. |1|
| CanonicalizeHostname | yes | Explicitly converts short hostnames to FQDNs, critical for matching Kerberos Service Principal Names (SPNs) and ensuring successful GSSAPI authentication. |3|
| CanonicalDomain | bitsmasher.net, lab.bitsmasher.net|Specifies domain suffixes for hostname canonicalization, enabling franklin to use short hostnames. |4|
| ControlMaster|auto|Enables connection multiplexing, allowing multiple SSH sessions to reuse a single authenticated connection, significantly speeding up subsequent connections. |5|
| ControlPath|~/.ssh/control-%r@%h:%p|Defines a unique socket path for multiplexed connections, ensuring proper session management. |6|
| ControlPersist|10m (or 1h, 4h as needed)|Keeps the master connection alive in the background for a specified duration after the last client disconnects, making subsequent connections almost instantaneous. |5|
| ServerAliveInterval|60|Sends a "no-op" message every 60 seconds if idle, preventing session timeouts due to network inactivity or firewalls. |7|
| ServerAliveCountMax|3|Specifies how many consecutive alive messages can be sent without a response before disconnecting, preventing indefinite hangs. |7|
| StrictHostKeyChecking | yes | Enforces strict host key verification, providing maximum protection against Man-in-the-Middle (MITM) attacks. |8|
| LogLevel|INFO (or DEBUG for troubleshooting)|Controls the verbosity of client-side logging, essential for diagnosing authentication issues. |9|
| ForwardAgent|no (or yes with extreme caution)|Controls SSH agent forwarding. Setting to no is more secure; yes allows remote host to use local agent, posing a security risk if the remote host is compromised.|10|
| Compression | yes | Enables data compression, potentially improving performance over slower network links by reducing data transfer size. |11|
| ForwardX11 | yes | Enables X11 forwarding, allowing graphical applications from the remote server to display on the local machine. |12|
| ForwardX11Trusted | yes | (Optional) Enables trusted X11 forwarding, which may be required by some X applications and simplifies X authentication. |13|

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
