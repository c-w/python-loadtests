"""
WSGI config for django_modwsgi_apache project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.11/howto/deployment/wsgi/
"""

import sys
from os import environ
from os.path import abspath
from os.path import dirname
from django.core.wsgi import get_wsgi_application

path = dirname(dirname(abspath(__file__)))
if path not in sys.path:
    sys.path.append(path)

environ.setdefault("DJANGO_SETTINGS_MODULE", "django_modwsgi_apache.settings")

application = get_wsgi_application()
