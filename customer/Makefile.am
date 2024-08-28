CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

clean:
	rm -rf _build *.egg-info
	find . -name '*.pyc' | xargs rm -rf
	find . -name '__pycache__' | xargs rm -rf
	for trash in AUTHORS ChangeLog _collect autom4te.cache config config.log _viz\
        	config.status configure configure~ libtool Makefile Makefile.in po\
        	cluster/Makefile cluster/Makefile.in docker/Makefile docker/Makefile.in _test; do \
                if [ -f $$trash ] || [ -d $$trash ]; then \
                	echo "Removing $$trash" ;\
                        rm -rf $$trash ;\
                fi ; \
	done

.PHONY: test
test:
	@echo "Found Python version $(PY39)"
	@$(PY39) -m venv _test
	( \
		. _test/bin/activate; \
		_test/bin/python -m pip install --upgrade pip; \
		_test/bin/python -m pip install tox; \
		_test/bin/python -m pip install -r test/requirements-test.txt; \
	)
