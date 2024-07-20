CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

.PHONY: src test

clean:
	@for trash in aclocal aclocal.m4 autom4te.cache config config.log config.status configure configure~ libtool Makefile Makefile.in; do\
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done
	rm -rf _build _test
	rm -rf .coverage
	rm -rf *.egg-info
	rm -rf .pytest_cache
	rm -rf .tox
	@find . -name '*.pyc' | xargs rm -rf
	@find . -name '__pycache__' | xargs rm -rf
	@if [ -f .buildlog ]; then rm .buildlog; fi
	@if [ -d "/nix" ]; then nix-collect-garbage -d; fi
	docker system prune -f

python:
	@$(PY39) -m venv _build
	( \
		source _build/bin/activate; \
		_build/bin/python -m pip install --upgrade pip\
                        --index-url http://storage1.lab.bitsmasher.net/pypi \
                        --extra-index-url https://pypi.org/simple \
                        --trusted-host storage1.lab.bitsmasher.net --upgrade pip; \
		_build/bin/python -m pip install -r src/requirements.txt --no-warn-script-location\
                        --index-url http://storage1.lab.bitsmasher.net/pypi \
                        --extra-index-url https://pypi.org/simple \
                        --trusted-host storage1.lab.bitsmasher.net --upgrade pip; \
	)

test:
	@$(PY39) -m venv _test
	( \
		source _test/bin/activate; \
		_test/bin/python -m pip install --upgrade pip\
                        --index-url http://storage1.lab.bitsmasher.net/pypi \
                        --extra-index-url https://pypi.org/simple \
                        --trusted-host storage1.lab.bitsmasher.net --upgrade pip; \
		_test/bin/python -m pip install tox\
                        --index-url http://storage1.lab.bitsmasher.net/pypi \
                        --extra-index-url https://pypi.org/simple \
                        --trusted-host storage1.lab.bitsmasher.net --upgrade pip; \
		_test/bin/python -m pip install -r test/requirements-test.txt --no-warn-script-location \
                        --index-url http://storage1.lab.bitsmasher.net/pypi \
                        --extra-index-url https://pypi.org/simple \
                        --trusted-host storage1.lab.bitsmasher.net --upgrade pip; \
	)

security: 
	@$(PY39) -m venv _security
	( \
		source _build/bin/activate; \
		_security/bin/python -m pip install --upgrade pip\
                        --index-url http://storage1.lab.bitsmasher.net/pypi \
                        --extra-index-url https://pypi.org/simple \
                        --trusted-host storage1.lab.bitsmasher.net --upgrade pip; \
		_security/bin/python -m pip install -r test/requirements-security.txt\
                        --index-url http://storage1.lab.bitsmasher.net/pypi \
                        --extra-index-url https://pypi.org/simple \
                        --trusted-host storage1.lab.bitsmasher.net --upgrade pip; \
	)
