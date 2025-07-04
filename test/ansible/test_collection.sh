ansible-galaxy collection build # generates MANIFEST.json and FILES.json


# https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_testing.html
ansible-test sanity --docker default -v
