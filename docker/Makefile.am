CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

.check-env-vars:
	@test $${CR_PAT?Push will fail. You need to export the CR_PAT token for GHCR}

build: 
	docker-compose build franklin-resume
	@echo "Tagging image:  $(shell docker images -q | head -1)"
	docker tag $(shell docker images -q | head -1) ghcr.io/devsecfranklin/franklin-resume:latest

push: .check-env-vars
	docker push ghcr.io/devsecfranklin/franklin-resume:latest

run: 
	docker run -it ghcr.io/devsecfranklin/franklin-resume:latest bash
