#!/usr/bin/env python3
import re


def parse_titles(file):
	for lines in file.readlines():
		print(lines[31:-8])

def parse_urls(file):
	url_pattern = re.compile("href=\"\S+\"")
	for lines in file.readlines():
		m = url_pattern.findall(lines)
		print(m[0][6:-1])

def parse_descs(file):
	desc_pattern = re.compile("<pre>[\w\s]*</pre>") #Figure out this regex later.
	m = desc_pattern.findall(file.read())
	print(m)

def file_from_url(gv, url):
	file_pattern = re.compile(gv + "/\S*")
	m = file_pattern.findall(url)
	print(m[0][len(gv)+1:])
def clean_dependency_string(dep_string):
	print(dep_string[15:-1])

if __name__ == "__main__":
	import sys
	if sys.argv[1] == "parse_titles":
		parse_titles(sys.stdin)
	elif sys.argv[1] == "parse_urls":
		parse_urls(sys.stdin)
	elif sys.argv[1] == "parse_descs":
		parse_descs(sys.stdin)
	elif sys.argv[1] == "file_from_url":
		file_from_url(sys.argv[2], sys.argv[3])
	elif sys.argv[1] == "clean_dependency_string":
		clean_dependency_string(sys.argv[2])