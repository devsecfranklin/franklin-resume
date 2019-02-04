.PHONY: markdown

CSS := css
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

gen_html: ## generate HTML from markdown
	if [ ! -d "$(TEMPLATES)" ]; then mkdir $(TEMPLATES); fi
	pandoc -f markdown -t html5 -o "$(TEMPLATES)/index.html" "$(MD)/pageone.md" -c "$(CSS)/franklin.css"

lint: ## check the Markdown files for issues
	if [ ! command -v mdl ]; then \
		echo "gem: --no-document" >> ~/.gemrc;\
		sudo gem install mdl;\
	fi
	find . -name '*.md' | xargs /usr/local/bin/mdl
