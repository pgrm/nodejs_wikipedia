import random
import urllib
from sys import argv

link_names = []
weighted_distribution = []

with open(argv[3]) as input_file:
    for line in input_file:
        (page_name, str_number_of_incoming_links) = line.split('\t')
        page_name = urllib.quote(page_name.replace('_', ' '))
        number_of_incoming_links = int(str_number_of_incoming_links)
        link_name_index = len(link_names)
        link_names.append(page_name)
        weighted_distribution += [link_name_index for i in xrange(0, number_of_incoming_links)]

for j in xrange(0, int(argv[2])):
    print argv[1] + link_names[random.choice(weighted_distribution)]