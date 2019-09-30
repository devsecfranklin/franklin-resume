REQS := requirements.txt
REQS_TEST := requirements.dev
# Used for colorizing output of echo messages
BLUE := "\\033[1\;36m"
NC := "\\033[0m" # No color/default

PRE := /app
TEMPLATES := my_resume/templates

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
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build: ## setup the build env
	python3 -m compileall .
	bash -xe tests/env_setup.sh

clean: ## Cleanup all the things
	rm -rf .tox
	rm -rf myvenv
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf *.egg-info
	rm -rf build
	rm -rf dist
	rm -rf htmlcov
	find . -name '*.pyc' | xargs rm -rf
	find . -name '__pycache__' | xargs rm -rf

dist: ## make a pypi style dist
	python3 -m compileall .
	python3 setup.py sdist bdist_wheel

lint: ## check the Markdown files for issues
	$(MAKE) build
	find . -name '*.md' | xargs /usr/local/bin/mdl

local: ## run application locally
	docker-compose -f docker/docker-compose.yml up --build franklin_resume

local-dev: ## test application locally
	$(MAKE) print-status MSG="Building Resume Application...hang tight!"
	python3 -m compileall .
	docker-compose -f docker/docker-compose.yml up --build dev_franklin_resume
	@docker-compose -f docker/docker-compose.yml run dev_franklin_resume /bin/bash

print-status:
	@:$(call check_defined, MSG, Message to print)
	@echo "$(BLUE)$(MSG)$(NC)"

python: ## set up the python environment
	$(MAKE) print-status MSG="Set up the Python environment"
	LD_LIBRARY_PATH=/usr/local/lib python3 -m venv myvenv
	. myvenv/bin/activate; \
	LD_LIBRARY_PATH=/usr/local/lib python3 -m pip install wheel; \
	LD_LIBRARY_PATH=/usr/local/lib python3 -m pip install -rrequirements/$(REQS)

test: python ## test the flask app
	$(MAKE) print-status MSG="Test the Flask App"
	LD_LIBRARY_PATH=/usr/local/lib python3 -m pip install -rrequirements/$(REQS_TEST)
	# tox
	python3 -m pytest tests/