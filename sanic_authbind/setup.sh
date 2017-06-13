#!/usr/bin/env bash

set -euo pipefail

# config
azure_account_name="$1"
azure_account_key="$2"
azure_table_name="${3:-pythonloadtests}"
runas="${4:-$(whoami)}"
sudo apt-get update

# install authbind
sudo apt-get install -y authbind
sudo touch /etc/authbind/byport/80
sudo chown "${runas}:${runas}" /etc/authbind/byport/80
sudo chmod 755 /etc/authbind/byport/80

# install python
sudo apt-get install -y python3 python3-venv python3-dev python3-pip libssl-dev
python3 -m venv sanic_venv
sanic_venv/bin/pip install --upgrade pip wheel

# install app
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/sanic_authbind/app.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/shared/app_business_logic.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/sanic_authbind/requirements.txt
sanic_venv/bin/pip install -r requirements.txt

# auto-start app
sudo apt-get install -y supervisor
sudo service supervisor start
sudo tee /etc/supervisor/conf.d/sanic_app.conf << EOF
[program:sanic_app]
command=/usr/bin/authbind "$(readlink -f .)/sanic_venv/bin/python" $(readlink -f app.py)
autostart=true
autorestart=true
startretries=3
stderr_logfile=/tmp/sanic_app.err.log
stdout_logfile=/tmp/sanic_app.out.log
user=${runas}
environment=AZURE_ACCOUNT_NAME="${azure_account_name}",AZURE_ACCOUNT_KEY="${azure_account_key}",AZURE_TABLE_NAME="${azure_table_name}"
EOF
sudo supervisorctl reread
sudo supervisorctl update
