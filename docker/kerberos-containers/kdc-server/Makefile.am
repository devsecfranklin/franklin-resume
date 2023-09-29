CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

.check-env-vars:
	@test $${CR_PAT?Push will fail. You need to export the CR_PAT token for GHCR}

build:
	docker-compose build kdc-server
	@echo "Size of image: $(shell docker image ls| grep kdc-server | awk -F '  +' '{print $$5}')"
	@echo "Tagging image:  $(shell docker image ls| grep kdc-server | awk -F '  +' '{print $$3}')"
	docker tag $(shell docker images -q | head -1) ghcr.io/devsecfranklin/kdc-server:latest

clean:
	docker system prune -f

push: .check-env-vars
	docker push ghcr.io/devsecfranklin/kdc-server:latest

run: 
	docker run -it ghcr.io/devsecfranklin/kdc-server:latest bash
