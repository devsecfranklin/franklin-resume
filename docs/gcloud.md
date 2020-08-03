# Infrastructure as a Service

Infrastructure as a service (IaaS) is a nearly instant computing infrastructure. For
my resume application, it is provisioned and managed as Infrastructure as Code
using [Terraform by Hashicorp](https://www.terraform.io/).

Because the entire resume application is [containerized using Docker](https://www.docker.com/why-docker)
I am able to [push a snapshot of the container](https://cloud.google.com/container-registry/docs/pushing-and-pulling) to [Google Cloud](https://cloud.google.com/).
Once the containerized application snapshot is uploaded, the Terraform scripts create a
Kubernetes cluster [using Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/quickstart) in GCloud.

## The Technical Details

It is possible to generate the Docker container with the Python3/Flask
application inside, and bring this container up on Google Cloud with
the Kuberbetes engine.

- Install kubectl and Google Cloud SDK

```fish
gcloud auth application-default login
gcloud config set project my-resume-71445
docker build -f ./docker/Dockerfile -t franklin-resume:v1 .
docker tag franklin-resume:v1 us.gcr.io/my-resume-71445/franklin-resume:v1
gcloud docker -- push us.gcr.io/my-resume-71445/franklin-resume:v1

gcloud config set container/cluster franklin-resume-cluster
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

gcloud container clusters create franklin-resume-cluster --zone us-central1-a --num-nodes 1
kubectl create -f gcp/webapp-deployment.yaml
kubectl apply -f gcp/webapp-deployment.yaml
```

- Now [run the terraform](https://github.com/thedevilsvoice/franklin-resume/tree/master/gcp) to provision the K8s cluster in GKE.
