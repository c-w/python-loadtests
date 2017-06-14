"""
WSGI config for django_modwsgi_apache project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.11/howto/deployment/wsgi/
"""

import json
import sys
from os import environ
from os.path import abspath
from os.path import dirname
from os.path import join

from django.core.wsgi import get_wsgi_application

app_dir = dirname(dirname(abspath(__file__)))
if app_dir not in sys.path:
    sys.path.append(app_dir)

try:
    with open(join(app_dir, 'env.json')) as fobj:
        env = json.load(fobj)
        for key, value in env.items():
            environ[key] = value
except IOError as ex:
    print("Error loading environment variables: %s" % ex, file=sys.stderr)

environ.setdefault("DJANGO_SETTINGS_MODULE", "django_modwsgi_apache.settings")

application = get_wsgi_application()
