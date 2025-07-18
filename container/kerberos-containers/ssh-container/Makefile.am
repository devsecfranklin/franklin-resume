CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

.check-env-vars:
	@test $${CR_PAT?Push will fail. You need to export the CR_PAT token for GHCR}

build:
	podman-compose build ssh-server
	@echo "Size of image: $(shell podman image ls| grep ssh-server | awk -F '  +' '{print $$5}')"
	@echo "Tagging image:  $(shell podman image ls| grep ssh-server | awk -F '  +' '{print $$3}')"
	docker tag $(shell podman images -q | head -1) ghcr.io/devsecfranklin/ssh-server:latest

clean:
	podman system prune -f

push: .check-env-vars
	podman push ghcr.io/devsecfranklin/ssh-server:latest

run:
	podman run -it ghcr.io/devsecfranklin/ssh-server:latest bash
