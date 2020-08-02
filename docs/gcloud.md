# Infrastructure as a Service

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
