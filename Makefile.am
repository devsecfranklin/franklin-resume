ACLOCAL_AMFLAGS = -I config/m4 -I aclocal
CLOCAL_AMFLAGS = -I config/m4 -I aclocal

#include target.mk

check: DOCKER-exists
PYTHON-exists: ; @which python > /dev/null
mytarget: check
.PHONY: check PYTHON-exists

clean:
if HAS_DOCKER
	docker system prune -f
endif
	rm -rf $(BUILDDIR) LDFLAGS
	find . -name '*.pyc' | xargs rm -rf
	find . -name '__pycache__' | xargs rm -rf
	for trash in AUTHORS ChangeLog _collect _build aclocal aclocal.m4 autom4te.cache config config.log _viz\
        	config.status configure configure~ libtool Makefile Makefile.in po\
			container/cloudbot/Makefile container/cloudbot/Makefile.in\
        	customer/Makefile customer/Makefile.in container/rhel8/Makefile.in container/rhel8/Makefile\
			container/Makefile container/Makefile.in _test _security NEWS;do \
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done

python:
	@$(PY39) -m venv $(BUILDDIR)/build
	( \
		source $(BUILDDIR)build/bin/activate; \
		$(BUILDDIR)/build/bin/python -m pip install --upgrade pip; \
		$(BUILDDIR)/build/bin/python -m pip install -r $(WORKDIR)/src/cloudbot/requirements.txt; \
		$(BUILDDIR)/build/bin/python -m pip install -r $(WORKDIR)/terraform/requirements.txt; \
	)

.PHONY: test
test:
	@$(PY39) -m venv $(BUILDDIR)/test
	( \
		source $(BUILDDIR)/test/bin/activate; \
		$(BUILDDIR)/test/bin/python -m pip install --upgrade pip; \
		$(BUILDDIR)/test/bin/python -m pip install -r$(WORKDIR)/test/requirements-test.txt; \
		$(WORKDIR)//bootstrap.sh \
	)
	@echo "$(info Found Python version $(PY39))"

security:
	@$(PY39) -m venv $(BUILDDIR)/security
	( \
		source $(BUILDDIR)/security/bin/activate; \
		$(BUILDDIR)/security/bin/python -m pip install --upgrade pip; \
		$(BUILDDIR)/security/bin/python -m pip install -r$(WORKDIR)/test/requirements-security.txt; \
	)
	@echo "Found Python version $(PY39)"
