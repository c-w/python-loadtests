#!/usr/bin/env bash

set -euo pipefail

# config
sudo apt-get update

# install python
sudo apt-get install -y python3 python3-venv python3-dev python3-pip libssl-dev
python3 -m venv py_venv
py_venv/bin/pip install --upgrade pip wheel

# install shared
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/shared/locustfile.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/shared/setup_azure_tables.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/shared/requirements.txt
py_venv/bin/pip install -r requirements.txt
