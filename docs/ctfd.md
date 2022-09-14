# Set up the CTFd Instance in GKE

```sh
kubectl create ns ctfd
kubectl config set-context --current --namespace=ctfd
kubectl apply -f yaml/ctfd-mysql-deployment.yaml
kubectl apply -f yaml/ctfd-redis-deployment.yaml
kubectl apply -f yaml/ctfd-backend.yaml
kubectl apply -f yaml/ctfd-ngnix-deployment.yaml
k get all
kubectl port-forward service/ctfd-nginx
kubectl port-forward service/ctfd-nginx 8080:8080 # this will make it so you can browse to the site
```