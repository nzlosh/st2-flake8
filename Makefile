# Copyright 2020-2024 StackStorm contributors.
# Copyright 2019 Extreme Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PY3 := python3
SYS_PY3 := $(shell which $(PY3))
PIP_VERSION = 24.0
VER := $(shell grep __version__ ./st2flake8/__init__.py | cut -d= -f2 | tr -d '" ')

# Virtual Environment
VENV_DIR ?= .venv

# Tox Environment
TOX_DIR ?= .tox

# Packaging Options
PKGDISTDIR    = dist
PKGBUILDDIR   = build


.PHONY: all
all: tox

.PHONY: clean
clean:
	rm -rf $(VENV_DIR)
	rm -rf $(TOX_DIR)
	rm -rf $(PKGDISTDIR)
	rm -rf $(PKGBUILDDIR)
	rm -rf *.egg-info
	rm -f coverage.xml

.PHONY: tox
tox: setup_virtualenv check_virtualenv
	$(VENV_DIR)/bin/tox

.PHONY: tests
tests: check_virtualenv
	$(VENV_DIR)/bin/pytest

.PHONY: create_virtualenv
create_virtualenv:
	test -d $(VENV_DIR) || $(SYS_PY3) -m venv $(VENV_DIR)

.PHONY: install_requirements
install_requirements: create_virtualenv
	$(VENV_DIR)/bin/pip install --upgrade pip==$(PIP_VERSION)
	$(VENV_DIR)/bin/pip install -r requirements.txt
	$(VENV_DIR)/bin/pip install -r requirements-test.txt

.PHONY: setup_virtualenv
setup_virtualenv: install_requirements

.PHONY: check_virtualenv
check_virtualenv:
	test -d $(VENV_DIR) || echo "Missing virtual environment, try running make setup_virtualenv."
	test -d $(VENV_DIR) || exit 1

.PHONY: build_application
build_application: check_virtualenv
	$(VENV_DIR)/bin/$(PY3) setup.py develop

.PHONY: build_package
build_package: check_virtualenv
	rm -rf $(PKGDISTDIR)
	rm -rf $(PKGBUILDDIR)
	$(VENV_DIR)/bin/$(PY3) setup.py sdist bdist_wheel
