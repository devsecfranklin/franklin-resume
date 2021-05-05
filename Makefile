.PHONY: docker python

REQS := python/requirements.txt
REQS_TEST := python/requirements-test.txt

# Used for colorizing output of echo messages
BLUE := "\\033[1\;36m"
LBLUE := "\\033[1\;34m"
LRED := "\\033[1\;31m"
NC := "\\033[0m" # No color/default

SHELL:=/bin/bash
SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit
MAKEFLAGS += --no-print-directory
MAKEOVERRIDES := $(filter-out NIX_REMOTE=%,$(MAKEOVERRIDES))
unexport NIX_REMOTE

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
  match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
  if match:
    target, help = match.groups()
    print("%-20s %s" % (target, help))
endef

export PRINT_HELP_PYSCRIPT

help:
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

app: ## run application locally
	@if [ -f /.dockerenv ]; then echo "Don't run make app inside docker container" && exit 1; fi;
	docker-compose -f docker-compose.yml up --build franklin_resume

build: ## build a container for the image repo
	@if [ -f /.dockerenv ]; then $(MAKE) print-status MSG="***> Don't run make build inside docker container <***" && exit 1; fi
	@$(MAKE) print-status MSG="Building the docker container"
	docker build -t frank378:franklin_resume \
		--build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') . | tee .buildlog

clean: ## Cleanup all the things
	rm -rf rst/_build
	rm -rf python/.coverage
	rm -rf python/*.egg-info
	rm -rf python/.pytest_cache
	rm -rf python/.tox
	@find . -name '*.pyc' | xargs rm -rf
	@find . -name '__pycache__' | xargs rm -rf
	@if [ -f .buildlog ]; then rm .buildlog; fi
	@if [ ! -d "/nix" ]; then nix-collect-garbage -d; fi

  
test: ## run all test cases
	@if [ ! -d "/nix" ]; then $(MAKE) print-error MSG="You don't have nix installed." && exit 1; fi
	@$(MAKE) print-status MSG="Running test cases"
	@nix-shell --run "tox"

print-error:
	@:$(call check_defined, MSG, Message to print)
	@echo -e "$(LRED)$(MSG)$(NC)"

print-status:
	@:$(call check_defined, MSG, Message to print)
	@echo -e "$(BLUE)$(MSG)$(NC)"

