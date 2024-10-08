CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

check: DOCKER-exists
PYTHON-exists: ; @which python > /dev/null
mytarget: check
.PHONY: check PYTHON-exists

clean:
	rm -rf _build *.egg-info
	find . -name '*.pyc' | xargs rm -rf
	find . -name '__pycache__' | xargs rm -rf
	for trash in AUTHORS ChangeLog _collect _build aclocal aclocal.m4 autom4te.cache config config.log _viz\
        	config.status configure configure~ libtool Makefile Makefile.in po\
			docker/cloudbot/Makefile docker/cloudbot/Makefile.in\
        	customer/Makefile customer/Makefile.in docker/rhel8/Makefile.in docker/rhel8/Makefile\
			docker/Makefile docker/Makefile.in _test NEWS;do \
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done
if HAS_DOCKER
	docker system prune -f
endif

python:
	@$(PY39) -m venv _build
	( \
		source _build/bin/activate; \
		_build/bin/python -m pip install --upgrade pip; \
		_build/bin/python -m pip install -r src/cloudbot/requirements.txt; \
		_build/bin/python -m pip install -r terraform/requirements.txt; \
	)

.PHONY: test
test:
	@$(PY39) -m venv _test
	( \
		source _test/bin/activate; \
		_test/bin/python -m pip install --upgrade pip; \
		_test/bin/python -m pip install -rtest/requirements-test.txt; \
		_test/bin/python -m pip install -rtest/requirements-security.txt; \
		./bootstrap.sh \
	)
	@echo "Found Python version $(PY39)"

