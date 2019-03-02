.PHONY: build doc markdown static templates

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
	bash -xe tests/env_setup.sh

clean: ## Cleanup all the things
	if [ -f "$(DOC)/my_resume.docx" ]; then rm $(DOC)/my_resume.docx; fi
	if [ -f "$(TEMPLATES)/index.html" ]; then rm $(TEMPLATES)/index.html; fi
	rm -rf franklin_resume.egg-info
	rm -rf dist/

dist: ## make a pypi style dist
	python3 setup.py sdist

doc: ## Convert markdown to MS Word
	pandoc -f markdown -t docx -s -o "$(DOC)/my_resume.docx" "$(MD)/header.md" "$(MD)/doc_header.md" "$(MD)/pageone.md" 

heroku: ## generate HTML from markdown on heroku
	if [ ! -d "$(PRE)/$(DOC)" ]; then mkdir $(PRE)/$(DOC);  fi
	pandoc -f markdown -s "$(PRE)/$(MD)/pageone.md" -o "$(PRE)/$(DOC)/my_resume.docx"	
	if [ ! -d "$(PRE)/$(TEMPLATES)" ]; then mkdir $(PRE)/$(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(PRE)/$(TEMPLATES)/index.html" "$(PRE)/$(MD)/header.md" "$(PRE)/$(MD)/dev_header.md" "$(PRE)/$(MD)/pageone.md" --title "Franklin Resume" --metadata author="Franklin" --template $(PRE)/$(TEMPLATES)/pandoc_template.html

html: ## generate HTML from markdown
	if [ ! -d "$(TEMPLATES)" ]; then mkdir $(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(TEMPLATES)/index.html" "$(MD)/header.md" "$(MD)/dev_header.md" "$(MD)/downloads.md" "$(MD)/pageone.md" --title "Franklin Resume" --metadata author="Franklin" --template $(MD)/pandoc_template.html

lint: ## check the Markdown files for issues
	$(MAKE) build
	find . -name '*.md' | xargs /usr/local/bin/mdl

local: ## run application locally
	docker-compose up --build franklin_resume

local-dev: ## test application locally
	docker-compose up --build dev_franklin_resume
	@echo "Now type: docker-compose run dev_franklin_resume /bin/bash"

pdf: ## generate a PDF version of reume
	pandoc -s -V geometry:margin=1in -o "$(DOC)/my_resume.pdf" "$(MD)/header.md" "$(MD)/doc_header.md" "$(MD)/pageone.md"
	#pandoc -f markdown -s "$(MD)/pageone.md" -o "doc/my_resume.pdf"