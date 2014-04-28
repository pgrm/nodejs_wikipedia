import mechanize
import time
import random_url_generator

from urllib import quote


class Transaction(object):
    url = 'http://localhost:8080'
    custom_timers = {}

    def __init__(self):
        pass

    def get_random_page_info(self):
        page_info = random_url_generator.get_random_page().replace('_', ' ')
        page_url = self.url + '/wiki/' + quote(page_info)
        return page_info, page_url

    def run(self):
        br = mechanize.Browser()
        br.set_handle_robots(False)

        (title, random_url) = self.get_random_page_info()

        start_timer = time.time()
        resp = br.open(random_url)
        resp.read()
        latency = time.time() - start_timer

        self.custom_timers['Direct_Page'] = latency

        assert (resp.code == 200)
        assert (title in resp.get_data())


if __name__ == '__main__':
    trans = Transaction()
    trans.run()
    print trans.custom_timers
