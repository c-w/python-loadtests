from random import randint

from locust import HttpLocust
from locust import TaskSet
from locust import task


class WebsiteTasks(TaskSet):
    @task
    def test(self):
        ident = randint(1, 1000000)
        self.client.get('/test/%s' % ident, name='/test/[ident]')


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
