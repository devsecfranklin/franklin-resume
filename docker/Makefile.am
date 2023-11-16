CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal
SHORT_NAME := $(shell docker image ls | grep ^franklin-resume | grep latest | sed -e's/  */ /g' | cut -d" " -f3)
LONG_NAME :=  $(shell docker image ls | grep ghcr.io/devsecfranklin/franklin-resume | grep latest | sed -e's/  */ /g' | cut -d" " -f3)
.check-env-vars:
	@test $${CR_PAT?Push will fail. You need to export the CR_PAT token for GHCR}

build:
	@if [ "${LONG_NAME}" != "${SHORT_NAME}" ] && [ ! -z "${LONG_NAME}" ]; then \
		echo "Found stale image: ${LONG_NAME}" ;\
		docker image rm -f $(LONG_NAME) ;\
	fi
	docker-compose build franklin-resume
	@echo "Tagging image:  $(shell docker images -q | head -1)"
	docker tag $(shell docker images -q | head -1) ghcr.io/devsecfranklin/franklin-resume:latest

clean:
	docker image rm -f $(STALE)
	docker system prune -f

push: .check-env-vars
	docker push ghcr.io/devsecfranklin/franklin-resume:latest

run: 
	docker run -it ghcr.io/devsecfranklin/franklin-resume:latest bash
