import random

input_file_name = "load_testing/test_scripts/existing_incoming_entries.txt"

link_names = []
weighted_distribution = []

with open(input_file_name) as input_file:
    for line in input_file:
        (page_name, str_number_of_incoming_links) = line.split('\t')
        number_of_incoming_links = int(str_number_of_incoming_links)
        link_name_index = len(link_names)
        link_names.append(page_name)
        weighted_distribution += [link_name_index for i in xrange(0, number_of_incoming_links)]


def get_random_page():
    return  link_names[random.choice(weighted_distribution)]