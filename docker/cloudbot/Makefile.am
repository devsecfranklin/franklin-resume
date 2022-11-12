CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

all:
	docker build -t gcr.io/gcp-gcs-pso/build-pod .
	docker push gcr.io/gcp-gcs-pso/build-pod
