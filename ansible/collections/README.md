# Collection

## Structure

* [Collection structure](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_structure.html#collection-structure)

A collection can contain these directories and files:

```sh
collection/
├── docs/
├── galaxy.yml
├── meta/
│   └── runtime.yml
├── plugins/
│   ├── modules/
│   │   └── module1.py
│   ├── inventory/
│   └── .../
├── README.md
├── roles/
│   ├── role1/
│   ├── role2/
│   └── .../
├── playbooks/
│   ├── files/
│   ├── vars/
│   ├── templates/
│   └── tasks/
└── tests/
```

## Testing

* [Getting Started With Molecule](https://ansible.readthedocs.io/projects/molecule/getting-started/)

```sh
cd ansible/collections/ansible_collections/lab/franklin/roles/cluster
mkdir extensions && cd extensions
molecule init scenario
molecule test # The full test lifecycle sequence
molecule converge # runs the same steps as molecule test for the default scenario, but will stop after the converge action.
```

### Test Files

* `create.yml` is a playbook file used for creating the instances and storing data in instance-config
* `destroy.yml` has the Ansible code for destroying the instances and removing them from instance-config
* `molecule.yml` is the central configuration entry point for Molecule per scenario. With this file,
you can configure each tool that Molecule will employ when testing your role.
* `converge.yml` is the playbook file that contains the call for your role. Molecule will invoke
this playbook with ansible-playbook and run it against an instance created by the driver.
