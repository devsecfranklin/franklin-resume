# Used for colorizing output of echo messages
BLUE := "\\033[1\;36m"
NC := "\\033[0m" # No color/default

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
	$(MAKE) pandoc
	$(MAKE) doc
	$(MAKE) pdf
	$(MAKE) html

clean: ## Cleanup all the things
	$(MAKE) print-status MSG="Clean up all the things."
	rm -f my_resume.*

doc: ## Convert markdown to MS Word
	$(MAKE) print-status MSG="Convert markdown to MS Word"
	pandoc -f markdown -t docx -s -o "my_resume.docx" "header.md" "doc_header.md" "pageone.md" 

html: ## generate HTML from markdown
	$(MAKE) print-status MSG="generate HTML from markdown"
	pandoc -f markdown -t html5 -o "my_resume.html" "header.md" "dev_header.md" "downloads.md" "pageone.md" \
	--title "Franklin Resume" --metadata author="Franklin" 
	#--template pandoc_template.html --data-dir=$(PWD)

pdf: ## generate a PDF version of resume
	$(MAKE) print-status MSG="generate a PDF version of resume"
	if [ ! -f "/.dockerenv" ]; then pandoc -s -V geometry:margin=1in -o "my_resume.pdf" "header.md" "doc_header.md" "pageone.md"; fi

print-status:
	@:$(call check_defined, MSG, Message to print)
	@echo "$(BLUE)$(MSG)$(NC)"

pandoc: ## Install pandoc
	if [ ! -f "/app/pandoc-2.7.3-1-amd64.deb" ]; then wget -P /app https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb; fi
	dpkg -i /app/pandoc-2.7.3-1-amd64.deb