.PHONY: markdown

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
	rm doc/my_resume.docx
	rm templates/*.html

doc: ## Convert markdown to MS Word
	if [ ! -d "doc" ]; then mkdir doc;  fi
	pandoc -f markdown -s "$(MD)/pageone.md" -o "doc/my_resume.docx"

html: ## generate HTML from markdown
	if [ ! -d "$(TEMPLATES)" ]; then mkdir $(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(TEMPLATES)/index.html" "$(MD)/pageone.md" -c "static/style.css" --metadata title="Franklin Resume"

lint: ## check the Markdown files for issues
	$(MAKE) build
	find . -name '*.md' | xargs /usr/local/bin/mdl
