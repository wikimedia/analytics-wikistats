wiki=enwiki
date=20091103
dumps=/mnt/data/xmldatadumps

perl ./WikiExtractRegUsers.pl -f $dumps/public/$wiki/$date/$wiki-$date-stub-meta-history.xml.gz
sort ./$wiki-$date-stub-meta-history.xml.csv -o ./$wiki-$date-stub-meta-history.xml.sorted.csv  

