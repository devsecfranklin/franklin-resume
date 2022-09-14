# Terraform

## AWS Setup

- Permissions issues:

```sh
aws sts get-caller-identity
aws sts get-session-token --region=us-west-2
```

## S3 Manual

- Create a S3 bucket to store backend state.

```sh
aws s3api list-buckets --query "Buckets[].Name"
```

## S3 Terraform

```sh
export TF_LOG="TRACE"
export TF_LOG_PATH="/tmp/terraform.franklin"
#export AWS_PROFILE="terraform"
AWS_ACCESS_KEY_ID=$(cat ${HOME}/.aws/credentials | grep aws_access_key_id | cut -f2 -d"=")
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID#"${AWS_ACCESS_KEY_ID%%[![:space:]]*}"}"
AWS_SECRET_ACCESS_KEY=$(cat ${HOME}/.aws/credentials | grep aws_secret_access_key | cut -f2 -d"=")
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY#"${AWS_SECRET_ACCESS_KEY%%[![:space:]]*}"}"
AWS_SECURITY_TOKEN=$(cat ${HOME}/.aws/credentials | grep aws_security_token | cut -f2 -d"=")
export AWS_SECURITY_TOKEN="${AWS_SECURITY_TOKEN#"${AWS_SECURITY_TOKEN%%[![:space:]]*}"}"
```
