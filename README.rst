Python loadtests
================

This repository contains sample apps and server setup scripts for a variety of Python web stacks:

- Sanic with Authbind
- Flask (behind gUnicorn and Nginx)
- Django (behind Apache)
- Connexion (behind Tornado and Nginx)

For each of these stacks, we then run a load-test that consists of a network-bound task and a framework-bound task.

Authbind + Sanic is the easiest stack to set up and is competitive performance-wise with more complicated stacks.

.. image:: benchmarks.png
  :width: 400
  :align: center
  :alt: Benchmarks of Sanic versus Flask, Connexion and Django
  :target: https://raw.githubusercontent.com/c-w/python-loadtests/master/docs/benchmarks.png

To reproduce these results, first set up a server for each of the web stacks using the setup scripts:

.. sourcecode :: bash

  stack_type=sanic_authbind  # or connexion_tornado_nginx or django_modwsgi_apache or flask_gunicorn_nginx
  curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/${stack_type}/setup.sh | bash -s my-azure-storage-account my-azure-storage-key

Now on a seperate driver machine, set up the data store for the network-bound task and then run the load test:

.. sourcecode :: bash

  curl -O https://raw.githubusercontent.com/c-w/python-loadtests/master/shared/setup.sh | bash
  py_env/bin/python3 setup_azure_tables.py --account=my-azure-storage-account --key=my-azure-storage-key

  test_type=SanicTest  # or ConnexionTest or DjangoTest or FlaskTest
  py_env/bin/locust ${test_type} --only-summary --no-web --clients=500 --hatch-rate=50  # let run for a while, then hit ctrl+c to see results
