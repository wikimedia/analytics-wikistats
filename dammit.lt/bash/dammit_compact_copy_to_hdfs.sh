#!/bin/bash

# cp
# Usage: hdfs dfs -cp [-f] [-p | -p[topax]] URI [URI ...] <dest>
# Copy files from source to destination. This command allows multiple sources as well in which case the destination must be a directory.
# Options:
# The -f option will overwrite the destination if it already exists.
# The -p option will preserve file attributes [topx] (timestamps, ownership, permission, ACL, XAttr). If -p is specified with no arg, then preserves timestamps, ownership, permission. If -pa is specified, then preserves permission also because ACL is a super-set of permission.
# Example:
# hdfs dfs -cp /user/hadoop/file1 /user/hadoop/file2
# hdfs dfs -cp /user/hadoop/file1 /user/hadoop/file2 /user/hadoop/dir
# Exit Code:
# Returns 0 on success and -1 on error.

yyyy='2017'
echo put dammit files into hdfs
merged='ezachte/wikistats_data/dammit/pagecounts/merged/'
echo merged=$merged

cd /home/$merged
hdfs dfs -put -f -p ./$yyyy /user/$merged 
hdfs dfs -ls -R /user/$merged > /home/$merged/files_in_hdfs 
