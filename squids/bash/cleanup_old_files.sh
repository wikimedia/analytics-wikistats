#! /bin/sh
ulimit -v 4000000

wikistats=/a/wikistats_git

# du /a/wikistats_git/squids/csv/ | grep G > cleanup_old_files.txt
find /a/wikistats_git/squids/csv/*/*/private -type f -mtime +93  | sort > cleanup_old_files.txt 
find /a/wikistats_git/squids/csv/*/*/private -type f -mtime +93  | sort | xargs rm >> cleanup_old_files.txt
# du /a/wikistats_git/squids/csv/ | grep G >> cleanup_old_files.txt

name=*Binaries*.csv
cd $wikistats/squids/csv
find -name $name -type f -exec bzip2 {} \;

