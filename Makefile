.PHONY: build doc markdown static templates

REQS := requirements.txt
REQS_TEST := requirements.dev
# Used for colorizing output of echo messages
BLUE := "\\033[1\;36m"
NC := "\\033[0m" # No color/default

PRE := /app
DOC := my_resume/doc
MD := markdown
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

all: ## generate all the formats
	$(MAKE) doc
	$(MAKE) pdf
	$(MAKE) html

build: ## setup the build env
	python3 -m compileall .
	bash -xe tests/env_setup.sh

clean: ## Cleanup all the things
	if [ -f "$(DOC)/my_resume.docx" ]; then rm $(DOC)/my_resume.docx; fi
	if [ -f "$(TEMPLATES)/index.html" ]; then rm $(TEMPLATES)/index.html; fi
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

doc: ## Convert markdown to MS Word
	pandoc -f markdown -t docx -s -o "$(DOC)/my_resume.docx" "$(MD)/header.md" "$(MD)/doc_header.md" "$(MD)/pageone.md" 

heroku: ## generate HTML from markdown on heroku
	if [ ! -d "$(PRE)/$(DOC)" ]; then mkdir $(PRE)/$(DOC);  fi
	pandoc -f markdown -s "$(PRE)/$(MD)/pageone.md" -o "$(PRE)/$(DOC)/my_resume.docx"	
	if [ ! -d "$(PRE)/$(TEMPLATES)" ]; then mkdir $(PRE)/$(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(PRE)/$(TEMPLATES)/index.html" "$(PRE)/$(MD)/header.md" "$(PRE)/$(MD)/dev_header.md" "$(PRE)/$(MD)/pageone.md" --title "Franklin Resume" --metadata author="Franklin" --template $(PRE)/$(MD)/pandoc_template.html

html: ## generate HTML from markdown
	if [ ! -d "$(TEMPLATES)" ]; then mkdir $(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(TEMPLATES)/md_index.html" "$(MD)/header.md" "$(MD)/dev_header.md" "$(MD)/downloads.md" "$(MD)/pageone.md" --title "Franklin Resume" --metadata author="Franklin" --template $(MD)/pandoc_template.html

lint: ## check the Markdown files for issues
	$(MAKE) build
	find . -name '*.md' | xargs /usr/local/bin/mdl

local: ## run application locally
	docker-compose up --build franklin_resume

local-dev: ## test application locally
	$(MAKE) print-status MSG="Building Resume Application...hang tight!"
	python3 -m compileall .
	docker-compose up --build dev_franklin_resume
	@docker-compose run dev_franklin_resume /bin/bash

pdf: ## generate a PDF version of reume
	pandoc -s -V geometry:margin=1in -o "$(DOC)/my_resume.pdf" "$(MD)/header.md" "$(MD)/doc_header.md" "$(MD)/pageone.md"
	#pandoc -f markdown -s "$(MD)/pageone.md" -o "doc/my_resume.pdf"

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