# Terraform

## AWS Setup

[Install `eksctl` from this link](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).

```sh
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv eksctl /usr/local/bin
terraform plan -out franklin.plan
terraform apply franklin.plan
eksctl get clusters --region eu-west-1 # you can also set region in .envrc
eksctl get cluster lab-franklin-cluster
```

in order to create nodegroups or managed nodegroups on a cluster which was not created by eksctl,
[a config file containing VPC details must be provided](https://eksctl.io/usage/unowned-clusters/)

```sh
eksctl create nodegroup --config-file=nodes.yaml
```

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
