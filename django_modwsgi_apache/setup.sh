#!/usr/bin/env bash

set -euo pipefail

# config
azure_account_name="$1"
azure_account_key="$2"
azure_table_name="${3:-pythonloadtests}"
sudo apt-get update

# install python
sudo apt-get install -y python3 python3-venv python3-dev python3-pip libssl-dev
python3 -m venv django_venv
django_venv/bin/pip install --upgrade pip wheel

# install app
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/django_modwsgi_apache/manage.py
mkdir -p django_modwsgi_apache; cd django_modwsgi_apache
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/django_modwsgi_apache/django_modwsgi_apache/__init__.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/django_modwsgi_apache/django_modwsgi_apache/settings.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/django_modwsgi_apache/django_modwsgi_apache/urls.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/django_modwsgi_apache/django_modwsgi_apache/views.py
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/django_modwsgi_apache/django_modwsgi_apache/wsgi.py
cd -
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/django_modwsgi_apache/requirements.txt
curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/shared/app_business_logic.py
django_venv/bin/pip install -r requirements.txt

tee env.json << EOF
{
  "AZURE_ACCOUNT_NAME": "${azure_account_name}",
  "AZURE_ACCOUNT_KEY": "${azure_account_key}",
  "AZURE_TABLE_NAME": "${azure_table_name}"
}
EOF

# setup apache
sudo apt-get install -y apache2 libapache2-mod-wsgi-py3
sudo tee /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  DocumentRoot /var/www/html
  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined
  <Directory $(readlink -f django_modwsgi_apache)>
    <Files wsgi.py>
      Require all granted
    </Files>
  </Directory>
  WSGIDaemonProcess django_app python-path=$(readlink -f django_modwsgi_apache) python-home=$(readlink -f django_venv)
  WSGIProcessGroup django_app
  WSGIApplicationGroup %{GLOBAL}
  WSGIScriptAlias / $(readlink -f django_modwsgi_apache/wsgi.py) process-group=django_app
</VirtualHost>
EOF
sudo setfacl -m u:www-data:rwx .
sudo service apache2 restart
