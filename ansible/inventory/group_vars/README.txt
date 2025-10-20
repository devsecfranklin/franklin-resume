For example, if you group hosts in your inventory by datacenter, and each datacenter uses its own NTP server and database server, you can create a file called /etc/ansible/group_vars/raleigh to store the variables for the raleigh group:

---
ntp_server: acme.example.org
database_server: storage.example.org

You can also create directories named after your groups or hosts. Ansible will read all the files in these directories in lexicographical order. An example with the ‘raleigh’ group:

/etc/ansible/group_vars/raleigh/db_settings
/etc/ansible/group_vars/raleigh/cluster_settings

