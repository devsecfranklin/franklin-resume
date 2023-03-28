# Set up the CTFd Instance in GKE

- Do not use node selector, it will need a match on ALL labels.
- You must set a public IP address with`gcloud compute addresses`

```sh
kubectl create ns ctfd
kubectl config set-context --current --namespace=ctfd
kubectl apply -f yaml/ctfd-mysql-deployment.yaml
kubectl apply -f yaml/ctfd-redis-deployment.yaml
kubectl apply -f yaml/ctfd-deployment.yaml
kubectl apply -f yaml/ctfd-backend.yaml
kubectl apply -f yaml/ctfd-ngnix-deployment.yaml
```

- Checkout the setup so far:

```sh
k get all
kubectl describe deployments
kubectl apply -f yaml/ctfd-backend.yaml
kubectl apply -f yaml/ctfd-ngnix-deployment.yaml
```

- Test connection:

```sh
kubectl port-forward service/ctfd-nginx
kubectl port-forward service/ctfd-nginx 8080:8080 # this will make it so you can browse to the site
```

- Navigate to `http://127.0.0.1:8080/setup`

- Make it public:

```sh
kubectl get svcneg
```
