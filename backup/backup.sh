#! /bin/bash
ulimit -v 8000000

backup="/srv/stats.wikimedia.org/htdocs/backup/"
cgibin="/srv/stats.wikimedia.org/cgi-bin/"
htdocs="/srv/stats.wikimedia.org/htdocs/"

cd $htdocs/wikibooks/EN
zip $backup/htdocs/wikibooks.zip *

cd $htdocs/wikinews/EN
zip $backup/htdocs/wikinews.zip *

cd $htdocs/wikiquote/EN
zip $backup/htdocs/wikiquote.zip *

cd $htdocs/wikisource/EN
zip $backup/htdocs/wikisource.zip *

cd $htdocs/wikispecial/EN
zip $backup/htdocs/wikispecial.zip *

cd $htdocs/wikiversity/EN
zip $backup/htdocs/wikiversity.zip *

cd $htdocs/wikivoyage/EN
zip $backup/htdocs/wikivoyage.zip *

cd $htdocs/wiktionary/EN
zip $backup/htdocs/wiktionary.zip *

cd $htdocs/wikimedia/EN
zip $backup/htdocs/wikimedia.zip *

exit

cd $htdocs/EN
zip $backup/htdocs/wikipedia.zip *

ls -l
cd $cgibin
zip $backup/cgi_bin/cgi_bin.zip *

cd $htdocs
zip $backup/htdocs/htdocs.zip *

cd $htdocs/archive
zip $backup/htdocs/archive.zip *

cd $htdocs/mail-lists
zip $backup/htdocs/mail_lists.zip *

cd $htdocs/new-mobile-pageviews-report
zip $backup/htdocs/new_mobile_pageviews_reports.zip *

cd $htdocs/page_views
zip $backup/htdocs/page_views.zip *

cd $htdocs/pediapress
zip $backup/htdocs/pediapress.zip *

cd $htdocs/reportcard
zip $backup/htdocs/reportcard.zip *

cd $htdocs/worldbank
zip $backup/htdocs/worldbank.zip *

cd $backup/cgi_bin
md5sum * > ../md5sum.txt
cd $backup/htdocs
md5sum * >> ../md5sum.txt
cd ..
ls -l


