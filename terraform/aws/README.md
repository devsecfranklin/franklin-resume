# Terraform

## AWS Setup

[Install `eksctl` from this link](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).

### Mac

```sh
brew upgrade eksctl && { brew link --overwrite eksctl; } || { brew tap weaveworks/tap; brew install weaveworks/tap/eksctl; }
```

### Linux

```sh
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv eksctl /usr/local/bin
```

```sh
eksctl create cluster --name lab-franklin --region us-west-1 --fargate
eksctl get clusters --region us-west-1 # you can also set region in .envrc
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
