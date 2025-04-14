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


   - copy /etc/ldap/ldap.conf
   - copy /etc/nsswitch.conf
   - dpkg-reconfigure libnss-ldap
   - dpkg-reconfigure libpam-ldap


   ldapsearch -x  -b "" -s base -LLL supportedSASLMechanisms
   ldapsearch -x -H ldap://10.10.13.1 -s "base" "supportedSASLMechanisms"
