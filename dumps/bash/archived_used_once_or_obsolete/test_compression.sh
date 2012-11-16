#!/bin/sh
clear

rm abc_*
rm *.7z
echo gzip best
date +%T
gzip  -c --fast abc > abc_fast.gz 

echo gzip fast
date +%T
gzip  -c --best abc > abc_best.gz

echo bzip2 fast
date +%T
bzip2 -c --fast abc > abc_fast.bz2

echo bzip2 best
date +%T
bzip2 -c --best abc > abc_best.bz2

echo 7z
date +%T
7z a abc abc
