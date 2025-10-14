# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

ACLOCAL_AMFLAGS = -I config/m4 -I aclocal/latex-m4
CLOCAL_AMFLAGS = -I config/m4 -I aclocal/latex-m4

#include target.mk

check: DOCKER-exists
PYTHON-exists: ; @which python > /dev/null
mytarget: check
.PHONY: check PYTHON-exists

clean:
if HAS_DOCKER
	docker system prune -f
endif
	rm -rf *.egg-info
	find . -name '*.pyc' | xargs rm -rf
	find . -name '__pycache__' | xargs rm -rf
	for trash in AUTHORS ChangeLog aclocal.m4 autom4te.cache config config.log \
        	config.status configure configure~ config.h.in~ libtool Makefile Makefile.in po \
		ansible/Makefile ansible/Makefile.in \
		assembly/Makefile assembly/Makefile.in assembly/src/Makefile assembly/src/Makefile.in \
		container/cloudbot/Makefile container/cloudbot/Makefile.in \
        	customer/Makefile customer/Makefile.in container/rhel8/Makefile.in container/rhel8/Makefile \
		container/Makefile container/Makefile.in src/nodebot/Makefile src/nodebot/Makefile.in \
		src/gui-test/Makefile.in src/gui-test/Makefile \
		_test _security NEWS;do \
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done

dist-clean: clean
	rm -rf _build

dev:
#/Users/fdiaz/.pyenv/versions/3.11.13/bin/python3 -m venv $(BUILDDIR)/dev
	$$(PY39) -m venv $(BUILDDIR)/dev
	( \
		source $(BUILDDIR)/build/bin/$(ACTIVATE); \
		$(BUILDDIR)/build/bin/python -m pip install --upgrade pip; \
		$(BUILDDIR)/build/bin/python -m pip install -r $(WORKDIR)/src/cloudbot/requirements.txt; \
		$(BUILDDIR)/build/bin/python -m pip install -r $(WORKDIR)/terraform/requirements.txt; \
		$(WORKDIR)/bootstrap.sh \
	)

.PHONY: test
test:
	@$(PY39) -m venv $(BUILDDIR)/test
	( \
		source $(BUILDDIR)/test/bin/$(ACTIVATE); \
		$(BUILDDIR)/test/bin/python -m pip install --upgrade pip; \
		$(BUILDDIR)/test/bin/python -m pip install -r$(WORKDIR)/test/python/requirements.txt; \
		$(BUILDDIR)/test/bin/python -m pip install -r$(WORKDIR)/test/python/requirements-dev.txt; \
		python3 -m pip install molecule[lint]; \
		python3 -m pip install "molecule-plugins[podman]"; \
		$(WORKDIR)/bootstrap.sh \
	)
	@echo "$(info Found Python version $(PY39))"

.PHONY: security
security:
	@$(PY39) -m venv $(BUILDDIR)/security
	( \
		source $(BUILDDIR)/security/bin/$(ACTIVATE); \
		$(BUILDDIR)/security/bin/python -m pip install --upgrade pip; \
		$(BUILDDIR)/security/bin/python -m pip install -r$(WORKDIR)/security/requirements.txt; \
		$(WORKDIR)/bootstrap.sh \
	)
	@echo "Found Python version $(PY39)"
