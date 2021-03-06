from random import randint

from locust import HttpLocust
from locust import TaskSet
from locust import task


class WebsiteTasks(TaskSet):
    @task
    def network(self):
        ident = randint(1, 1000000)
        self.client.get('/network/%s' % ident, name='/network/[ident]')

    @task
    def echo(self):
        ident = randint(1, 1000000)
        self.client.get('/echo/%s' % ident, name='/echo/[ident]')


class WebsiteTest(HttpLocust):
    task_set = WebsiteTasks
    min_wait = 500
    max_wait = 2000


class SanicTest(WebsiteTest):
    host = 'http://52.166.78.63'


class FlaskTest(WebsiteTest):
    host = 'http://52.233.169.18'


class ConnexionTest(WebsiteTest):
    host = 'http://52.166.122.193'


class DjangoTest(WebsiteTest):
    host = 'http://52.232.102.239'
