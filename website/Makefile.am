CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

build:
	docker-compose build website
	@echo "Size of image: $(shell docker image ls| grep ^website | awk -F '  +' '{print $$5}')"
	@echo "Tagging image:  $(shell docker image ls| grep ^website | awk -F '  +' '{print $$3}')"
	docker tag $(shell docker images -q | head -1) gcr.io/gcp-gcs-pso/website:latest

clean:
	@for trash in Makefile Makefile.in; do \
	if [ -f $$trash ] || [ -d $$trash ]; then \
		echo "Removing $$trash" ;\
		rm -rf $$trash ;\
	fi ; \
	done
	docker system prune -f

node:
	npm install @linthtml/linthtml --save-dev
	npm install js-beautify
	@if [ ! -e ".linthtmlrc.json" ]; then ./node_modules/.bin/linthtml --init; fi
	npm ci

push:
    docker push gcr.io/gcp-gcs-pso/website

run:
	docker run --name website -p 80:80 -d nginx
