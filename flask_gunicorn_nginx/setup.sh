#!/usr/bin/env bash

set -euo pipefail

# config
azure_account_name="$1"
azure_account_key="$2"
azure_table_name="${3:-pythonloadtests}"
runas="${4:-$(whoami)}"
sudo apt-get update

# install python
sudo apt-get install -y python3 python3-venv python3-dev python3-pip libssl-dev
python3 -m venv flask_venv
flask_venv/bin/pip install --upgrade pip wheel

# install app
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/flask_gunicorn_nginx/app.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/shared/app_business_logic.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/flask_gunicorn_nginx/requirements.txt
flask_venv/bin/pip install -r requirements.txt

# setup nginx
touch flask_app.socket
sudo apt-get install -y nginx
sudo tee /etc/nginx/sites-available/flask_app << EOF
server {
  listen 80;
  client_max_body_size 50M;
  
  location / {
    include proxy_params;
    proxy_pass http://unix:$(readlink -f flask_app.socket)
  }
}
EOF
sudo ln -fs /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled
sudo rm -f /etc/ngix/sites-enabled/default
sudo service nginx start

# auto-start app
sudo apt-get install -y supervisor
sudo service supervisor start
sudo tee /etc/supervisor/conf.d/flask_app.conf << EOF
[program:flask_app]
command=$(readlink -f flask_venv/bin/gunicorn) --workers=9 --bind="unix:$(readlink -f flask_app.socket)" app:app
autostart=true
autorestart=true
startretries=3
stderr_logfile=/tmp/flask_app.err.log
stdout_logfile=/tmp/flask_app.out.log
user=${runas}
environment=AZURE_ACCOUNT_NAME="${azure_account_name}",AZURE_ACCOUNT_KEY="${azure_account_key}",AZURE_TABLE_NAME="${azure_table_name}"
EOF
sudo supervisorctl reread
sudo supervisorctl update
