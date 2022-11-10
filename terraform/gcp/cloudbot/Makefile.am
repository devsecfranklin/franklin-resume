CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

clean:
	@for trash in aclocal aclocal.m4 autom4te.cache config config.log config.status configure libtool Makefile Makefile.in; do\
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done

python: 
	@$(PY39) -m venv _build
	( \
		source _build/bin/activate; \
		_build/bin/python -m pip install --upgrade pip; \
		_build/bin/python -m pip install tox; \
		_build/bin/python -m pip install -rsrc/requirements.txt; \
	)

test: 
	@$(PY39) -m venv _build
	( \
		source _build/bin/activate; \
		_build/bin/python -m pip install --upgrade pip; \
		_build/bin/python -m pip install tox; \
		_build/bin/python -m pip install -rtests/requirements-test.txt; \
        _build/bin/python -m pip install -rtests/requirements-security.txt; \
	)
