cd /a/squid/archive/edits

function edit {
  date=$1
  echo $date

#  cat ~/submits-${date}.tsv | \
#  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | `# e.g. amssq54.esams.wikimedia.org -> #esams#` \
#  sed 's/\tcp\w*\t/\t\#cp\#\t/' |                               `# e.g. cp120 -> #cp#` \
#  sed 's/\tssl\w*\t/\t\#ssl\#\t/' |                             `# e.g. sl100 -> #ssl#` \
#  sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' |  `# e.g. cp123.wikimedia.org -> #cp#` \
#  sed 's/amssq[^\t]*/\#amssq\#/g' |                             `# e.g. amssq100 -> #amssq#` \
#  sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' |     `# e.g. http://en.m.wikipedia.org/wiki/Rembrandt -> url-mobile-site` \
#  sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' |                  `# e.g. http://en.wikipedia.org/wiki/Rembrandt -> url-main-site` \
#  sed -E 's/;[^\t]*\t/\t/' |                                    `# e.g. text/html; font blabla -> text/html` \
#  cut  -f 1,2,7,9,10,12                                         `# file server status method url mime` \
#  > ~/submits-${date}-short.tsv

  cat ~/submits-${date}-short.tsv | \
  grep -P "GET|POST" |\
  grep -P "200|302" | \
  grep -P "text\/html|multipart|\t\-$" | \
  sed -E 's/\#(esams|eqiad|ulsfo|amssq|cp|sq)\#/\#non-ssl\#/g' |\
  cut -f 2-99 |\
# sort \
# uniq -c \
  sort >>  ~/submits-tallied-no-dates-no-uniq
}

dates="2013-05-01 2013-06-01 2013-07-01 2013-08-01 2013-09-01 2013-10-01 2013-11-01 2013-12-01 2014-01-01 2014-02-01 2014-03-01 2014-04-01 2014-05-01 2014-06-01 2014-07-01 2014-08-01 2014-09-01 2014-10-01 2014-11-01 2014-12-01 2015-01-01" ;

rm -f ~/submits-tallied 
rm -f ~/submits-tallied-no-dates-no-uniq

for date in $dates ;
do 
  edit $date
done

cat ~/submits-tallied-no-dates-no-uniq | grep -P "200|302" | sort | uniq -c | grep -P -v "^\s*\d{1,2} " | sort -k 2 -k 3 -k 4 -k 5 -k 6

exit
  
cat ~/submits-${date}.tsv | sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/amsq[^\t]*/\#amssq#g' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

exit

cat ~/submits-2013-05-01-short.tsv | grep "amssq" | grep -P "200|302" | grep -P "GET|POST" | sed -E 's/\#(esams|eqiad|ulsfo|cp|sq)\#/\#non-ssl\#/g' | sort | uniq -c 

exit

cat ~/submits-${date}.tsv | sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/amsq[^\t]*/\#amssq#g' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2013-06-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2013-07-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2013-08-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2013-09-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2013-10-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2013-11-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2013-12-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-01-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-02-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-03-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-04-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-05-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-06-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-07-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-08-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-09-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-10-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-11-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2014-12-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

date="2015-01-01"
cat ~/submits-${date}.tsv |  sed -E 's/\t\w*\.(esams|eqiad|ulsfo)\.[^\t]*\t/\t\#\1\#\t/' | sed 's/\tcp\w*\t/\t\#cd\#\t/' | sed 's/\tssl\w*\t/\t\#ssl\#\t/' |sed -E 's/\t(cp|sq)[^\.\t]*\.wikimedia\.org\t/\t\#\1\#\t/' | sed 's/\thttp[^\t]*\.m\.[^\t]*\t/\turl-mobile-site\t/g' | sed 's/\thttp[^\t]*\t/\turl-main-site\t/g' | sed -E 's/;[^\t]*\t/\t/' | cut  -f 1,2,7,9,10,12 > ~/submits-${date}-short.tsv

