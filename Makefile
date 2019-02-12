.PHONY: build doc markdown static templates test

PRE := /app
MD := markdown
TEMPLATES := templates

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
	bash -xe test/env_setup.sh

clean: ## Cleanup all the things
	if [ -f "doc/my_resume.docx" ]; then rm doc/my_resume.docx; fi
	if [ -f "$(TEMPLATES)/index.html" ]; then rm $(TEMPLATES)/index.html; fi

doc: ## Convert markdown to MS Word
	if [ ! -d "doc" ]; then mkdir doc;  fi
	pandoc -f markdown -s "$(MD)/pageone.md" -o "doc/my_resume.docx"

heroku: ## generate HTML from markdown on heroku
	if [ ! -d "$(PRE)/doc" ]; then mkdir $(PRE)/doc;  fi
	pandoc -f markdown -s "$(PRE)/$(MD)/pageone.md" -o "$(PRE)/doc/my_resume.docx"	
	if [ ! -d "$(PRE)/$(TEMPLATES)" ]; then mkdir $(PRE)/$(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(PRE)/$(TEMPLATES)/index.html" "$(PRE)/$(MD)/pageone.md" --title "Franklin Resume" --metadata author="Franklin" --template $(PRE)/$(MD)/pandoc_template.html

html: ## generate HTML from markdown
	if [ ! -d "$(TEMPLATES)" ]; then mkdir $(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(TEMPLATES)/index.html" "$(MD)/pageone.md" --title "Franklin Resume" --metadata author="Franklin" --template $(MD)/pandoc_template.html

lint: ## check the Markdown files for issues
	$(MAKE) build
	find . -name '*.md' | xargs /usr/local/bin/mdl
