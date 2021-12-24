.PHONY: python

PY39 := $(shell command -v python3 2> /dev/null)
ifndef PY39
    PY39 := $(shell command -v python 2> /dev/null)
endif

REQS := requirements.txt
REQS_TEST := tests/requirements-test.txt

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
	docker run -it -p 5000:5000 frank378:franklin_resume

build: ## build a container for the image repo
	@if [ -f /.dockerenv ]; then $(MAKE) print-status MSG="***> Don't run make build inside docker container <***" && exit 1; fi
	@$(MAKE) print-status MSG="Building the docker container"
	docker build -t frank378:franklin_resume .

clean: ## Cleanup all the things
	rm -rf _build
	rm -rf .coverage
	rm -rf *.egg-info
	rm -rf .pytest_cache
	rm -rf .tox
	@find . -name '*.pyc' | xargs rm -rf
	@find . -name '__pycache__' | xargs rm -rf
	@if [ -f .buildlog ]; then rm .buildlog; fi
	@if [ ! -d "/nix" ]; then nix-collect-garbage -d; fi
	@if [ -d "venv" ]; then rm -rf venv; fi

print-error:
	@:$(call check_defined, MSG, Message to print)
	@echo -e "$(LRED)$(MSG)$(NC)"

print-status:
	@:$(call check_defined, MSG, Message to print)
	@echo -e "$(BLUE)$(MSG)$(NC)"

python: ## build the python env
	@$(PY39) -m venv _build 
	. _build/bin/activate
	@$(PY39) -m pip install --upgrade pip
	@$(PY39) -m pip install tox
	@$(PY39) -m pip install -r requirements.txt --no-warn-script-location
	@$(PY39) -m pip install -r tests/requirements-test.txt --no-warn-script-location

test: ## run all test cases
	@if [ ! -d "/nix" ]; then $(MAKE) print-error MSG="You don't have nix installed." && exit 1; fi
	@$(MAKE) print-status MSG="Running test cases"
	@nix-shell --run "tox -e py39"