exit
zgrep  "action=submit"  edits.tsv.log-20130501.gz edits.tsv.log-20130502.gz | grep 2013-05-01T | sed 's/:/\t/' > ~/submits-2013-05-01.tsv
zgrep  "action=submit"  edits.tsv.log-20130601.gz edits.tsv.log-20130602.gz | grep 2013-06-01T | sed 's/:/\t/' > ~/submits-2013-06-01.tsv
zgrep  "action=submit"  edits.tsv.log-20130701.gz edits.tsv.log-20130702.gz | grep 2013-07-01T | sed 's/:/\t/' > ~/submits-2013-07-01.tsv
zgrep  "action=submit"  edits.tsv.log-20130801.gz edits.tsv.log-20130802.gz | grep 2013-08-01T | sed 's/:/\t/' > ~/submits-2013-08-01.tsv
zgrep  "action=submit"  edits.tsv.log-20130901.gz edits.tsv.log-20130902.gz | grep 2013-09-01T | sed 's/:/\t/' > ~/submits-2013-09-01.tsv
zgrep  "action=submit"  edits.tsv.log-20131001.gz edits.tsv.log-20131002.gz | grep 2013-10-01T | sed 's/:/\t/' > ~/submits-2013-10-01.tsv
zgrep  "action=submit"  edits.tsv.log-20131101.gz edits.tsv.log-20131102.gz | grep 2013-11-01T | sed 's/:/\t/' > ~/submits-2013-11-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140101.gz edits.tsv.log-20140102.gz | grep 2014-01-01T | sed 's/:/\t/' > ~/submits-2014-01-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140201.gz edits.tsv.log-20140202.gz | grep 2014-02-01T | sed 's/:/\t/' > ~/submits-2014-02-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140301.gz edits.tsv.log-20140302.gz | grep 2014-03-01T | sed 's/:/\t/' > ~/submits-2014-03-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140401.gz edits.tsv.log-20140402.gz | grep 2014-04-01T | sed 's/:/\t/' > ~/submits-2014-04-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140501.gz edits.tsv.log-20140502.gz | grep 2014-05-01T | sed 's/:/\t/' > ~/submits-2014-05-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140601.gz edits.tsv.log-20140602.gz | grep 2014-06-01T | sed 's/:/\t/' > ~/submits-2014-06-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140701.gz edits.tsv.log-20140702.gz | grep 2014-07-01T | sed 's/:/\t/' > ~/submits-2014-07-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140801.gz edits.tsv.log-20140802.gz | grep 2014-08-01T | sed 's/:/\t/' > ~/submits-2014-08-01.tsv
zgrep  "action=submit"  edits.tsv.log-20140901.gz edits.tsv.log-20140902.gz | grep 2014-09-01T | sed 's/:/\t/' > ~/submits-2014-09-01.tsv
zgrep  "action=submit"  edits.tsv.log-20141001.gz edits.tsv.log-20141002.gz | grep 2014-10-01T | sed 's/:/\t/' > ~/submits-2014-10-01.tsv
zgrep  "action=submit"  edits.tsv.log-20141101.gz edits.tsv.log-20141102.gz | grep 2014-11-01T | sed 's/:/\t/' > ~/submits-2014-11-01.tsv
zgrep  "action=submit"  edits.tsv.log-20141201.gz edits.tsv.log-20141202.gz | grep 2014-12-01T | sed 's/:/\t/' > ~/submits-2014-12-01.tsv
zgrep  "action=submit"  edits.tsv.log-20150101.gz edits.tsv.log-20150102.gz | grep 2015-01-01T | sed 's/:/\t/' > ~/submits-2015-01-01.tsv
zgrep  "action=submit"  edits.tsv.log-20150201.gz edits.tsv.log-20150202.gz | grep 2015-02-01T | sed 's/:/\t/' > ~/submits-2015-02-01.tsv

grep "/302" ~/submits-2013-05-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-05-01.csv
grep "/302" ~/submits-2013-06-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-06-01.csv
grep "/302" ~/submits-2013-07-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-07-01.csv
grep "/302" ~/submits-2013-08-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-08-01.csv
grep "/302" ~/submits-2013-09-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-09-01.csv
grep "/302" ~/submits-2013-10-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-10-01.csv
grep "/302" ~/submits-2013-11-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-11-01.csv
grep "/302" ~/submits-2013-12-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2013-12-01.csv
grep "/302" ~/submits-2014-01-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-01-01.csv
grep "/302" ~/submits-2014-02-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-02-01.csv
grep "/302" ~/submits-2014-03-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-03-01.csv
grep "/302" ~/submits-2014-04-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-04-01.csv
grep "/302" ~/submits-2014-05-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-05-01.csv
grep "/302" ~/submits-2014-06-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-06-01.csv
grep "/302" ~/submits-2014-07-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-07-01.csv
grep "/302" ~/submits-2014-08-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-08-01.csv
grep "/302" ~/submits-2014-09-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-09-01.csv
grep "/302" ~/submits-2014-10-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-10-01.csv
grep "/302" ~/submits-2014-11-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-11-01.csv
grep "/302" ~/submits-2014-12-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2014-12-01.csv
grep "/302" ~/submits-2015-01-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2015-01-01.csv
grep "/302" ~/submits-2015-02-01.tsv | grep -v "miss/302" | sed -E 's/text/html;[^\t]*\t/text/html\t/g' | cut -f 2,7 | sort | uniq -c | sed 's/\t/,/g' | sed 's/^[ \t]*//' | sed 's/ /,/g'> ~/submits-302-no-redirects-2015-02-01.csv
