clean:
	docker system prune -f

push: .check-env-vars
	docker push ghcr.io/devsecfranklin/customer:latest

run:
	docker run -it customer-build bash

rhel:
	docker compose build customer-build
    @echo "Tagging image:  $(shell docker images -q | head -1)"
    docker tag $(shell docker images -q | head -1) ghcr.io/devsecfranklin/customer:latest
