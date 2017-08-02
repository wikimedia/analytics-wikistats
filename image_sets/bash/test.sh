#! /bin/bash
ulimit -v 1000000

export http_proxy=http://webproxy.eqiad.wmnet:8080 # Jan 2015 see https://wikitech.wikimedia.org/wiki/Http_proxy

convert test_in.jpg -resize 200x100 test.jpg
