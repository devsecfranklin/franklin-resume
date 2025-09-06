CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

build:
	docker compose build mmmbot
	@echo "Size of image: $(shell docker image ls| grep ^mmmbot | awk -F '  +' '{print $$5}')"
	@echo "Tagging image:  $(shell docker image ls| grep ^mmmbot | awk -F '  +' '{print $$3}')"
	docker tag $(shell docker images -q | head -1) gcr.io/gcp-gcs-pso/mmmbot:latest

clean:
	docker system prune -f

push: .check-env-vars
	docker push gcr.io/gcp-gcs-pso/mmmbot:latest

bot-run:
	docker run -it gcr.io/gcp-gcs-pso/mmmbot:latest bash
