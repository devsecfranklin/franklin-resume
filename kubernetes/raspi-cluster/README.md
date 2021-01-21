# how to kube

cd to workspace/franklin-resume

Build the docker container with the Flask app

```bash
docker-compose -f docker/docker-compose.yml build dev_franklin_resume
docker tag docker_franklin_resume:latest frank378/franklin-resume:arm-0.1
docker images
docker pull frank378/franklin-resume:arm-0.1
```

Now you can deploy it

```bash
kubectl apply -f resume-deployment.yml
kubectl get deployments
kubectl apply -f resume-service.yml
kubectl get svc
kubectl get pods
kubectl describe pods/franklin-resume-pod
```
