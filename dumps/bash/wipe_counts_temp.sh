#! /bin/bash 

ulimit -s 100000

# inspect temporary Wikistats files per wiki
# if file '@Ready' more than $retention days old, remove all files in dir
# $retention days delay is to allow manual inspection of anomalous results     
# note: this 'indirect' approach ensures all files in a directory are removed at the same time 

retention='2'

cd /home/ezachte/wikistats_data/dumps/temp

for dir in ./* ; 
do 

  if [ -d "$dir" ]; then  # is directory ?

    if [ -f "$dir/@Ready" ]; then # dir contains file '@Ready' ?

      echo "file $dir/@Ready found -> remove files in this directory if file age of '@Ready' is older than $retention days"

      rm @FilesRemoved      # erase old file
      ls -l $dir > "@Files" # save list of files (at one directory level higher, to move down later)

      if test "`find $dir/@Ready -mtime $retention`" ; then

        echo "file @Ready older than $retention days"
        for f in $dir/* ; 
        do
          echo "rm $f" >> @FilesRemoved
          rm $f 
        done
         
      else
        echo "file @Ready not older than $retention days"
      fi
      
      mv @Files $dir
      mv @FilesRemoved $dir

    else
      echo "file $dir/@Ready not found"
    fi ;

  fi ;
done 
