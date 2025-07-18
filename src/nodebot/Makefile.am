CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

all:
	podman build -t gcr.io/gcp-gcs-pso/build-pod .
	#podman tag $(shell podman images -q | head -1) gcr.io/gcp-gcs-pso/build-pod:latest
	podman push gcr.io/gcp-gcs-pso/build-pod

