
## (TERRAFORM) Access PS Lab AWS Account via CLI

* Complete the steps as described in the previous section.
* Use the credentials in ~/.aws/credentials file for Terraform.
* BEST PRACTICE: Put AWS credentials in an environment variable.

Linux/Macintosh (BASH shell):

```sh
export AWS_ACCESS_KEY_ID=`grep -A1 sso_eng ~/.aws/credentials|grep aws_access|cut -f2 -d'='|xargs`
export AWS_SECRET_ACCESS_KEY=`grep -A2 sso_eng ~/.aws/credentials|grep aws_secret|cut -f2 -d'='|xargs`
export AWS_DEFAULT_REGION=us-west-2 # optional
```

Windows Command Prompt:

```sh
C:\> setx AWS_ACCESS_KEY_ID AKIAIOSFODNN7EXAMPLE
C:\> setx AWS_SECRET_ACCESS_KEY wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
C:\> setx AWS_DEFAULT_REGION us-west-2
```

Windows Power Shell:

```sh
PS C:\> $Env:AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
PS C:\> $Env:AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
PS C:\> $Env:AWS_DEFAULT_REGION="us-west-2"
```

## (OPTIONAL) Encrypt Your AWS Credentials

* Using the "pass" manager means you can remove plain text credentials
  from the local file system.
  * Prevents credentials from being committed to revision control by accident.
  * When using pass, your credentials are still encrypted with your private key, even
    if they are accidentally committed to revision control.
  * With pass, you can use your own GPG key, Keybase key, etc. to protect
    your secrets.

Macintosh:

```sh
brew install pass gpg2
gpg2 --list-keys # get your public key id
pass init C25565E4701F4ED36A0711AA114F3606EFD923BB # id of your public GPG key
pass insert aws-access-key-id
pass ls
pass insert aws-secret-access-key
pass ls
pass show aws-secret-access-key
```

Docker/Alpine Linux:

```sh
apk update && apk add --no-cache pass gnupg
gpg --list-keys # get your public key id
pass init C25565E4701F4ED36A0711AA114F3606EFD923BB # id of your public GPG key
pass insert aws-access-key-id
pass ls
pass insert aws-secret-access-key
pass ls
pass show aws-secret-access-key
```

* Create Terraform plan, apply, etc.

```sh
export AWS_ACCESS_KEY_ID=$(pass aws-access-key-id) # your creds come from the vault
export AWS_SECRET_ACCESS_KEY=$(pass aws-secret-access-key) # your creds come from the vault
terraform plan # should be able to get your creds from your shell
```

### (OPTIONAL) Run Configuration Wizard

Most users can safely skip this optional step.

* You might wish to reconfigure your Credentials, set certain defaults, etc.

```sh
python3 -m venv venv
source venv/bin/activate
gimme-aws-creds --action-configure # run through all the options
gimme-aws-creds --action-register-device # set default MFA device
deactivate
```
