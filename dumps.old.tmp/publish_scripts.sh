#!/bin/sh

echo "Zip scripts"
zip WikiCounts.zip WikiCounts*.pl
zip WikiReports.zip WikiReports*.pl 
zip scripts.zip WikiCounts.zip WikiReports.zip

echo "Publish scripts"
cp scripts.zip /mnt/htdocs
