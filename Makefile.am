CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

.PHONY: src tests

app:
	@if [ -f /.dockerenv ]; then echo "Don't run make app inside docker container" && exit 1; fi;
	docker run -it -p 5000:5000 frank378:franklin_resume

build: ## build a container for the image repo
	@if [ -f /.dockerenv ]; then $(MAKE) print-status MSG="***> Don't run make build inside docker container <***" && exit 1; fi
	@$(MAKE) print-status MSG="Building the docker container"
	docker build -t frank378:franklin_resume .

clean:
	@for trash in aclocal aclocal.m4 autom4te.cache config config.log config.status configure libtool Makefile Makefile.in; do\
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done
	rm -rf _build
	rm -rf .coverage
	rm -rf *.egg-info
	rm -rf .pytest_cache
	rm -rf .tox
	@find . -name '*.pyc' | xargs rm -rf
	@find . -name '__pycache__' | xargs rm -rf
	@if [ -f .buildlog ]; then rm .buildlog; fi
	@if [ -d "/nix" ]; then nix-collect-garbage -d; fi

python:
	@$(PY39) -m venv _build
	( \
		source _build/bin/activate; \
		_build/bin/python -m pip install --upgrade pip; \
        _build/bin/python -m pip install tox; \
		_build/bin/python -m pip install -r requirements.txt --no-warn-script-location; \
        _build/bin/python -m pip install -r tests/requirements-test.txt --no-warn-script-location; \
	)

test: ## run all test cases
	@$(PY39) -m venv _build
	( \
		source _build/bin/activate; \
		_build/bin/python -m pip install --upgrade pip; \
		_build/bin/python -m pip install tox; \
		_build/bin/python -m pip install -r tests/requirements-test.txt; \
		_build/bin/python -m pip install -r tests/requirements-security.txt; \
	)
