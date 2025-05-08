# Test

Dev stuff goes in here. Do these steps about once a week:

- `make clean`
- `bootstrap.sh`
- `./configure.sh`
- `make test`
- `. _test/bin/activate`

## Airlock Host

- You can connect to the test instance like so: `gcloud compute ssh --zone=us-central1-a lab-franklin-airlock1`
- add a disk like so:

```sh
gcloud compute instances attach-disk lab-franklin-airlock1 --disk=lab-franklin-dev --device-name=lab-franklin-dev --zone=us-central1-a
ls -l /dev/disk/by-id/google-*
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p /mnt/development
sudo mount -o discard,defaults /dev/sdb /mnt/development
```

Now set up the env:

```sh
sudo apt install -y gcc make libtool git libxml2-utils gnupg2 direnv locales mlocate pandoc python3-venv bzip2 uuid jq graphviz
sudo dpkg-reconfigure locales # set default to "en_US.UTF-8"
sudo updatedb
sudo -g engr bash  # change into engr group using BASH
cd ~/workspace/customer
./booststrap.sh
./configure
make test
. _test/bin/activate.fish
```

## Test Host

- Note that the test host is in a different zone.

```sh
gcloud compute ssh --zone=us-central1-f lab-franklin-test-vm
eval `ssh-agent`
ssh-add ~/.ssh/id_rsa_work
curl icanhazip.com # ge the IP of the current host
```

## RDP

Once connected to customer VPN, these are the hosts to get to FW.

```sh
156.134.199.224
156.134.234.244
156.134.234.245
156.134.234.246 # This is the main host
```

## XML formatting

`tidy`:

```sh
apt install -y tidy
cd /tmp/palo/data && tidy -xml -i -q output_space.xml
```

`xmllint`:

```sh
apt-get install -y libxml2-utils
cd /tmp/palo/data && xmllint --format output_space.xml
```

Need to install shfmt.

## JFrog Setup

[Integrate JFrog with VSCode](https://devops-wiki.inside.ups.com/dpt/jfrog/integration/jfrog-ide-plugin-integration-vscode/)

## pip install from Artifactory

To [pull dependencies from Artifactory](https://devops-wiki.inside.ups.com/cloud/openshift/openshift-ci/artifactory/?h=#python-pip) during the pip install
process, create a `pip.conf` secret that includes your service
accounts credentials:

```sh
[global]
index-url = https://<YOUR_SERVICE_ACCOUNT_USER:YOUR_SERVICE_ACCOUNT_IDENTITY_TOKEN>@jfrog.inside.ups.com/artifactory/api/pypi/python/simple
```

Next, run the following commands to create the secret for the
`pip.conf` file and give it the appropriate label for your pipeline:

```sh
# Create the secret from the pip.conf file in develop build project
oc create secret generic pipconf --from-file=pip.conf=<path/to/pip.conf> -n <YOUR_APP_NAME>-build
# Create the secret in release-build
oc create secret generic pipconf --from-file=pip.conf=<path/to/pip.conf> -n <YOUR_APP_NAME>-release-build
# Label the secret so it can be moved into feature projects
oc label secret/pipconf openshiftciapplication=<YOUR_APP_NAME> -n <YOUR_APP_NAME>-build
# Label the secret so it can be moved into hotfix projects
oc label secret/pipconf openshiftciapplication=<YOUR_APP_NAME> -n <YOUR_APP_NAME>-release-build
```

## Clang Setup

- install clang

## Cases

1. test to fail if text file does not exist.
2. Search file for unmatch quotes: `tr -cd "'\n" < run_me.sh | awk 'length%2==1 {print NR, $0}'`
3. Run `shellcheck` and `bin/format_shell_script.sh` on shell scripts.
