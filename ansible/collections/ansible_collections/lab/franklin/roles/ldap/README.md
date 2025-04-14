OpenLDAP
=========

.. code-block:: bash

   apt-get install slapd ldap-utils
   kadmin: addprinc -randkey ldap/ns2.lab.bitsmasher.net@LAB.BITSMASHER.NET
   kadmin: ktadd -k ldap.keytab ldap/ns2.lab.bitsmasher.net@LAB.BITSMASHER.NET

.. code-block:: bash

   dpkg-reconfigure slapd
   cp /usr/share/doc/slapd/examples/DB_CONFIG /var/lib/ldap
   kinit root/admin
   ldapadd -c -x -D cn=admin,dc=lab,dc=bitsmasher,dc=net -W -f /etc/ldap/my_ldif/configroot.ldif
   ldapadd -c -x -D cn=admin,dc=lab,dc=bitsmasher,dc=net -W -f /etc/ldap/my_ldif/loglevel.ldif
   ldapadd -c -x -D cn=admin,dc=lab,dc=bitsmasher,dc=net -W -f /etc/ldap/my_ldif/uid_eq.ldif
   ldapadd -c -x -D cn=admin,dc=lab,dc=bitsmasher,dc=net -W -f /etc/ldap/my_ldif/access.ldif
   ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts
   ldapsearch -b 'dc=lab,dc=bitsmasher,dc=net' -s base '(objectclass=*)' -x

.. code-block:: bash

   ldapadd -c -x -D cn=admin,dc=lab,dc=bitsmasher,dc=net -W -f ou.ldif
   ldapsearch -x ou=people

   slappasswd
   ldapadd -c -x -D cn=admin,dc=lab,dc=bitsmasher,dc=net -W -f franklin.ldif
   ldappasswd -x -D cn=admin,dc=lab,dc=bitsmasher,dc=net -W -S uid=franklin,ou=People,dc=lab,dc=bitsmasher,dc=net
   dpkg-reconfigure libpam-ldap
   dpkg-reconfigure libnss-ldap

* copy /etc/ldap/ldap.conf
* copy /etc/nsswitch.conf
* dpkg-reconfigure libnss-ldap
* dpkg-reconfigure libpam-ldap

   ldapsearch -x  -b "" -s base -LLL supportedSASLMechanisms
   ldapsearch -x -H ldap://10.10.13.1 -s "base" "supportedSASLMechanisms"

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
