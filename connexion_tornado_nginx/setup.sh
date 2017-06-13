#!/usr/bin/env bash

set -euo pipefail

# config
azure_account_name="$1"
azure_account_key="$2"
azure_table_name="${3:-pythonloadtests}"
runas="${4:-$(whoami)}"
sudo apt-get update

# install python
sudo apt-get install -y python3 python3-venv python3-dev python3-pip
python3 -m venv connexion_venv
connexion_venv/bin/pip install --upgrade pip wheel

# install app
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/connexion_tornado_nginx/app.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/shared/app_business_logic.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/connexion_tornado_nginx/api.yaml
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/connexion_tornado_nginx/requirements.txt
connexion_venv/bin/pip install -r requirements.txt

# setup nginx
sudo apt-get install -y nginx
sudo tee /etc/nginx/sites-available/connexion_app << EOF
upstream frontends {
  server 127.0.0.1:8080;
  server 127.0.0.1:8081;
  server 127.0.0.1:8082;
  server 127.0.0.1:8083;
}

proxy_next_upstream error;

server {
  listen 80;
  client_max_body_size 50M;
  
  location / {
    proxy_pass_header Server;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Scheme \$scheme;
    proxy_pass http://frontends;
  }
}
EOF
sudo ln -s /etc/nginx/sites-available/connexion_app /etc/nginx/sites-enabled
sudo rm /etc/ngix/sites-available/default
sudo service nginx start

# auto-start app
sudo apt-get install -y supervisor
sudo service supervisor start
sudo tee /etc/supervisor/conf.d/connexion_app_8080.conf << EOF
[program:connexion_app_8080]
command=$(readlink -f connexion_venv/bin/python) $(readlink -f app.py) --port 8080
autostart=true
autorestart=true
startretries=3
stderr_logfile=/tmp/connexion_app_8080.err.log
stdout_logfile=/tmp/connexion_app_8080.out.log
user=${runas}
environment=AZURE_ACCOUNT_NAME=${azure_account_name},AZURE_ACCOUNT_KEY=${azure_account_key},AZURE_TABLE_NAME=${azure_table_name}
EOF
sudo tee /etc/supervisor/conf.d/connexion_app_8081.conf << EOF
[program:connexion_app_8081]
command=$(readlink -f connexion_venv/bin/python) $(readlink -f app.py) --port 8081
autostart=true
autorestart=true
startretries=3
stderr_logfile=/tmp/connexion_app_8081.err.log
stdout_logfile=/tmp/connexion_app_8081.out.log
user=${runas}
environment=AZURE_ACCOUNT_NAME=${azure_account_name},AZURE_ACCOUNT_KEY=${azure_account_key},AZURE_TABLE_NAME=${azure_table_name}
EOF
sudo tee /etc/supervisor/conf.d/connexion_app_8082.conf << EOF
[program:connexion_app_8082]
command=$(readlink -f connexion_venv/bin/python) $(readlink -f app.py) --port 8082
autostart=true
autorestart=true
startretries=3
stderr_logfile=/tmp/connexion_app_8082.err.log
stdout_logfile=/tmp/connexion_app_8082.out.log
user=${runas}
environment=AZURE_ACCOUNT_NAME=${azure_account_name},AZURE_ACCOUNT_KEY=${azure_account_key},AZURE_TABLE_NAME=${azure_table_name}
EOF
sudo tee /etc/supervisor/conf.d/connexion_app_8083.conf << EOF
[program:connexion_app_8083]
command=$(readlink -f connexion_venv/bin/python) $(readlink -f app.py) --port 8083
autostart=true
autorestart=true
startretries=3
stderr_logfile=/tmp/connexion_app_8083.err.log
stdout_logfile=/tmp/connexion_app_8083.out.log
user=${runas}
environment=AZURE_ACCOUNT_NAME=${azure_account_name},AZURE_ACCOUNT_KEY=${azure_account_key},AZURE_TABLE_NAME=${azure_table_name}
EOF
sudo supervisorctl reread
sudo supervisorctl update
