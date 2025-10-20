# AWS EKS CN series

1. Deploy the terraform in `terraform/backend'
2. Deploy the terraform in `terraform/aws`
3. Run the YAML in `terraform/aws` like so: `eksctl create cluster -f nodes.yaml`
4. Edit the files in this directory.

## EKS cluster setup

```sh
eksctl get clusters --region ca-central-1
#eksctl create cluster --name lab-franklin --region us-west-1 --fargate
eksctl create nodegroup --config-file=nodes.yaml
eksctl utils describe-stacks --region=ca-central-1 --cluster=lab-franklin-cluster
eksctl get clusters --region us-west-1 # you can also set region in .envrc
eksctl get cluster lab-franklin-cluster
```

in order to create nodegroups or managed nodegroups on a cluster which was not created by eksctl,
[a config file containing VPC details must be provided](https://eksctl.io/usage/unowned-clusters/)

```sh
aws cloudformation list-stacks --region ca-central-1
aws cloudformation get-template --stack-name eksctl-lab-franklin-cluster --region ca-central-1
eksctl utils describe-stacks --name="lab-franklin-cluster" --region=ca-central-1
eksctl create nodegroup --config-file=nodes.yaml
```

- Permissions issues:

```sh
aws sts get-caller-identity
aws sts get-session-token --region=us-west-2
```
