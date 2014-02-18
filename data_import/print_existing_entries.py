from sys import argv
from urllib import quote
from urllib2 import urlopen
from urllib2 import HTTPError
#from time import sleep

with open(argv[2]) as input_file:
    for line in input_file:
        page_name = line.split('\t')[0]

        try:
            urlopen(argv[1] + quote(page_name.replace('_', ' ')))
            print line[:-1]
        except HTTPError:
            pass