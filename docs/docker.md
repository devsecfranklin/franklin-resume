# Pre-Built Container Image

Here I've create an account on Docker Hub and linked my GitHub repo to it.
The Docker Hub account monitors the GitHub account for merges. When a new
version of the containerized application is available, Docker Hub builds
and publishes it. I simply needed to tell Hub where to find my main DOckerfile
for the Flask application.

## Get the Container

Here is a link to the latest container, suitable for use in GKE, private k8s
cloud, etc.

* [Docker Hub: Latest Container Image](https://hub.docker.com/repository/docker/frank378/franklin-resume)
