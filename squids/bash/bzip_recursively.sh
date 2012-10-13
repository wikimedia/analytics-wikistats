#!/bin/bash
ulimit -v 20000
wikistats=/a/wikistats_git

name=*Binaries*.csv
cd $wikistats/squids/csv
find -name $name -type f -exec bzip2 {} \;

