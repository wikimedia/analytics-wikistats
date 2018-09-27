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

yyyy='2017' # <--- update yearly !!!

echo put dammit files into hdfs

merged_local='/srv/dumps/pagecounts-ez/merged/'
merged_hdfs='/user/wikistats_data/dammit/pagecounts/'

echo merged_local=$merged_local
echo merged_hdfs=$merged_hdfs

cd $merged_local
ls -l

 hdfs dfs -put -f -p ./$yyyy $merged_hdfs
#hdfs dfs -put -f -p ./pagecounts-2017-11-views-ge-5.bz2 /user/$merged2 # test
 hdfs dfs -ls -R $merged_hdfs > $merged_local/files_in_hdfs

# to do: verify that files were uploaded to hdfs (how? parse file 'files_in_hdfs'?)
# if uploaded correctly, delete automatically from $merged
