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
aws eks --region ca-central-1 update-kubeconfig --name lab-franklin-cluster # allow log in to cluster via k8s
```
