# Development Environment

## VSCode

I use the [Visual Studio Code IDE](https://code.visualstudio.com/) with various plugins
and scanners, [Prisma Cloud](https://marketplace.visualstudio.com/items?itemName=PaloAltoNetworksInc.prisma-cloud) IaC security scanner for example.

## Fish Shell

This is a fun shell! The [oh my fish](https://github.com/oh-my-fish/oh-my-fish)
extension has [lots of great themes](https://github.com/oh-my-fish/oh-my-fish/blob/master/docs/Themes.md).

## Direnv

I use [the direnv shell extension](https://direnv.net/) to make
it easier to manage Shell variables. The `.envrc` file is not
checked in to the repo since the filename will trigger security
alerts with GitGaurdian. A copy of my `.envrc` file is
here for reference:

```fish
# Author: @theDevilsVoice
# Date: 06/02/2020
#
# Name: .envrc
#
# Description: Configure and deploy on GCP
#
# Run Information: https://direnv.net/
#

# You can set TF_LOG to one of the log levels TRACE, DEBUG, INFO,
# WARN or ERROR to change the verbosity of the logs. TRACE is the
# most verbose and it is the default if TF_LOG is set to something
# other than a log level name.
export TF_LOG="TRACE"
export TF_LOG_PATH="/tmp/terraform.franklin"

# Leave commented out if no organization
#export TF_VAR_org_id=`gcloud organizations list | grep -v DISPLAY | cut -f3 -d' '`
export TF_VAR_billing_account=`gcloud beta billing accounts list | grep -v ACCOUNT | cut -f1 -d' '`
# Franklin personal account
export TF_ADMIN="my-resume-71445"
export TF_CREDS="${HOME}/.config/gcloud/${USER}-terraform-admin.json"
export GOOGLE_APPLICATION_CREDENTIALS="${TF_CREDS}"
export GOOGLE_PROJECT="${TF_ADMIN}"
```
