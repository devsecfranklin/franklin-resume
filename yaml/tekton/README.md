# Tekton

[Need to add firewall rule in GCP/GKE](https://stackoverflow.com/questions/59461747/tekton-on-private-kubernetes-cluster-on-gcp-gke)

- The rule is called `ps-devsecops-allow-tekton-webhook`

## Setup

```sh
gcloud container clusters list
gcloud container clusters get-credentials ps-devsecops-gke --region=us-central1
kubectl create clusterrolebinding fdiaz-gke-bot-cluster-admin-binding --clusterrole=cluster-admin --user=fdiaz-gke-bot@gcp-gcs-pso.iam.gserviceaccount.com
kubectl get endpoints --namespace default kubernetes
kubectl get nodes
```

[Installation](https://tekton.dev/docs/installation/pipelines/#installing-tekton-pipelines-on-kubernetes)

```sh
kubectl config set-context --current --namespace=tekton-pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
kubectl get namespace tekton-pipelines
# you can wait to see it RUNNING
watch kubectl get pods -n tekton-pipelines
kubectl config set-context --current --namespace=tekton-pipelines
kubectl api-resources --api-group='tekton.dev'
```

kubectl get podsecuritypolicy

## Watch the logs

Controller

```sh
kubectl logs (kubectl get pods --namespace tekton-pipelines | grep pipelines-controller | cut -f1 -d' ')  --namespace tekton-pipelines -f
```

Webhook

```sh
kubectl logs (kubectl get pods --namespace tekton-pipelines | grep pipelines-webhook | cut -f1 -d' ')  --namespace tekton-pipelines -f
```

## Operation

dashboard

```sh
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097
```

[Navigate to the Dashboard](http://127.0.0.1:9097/#/pipelineruns)

### Create Pipeline Resources

- git repos
- buckets/pvc

### Create Pipelines

```sh
kubectl apply -f pipeline.yaml 
tkn res ls
```

### Tasks

Github

```sh
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/github-add-comment/0.4/github-add-comment.yaml
pass show GIT_TOKEN
kubectl create secret generic github -n tekton-pipelines --from-literal token="`pass show GIT_TOKEN`"
kubectl annotate -n tekton-pipelines secret github "tekton.dev/git-0=https://github.com"
kubectl get -n tekton-pipelines secret github -o yaml
```

```sh
export GIT_TOKEN=(pass GIT_TOKEN)
tkn hub install task git-clone -n tekton-pipelines
 tkn task start git-clone --namespace=tekton-pipelines \
 --param url=https://$GIT_TOKEN@github.com/thedevilsvoice/gcp_tagging_automation \
 --param revision=main --param deleteExisting=true \
 --workspace name=output,claimName=tekton-ci-build --use-param-defaults \
 --showlog

```

Testing

```sh
# https://hub.tekton.dev/tekton/task/conftest
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/conftest/0.1/conftest.yaml
```

Code Formatting

```sh
# https://hub.tekton.dev/tekton/task/black
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/black/0.1/black.yaml
# https://hub.tekton.dev/tekton/task/check-make
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/check-make/0.1/check-make.yaml
```

Building

```sh
# https://hub.tekton.dev/tekton/task/kaniko
tkn hub install task kaniko -n tekton-pipelines 
```

Deploy

```sh
# azure cli
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/az/0.1/az.yaml
# https://hub.tekton.dev/tekton/task/ibmcloud
```

### Logs

```sh
kubectl delete pods --field-selector status.phase=Failed -n tekton-pipelines
kubectl get taskruns -o yaml 
kubectl describe pod git-clone-run-67v2n-pod-5q2sw 
```
