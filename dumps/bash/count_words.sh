#!/bin/sh
ulimit -v 1000000

# x=1000
x=1
while [ $x -gt 0 ]
do
# clear
  perl WikiCountWords.pl 
  x=`/usr/bin/expr $x - 1 `
  echo "x=$x"
done
echo "Ready"   


