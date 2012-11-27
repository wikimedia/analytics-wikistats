#!/usr/bin/perl

## add text from http://wiki.squid-cache.org/SquidFaq/SquidLogs
## ReportOrigin how to handle '!error <-> other
## VisitorsSampledLogOrigins.htm  total count<->alpha are not the same (+ skip total for "google (total)")
## VisitorsSampledLogOrigins.htm  totals google don't match ReportMimeTypes
## VisitorsSampledLogOrigins.htm internal tonen als bij mime types

# cater for missing files -> different multiplier
# csv file google bot hits per hour -> Stu
# report for edit/submit
# log.txt s -> date folder

  use CGI::Carp qw(fatalsToBrowser);
  use Getopt::Std ;
  use Time::Local ;
  use Cwd;
  use Net::Domain qw (hostname);

  $hostname = `hostname` ;
  chomp ($hostname) ;

  $false     = 0 ;
  $true      = 1 ;

  $| = 1; # flush screen output

  getopt ("dm", \%options) ; # usually contains today's date, will process yesterday's data
  $reportdaysback = $options {"d"} ;
  $reportmonth    = $options {"m"} ;

  # date range used to be read from csv file with ReadDate, now there are daily csv files
  # if earlier methods still is useful it needs to be tweaked
# if (($reportmonth ne "") && ($reportmonth !~ /^\d{6}$/))
  if (($reportmonth !~ /^\d{6}$/) && ($reportdaysback !~ /^-\d+/))
  { print "Specify month as -m yyyymm or days back as -d -[days] (e.g. -d -1 for yesterday)" ; exit ; }

  if ($reportmonth =~ /^\d{6}$/)
  { $reportmonth = substr ($reportmonth,0,4) . "-" . substr ($reportmonth,4,2) ; }
  else
  {
    ($sec,$min,$hour,$day,$month,$year) = localtime (time+$reportdaysback*86400) ;
    $reportmonth = sprintf ("%04d-%02d",$year+1900,$month+1) ;
  }
  print "Report month = $reportmonth\n" ;

  $threshold_mime    = 0 ;
  $threshold_project = 10 ;

  $file_log              = "WikiReportsSampledVisitorsLog.log" ;

  $file_html_crawlers    = "VisitorsSampledLogCrawlers.htm" ;
  $file_html_methods     = "VisitorsSampledLogMethods.htm" ;
  $file_html_origins     = "VisitorsSampledLogOrigins.htm" ;
  $file_html_opsys       = "VisitorsSampledLogOperatingSystems.htm" ;
  $file_html_scripts     = "VisitorsSampledLogScripts.htm" ;
  $file_html_skins       = "VisitorsSampledLogSkins.htm" ;
  $file_html_requests    = "VisitorsSampledLogRequests.htm" ;
  $file_html_google      = "VisitorsSampledLogGoogle.htm" ;
  $file_html_clients     = "VisitorsSampledLogClients.htm" ;

  $file_csv_crawlers     = "WikiCountsSampledVisitorsLogCrawlers.csv" ;
  $file_csv_methods      = "WikiCountsSampledVisitorsLogMethods.csv" ;
  $file_csv_origins      = "WikiCountsSampledVisitorsLogOrigins.csv" ;
  $file_csv_opsys        = "WikiCountsSampledVisitorsLogOpSys.csv" ;
  $file_csv_requests     = "WikiCountsSampledVisitorsLogRequests.csv" ;
  $file_csv_scripts      = "WikiCountsSampledVisitorsLogScripts.csv" ;
  $file_csv_google       = "WikiCountsSampledVisitorsLogSearch.csv" ;
  $file_csv_skins        = "WikiCountsSampledVisitorsLogSkins.csv" ;
  $file_csv_clients      = "WikiCountsSampledVisitorsLogClients.csv" ;
  $file_csv_google_bots  = "WikiCountsSampledVisitorsLogGoogleBots.csv" ;

  print "\n\nJob WikiReportsSampledVisitorsLog.pl\n\n" ;

  if (-d "/a/log")
  {
    print "\n\nJob runs on server $hostname\n\n" ;
    $dir_root = "/home/ezachte" ;
  }
  else
  {
    print "Job runs local for tests\n\n" ;
    # $dir_root = "zwinger/edit-submit" ; # test
    $dir_root = "." ;

#   if (! -e $file_csv_requests) {  $file_csv_requests =~ s/\./Test./ }
#   if (! -e $file_csv_methods)  {  $file_csv_methods  =~ s/\./Test./ }
#   if (! -e $file_csv_skins)    {  $file_csv_skins    =~ s/\./Test./ }
#   if (! -e $file_csv_scripts)  {  $file_csv_scripts  =~ s/\./Test./ }
#   if (! -e $file_csv_opsys)    {  $file_csv_opsys    =~ s/\./Test./ }
#   if (! -e $file_csv_origins)  {  $file_csv_origins  =~ s/\./Test./ }
#   if (! -e $file_csv_google)   {  $file_csv_google   =~ s/\./Test./ }
#   if (! -e $file_csv_crawlers) {  $file_csv_crawlers =~ s/\./Test./ }
  }

  require "$dir_root/WikiReportsDate.pl" ;

  if (! -d "$dir_root/$reportmonth")
  { print "Directory not found: $dir_root\/$reportmonth\n" ; exit ; }

  for ($day = 1 ; $day <= 31 ; $day ++)
  {
    $date = $reportmonth . "-".  sprintf ("%02d", $day) ;
    $dir  = "$dir_root/$reportmonth/$date" ;

    if (-d $dir)
    {
      if ($date_first eq "")
      { $date_first = $date ; }
      $date_last = $date ;
      print "Process dir $dir\n" ;
      push @dirs_process, $dir ;
    }
    else
    { print "Missing dir $dir!\n" ; }

  }
  if ($#dirs_process < 0)
  { print "No valid data to process.\n" ; exit ; }

  $dir_reports = "$dir_root/$reportmonth" ;

  $google_ip_ranges = "<b>IP ranges:</b> known ip ranges for Google are 64.233.[160.0-191.255], 66.249.[64.0-95.255], 66.102.[0.0-15.255], 72.14.[192.0-255.255], <br>74.125.[0.0-255.255], " .
  "209.085.[128.0-255.255], 216.239.[32.0-63.255] and a few minor other subranges</small><p>\n" ;

  &OpenLog ;
  &PrepHtml ;
  &SetPeriod ; # now date range derived from which folders found

# &ReadDate ; date range was read from csv file

  foreach $dir_process (@dirs_process)
  {
    &ReadInputClients ;
    &ReadInputCrawlers ;
    &ReadInputMethods ;
    &ReadInputMimeTypes ;
    &ReadInputOpSys ;
    &ReadInputOrigins ;
    &ReadInputScripts ;
    &ReadInputGoogle ;
    &ReadInputSkins ;
  }

  &CalcPercentages ;
  &NormalizeCounts ;
  &SortCounts ;

  &WriteReportClients ;
  &WriteReportCrawlers ;
  &WriteReportMethods ;
  &WriteReportMimeTypes ;
  &WriteReportOpSys ;
  &WriteReportOrigins ;
  &WriteReportScripts ;
  &WriteReportGoogle ;
  &WriteReportSkins ;
  &WriteCsvGoogleBots ;

  close "FILE_LOG" ;
  print "\nReady\n\n" ;

#  if (-d "/a/log")
#  {
#   $cmd = "tar -cf $dir_reports/$date_last\-csv.tar $dir_reports_in/*.csv | bzip2 $dir_reports/$date_last\-csv.tar" ;
#   print "cmd = '$cmd'\n" ;
#    `$cmd` ;
    $cmd = "tar -cf $dir_reports/$reportmonth\-html.tar $dir_reports/*.htm | bzip2 $dir_reports/$reportmonth\-html.tar" ;
    print "cmd = '$cmd'\n" ;
#    `$cmd` ;
#  }

  exit ;

sub ReadDate
{
  open  CSV_CRAWLERS, '<', "$dir_process/$file_csv_crawlers" ;
  $line = <CSV_CRAWLERS> ;
  close CSV_CRAWLERS ;
# print "DATE LINE $line\n" ;
  chomp ($line) ;
  $line =~ s/^.*?(\d\d\d\d\-\d\d\-\d\d(?:T\d\d)?).*?(\d\d\d\d\-\d\d\-\d\d(?:T\d\d)?).*$/$1.",".$2/e ;
  ($timefrom,$timetill) = split (',', $line) ;
  if (($timefrom eq "") || ($timetill eq ""))
  { &Abort ("$file_csv_crawlers does not contain valid date range on first line\n") ; }

  $yearfrom  = substr ($timefrom,0,4) ;
  $monthfrom = substr ($timefrom,5,2) ;
  $dayfrom   = substr ($timefrom,8,2) ;
  $hourfrom  = substr ($timefrom,11,2) ;

  $yeartill  = substr ($timetill,0,4) ;
  $monthtill = substr ($timetill,5,2) ;
  $daytill   = substr ($timetill,8,2) ;
  $hourtill  = substr ($timetill,11,2) ;

  $period = sprintf ("%d %s %d %d:00 - %d %s %d %d:00", $dayfrom, &GetMonthShort ($monthfrom), $yearfrom, $hourfrom, $daytill, &GetMonthShort ($monthtill), $yeartill, $hourtill) ;

  $timefrom  = timegm (0,0,$hourfrom,$dayfrom,$monthfrom-1,$yearfrom-1900) ;
  $timetill  = timegm (0,0,$hourtill,$daytill,$monthtill-1,$yeartill-1900) ;

  $timespan   = ($timetill - $timefrom) / 3600 ;
  $multiplier = (24 * 3600) / ($timetill - $timefrom) ;

  $header =~ s/DATE/Daily averages, based on sample period: $period (yyyy-mm-dd)/ ;
}

sub SetPeriod
{
  $year_first  = substr ($date_first,0,4) ;
  $month_first = substr ($date_first,5,2) ;
  $day_first   = substr ($date_first,8,2) ;
  $hour_first  = 0 ; # substr ($date_first,11,2) ;

  $year_last   = substr ($date_last,0,4) ;
  $month_last  = substr ($date_last,5,2) ;
  $day_last    = substr ($date_last,8,2) ;
  $hour_last   = 0 ; # substr ($date_last,11,2) ;

  $timefrom  = timegm (0,0,0,$day_first,$month_first-1,$year_first-1900) ;
  $timetill  = timegm (0,0,0,$day_last,$month_last-1,$year_last-1900) + 86400 ; # date_last + 1 day (in seconds)

  $timespan   = ($timetill - $timefrom) / 3600 ;
  $multiplier = (24 * 3600) / ($timetill - $timefrom) ;

  $period = sprintf ("%d %s %d - %d %s %d", $day_first, &GetMonthShort ($month_first), $year_first, $day_last, &GetMonthShort ($month_last), $year_last) ;
  $header =~ s/DATE/Daily averages, based on sample period: $period/ ;
  print "Sample period: $period => for daily averages multiplier = " . sprintf ("%.2f",$multiplier) . "\n" ;
}

sub PrepHtml
{
  $language = "en" ;
  $header = "<!DOCTYPE FILE_HTML PUBLIC '-//W3C//DTD FILE_HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>\n" .
            "<html lang='en'>\n" .
            "<head>\n" .
            "<title>TITLE</title>\n" .
            "<meta http-equiv='Content-type' content='text/html; charset=iso-8859-1'>\n" .
            "<meta name='robots' content='index,follow'>\n" .
            "<script language='javascript' type='text/javascript' src='../WikipediaStatistics13.js'></script>\n" .
            "<style type='text/css'>\n" .
            "<!--\n" .
            "body {font-family:arial,sans-serif; font-size:12px }\n" .
            "h2   {margin:0px 0px 3px 0px; font-size:18px}\n" .
            "td   {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top}\n" .
            "th   {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top ; font-width:bold}\n" .
            "td.hl {text-align:left;}\n" .
            "td.hr {text-align:right;}\n" .
            "td.r {text-align:right;  border: inset 1px #FFFFFF}\n" .
            "td.c {text-align:center; border: inset 1px #FFFFFF}\n" .
            "td.l {text-align:left;   border: inset 1px #FFFFFF}\n" .
            "th.c {text-align:center; border: inset 1px #FFFFFF}\n" .
            "th.l {text-align:left;   border: inset 1px #FFFFFF}\n" .
            "th.lh3 {text-align:left;   border: inset 1px #FFFFFF ; font-size:14px}\n" .
            "a:link { color:blue;text-decoration:none;}\n" .
            "a:visited {color:#0000FF;text-decoration:none;}\n" .
            "a:active  {color:#0000FF;text-decoration:none;}\n" .
            "a:hover   {color:#FF00FF;text-decoration:underline}\n" .
            "-->\n" .
            "</style>\n" .
            "<body bgcolor='\#FFFFDD'>\n<table width=100%>\n<tr><td class=hl>\n<h2>HEADER</h2>\n<b>DATE</b>\n</td>\n<td class=hr>" .
            "<input type='button' value=' Wikimedia Statistics ' onclick='window.location=\"http://stats.wikimedia.org\"'>" .
            "</td></tr>\n</table><hr>" .
            "&nbsp;This analysis is based on a 1:1000 sampled server log (squids) &rArr; <font color=#008000><b>all counts x 1000</b></font>.<br>\n" .
            "&nbsp;See also: <b>LINKS</b><br>NOTES&nbsp;\n" ; # . "PRE\n" ;

  # to be localized some day like any reports
  $out_license      = "All data and images on this page are in the public domain." ;
  $out_generated    = "Generated on " ;
  $out_author       = "Author" ;
  $out_mail         = "Mail" ;
  $out_site         = "Web site" ;
  $out_home         = "Home" ;
  $out_sitemap      = "Site map";
  $out_myname = "Erik Zachte" ;
  $out_mymail = "ezachte@### (no spam: ### = wikimedia.org)" ;
  $out_mysite = "http://infodisiac.com/" ;

  $colophon = "<p>\n" .
               $out_generated . &GetDate (time) . "\n<br>" .
               $out_author . ":" . $out_myname .
               " (<a href='" . $out_mysite . "'>" . $out_site . "</a>)\n<br>" .
               "$out_mail: $out_mymail<br>\n" .
               "$out_license" .
               "</small>\n" ;

  $dummy_requests  = "Requests <font color=#808080>by destination</font> or " ;
  $dummy_origins   = "<font color=#000060>by origin</font>" ;
  $dummy_methods   = "<font color=#000060>Methods</font>" ;
  $dummy_scripts   = "<font color=#000060>Scripts</font>" ;
  $dummy_skins     = "<font color=#000060>Skins</font>" ;
  $dummy_crawlers  = "<font color=#C0C0C0>Crawlers</font>" ;
  $dummy_opsys     = "<font color=#000060>Op.Sys.</font>" ;
  $dummy_browsers  = "<font color=#000060>Browsers</font>" ;
  $dummy_google    = "<font color=#000060>Google</font>" ;

  $link_requests   = "Requests <a href='$file_html_requests'>by destination</a> or " ;
  $link_origins    = "<a href='$file_html_origins'>by origin</a>" ;
  $link_methods    = "<a href='$file_html_methods'>Methods</a>" ;
  $link_scripts    = "<a href='$file_html_scripts'>Scripts</a>" ;
  $link_skins      = "<a href='$file_html_skins'>Skins</a>" ;
  $link_crawlers   = "<a href='$file_html_crawlers'>Crawlers</a>" ;
  $link_opsys      = "<a href='$file_html_opsys'>Op.Sys.</a>" ;
  $link_browsers   = "<a href='$file_html_clients'>Browsers</a>" ;
  $link_google     = "<a href='$file_html_google'>Google</a>" ;
}

sub ReadInputClients
{
  my $file_csv = "$dir_process/$file_csv_clients" ;
  if (! -e $file_csv)
  { print "Function ReadInputClients: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_CLIENTS, '<', $file_csv ;

  while ($line = <CSV_CLIENTS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp ($line) ;

    if ($line =~ /^E/)
    {
      ($rectype, $engine, $count) = split (',', $line) ;
      if (($engine !~ /^Gecko/) && ($engine !~ /^AppleWebKit/))
      { next ; }
      if ($engine !~ / \d/)
      { $engine =~ s/\// / ; }
      $engines {$engine} += $count ;
      $engine =~ s/\/.*$// ;
      $engine =~ s/ .*$// ;
      $total_engines {$engine} += $count ;
    }
    elsif ($line =~ /^G/)
    {
      ($rectype, $mobile, $group, $count, $perc) = split (',', $line) ;
      $total_clientgroups {$mobile} += $count ;
      $clientgroups {"$mobile,$group"} = $count ;
    }
    else
    {
      ($rectype, $client, $count, $perc) = split (',', $line) ;

      $total_clients += $count ;
      $client =~ s/_/./g ;
      $client =~ s/\.\./Other/g ;
      if ($client !=~ / \d/)
      { $client =~ s/\// / ; }
      if ($rectype eq "-") { $total_clients_non_mobile += $count ; }
      if ($rectype eq "M") { $total_clients_mobile     += $count ; }
      if ($count > $clients {"$rectype,$client"})
      { $clients      {"$rectype,$client"} = $count ; }
    }
  }
  close CSV_CLIENTS ;
}

sub ReadInputCrawlers
{
  my $file_csv = "$dir_process/$file_csv_crawlers" ;
  if (! -e $file_csv)
  { print "Function ReadInputCrawlers: file $file_csv not found!!! Abort function.\n" ; return ; }
  open  CSV_CRAWLERS, '<', $file_csv ;
  while ($line = <CSV_CRAWLERS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp ($line) ;
    ($count, $mime, $agent) = split (',', $line,3) ;
    $mime2 = $mime ;
    $mime =~ s/^image\/.*$/image\/../ ;
    $mime =~ s/^text\/.*$/text\/../ ;
    $agent =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;
    if ($agent =~ /<\s*script\s*>/i)
    { next ; }
    if ($agent =~ /MSIE \d+\.\d+/) # most likely false positives
    { next ; }
    if ($agent =~ /\|Google ip add?ress/) # typo
    {
      $agent =~ s/\|Google ip add?ress// ;
      $agent =~ s/GoogleBot/<b><font color=green>GoogleBot<\/font><\/b>/gi ;
    }
    if ($agent =~ / \|no Google ip address/)
    {
      $agent =~ s/ \|no Google ip address// ;
      $agent =~ s/GoogleBot/<b><font color=red>GoogleBot<\/font><\/b>/gi ;
    }

    $agent =~ s/\+//g ;
#   $agent =~ s/^Mozilla\/\d+\.\d+\s*\(compatible\s*;\s*([^\)]*)\)\s*/$1/ ; # Mozilla/5.0 (compatible; xxx) -> xxx
#   $agent =~ s/^Mozilla\/\d+\.\d+\s*\(\s*([^\)]*)\)\s*/$1/ ; # Mozilla/5.0 (xxx) -> xxx
    $agent =~ s/\((http:.*?feedfetcher.html)[^\)]*\)/($1)/ ;  # (http://www.google.com/feedfetcher.html; 1 subscribers; feed-id=1894739019218796495)
    $agent =~ s/FeedFetcher-Google/FeedFetcher-Google/i ;
    if ($agent !~ /http:/)
    { $agent =~ s/(bot|spider|crawl(?:er)?)/<b>$1<\/b>/gi ; }
    if ($mime2 eq "text/html")
    { $total_page_crawlerrequests += $count ; }
    $crawlers {"$mime|$agent"} += $count ;
  }
  close CSV_CRAWLERS ;
}

sub ReadInputMethods
{
  my $file_csv = "$dir_process/$file_csv_methods" ;
  if (! -e $file_csv)
  { print "Function ReadInputMethods: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_METHODS, '<', $file_csv ;
  while ($line = <CSV_METHODS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    ($method, $status, $count) = split (',', $line) ;
    $statusses {"$method,$status"} += $count ;
    $methods   {$method}           += $count ;
  }
  close CSV_METHODS ;
}

sub ReadInputMimeTypes
{
  my $file_csv = "$dir_process/$file_csv_requests" ;
  if (! -e $file_csv)
  { print "Function ReadInputMimeTypes: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_REQUESTS, '<', $file_csv ;
  while ($line = <CSV_REQUESTS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp $line ;
    ($project, $origin, $ext, $mime, $parm, $count) = split (',', $line) ;

    $show = 0 ;
    $project = &ExpandAbbreviation ($project) ;

    $mime =~ s/(\w+\.)(\w+\.)(\w+)/$1$2<br>$3/ ;
    $mime =~ s/opensearchdescription/opensearch-<br>description/ ;
    if ($project =~ /\./)
    {
      $project = '!invalid!' ;
      if ($origin ne "external")
      { $origin = 'internal' ; }
      $ext  = ".." ;
      $mime = ".." ;
      next ;
    }

    if ($parms eq "")
    { $parms = "&nbsp;" ; }
    $ext =~ s/^([a-z\[\]]*)[^a-z\[\]].*$/$1/g ;
    $ext =~ s/\((.*)\)/ ($1.php)/ ;
    if ($project eq $origin)
    { $origin = '&lArr;' ; }

    if ($project ne "upload")
    { @counts_prem {"$project,$origin,$ext,$mime"} += $count ; }
    # if ($project ne "upload")
    # { @counts_pm {"$project,$mime"} += $count ; }

    $counts_pm {"$project,$mime"} += $count ;
    ($domain = $project) =~ s/\:.*$// ;
    $counts_dm  {"$domain,$mime"} += $count ;
    $mimetypes {$mime} += $count ;
    $projects  {$project} += $count ;
    $domains   {$domain} += $count ;

    if ($mime =~ /image\/(?:png|jpeg|gif)/)
    {
      $images_project {$project} += $count ;
      $images_domain  {$domain} += $count ;
    }
    $mimetypes_found {$mime} ++ ;
    # @counts_prem {"$project,$origin,$ext,$mime"} += $count ;

    $total_mimes += $count ;
  }
  close CSV_REQUESTS ;

#  $html .= "<tr><th class=c>counts</th><th class=l>project</th><th class=l>origin</th><th class=l>extension</th><th class=l>mime</th></tr>\n" ;
#  $rows = 0 ;
#  foreach $key (sort keys %counts_prem)
#  {
#    ($project, $origin, $ext, $mime) = split (',', $key) ;
#    $count = $counts_prem {$key} ;
#    $count =~ s/^(\d+?)(\d\d\d)$/$1,$2/ ;
#    $html .= "<tr><td class=r>${count},000</td><td class=l>$project</td><td class=l>$origin</td><td class=l>$ext</td><td class=l>$mime</td></tr>\n" ;
#    $rows++ ;
#  }
#  $html .= "</table>\n" ;
#  $html .= "<small>$rows rows written</small><p>" ;

#  $html .= "<table border=1>\n" ;
#  $html .= "<tr><th class=c>counts</th><th class=l>project</th><th class=l>mime</th></tr>\n" ;
#  $rows = 0 ;
#  foreach $key (sort keys %counts_pm)
#  {
#    ($project, $mime) = split (',', $key) ;
#    $count = $counts_pm {$key} ;
#    $count =~ s/^(\d+?)(\d\d\d)$/$1,$2/ ;
#    $html .= "<tr><td class=r>${count},000</td><td class=l>$project</td><td class=l>$mime</td></tr>\n" ;
#    $rows++ ;
#  }
#  $html .= "</table>\n" ;
#  $html .= "<small>$rows rows written</small><p>" ;
}

sub ReadInputOpSys
{
  my $file_csv = "$dir_process/$file_csv_opsys" ;
  if (! -e $file_csv)
  { print "Function ReadInputOpSys: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_OPSYS, '<', $file_csv ;
  while ($line = <CSV_OPSYS>)
  {
    if ($line =~ /^#/) # comments
    {
      if ($line =~ /^# mobile:/)
      {
        $line =~ s/^.*?: // ;
        ($month_upd_keywords_mobile = $line) =~ s/^.*?\(([^\)]+)\).*$/$1/ ;
        ($keywords_mobile = $line)           =~ s/ \([^\)]+\).*$// ;
        $keywords_mobile =~ s/\|/, /g ;
        $keywords_mobile =~ s/((?:[^,]+,){10})/$1<br>/g ;
        next ;
      }
      next ;
    }
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp $line ;
    ($rectype, $os, $count, $perc) = split (',', $line) ;
    if ($count !~ /^\d+$/) # -,Linux Gentoo,,2,0.00% (extra comma !)
    { next ; }             # should not happen to be fixed in counts script
    $os =~ s/_/./g ;
    $os =~ s/\.\./Other/g ;
    if ($rectype ne "G")
    {
      if ($os =~ / \d/)
      { ; }
      else
      { $os =~ s/\// / ; }
    }

    if ($rectype eq "-") { $total_opsys_non_mobile += $count ; }
    if ($rectype eq "M") { $total_opsys_mobile     += $count ; }

    $opsys {"$rectype,$os"} += $count ;
  }
}


sub ReadInputOrigins
{
  my $file_csv = "$dir_process/$file_csv_origins" ;
  if (! -e $file_csv)
  { print "Function ReadInputOrigins: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_ORIGINS, '<', $file_csv ;
  while ($line = <CSV_ORIGINS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp $line ;
    ($source, $origin, $toplevel, $mimecat, $count) = split (',', $line) ;

# test:
     if (($source eq "external") && ($origin !~ /^google/))
     { $origin .= $toplevel ; }

#    ~ s/xx:upload/upload (~css)/;
#   $origin =~ s/wb:/wikibooks:/;
#   $origin =~ s/wk:/wiktionary:/;
#   $origin =~ s/wn:/wikinews:/;
#   $origin =~ s/wp:/wikipedia:/;
#   $origin =~ s/wq:/wikiquote:/;
#   $origin =~ s/ws:/wikisource:/;
#   $origin =~ s/wv:/wikiversity:/;
#    $origin =~ s/wx://;
#    $origin =~ s/mw:/mediawiki:/;
#    $origin =~ s/wm:/wikimedia:/;
#    $origin =~ s/wmf:/foundation:/;
#    $origin =~ s/:www$/:portal/;
#    $origin =~ s/:mw$/:mediawiki/;

    if ($source eq "internal")
    {
      $origin = &ExpandAbbreviation ($origin) ;
      ($project,$subproject) = split (':', $origin) ;
      $origin_int_top_split  {"$mimecat:$origin"} += $count ;
      $origin_int_top        {$origin} += $count ;
      $project_int_top_split {"$mimecat:$project"} += $count ;
      $project_int_top       {$project} += $count ;
    }
    else
    {
#      $origin2 = $origin ;
#      $origin2 =~ s/^google.*?\|/google:ext|/ ;
#      $origin2 =~ s/^yahoo.*\|/yahoo:ext|/ ;
#      if (($origin2 !~ /^google/) && ($origin2 !~ /^yahoo/))
#      { $origin2 =~ s/^.*?\|/other:ext|/ ; }
#       ($prefix,$code) = split ('\:', $origin2) ;
#       print "$origin -> $origin2\n" ;
#      $origin_ext_top_split {$origin} += $count ;
#      $origin_ext_top       {$code}     += $count ;

#      if ($origin =~ /\|page/)
#      {
#       ($prefix,$code) = split ('\:', $origin) ;
#        $code     =~ s/\|.*$// ;
#        $origin =~ s/\|.*$// ;
#        $origin_ext_page_top_split {$origin} += $count ;
#        $origin_ext_page_top       {$code}     += $count ;
#      }
      if ($origin eq "unmatched ip address")
      { $origin = "origin unknown" ; }

      if ($mimecat eq "page")
      { $total_page_requests_external += $count ; }

      $origin_ext_top_split {"$mimecat:$origin"} += $count ;
      $origin_ext_top       {$origin} += $count ;
      $total_origins_external_counted += $count ;
    # if ($origin =~ /^google/)
    # {
    #   $origin = "google (total)" ;
    #   $origin_ext_top_split {"$mimecat:$origin"} += $count ;
    #   $origin_ext_top       {$origin} += $count ;
    # }
    }
  }

  close CSV_ORIGINS ;
}

sub ReadInputScripts
{
  my $file_csv = "$dir_process/$file_csv_scripts" ;
  if (! -e $file_csv)
  { print "Function ReadInputScripts: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_SCRIPTS, '<', $file_csv ;
  while ($line = <CSV_SCRIPTS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp $line ;
    $line =~ s/\%3B/;/gi ;
    $line =~ s/\&amp;/\&/gi ;
    ($ext, $script, $parm, $count) = split (',', $line) ;
    if ($script =~ /\%/)
    { $script = "other" ; }
    if ($parm =~ /\%/)
    { $parm = "other" ; }

    if (($ext eq "php") && ($parm =~ /action=/) && ($parm !~ /search=/)) # action can occur as parm after search
    {
      @parms = split ('\&', $parm) ;
      foreach $parm (@parms)
      {
        ($keyword,$data) = split ('\=', $parm) ;
        if ($keyword eq "action")
        { @actions {"$script,$data"} += $count }
      }
    }
  }
  close CSV_SCRIPTS ;

# foreach $key (sort {$actions {$b} <=> $actions {$a}} keys %actions)
# { print "$key: " . $actions {$key} . "\n" ; }

  open  CSV_SCRIPTS, '<', "$dir_process/$file_csv_scripts" ;
  read_script:
  while ($line = <CSV_SCRIPTS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp $line ;
    $line =~ s/\%3B/;/gi ;
    $line =~ s/\%5B/[/gi ;
    $line =~ s/\%5D/]/gi ;
    $line =~ s/\&amp;/\&/gi ;
    ($ext, $script, $parm, $count) = split (',', $line) ;

    # incomplete validation check on valid names, but captures already lot of rubbish
    if ($script =~ /\%/)
    { $script = "other" ; }
    if ($parm =~ /\%/)
    { $parm = "other" ; }

    if (($parm =~ /amp;amp;/) ||
        ($parm =~ /feed=.*feed=/))
    { next read_script ; }

    if (($ext eq "php") && ($parm =~ /action=/))
    {
      @parms = split ('\&', $parm) ;
      foreach $parm (@parms)
      {
        ($keyword,$data) = split ('\=', $parm) ;
        if ($keyword eq "action")
        {
          if (@actions {"$script,$data"} < 2)
          { next read_script ; }
        }
      }
    }
    if ($ext eq "php")
    {
      # generalize ns10 -> ns.. + remove all ns..=.. but one
      $parm =~ s/\&ns\d+/\&ns../g ;
      $parm =~ s/\&ns\.\.=\.\./-*^-*^/ ;
      $parm =~ s/\&ns\.\.=\.\.//g ;
      $parm =~ s/\-\*\^\-\*\^/\&ns\.\.=\.\./g ;

      # generalize nsargs[]= -> remove all but one
      $parm =~ s/\&rsargs\[\]=\.\./-*^-*^/ ;
      $parm =~ s/\&rsargs\[\]=\.\.//g ;
      $parm =~ s/\-\*\^\-\*\^/\&rsargs\[n\]=\.\./g ;

      if (length ($parm) > 100)
      { $parm =~ s/(.{100}[^\&]*\&)/$1<br>/g ; }

      $parms   {"$script,$parm"} += $count ;
      $scripts_php {$script}     += $count ;
    }
    elsif ($ext eq "js")
    { $scripts_js {$script}      += $count ; }
    elsif ($ext eq "css")
    { $scripts_css {$script}     += $count ; }
  }
  close CSV_SCRIPTS ;
}

sub ReadInputGoogle
{
  my $file_csv = "$dir_process/$file_csv_google" ;
  if (! -e $file_csv)
  { print "Function ReadInputGoogle: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_SEARCH, '<', $file_csv ;
  while ($line = <CSV_SEARCH>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp $line ;
    ($matches, $site, $origin, $service, $agent, $mimecat, $toplevel, $count) = split (',', $line) ;

    if ($service eq "Imposters?")
    { $service = "GoogleBot?" ; }
    if ($service eq "GoogleBotNot?")
    { $service = "GoogleBot?" ; }
    if ($service eq "Crawler")
    { $service = "GoogleBot" ; }

    if ($matches =~ /x/)
    { $googleIp = 'Y' ; }
    else
    { $googleIp = 'N' ; }

    if ($site ne "google") { next ; }

    if ($toplevel eq "-")
    { $toplevel = "undefined" ; }
    if (length ($toplevel) > 3)
    { $toplevel = "_$toplevel" ; } # sort on top

    $searches_crawlers {$service}    += $count ;
    $searches_service  {"$service,$googleIp"} += $count ;
    $searches_toplevel  {$toplevel}  += $count ;
    $searches_service_mimecat  {"$service,$mimecat,$googleIp"} += $count ;
    $searches_service_mimecat  {"$service,total,$googleIp"} += $count ;
    $searches_service_matches  {"$service,$matches"} += $count ;

#    if ($origin =~ /search/i)
    if ($toplevel =~ /^[a-zA-Z0-9-]+$/)
    { $searches_toplevel_tld_found {$toplevel} += $count ; } # print "$line\n" ;}
    else
    {
      $searches_mimecat_tld_not_found {$mimecat} += $count ;
      $searches_mimecat_tld_not_found {"total"}  += $count ;
    }

    $searches_toplevel_mimecat {"$toplevel,$mimecat"} += $count ;
    $searches_toplevel_mimecat {"$toplevel,total"} += $count ;

#  if ($toplevel !~ /:/) { print "invalid toplevel $toplevel\n" ; }
  }
  close CSV_SEARCH ;
}

sub CalcPercentages
{
  my $total_opsys = $total_opsys_mobile + $total_opsys_non_mobile ;
  foreach $key (keys %opsys)
  { $opsys_perc {$key} = sprintf ("%.2f",(100*$opsys {$key}/$total_opsys)) . "%" ; }

  foreach $key (keys %clients)
  { $clients_perc {$key} = sprintf ("%.2f",(100*$clients {$key}/$total_clients)) . "%" ; }

  foreach $key (keys %clientgroups)
  {
    $perc = 100*$clientgroups {$key}/$total_clients ;
    if ($perc > 0.02)
    { $clientgroups_perc {$key} = sprintf ("%.2f",$perc) . "%" ; }
    else
    {
      ($mobile,$group) = split (',', $key) ;
      $clientgroups_other {$mobile} += $clientgroups {$key} ;
      $clientgroups {$key} = 0 ;
    }
  }
}

sub ReadInputSkins
{
  my $file_csv = "$dir_process/$file_csv_skins" ;
  if (! -e $file_csv)
  { print "Function ReadInputSkins: file $file_csv not found!!! Abort function.\n" ; return ; }
  open CSV_SKINS, '<', $file_csv ;
  while ($line = <CSV_SKINS>)
  {
    if ($line =~ /^#/) { next ; } # comments
    if ($line =~ /^:/) { next ; } # csv header (not a comment)

    chomp $line ;
    ($skins, $count) = split (',', $line) ;

    $skins {$skins} += $count ;
    ($name,$rest) = split ('\/', $skins, 2) ;
    $skin_set {$name}+= $count ;
  }
  close CSV_SCRIPTS ;
}

sub NormalizeCounts
{
# ReadInputClients
  foreach $key (keys %engines)
  { $engines {$key} = &Normalize ($engines {$key}) ; }
  foreach $key (keys %clients)
  { $clients {$key} = &Normalize ($clients {$key}) ; }
  foreach $key (keys %clientgroups)
  { $clientgroups {$key} = &Normalize ($clientgroups {$key}) ; }

  $total_engines            = &Normalize ($total_engines) ;
  $total_clientgroups       = &Normalize ($total_clientgroups) ;
  $total_clients            = &Normalize ($total_clients) ;
  $total_clients_mobile     = &Normalize ($total_clients_mobile) ;
  $total_clients_non_mobile = &Normalize ($total_clients_non_mobile) ;

# ReadInputCrawlers
  foreach $key (keys %crawlers)
  { $crawlers {$key} = &Normalize ($crawlers {$key}) ; }

  $total_page_crawlerrequests  = &Normalize ($total_page_crawlerrequests) ;

# ReadInputMethods
  foreach $key (keys %statusses)
  { $statusses {$key} = &Normalize ($statusses {$key}) ; }
  foreach $key (keys %methods)
  { $methods {$key} = &Normalize ($methods {$key}) ; }

# ReadInputMimeTypes
  foreach $key (keys %mimetypes)
  { $mimetypes {$key} = &Normalize ($mimetypes {$key}) ; }
  foreach $key (keys %projects)
  { $projects {$key} = &Normalize ($projects {$key}) ; }
  foreach $key (keys %domains)
  { $domains {$key}  = &Normalize ($domains {$key}) ; }
  foreach $key (keys %images_project)
  { $images_project {$key}  = &Normalize ($images_project {$key}) ; }
  foreach $key (keys %images_project)
  { $images_project {$key}  = &Normalize ($images_project {$key}) ; }
  foreach $key (keys %images_domain)
  { $images_domain {$key}  = &Normalize ($images_domain {$key}) ; }
  foreach $key (keys %mimetypes_found)
  { $mimetypes_found {$key}  = &Normalize ($mimetypes_found {$key}) ; }
  foreach $key (keys %counts_pm)
  { $counts_pm {$key}  = &Normalize ($counts_pm {$key}) ; }
  foreach $key (keys %counts_dm)
  { $counts_dm {$key}  = &Normalize ($counts_dm {$key}) ; }
  foreach $key (keys %counts_prem)
  { $counts_prem {$key}  = &Normalize ($counts_prem {$key}) ; }

  $total_mimes = &Normalize ($total_mimes) ;

# ReadInputOpSys
  foreach $key (keys %opsys)
  { $opsys {$key} = &Normalize ($opsys {$key}) ; }

  $total_opsys_non_mobile = &Normalize ($total_opsys_non_mobile) ;
  $total_opsys_mobile     = &Normalize ($total_opsys_mobile) ;

# ReadInputOrigins
  foreach $key (keys %origin_int_top)
  { $origin_int_top {$key} = &Normalize ($origin_int_top {$key}) ; }
  foreach $key (keys %origin_int_top_split)
  { $origin_int_top_split {$key} = &Normalize ($origin_int_top_split {$key}) ; }
  foreach $key (keys %origin_ext_top)
  { $origin_ext_top {$key} = &Normalize ($origin_ext_top {$key}) ; }
  foreach $key (keys %origin_ext_top_split)
  { $origin_ext_top_split {$key} = &Normalize ($origin_ext_top_split {$key}) ; }
  foreach $key (keys %origin_ext_page_top)
  { $origin_ext_page_top {$key} = &Normalize ($origin_ext_page_top {$key}) ; }
  foreach $key (keys %project_int_top)
  { $project_int_top {$key} = &Normalize ($project_int_top {$key}) ; }
  foreach $key (keys %project_int_top_split)
  { $project_int_top_split {$key} = &Normalize ($project_int_top_split {$key}) ; }

  $total_page_requests_external = &Normalize ($total_page_requests_external) ;
  $total_origins_external_counted = &Normalize ($total_origins_external_counted) ;

# ReadInputScripts
  foreach $key (keys %parms)
  { $parms {$key} = &Normalize ($parms {$key}) ; }
  foreach $key (keys %scripts_php)
  { $scripts_php {$key} = &Normalize ($scripts_php {$key}) ; }
  foreach $key (keys %scripts_js)
  { $scripts_js {$key} = &Normalize ($scripts_js {$key}) ; }
  foreach $key (keys %scripts_css)
  { $scripts_css {$key} = &Normalize ($scripts_css {$key}) ; }

# ReadInputGoogle
  foreach $key (keys %searches_service)
  { $searches_service {$key} = &Normalize ($searches_service {$key}) ; }
  foreach $key (keys %searches_crawlers)
  { $searches_crawlers {$key} = &Normalize ($searches_crawlers {$key}) ; }
  foreach $key (keys %searches_toplevel)
  { $searches_toplevel {$key} = &Normalize ($searches_toplevel {$key}) ; }
  foreach $key (keys %searches_toplevel_tld_found)
  { $searches_toplevel_tld_found {$key} = &Normalize ($searches_toplevel_tld_found {$key}) ; }
  foreach $key (keys %searches_service_mimecat)
  { $searches_service_mimecat {$key} = &Normalize ($searches_service_mimecat {$key}) ; }
  foreach $key (keys %searches_service_matches)
  { $searches_service_matches {$key} = &Normalize ($searches_service_matches {$key}) ; }
  foreach $key (keys %searches_toplevel_mimecat)
  { $searches_toplevel_mimecat {$key} = &Normalize ($searches_toplevel_mimecat {$key}) ; }
  foreach $key (keys %searches_mimecat_tld_not_found)
  { $searches_mimecat_tld_not_found {$key} = &Normalize ($searches_mimecat_tld_not_found {$key}) ; }

# ReadInputSkins
  foreach $key (keys %skins)
  { $skins {$key} = &Normalize ($skins {$key}) ; }
  foreach $key (keys %skin_set)
  { $skin_set {$key} = &Normalize ($skin_set {$key}) ; }
}

sub SortCounts
{
# ReadInputClients
  @engines_sorted_count  = sort {$engines {$b} <=> $engines {$a}} keys %engines ;
  @engines_sorted_alpha  = sort {$a cmp $b} keys %engines ;
  @clientgroups_sorted_count  = sort {$clientgroups {$b} <=> $clientgroups {$a}} keys %clientgroups ;
  @clientgroups_sorted_alpha  = sort {$a cmp $b} keys %clientgroups ;
  @clients_sorted_count  = sort {$clients {$b} <=> $clients {$a}} keys %clients ;
  @clients_sorted_alpha  = sort {$a cmp $b} keys %clients ;

# ReadInputCrawlers
  @crawlers_sorted_count  = sort {$crawlers {$b} <=> $crawlers {$a}} keys %crawlers ;
  @crawlers_sorted_alpha  = sort {$a cmp $b} keys %crawlers ;

# ReadInputMethods
  @statusses_sorted_count  = sort {$statusses {$b} <=> $statusses {$a}} keys %statusses ;
  @statusses_sorted_method = sort {$a cmp $b}                           keys %statusses ;
  @methods_sorted_count    = sort {$methods   {$b} <=> $methods   {$a}} keys %methods ;
  @methods_sorted_method   = sort {$a cmp $b}                           keys %methods ;

# ReadInputMimeTypes
  @mimetypes_sorted = sort {&SortMime ($b) <=> &SortMime ($a)} keys %mimetypes ;
  @projects_sorted  = sort {$projects {$b} <=> $projects {$a}} keys %projects ;
  @domains_sorted   = sort {$domains  {$b} <=> $domains  {$a}} keys %domains ;

# ReadInputOpSys
  @opsys_sorted_alpha = sort {lc($a) cmp lc($b)} keys %opsys ;
  @opsys_sorted_count = sort {$opsys {$b} <=> $opsys {$a}} keys %opsys ;

# ReadInputOrigins
  @origin_int_top_sorted_alpha       = sort keys %origin_int_top ;
  @origin_ext_top_sorted_alpha       = sort keys %origin_ext_top ;
  @origin_ext_page_top_sorted_alpha  = sort keys %origin_ext_page_top ;
  @origin_int_top_sorted_count       = sort {$origin_int_top {$b} <=> $origin_int_top {$a}} keys %origin_int_top ;
  @origin_ext_top_sorted_count       = sort {$origin_ext_top {$b} <=> $origin_ext_top {$a}} keys %origin_ext_top ;
  @origin_ext_page_top_sorted_count  = sort {$origin_ext_page_top {$b} <=> $origin_ext_page_top {$a}} keys %origin_ext_page_top ;

  @project_int_top_sorted_alpha      = sort keys %project_int_top ;
  @project_int_top_sorted_count      = sort {$project_int_top {$b} <=> $project_int_top {$a}} keys %project_int_top ;

# ReadInputScripts
  @parms_sorted_count    = sort {$parms   {$b} <=> $parms {$a}}                   keys %parms ;
  @parms_sorted_script   = sort {$a cmp $b}                                       keys %parms ;
  @scripts_php_sorted_count  = sort {$scripts_php   {$b} <=> $scripts_php   {$a}} keys %scripts_php ;
  @scripts_php_sorted_script = sort {$a cmp $b}                                   keys %scripts_php ;
  @scripts_js_sorted_count   = sort {$scripts_js    {$b} <=> $scripts_js    {$a}} keys %scripts_js ;
  @scripts_js_sorted_script  = sort {$a cmp $b}                                   keys %scripts_js ;
  @scripts_css_sorted_count  = sort {$scripts_css   {$b} <=> $scripts_css   {$a}} keys %scripts_css ;
  @scripts_css_sorted_script = sort {$a cmp $b}                                   keys %scripts_css ;

# ReadInputGoogle
  @searches_service_count  = sort {$searches_service {$b} <=> $searches_service {$a}}   keys %searches_service ;
  @searches_service_alpha  = sort                                                       keys %searches_service ;
  @searches_toplevel_count = sort {$searches_toplevel {$b} <=> $searches_toplevel {$a}} keys %searches_toplevel_tld_found ;
  @searches_toplevel_alpha = sort                                                       keys %searches_toplevel_tld_found ;
  @searches_service_matches_alpha  = sort                                               keys %searches_service_matches ;

# ReadInputSkins
  @skins_sorted_skin  = sort keys %skins ;
}

sub WriteReportClients
{
  open FILE_HTML_CLIENTS, '>', "$dir_reports/$file_html_clients" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Browsers e.a./ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Browsers e.a./ ;
  $html =~ s/LINKS/$link_requests $link_origins \/  $link_methods \/ $link_scripts \/ $link_skins \/ $link_crawlers \/ $link_opsys \/ $dummy_browsers \/ $link_google/ ;
  $html =~ s/NOTES// ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td class=l colspan=99 wrap>The following overview of page requests per client (~browser) application is based on the <a href='http://en.wikipedia.org/wiki/User_agent'>user agent</a> information that accompanies most server requests.<br>" .
           "Please note that agent information does not follow strict guidelines and some programs may provide wrong information on purpose.<br>" .
           "This report ignores all requests where agent information is missing, or contains any of the following: bot, crawl(er) or spider.<p>" .
           "<b>Recommended reading:</b> <a href='http://en.wikipedia.org/wiki/Usage_share_of_web_browsers'>Wikipedia article</a> on usage share of web browsers and measurement methodology." .
           "</td></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY
  $html .= "<tr><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In order of popularity</h3></th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browsers, non mobile</th></tr>\n" ;
  $perc_total = 0 ;
  foreach $key (@clientgroups_sorted_count)
  {
    $count = $clientgroups {$key} ;
    if ($count == 0) { next ; }
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    if ($mobile ne '-') { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$group</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    $perc =~ s/\%// ;
    $perc_total += $perc ;
  }

  $count = $clientgroups_other {'-'} ;
  $total = &FormatCount ($total_clientgroups {'-'}) ;
  $perc = sprintf ("%.2f", 100 * $count / ($total_clientgroups {'-'} + $total_clientgroups {'M'})) ;
  $perc_total += $perc ;
  $perc_total = sprintf ("%.1f", $perc_total) ;

  $html .= "<tr><td class=l>Other</th><td class=r>$count</td><td class=r>$perc\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc_total\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browsers, mobile</th></tr>\n" ;
  foreach $key (@clientgroups_sorted_count)
  {
    $count = $clientgroups {$key} ;
    if ($count == 0) { next ; }
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    if ($mobile ne 'M') { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$group</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    $perc =~ s/\%// ;
  }
  $count = $clientgroups_other {'M'} ;
  $perc = sprintf ("%.2f", 100 * $count / ($total_clientgroups {'-'} + $total_clientgroups {'M'})) ;
  $perc_total = sprintf ("%.1f", (100 - $perc_total)) ;
  $total = &FormatCount ($total_clientgroups {'M'}) ;
  $html .= "<tr><td class=l>Other</th><td class=r>$count</td><td class=r>$perc\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc_total\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browser versions, non mobile</th></tr>\n" ;

  foreach $key (@clients_sorted_count)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    if ($rectype ne '-') { next ; } # group
    $perc  = $clients_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$client</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    $perc =~ s/\%// ;
  }
  $total = &FormatCount ($total_clients_non_mobile) ;
  $perc = sprintf ("%.1f",100*$total_clients_non_mobile / ($total_clients_mobile + $total_clients_non_mobile)) ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browser versions, mobile</th></tr>\n" ;
  foreach $key (@clients_sorted_count)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    if ($rectype ne 'M') { next ; } # group
    $perc  = $clients_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$client</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
  }
  $total = &FormatCount ($total_clients_mobile) ;
  $perc  = sprintf ("%.1f", (100 - $perc_total)) ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc\%</th></tr>\n" ;

  $html .= "</table>\n" ;

  # CLIENTS In alphabetical order
  $html .= "</td><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In alphabetical order</h3></th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browsers, non mobile</th></tr>\n" ;
  $perc_total = 0 ;
  foreach $key (@clientgroups_sorted_alpha)
  {
    $count = $clientgroups {$key} ;
    if ($count == 0) { next ; }
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    if ($mobile ne '-') { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$group</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    $perc =~ s/\%// ;
    $perc_total += $perc ;
  }

  $count = $clientgroups_other {'-'} ;
  $total = &FormatCount ($total_clientgroups {'-'}) ;
  $perc = sprintf ("%.2f", 100 * $count / ($total_clientgroups {'-'} + $total_clientgroups {'M'})) ;
  $perc_total += $perc ;
  $perc_total = sprintf ("%.1f", $perc_total) ;
  $html .= "<tr><td class=l>Other</th><td class=r>$count</td><td class=r>$perc\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc_total\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browsers, mobile</th></tr>\n" ;
  foreach $key (@clientgroups_sorted_alpha)
  {
    if ($count == 0) { next ; }
    $count = $clientgroups {$key} ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    if ($mobile ne 'M') { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$group</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    $perc =~ s/\%// ;
  }

  $count = $clientgroups_other {'M'} ;
  $total = &FormatCount ($total_clientgroups {'M'}) ;
  $perc = sprintf ("%.2f", 100 * $count / ($total_clientgroups {'-'} + $total_clientgroups {'M'})) ;
  $perc_total = sprintf ("%.1f", (100 - $perc_total)) ;
  $html .= "<tr><td class=l>Other</th><td class=r>$count</td><td class=r>$perc\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc_total\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browser versions, non mobile</th></tr>\n" ;

  foreach $key (@clients_sorted_alpha)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    if ($rectype ne '-') { next ; } # group
    $perc  = $clients_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$client</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
  }
  $total = &FormatCount ($total_clients_non_mobile) ;
  $perc = sprintf ("%.1f",100*$total_clients_non_mobile / ($total_clients_mobile + $total_clients_non_mobile)) ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browser versions, mobile</th></tr>\n" ;
  foreach $key (@clients_sorted_alpha)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    if ($rectype ne 'M') { next ; } # group
    $perc  = $clients_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$client</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
  }
  $total = &FormatCount ($total_clients_mobile) ;
  $perc = sprintf ("%.1f",100*$total_clients_mobile / ($total_clients_mobile + $total_clients_non_mobile)) ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total</th><th class=r>$perc\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browser engines</th></tr>\n" ;

  $engine_prev = "" ;
  foreach $engine (@engines_sorted_alpha)
  {
    $total = $engines {$engine} ;
    if ($total < 5) { next ; }
    $engine2 = $engine ;
    $engine2 =~ s/\/.*$// ;
    $engine2 =~ s/ .*$// ;
    if (($engine2 ne $engine_prev) && ($engine_prev ne ""))
    {
      $total_engine = $total_engines {$engine_prev} ;
      $perc_engine = sprintf ("%.1f", 100 * $total_engine / ($total_clients_mobile + $total_clients_non_mobile)) ;
      $total_engine = &FormatCount ($total_engine) ;
      $html .= "<tr><th class=l>Total</th><th class=r>$total_engine</th><th class=r>$perc_engine\%</th></tr>\n" ;
    }
    $engine_prev = $engine2 ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$engine</td><td class=r>$total</td><td class=r>&nbsp;</td></tr>\n" ;
  }
  $total_engine = $total_engines {$engine_prev} ;
  $perc_engine = sprintf ("%.1f", 100 * $total_engine / ($total_clients_mobile + $total_clients_non_mobile)) ;
  $total_engine = &FormatCount ($total_engine) ;
  $html .= "<tr><th class=l>Total</th><th class=r>$total_engine</th><th class=r>$perc_engine\%</th></tr>\n" ;

  $html .= "</table>\n" ;
  $html .= "</td></tr>\n" ;

  $html .= "<tr><td colspan=99 class=l wrap>Requests from mobile devices are recognized as follows:<br>" .
           "Agent string contains any of the following terms (last upd: $month_upd_keywords_mobile):<br>" .
           "<i>$keywords_mobile</i></td></tr>" ;

  $html .= "</table>\n" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon ;

  print FILE_HTML_CLIENTS $html ;
  close FILE_HTML_CLIENTS ;
}

sub WriteReportCrawlers
{
  open FILE_HTML_CRAWLERS, '>', "$dir_reports/$file_html_crawlers" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Crawler requests/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Crawler requests/ ;
  $html =~ s/LINKS/$link_requests $link_origins \/ $link_methods \/ $link_scripts \/ $link_skins \/ $dummy_crawlers \/ $link_google/ ;
  $html =~ s/NOTES// ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td class=l colspan=99>The following overview of crawler (aka bot) page requests is based on the <a href='http://en.wikipedia.org/wiki/User_agent'>user agent</a> information that accompanies most server requests." .
           " Unfortunately this user agent information follows rather loosely defined guidelines." .
           "<br>Also please bear in mind than the most popular crawler names may be somewhat overrepresented." .
           " This is the result of so called <i>user agent spoofing</i> (where a requester supplies false credentials, e.g. to bypass web servers filters)." .
           "<br>GoogleBot seems to be a favorite for spoofing. Therefore requests from an ip address registered by Google (see below) are color coded <b><font color=green>GoogleBot</font></b>, others <b><font color=red>GoogleBot</font></b>" .
           "<p>For this report page requests are considered to be issued by a crawler in two cases:" .
           "<br>1 The user agent string contains a web address (only crawlers should have that, but there a some false positives, " .
           "  where a browser sends a user agent string with a web address (ill behaved plug-in, main offenders have been eliminated)" .
           "<br>2 The user agent string contains the term bot, spider or crawl[er]'" .
           "PERC_GOOGLE\n" .
           "</td></tr>\n" ;

  $total_crawlers = 0 ;
# $html .= "<tr><th class=l>Count<br><small>x 1000</small></th><th class=l>Secondary domain<br>(~site) name</th><th class=l>Mime type</th><th class=l>User agent</th></tr>\n" ;
  foreach $mime_agent (sort {$crawlers {$b} <=> $crawlers {$a}} keys %crawlers)
  {
    $count = $crawlers {$mime_agent} ;
    ($mime, $agent) = split ('\|', $mime_agent,2) ;
    $agent =~ s/([^,;\(\)\s]+?\@[^,;\(\)\s]+)/ <font color=#808080>mail address<\/font> /g ;
    $agent =~ s/([\w-]+\s*.?at.?\s*[\w-]+\s*.?dot.?\s*[\w-]+)/ <font color=#808080>mail address<\/font> /gi ;
    $site = "-" ;
    if ($agent =~ /http:/)
    {
      $site = $agent ;
      $site =~ s/^.*?http:/http:/ ;
      $site =~ s/&gt;/>/gi ;
      $site =~ s/&lt;/</gi ;
      $site =~ s/^(.*?)[,;\)\<\>\s)].*$/$1/ ;
    }
    $agent =~ s/\Q$site\E/<b>$site<\/b>/ ;
 #  $agent =~ s/\Q$site\E// ;

    $secondary_domain = &GetSecondaryDomain ($site) ;
    if (($secondary_domain eq "google") and ($agent =~ /color=red>GoogleBot</))
    { $secondary_domain .= "?" ; }

    $secondary_domains {$secondary_domain} += $count ;

    if ($secondary_domain ne "-")
    { $crawlers_per_domain {$secondary_domain} {$mime_agent} += $count ; }
    else
    {
      $crawlers_no_url  {$agent} {$mime} += $count ;
      $crawlers_no_url_agent {$agent} += $count ;
    }

    $total_crawlers += $count ;
    if ($count <= 2) { next ; }
    # $count = &FormatCount ($count) ;
    # $html .= "<tr><td class=r>$count</td><td class=l><a href='$site'>$secondary_domain</a></td><td class=l>$mime</td><td class=l>$agent</td></tr>\n" ;
    # $rows++ ;
  }

  $perc_crawlers = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_crawlers = sprintf ("%.1f",100 * $total_page_crawlerrequests/$total_page_requests_external) ; }

  $total_page_requests_external2 = &FormatCount ($total_page_requests_external*1000) ;
  $total_page_crawlerrequests2 = &FormatCount ($total_page_crawlerrequests*1000) ;
  $html =~ s/PERC_GOOGLE/<p>In total $total_page_crawlerrequests2 page requests (mime type <a href='VisitorsSampledLogRequests.htm'>text\/html<\/a> only!) per day are considered crawler requests, out of $total_page_requests_external2 external requests, which is $perc_crawlers%/ ;

  $total_crawlers = &FormatCount ($total_crawlers) ;
# $html .= "<tr><th class=l>$total_crawlers</th><th class=l colspan=2>total</th></tr>\n" ;
# $html .= "</table><p>\n" ;

#  $html .= "<table border=1>\n" ;
#  $html .= "<tr><th class=l colspan=99>Top 25 secondary domains<br>(~ sites) mentioned</th></tr>\n" ;
#  foreach $secondary_domain (sort {$secondary_domains {$b} <=> $secondary_domains {$a}} keys %secondary_domains)
#  {
#    if ($secondary_domain eq "..") { next ; }
#    if (++$secondary_domains_listed > 25) { last ; }
#    $count = $secondary_domains {$secondary_domain} ;
#    $count = &FormatCount ($count) ;
#    $html .= "<tr><td class=r>$count</td><td class=l colspan=2>$secondary_domain</td></tr>\n" ;
#  }
#  $html .= "</table>\n" ;

  $html .= "<tr><th class=lh3 colspan=99>Page requests for crawlers that specify a url in the agent string</th></tr>\n" ;
  $html .= "<tr><th class=l>Count<br><small>x 1000</small></th><th class=l>Secondary domain<br>(~site) name</th><th class=l>URL</th><th class=l>Mime type</th><th class=l>User agent</th></tr>\n" ;
  foreach $secondary_domain (sort {$secondary_domains {$b} <=> $secondary_domains {$a}} keys %secondary_domains)
  {
    if ($secondary_domain eq "-") { next ; }
    $total = $secondary_domains {$secondary_domain} ;
    $total_crawlers_url += $total ;
    if ($total < 10) { last ; }
    $total = &FormatCount ($total) ;
    $html .= "<tr><th class=r>$total</th><th class=l colspan=99>$secondary_domain</th></tr>\n" ;
    foreach $mime_agent (sort {$crawlers_per_domain {$secondary_domain} {$b} <=> $crawlers_per_domain {$secondary_domain} {$a}} keys %{$crawlers_per_domain {$secondary_domain}})
    {
      ($mime, $agent) = split ('\|', $mime_agent,2) ;
      $agent =~ s/([^,;\(\)\s]+?\@[^,;\(\)\s]+)/ <font color=#808080>mail address<\/font> /g ;
      $agent =~ s/([\w-]+\s*.?at.?\s*[\w-]+\s*.?dot.?\s*[\w-]+)/ <font color=#808080>mail address<\/font> /gi ;
      $site = "-" ;
      if ($agent =~ /http:/)
      {
        $site = $agent ;
        $site =~ s/^.*?http:/http:/ ;
        $site =~ s/&gt;/>/gi ;
        $site =~ s/&lt;/</gi ;
        $site =~ s/^(.*?)[,;\)\<\>\s)].*$/$1/ ;
      }
    # $agent =~ s/\Q$site\E/<b>$site<\/b> <a href='$site'>x<\/a>/ ;
      if ($site ne "-")
      { $agent =~ s/\Q$site\E/<b>url<\/b>/ ; }
      $count = $crawlers_per_domain {$secondary_domain} {$mime_agent} ;
      if ($count <= 2) { next ; }
    # print "[$secondary_domain] [$mime_agent] : $count\n" ;
      $count = &FormatCount ($count) ;
      ($site2 = $site) =~ s/^http:\/\/// ;
      $html .= "<tr><td class=r>$count</td><td class=l>&nbsp;</td><td class=l><a href='$site' ref='nofollow'>$site2<\/a></td><td class=l>$mime</td><td class=l>$agent</td></tr>\n" ;
      $rows++ ;
    }
  }
  $total_crawlers_url = &FormatCount ($total_crawlers_url) ;
  $html .= "<tr><th class=l>$total_crawlers_url</th><th class=l colspan=99>total</th></tr>\n" ;
  $html .= "</table><p>\n" ;

  $total_crawlers_no_url = 0 ;
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th class=lh3 colspan=99>Page requests for probable crawlers, recognized by keyword</th></tr>\n" ;
  $html .= "<tr><th class=l width=40>Count<br><small>x 1000</small></th><th class=l colspan=99>Agent string</th></tr>\n" ;
  $html .= "<tr><th class=l width=40>&nbsp;</td><th class=l width=40>&nbsp;</td><th class=l>Mime type (count &ge; 3)</th></tr>\n" ;
  foreach $agent (sort {$crawlers_no_url_agent {$b} <=> $crawlers_no_url_agent {$a}} keys %crawlers_no_url_agent)
  {
    $total = $crawlers_no_url_agent {$agent} ;
    $total_crawlers_no_url += $total ;
    if ($total < 3) { last ; }
    $total = &FormatCount ($total) ;
    $html .= "<tr><th class=r>$total</th><td class=l colspan=99>$agent</td></tr>\n" ;
    foreach $mime (sort {$crawlers_no_url {$agent} {$b} <=> $crawlers_no_url {$agent} {$a}} keys %{$crawlers_no_url {$agent}})
    {
      $agent =~ s/([^,;\(\)\s]+?\@[^,;\(\)\s]+)/ <font color=#808080>mail address<\/font> /g ;
      $agent =~ s/([\w-]+\s*.?at.?\s*[\w-]+\s*.?dot.?\s*[\w-]+)/ <font color=#808080>mail address<\/font> /gi ;
      $count = $crawlers_no_url {$agent} {$mime} ;
      $count = &FormatCount ($count) ;
      ($site2 = $site) =~ s/^http:\/\/// ;
      $html .= "<tr><td class=r>$count</td><td>&nbsp;</td><td class=l colspan=99>$mime</td></tr>\n" ;
      $rows++ ;
    }
  }

  $total_crawlers_no_url = &FormatCount ($total_crawlers_no_url) ;
  $html .= "<tr><th class=l>$total_crawlers_no_url</th><th class=l colspan=99>total</th></tr>\n" ;
  $html .= "</table><p>\n" ;

  $html .= "<p>$google_ip_ranges" ;
  $html .= $colophon ;

  print FILE_HTML_CRAWLERS $html ;
  close FILE_HTML_CRAWLERS ;
}

sub WriteReportMethods
{
  open FILE_HTML_METHODS, '>', "$dir_reports/$file_html_methods" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Request Methods/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Request Methods/ ;
  $html =~ s/LINKS/$link_requests $link_origins \/  $dummy_methods \/ $link_scripts \/ $link_skins \/ $link_crawlers \/ $link_opsys \/ $link_browsers \/ $link_google/ ;
  $html =~ s/NOTES// ;

  $html .= "<table border=0>\n" ;
  $html .= "<tr><td>" ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In order of request volume</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=2 class=l>Method</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  $total_methods = 0 ;
  foreach $method (@methods_sorted_count)
  {
    $total = $methods {$method} ;
    $total_methods += $total ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td colspan=2 class=l>$method</td><td class=r>$total</td></tr>\n" ;
  }
  $total_methods = &FormatCount ($total_methods) ;
  $html .= "<tr><th colspan=2 class=l>Total</th><th class=r>$total_methods</th></tr>\n" ;
  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td class=l>Method</th><th class=l>Result</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $total_statusses = 0 ;
  foreach $status (@statusses_sorted_count)
  {
    $total = $statusses {$status} ;
    $total_statusses += $total ;
    $total = &FormatCount ($total) ;
    ($method,$result) = split (',', $status, 2) ;

    $html .= "<tr><td class=l>$method</td><td class=l>$result</td><td class=r>$total</td></tr>\n" ;
    $rows++ ;
  }
  $total_statusses = &FormatCount ($total_statusses) ;
  $html .= "<tr><th colspan=2 class=l>Total</th><th class=r>$total_statusses</th></tr>\n" ;
  $html .= "</table>\n" ;

  $html .= "</td><td>&nbsp;&nbsp;&nbsp;</td><td>" ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In alphabetical order: method+result</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=2 class=l>Method</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  foreach $method (@methods_sorted_method)
  {
    $total = &FormatCount ($methods {$method}) ;
    $html .= "<tr><td colspan=2 class=l>$method</td><td class=r>$total</td></tr>\n" ;
  }
  $html .= "<tr><th colspan=2 class=l>Total</th><th class=r>$total_methods</th></tr>\n" ;
  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th class=l>Method</th><th class=l>Result</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  foreach $status (@statusses_sorted_method)
  {
    $total = &FormatCount ($statusses {$status}) ;
    ($method,$result) = split (',', $status, 2) ;

    $html .= "<tr><td class=l>$method</td><td class=l>$result</td><td class=r>$total</td></tr>\n" ;
    $rows++ ;
  }
  $html .= "<tr><th colspan=2 class=l>Total</th><th class=r>$total_statusses</th></tr>\n" ;
  $html .= "</table>\n" ;

  $html .= "</td></tr></table>\n" ;
  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon ;

  print FILE_HTML_METHODS $html ;
  close FILE_HTML_METHODS ;
}

sub WriteReportMimeTypes
{
  open FILE_HTML_REQUESTS, '>', "$dir_reports/$file_html_requests" ;

  $html = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Requests by destination/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Requests by destination/ ;
  $html =~ s/LINKS/$dummy_requests $link_origins \/ $link_methods \/ $link_scripts \/ $link_skins \/ $link_crawlers  \/ $link_opsys \/ $link_browsers \/ $link_google/ ;
  $html =~ s/NOTES/<br>&nbsp;This report shows where requests are sent to. Report 'Requests by origin' shows where requests come from.<br>&nbsp;Those numbers bear no direct relation.<br>/ ;
  $html .= "<table border=1>\n" ;

  $header1 = "<tr><th colspan=2 class=l><small>x 1000</small></th><th colspan=2 class=c>Totals</th><th class=c><font color=#008000>Pages</font></th><th colspan=3 class=c><font color=#900000>Images</font></th><th colspan=99 class=c>Other</th></tr>\n" ;
  $header2 = "<tr><th colspan=2 class=l>&nbsp;</th><th class=c>total<br>all</th><th class=c><font color=#900000>total<br>images</font></th>\n" ;
  $columns = 0 ;
  foreach $mimetype (@mimetypes_sorted)
  {
    $columns++ ;
    if ($mimetypes_found {$mimetype} < $threshold_mime) { next ;}
    $mimetype2 = $mimetype ;
    if ($mimetype2 eq "text/html")
    { $mimetype2 .= "<br><small>(page)</small> " ; }
    if ($mimetype2 =~ /image\/(?:png|jpeg|gif)/)
    { $mimetype2 .= "<br><small>(img)</small> " ; }
    if ($columns == 1)
    { $mimetype2 = "<font color=#008000>$mimetype2</font" ; }
    if (($columns >= 2) && ($columns <= 4))
    { $mimetype2 = "<font color=#900000>$mimetype2</font" ; }
    ($mime1,$mime2) = split ('\/', $mimetype2, 2) ;
    $header2 .= "<th class=c>$mime1<br>$mime2</th>\n" ;
  }
  $header2 .= "</tr>\n" ;
  $html .= $header1 . $header2 ;

  $rows = 0 ;
  $total_mimes2  = 0 ;
  $total_images1 = 0 ;
  foreach $domain (@domains_sorted)
  {
    $html .= "<tr><td colspan=2 class=l>" . ucfirst($domain) . "</td>\n" ;
    $total = $domains {$domain} ;
    $total_mimes2 += $total ;
    $total = &FormatCount ($total) ;
    $total_images = $images_domain {$domain} ;
    $total_images1 += $total_images ;
    $total_images = &FormatCount ($total_images) ;
    $total_images = "<font color=#900000>" . &FormatCount ($total_images) . "</font>" ;

    $html .= "<th class=r>$total</th><th class=r>$total_images</th>\n" ;
    $columns = 0 ;
    foreach $mimetype (@mimetypes_sorted)
    {
      $columns++ ;
      if ($mimetypes_found {$mimetype} < $threshold_mime) { next ;}
      $count = &FormatCount ($counts_dm {"$domain,$mimetype"}) ;
      if ($columns == 1)
      { $count = "<font color=#008000>$count</font" ; }
      if (($columns >= 2) && ($columns <= 4))
      { $count = "<font color=#900000>$count</font" ; }
      if ($count eq "")
      { $count = "&nbsp;" ; }
      $html .= "<td class=r>$count</td>\n" ;
    }
    $html .= "</tr>\n" ;
    $rows++ ;
  }

  if ($total_mimes != $total_mimes2)
  {
    print ERR "total_mimes $total_mimes != total_mimes2 $total_mimes2\n" ;
    print     "total_mimes $total_mimes != total_mimes2 $total_mimes2\n" ;
  }

  $total_mimes1  = &FormatCount ($total_mimes) ;
  $total_images1 = &FormatCount ($total_images1) ;
  $total_images1 = "<font color=#900000>" . &FormatCount ($total_images1) . "</font>" ;
  $html .= "<tr><th colspan=2 class=l>Total</th><th class=c>$total_mimes1</th><th class=c>$total_images1</th>\n" ;
  $columns = 0 ;
  foreach $mimetype (@mimetypes_sorted)
  {
    $columns++ ;
    if ($mimetypes_found {$mimetype} < $threshold_mime) { next ;}
    $count = &FormatCount ($mimetypes {$mimetype}) ;
    if ($columns == 1)
    { $count = "<font color=#008000>$count</font" ; }
    if (($columns >= 2) && ($columns <= 4))
    { $count = "<font color=#900000>$count</font" ; }
    $html .= "<th class=r>$count</th>\n" ;
  }
  $html .= "</tr>\n" ;

  $html .= "<tr><th colspan=99>&nbsp;</th></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l><b>Per project / language subproject</b> (top 50)</td></tr>\n" ;
  $total_mimes3 = 0 ;
  $total_mimes4 = 0 ;
  $cnt_projects = 0 ;
  foreach $project (@projects_sorted)
  {
    if (++ $cnt_projects > 50) { last ; }
    $total = $projects {$project} ;
    $total_mimes3 += $total ;
    if ($total < $threshold_project) { next ; }
    $total_mimes4 += $total ;
    ($domain,$language) = split ('\:', $project,2) ;
    $html .= "<tr><td class=l>" . ucfirst($domain) . "</td><td class=l>$language</td>\n" ;

    $total = &FormatCount ($total) ;
    $total_images = $images_project {$project} ;
    $total_images2 += $total_images ;
    $total_images = "<font color=#900000>" . &FormatCount ($total_images) . "</font>" ;
    $html .= "<th class=r>$total</th><th class=r>$total_images</th>\n" ;

    $columns = 0 ;
    foreach $mimetype (@mimetypes_sorted)
   {
      $columns++ ;
      if ($mimetypes_found {$mimetype} < $threshold_mime) { next ;}
      $count = &FormatCount ($counts_pm {"$project,$mimetype"}) ;
      if ($columns == 1)
      { $count = "<font color=#008000>$count</font" ; }
      if (($columns >= 2) && ($columns <= 4))
      { $count = "<font color=#900000>$count</font" ; }
#     if ($count eq "")
#     { $count = "&nbsp;" ; }
      $html .= "<td class=r>$count</td>\n" ;
    }
    $html .= "</tr>\n" ;
    $rows++ ;
  }
  $html .= $header2 . $header1 ;
  $html .= "</table>\n" ;
  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

  if ($total_mimes != $total_mimes3)
  {
    print ERR "total_mimes $total_mimes != total_mimes3 $total_mimes3\n" ;
    print     "total_mimes $total_mimes != total_mimes3 $total_mimes3\n" ;
  }

  if ($threshold_mime > 0)
  {
    $html .= "<b>Mime types that are found on less than $threshold_mime projects:</b> (again 1 = 1000)<p>" ;
    foreach $mimetype (@mimetypes_sorted)
    {
      if ($mimetypes_found {$mimetype} >= $threshold_mime) { next ;}
      $count = $mimetypes {$mimetype} ;
      $count =~ s/^(\d{1,3})(\d\d\d)$/$1,$2/ ;
      $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
      $html .= "<b>$mimetype</b> $count total<br>" ;
    }
  }

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon ;

  print FILE_HTML_REQUESTS $html ;
  close FILE_HTML_REQUESTS ;
}

sub WriteReportOpSys
{
  open FILE_HTML_OPSYS, '>', "$dir_reports/$file_html_opsys" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Operating Systems/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Operating Systems/ ;
  $html =~ s/LINKS/$link_requests $link_origins \/ $link_methods \/ $link_scripts \/ $link_skins \/ $link_crawlers \/ $dummy_opsys \/ $link_browsers \/ $link_google/ ;
  $html =~ s/NOTES// ;

  $total_all2 = &FormatCount ($total_opsys_mobile + $total_opsys_non_mobile) ;
  $total_opsys_mobile2 = &FormatCount ($total_opsys_mobile) ;
  $total_opsys_non_mobile2 = &FormatCount ($total_opsys_non_mobile) ;
  $total_perc_mobile = sprintf ("%.1f", 100 * $total_opsys_mobile / ($total_opsys_mobile + $total_opsys_non_mobile)) ;
  $total_perc_non_mobile = 100 - $total_perc_mobile ;
  $line_total_all        = "<tr><th class=l>Total</th><th class=r>$total_all2</th><th class=r>100\%</th></tr>\n" ;
  $line_total_mobile     = "<tr><th class=l>Total</th><th class=r>$total_opsys_mobile2</th><th class=r>$total_perc_mobile\%</th></tr>\n" ;
  $line_total_non_mobile = "<tr><th class=l>Total</th><th class=r>$total_opsys_non_mobile2</th><th class=r>$total_perc_non_mobile\%</th></tr>\n" ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td class=l colspan=99>The following overview of page requests by operating system is based on the <a href='http://en.wikipedia.org/wiki/User_agent'>user agent</a> information that accompanies most server requests.<br>" .
           "Please note that agent information does not follow strict guidelines and some programs may provide wrong information on purpose.<br>" .
           "This report ignores all requests where agent information is missing, or contains any of the following: bot, crawl(er) or spider.<p>" .
           "<a href='http://en.wikipedia.org/wiki/Windows_NT#Releases'>Wikipedia</a>: NT 5.0 = Windows 2000, NT 5.1/5.2 = XP + Server 2003, NT 6.0 = VISTA + Server 2008, NT 6.1 = Windows 7.<br> " .
           "<a href='http://en.wikipedia.org/wiki/Mac_OS_X#Versions'>Wikipedia</a>: OS X 10.4 = Tiger, 10.5 = Leopard, 10.6 = Snow Leopard.<br> " .
           "<a href='http://en.wikipedia.org/wiki/Ubuntu#Releases'>Wikipedia</a>: Ubuntu 7.10 = Gutsy Gibbon, 8.04 = Hardy Heron, 8.10 = Intrepid Ibex, 9.04 = Jaunty Jackalope, 9.10 = Karma Koala." .
           "</td></tr>\n" ;

# $html .= "<tr><th class=l>Count<br><small>x 1000</small></th><th class=l>Secondary domain<br>(~site) name</th><th class=l>Mime type</th><th class=l>User agent</th></tr>\n" ;

  $html .= "<tr><td width=50% valign=top>" ;

  # OS SORTED BY FREQUENCY
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=99 class=l><h3>In order of popularity</h3></td></tr>" ;
  $html .= "<tr><th class=l>Operating System</th><th class=r>Requests</th><th class=r>Percentage</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne 'G') { next ; } # group
    if ($key     =~ / /) { next ; } # subgroup
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_all ;

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per platform for Mac and Linux</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne 'G') { next ; } # group
    if ($key     !~ / /) { next ; } # subgroup
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, non mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne '-') { next ; } # group
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_non_mobile ;

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne 'M') { next ; } # group
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_mobile ;
  $html .= "</table>\n" ;

  $html .= "</td><td width=50% valign=top>" ;

  # IN ALPHABETICAL ORDER
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td colspan=99 class=l><h3>In alphabetical order</h3></td></tr>" ;
  $html .= "<tr><th class=l>Operating System</th><th class=r>Requests</th><th class=r>Percentage</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne 'G') { next ; } # group
    if ($key     =~ / /) { next ; } # subgroup
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_all ;

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per platform for Mac and Linux</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne 'G') { next ; } # group
    if ($key     !~ / /) { next ; } # subgroup
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, non mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne '-') { next ; } # group
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }

  $html .= $line_total_non_mobile ;
  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    if ($perc lt "0.02%") { next ; }
    ($rectype, $os) = split (',', $key,2) ;
    if ($rectype ne 'M') { next ; } # group
    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td><td class=r>$count</td><td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_mobile ;
  $html .= "</table>\n" ;
  $html .= "</td></tr>" ;

  $html .= "<tr><td colspan=99 class=l wrap>Requests from mobile devices are recognized as follows:<br>" .
           "Agent string contains any of the following terms (last upd: $month_upd_keywords_mobile):<br>" .
           "<i>$keywords_mobile</i></td></tr>" ;

  $html .= "</table><p>" ;

#  $perc_crawlers               = sprintf ("%.1f",100 * $total_page_crawlerrequests/$total_page_requests_external) ;
#  $total_page_requests_external2 = &FormatCount ($total_page_requests_external*1000) ;
#  $total_page_crawlerrequests2 = &FormatCount ($total_page_crawlerrequests*1000) ;
#  $html =~ s/PERC_GOOGLE/<p>In total $total_page_crawlerrequests2 page requests (mime type <a href='VisitorsSampledLogRequests.htm'>text\/html<\/a> only!) per day are considered crawler requests, out of $total_page_requests_external2 external requests, which is $perc_crawlers%/ ;

#  $total_crawlers = &FormatCount ($total_crawlers) ;

# $html .= "<tr><th class=l>$total_crawlers</th><th class=l colspan=2>total</th></tr>\n" ;
# $html .= "</table><p>\n" ;

#  $html .= "<table border=1>\n" ;
#  $html .= "<tr><th class=l colspan=99>Top 25 secondary domains<br>(~ sites) mentioned</th></tr>\n" ;
#  foreach $secondary_domain (sort {$secondary_domains {$b} <=> $secondary_domains {$a}} keys %secondary_domains)
#  {
#    if ($secondary_domain eq "..") { next ; }
#    if (++$secondary_domains_listed > 25) { last ; }
#    $count = $secondary_domains {$secondary_domain} ;
#    $count = &FormatCount ($count) ;
#    $html .= "<tr><td class=r>$count</td><td class=l colspan=2>$secondary_domain</td></tr>\n" ;
#  }
#  $html .= "</table>\n" ;

  $html .= $colophon ;

  print FILE_HTML_OPSYS $html ;
  close FILE_HTML_OPSYS ;
}

# http://en.wikipedia.org/wiki/Domain_name
sub WriteReportOrigins
{
  open FILE_HTML_ORIGINS, '>', "$dir_reports/$file_html_origins" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Requests by origin/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Requests by origin/ ;
  $html =~ s/LINKS/$link_requests $dummy_origins \/ $link_methods \/ $link_scripts \/ $link_skins \/ $link_crawlers  \/ $link_opsys \/ $link_browsers \/ $link_google/ ;
  $html =~ s/NOTES/<br>&nbsp;This report shows where requests come from. Report 'Requests by destination' shows where requests are serviced.<br>&nbsp;Those numbers bear no direct relation.<br>/ ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td colspan=99>" ;


  $html .= "<table border=0 width=100%>\n" ;
# $html .= "<tr><td colspan=99 class=c>traffic from yahoo is allocated as if yahoo used same domain naming scheme as google: <b>search.yahoo.ca</b> instead of <b>ca.search.yahoo.com</b></td></tr>\n" ;
# $html .= "<tr><td colspan=99 class=c><small>All counts x 1000</small></td></tr>\n" ;

  # INTERNAL ORIGINS

  $html .= "<tr><td colspan=99 class=c><h3>Requests with internal origins</h3></td></tr>\n" ;
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=2 class=l><b>Internal origins<br>sorted by<br>frequency</b></td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $project (@project_int_top_sorted_count)
  {
    $total  = $project_int_top {$project} ;
    $page   = $project_int_top_split {"page:$project"} ;
    $image  = $project_int_top_split {"image:$project"} ;
    $rest   = $project_int_top_split {"other:$project"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td colspan=2 class=l>" . ucfirst($project) . "</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>Total</th><th class=r>$total_total</th><td class=r>$total_page</td><td class=r>$total_image</td><td class=r>$total_rest</td></tr>\n" ;

  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l><b>Per project language / subproject</b> (top 50)</td></tr>\n" ;
  $projects    = 0 ;
  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $origin (@origin_int_top_sorted_count)
  {
    if (++$projects > 50)
    {
      $origin_int_top_other {"all"}   += $origin_int_top       {$origin} ; ;
      $origin_int_top_other {"page"}  += $origin_int_top_split {"page:$origin"}  ;
      $origin_int_top_other {"image"} += $origin_int_top_split {"image:$origin"}  ;
      $origin_int_top_other {"other"} += $origin_int_top_split {"other:$origin"}  ;
      next ;
    }
    $top100_internal_origins {$origin} ++ ;
    $total  = $origin_int_top {$origin} ;
    $page   = $origin_int_top_split {"page:$origin"} ;
    $image  = $origin_int_top_split {"image:$origin"} ;
    $rest   = $origin_int_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    ($project,$subproject) = split (':', $origin) ;
    $html .= "<tr><td class=l>" . ucfirst($project) . "</td><td class=l>$subproject</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;

  }
  $total  = $origin_int_top_other {"all"} ;
  $page   = $origin_int_top_other {"page"} ;
  $image  = $origin_int_top_other {"image"} ;
  $rest   = $origin_int_top_other {"other"} ;
  $total_total  += $total ;
  $total_page   += $page ;
  $total_image  += $image ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td colspan=2 class=l>Other</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  $grand_grand_total  = $total_total ;
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>Total</th><th class=r>$total_total</th><td class=r>$total_page</td><td class=r>$total_image</td><td class=r>$total_rest</td></tr>\n" ;
  $html .= "</table>" ;

  # BY ALPHABET
  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=2 class=l><b>Internal origins<br>sorted by<br>alphabet</b></td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $project (@project_int_top_sorted_alpha)
  {
    $total  = $project_int_top {$project} ;
    $page   = $project_int_top_split {"page:$project"} ;
    $image  = $project_int_top_split {"image:$project"} ;
    $rest   = $project_int_top_split {"other:$project"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td colspan=2 class=l>$project</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>total</th><th class=r>$total_total</th><td class=r>$total_page</td><td class=r>$total_image</td><td class=r>$total_rest</td></tr>\n" ;

  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l><b>Per project language / subproject</b> (top 50)</td></tr>\n" ;
  $projects    = 0 ;
  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $origin (@origin_int_top_sorted_alpha)
  {
    if ($top100_internal_origins {$origin} == 0) { next ; }

    $total  = $origin_int_top {$origin} ;
    $page   = $origin_int_top_split {"page:$origin"} ;
    $image  = $origin_int_top_split {"image:$origin"} ;
    $rest   = $origin_int_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    ($project,$subproject) = split (':', $origin) ;
    $html .= "<tr><td class=l>$project</td><td class=l>$subproject</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;

  }
  $total  = $origin_int_top_other {"all"} ;
  $page   = $origin_int_top_other {"page"} ;
  $image  = $origin_int_top_other {"image"} ;
  $rest   = $origin_int_top_other {"other"} ;
  $total_total  += $total ;
  $total_page   += $page ;
  $total_image  += $image ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td colspan=2 class=l>other</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>total</th><th class=r>$total_total</th><td class=r>$total_page</td><td class=r>$total_image</td><td class=r>$total_rest</td></tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
  $html .= "</table>" ;

  # REQUESTS WITH EXTERNAL ORIGINS

  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=99 class=c>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=c><h3>Requests with external origins</h3></td></tr>\n" ;
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;
# $html .= "<tr><td class=l><b><a href='http://...'>External origins</a><br>sorted by<br>frequency</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  $html .= "<tr><td class=l><b>External origins<br>sorted by<br>frequency</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $projects     = 0 ;
  $total_total  = 0 ;
  $total_page   = 0 ;
  $total_image  = 0 ;
  $total_rest   = 0 ;
  foreach $origin (@origin_ext_top_sorted_count)
  {
    $total  = $origin_ext_top {$origin} ;
    $page   = $origin_ext_top_split {"page:$origin"} ;
    $image  = $origin_ext_top_split {"image:$origin"} ;
    $rest   = $origin_ext_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;

    if (++$projects > 100)
    {
      $origin_ext_top_other {"all"}   += $origin_ext_top       {$origin} ; ;
      $origin_ext_top_other {"page"}  += $origin_ext_top_split {"page:$origin"}  ;
      $origin_ext_top_other {"image"} += $origin_ext_top_split {"image:$origin"}  ;
      $origin_ext_top_other {"other"} += $origin_ext_top_split {"other:$origin"}  ;
      next ;
    }
    $top100_internal_origins {$origin} ++ ;

    if ($origin =~ /\./)
    { $link_origin = "<a href='http://$origin' ref='nofollow'>$origin</a>" ; }
    else
    { $link_origin = $origin ; }
    $html .= "<tr><td class=l>$link_origin</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $total  = $origin_ext_top_other {"all"} ;
  $page   = $origin_ext_top_other {"page"} ;
  $image  = $origin_ext_top_other {"image"} ;
  $rest   = $origin_ext_top_other {"other"} ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  $grand_grand_total  = $total_total ;
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_page</td><td class=r>$total_image</td><td class=r>$total_rest</td></tr>\n" ;
  $html .= "</table>" ;

  # BY ALPHABET
  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;
# $html .= "<tr><td class=l><b><a href='http://...'>External origins</a><br>sorted by<br>alphabet</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  $html .= "<tr><td class=l><b>External origins<br>sorted by<br>alphabet</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $projects     = 0 ;
  $total_total  = 0 ;
  $total_page   = 0 ;
  $total_image  = 0 ;
  $total_rest   = 0 ;
  foreach $origin (@origin_ext_top_sorted_alpha)
  {

    $total  = $origin_ext_top {$origin} ;
    $page   = $origin_ext_top_split {"page:$origin"} ;
    $image  = $origin_ext_top_split {"image:$origin"} ;
    $rest   = $origin_ext_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($top100_internal_origins {$origin} == 0) { next ; }
    $html .= "<tr><td class=l>$origin</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;

  }
  $total  = $origin_ext_top_other {"all"} ;
  $page   = $origin_ext_top_other {"page"} ;
  $image  = $origin_ext_top_other {"image"} ;
  $rest   = $origin_ext_top_other {"other"} ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td><th class=r>$total</th><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_page</td><td class=r>$total_image</td><td class=r>$total_rest</td></tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
# $html .= "<tr><td colspan=99 class=c>For presentation conciseness the top level domain (.org, .com, ..) is ignored here. There is a theoretical<br> possibility that figures for two unrelated sites which are both popular are presented as one here.<p>" .
#          "'Unmatched ip address': all requests without explicit referer url that were not allocated <br>to a site based on known ip range, e.g. google (by ip) or agent string, e.g. google (by agent)</td></tr>" ;
  $html .= "<tr><td colspan=99 class=c>'Origin unknown': all requests without explicit referer url, without known ip range and without identity clue in the agent string.<br>Note that right now only ip ranges for Google and Yahoo are recognized by the script (manual input Feb 2009)</td></tr>" ;
  $html .= "</table>" ;

  # EXTERNAL ORIGINS
if (0)
{
  $html .= "<tr><td colspan=99 class=c>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=c><h3>External origins</h3></td></tr>\n" ;
  $html .= "<tr><td width=50% valign=top>" ;


  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td class=l><b><a href='http://en.wikipedia.org/wiki/Top-level_domain'>Top level domains</a> (tld)<br>sorted by<br>frequency</b></td><th class=r>&nbsp;Total</th><th class=r>Google</th><th class=r>Yahoo</th><th class=r>Other</th></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Generic_top-level_domain'>Generic</a> and <a href='http://en.wikipedia.org/wiki/Sponsored_top-level_domains'>Sponsored</a> tld's</a></b></td></tr>\n" ;
  foreach $toplevel (@origin_ext_page_top_sorted_count)
  {
    if ((length ($toplevel) <= 2) || ($toplevel =~ /^(?:address|local|rest|unspecified)$/)) { next ; }
    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;
  }
  $grand_total  += $total_total ;
  $grand_google += $total_google ;
  $grand_yahoo  += $total_yahoo ;
  $grand_rest   += $total_rest ;
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Country_code_top-level_domain'>Country code tld's</a></b></td></tr>\n" ;
  foreach $toplevel (@origin_ext_page_top_sorted_count)
  {
    if (length ($toplevel) != 2) { next ; }
    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;
  }
  $grand_total  += $total_total ;
  $grand_google += $total_google ;
  $grand_yahoo  += $total_yahoo ;
  $grand_rest   += $total_rest ;
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Remainder</th></tr>\n" ;
  $total  = $origin_ext_page_top {"local"} ;
  $google = $origin_ext_page_top_split {"google:local"} ; # always zero
  $yahoo  = $origin_ext_page_top_split {"yahoo:local"} ; # always zero
  $rest   = $origin_ext_page_top_split {"other:local"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>localhost</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $total  = $origin_ext_page_top {"address"} ;
  $google = $origin_ext_page_top_split {"google:address"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:address"} ;
  $rest   = $origin_ext_page_top_split {"other:address"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>ip address</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $total  = $origin_ext_page_top {"rest"} ;
  $google = $origin_ext_page_top_split {"google:rest"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:rest"} ;
  $rest   = $origin_ext_page_top_split {"other:rest"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $total  = $origin_ext_page_top {"unspecified"} ;
  $google = $origin_ext_page_top_split {"google:unspecified"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:unspecified"} ;
  $rest   = $origin_ext_page_top_split {"other:unspecified"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>anonymous</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $grand_total  += $total_total ;
  $grand_google += $total_google ;
  $grand_yahoo  += $total_yahoo ;
  $grand_rest   += $total_rest ;
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Grand total external</th></tr>\n" ;
  $grand_total  = &FormatCount ($grand_total) ;
  $grand_google = &FormatCount ($grand_google) ;
  $grand_yahoo  = &FormatCount ($grand_yahoo) ;
  $grand_rest   = &FormatCount ($grand_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$grand_total</th><td class=r>$grand_google</td><td class=r>$grand_yahoo</td><td class=r>$grand_rest</td></tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><th class=l>Top level domains<br>sorted by<br>alphabet</th><th class=r>Total<th class=r>Google<th class=r>Yahoo<th class=r>Other</th></tr>\n" ;
# $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Top-level_domain'>generic/sponsored tld's</a></b></th></tr>\n" ;
  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Generic and sponsored tld's</b></td></tr>\n" ;

  foreach $toplevel (@origin_ext_page_top_sorted_alpha)
  {
    if ((length ($toplevel) <= 2) || ($toplevel =~ /^(?:address|local|rest|unspecified)$/)) { next ; }
    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Country_code_top-level_domain'>Country code tld's</a></b></td></tr>\n" ;
  foreach $toplevel (@origin_ext_page_top_sorted_alpha)
  {
    if (length ($toplevel) != 2) { next ; }
    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Remainder</th></tr>\n" ;
  $total  = $origin_ext_page_top {"local"} ;
  $google = $origin_ext_page_top_split {"google:local"} ; # always zero
  $yahoo  = $origin_ext_page_top_split {"yahoo:local"} ; # always zero
  $rest   = $origin_ext_page_top_split {"other:local"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>localhost</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $total  = $origin_ext_page_top {"address"} ;
  $google = $origin_ext_page_top_split {"google:address"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:address"} ;
  $rest   = $origin_ext_page_top_split {"other:address"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>ip address</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $total  = $origin_ext_page_top {"rest"} ;
  $google = $origin_ext_page_top_split {"google:rest"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:rest"} ;
  $rest   = $origin_ext_page_top_split {"other:rest"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $total  = $origin_ext_page_top {"unspecified"} ;
  $google = $origin_ext_page_top_split {"google:unspecified"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:unspecified"} ;
  $rest   = $origin_ext_page_top_split {"other:unspecified"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>anonymous</td><th class=r>$total</th><td class=r>$google</td><td class=r>$yahoo</td><td class=r>$rest</td></tr>\n" ;

  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Grand total external</th></tr>\n" ;
  $html .= "<tr><th class=l>total</th><th class=r>$grand_total</th><td class=r>$grand_google</td><td class=r>$grand_yahoo</td><td class=r>$grand_rest</td></tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
  $html .= "</table>" ;
  $html .= "</td></tr>" ;

  $html .= "</table>\n" ;
}

sub WriteReportScripts
{
  open FILE_HTML_SCRIPTS, '>', "$dir_reports/$file_html_scripts" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Scripts/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Scripts/ ;
  $html =~ s/LINKS/$link_requests $link_origins \/ $link_methods \/ $dummy_scripts \/ $link_skins \/ $link_crawlers  \/ $link_opsys \/ $link_browsers \/ $link_google/ ;
  $html =~ s/NOTES// ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td colspan=99>" ;


  $html .= "<table border=0 width=100%>\n" ;
  $html .= "<tr><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td class=l><h3>In order of request volume</h3></td><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>css</b></th></tr>\n" ;
  foreach $script (@scripts_css_sorted_count)
  {
    $total = $scripts_css {$script} ;
    if ($total < 3) { next ; }
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td><td class=r>$total</td></tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>js</b></th></tr>\n" ;
  foreach $script (@scripts_js_sorted_count)
  {
    $total = $scripts_js {$script} ;
    if ($total < 3) { next ; }
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td><td class=r>$total</td></tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>php</b></th></tr>\n" ;
  $total_php = 0 ;
  foreach $script (@scripts_php_sorted_count)
  {
    $total = $scripts_php {$script} ;
    if ($total < 3) { next ; }
    $total_php += $total ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td><td class=r>$total</td></tr>\n" ;
    foreach $key (sort {$actions {$b} <=> $actions {$a}} keys %actions)
    {
      ($script2,$action) = split (',', $key) ;
      if (($script eq $script2) && ($actions {$key} < $scripts_php {$script}))
      { $html .= "<tr><td class=l>&nbsp;&nbsp;&nbsp;<small>$action</small></td><td class=r><small>" . &FormatCount ($actions {$key}) . "</small></td></tr>\n" ; }
    }
  }
  $total_php = &FormatCount ($total_php) ;
  $html .= "<tr><th class=l>total php</th><th class=r>$total_php</th></tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td class=l><h3>In alphabetical order</h3></td><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>css</b></th></tr>\n" ;
  foreach $script (@scripts_css_sorted_script)
  {
    $total = $scripts_css {$script} ;
    if ($total < 3) { next ; }
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td><td class=r>$total</td></tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>js</b></th></tr>\n" ;
  foreach $script (@scripts_js_sorted_script)
  {
    $total = $scripts_js {$script} ;
    if ($total < 3) { next ; }
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td><td class=r>$total</td></tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>php</b></th></tr>\n" ;
  foreach $script (@scripts_php_sorted_script)
  {
    $total = $scripts_php {$script} ;
    if ($total < 3) { next ; }
    $total_php += $total ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td><td class=r>$total</td></tr>\n" ;
    foreach $key (sort keys %actions)
    {
      ($script2,$action) = split (',', $key) ;
      if (($script eq $script2) && ($actions {$key} < $scripts_php {$script}))
      { $html .= "<tr><td class=l>&nbsp;&nbsp;&nbsp;<small>$action</small></td><td class=r><small>" . &FormatCount ($actions {$key}) . "</small></td></tr>\n" ; }
    }
  }
  $html .= "<tr><th class=l>total php</th><th class=r>$total_php</th></tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
  $html .= "</table>" ;
  $html .= "</td></tr>" ;

  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>PHP scripts and generalized arguments, sorted by frequency, top 25</h3></th></tr>\n" ;
  $html .= "<tr><th class=l>Script</th><th class=l>Parameters</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  foreach $parm (@parms_sorted_count)
  {
    $total = &FormatCount ($parms {$parm}) ;
    ($name,$parms) = split (',', $parm) ;
    if ($parms eq "")
    { $parms = "-" ; }
    $html .= "<tr><td class=l>$name</td><td class=l>$parms</td><td class=r>$total</td></tr>\n" ;
    $rows++ ;
    if ($rows == 25) { last ; }
  }
# $html .= "</table>\n" ;
#  $html .= "</td><td>&nbsp;&nbsp;&nbsp;</td><td>" ;
# $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l><h3>PHP scripts and generalized arguments, in alphabetical order <small>(&ge; 3)</small></h3></small></th></tr>\n" ;

  $html .= "<tr><td colspan=2 class=l><b>Script</b><br>Parameters</td><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  $nameprev = "" ;
  foreach $parm (@parms_sorted_script)
  {
    ($name,$parms) = split (',', $parm, 2) ;

    $total = &FormatCount ($parms {$parm}) ;
    if ($name ne $nameprev)
    {
      $total = &FormatCount ($scripts_php {$name}) ;
      if ($total < 3) { next ; }
      if ($nameprev ne "")
      { $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ; }
      if (($name eq "api.php") || ($name eq "index.php"))
      { $html .= "<tr><td colspan=2 class=l><b>$name</b> <small>(&ge; 3)</small></td><th class=r>$total</th></tr>\n" ; }
      else
      { $html .= "<tr><td colspan=2 class=l><b>$name</b></td><th class=r>$total</th></tr>\n" ; }
    }
    $total = $parms {$parm} ;
    if ((($name eq "api.php") || ($name eq "index.php")) && ($total <= 2))
    { next ; }
    $total = &FormatCount ($total) ;
    if ($parms eq "")
    { $parms = "-" ; }
    $html .= "<tr><td colspan=2 class=l>$parms</td><td class=r>$total</td></tr>\n" ;
    $rows++ ;
    $nameprev = $name ;
  }
  $html .= "</table>\n" ;

  $html .= "</td></tr></table>\n" ;
  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon ;

  print FILE_HTML_SCRIPTS $html ;
  close FILE_HTML_SCRIPTS ;
}

sub WriteReportGoogle
{
  open FILE_HTML_SEARCH, '>', "$dir_reports/$file_html_google" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Google requests/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Google requests/ ;
  $html =~ s/LINKS/$link_requests $link_origins \/  $link_methods \/ $link_scripts \/ $link_skins \/ $link_crawlers  \/ $link_opsys \/ $link_browsers \/ $dummy_google/ ;
  $html =~ s/NOTES// ;

  $html .= "<table border=1 width=500 wrap>\n" ;
#  $html .= "<tr><td colspan=99 class=l>&nbsp;<br>This report shows <b>all requests to Wikimedia servers where a Google server of service was involved in any way</b>,<br> " .
#           "be it the <a href='http://en.wikipedia.org/wiki/Googlebot'>GoogleBot</a> crawler or <a href='http://www.google.com/feedfetcher.html'>FeedFetcher</a> collector scripts that run on Google servers,<br> " .
#           "or a user that follows a link from a Google Web or Google Desktop search results page, or " .
#           "from Google Maps or Google Earth etcetera. <p>Technically speaking three fields in the <a href='http://wikitech.wikimedia.org/view/Squid_log_format'>squid log records</a> are checked for this: " .
#           "client ip address, referer header and user agent header.<br>A request can originate from an ip address which has been registered by Google and/or it can carry a referer tag that tells us<br>a user clicked a link " .
#           "on a Google results page and/or it can carry an agent string that mentions a Google application which<br>can reasonably be assumed to be genuinely Google's. See bottom of page for <a href='#details'>further details</a>." .
#           "PERC_GOOGLE\n" ;
  $html .= "<tr><td colspan=99 class=l wrap>&nbsp;<br>This report shows <b>all requests to Wikimedia servers where a Google server of service was involved in any way</b>, " .
           "be it the <a href='http://en.wikipedia.org/wiki/Googlebot'>GoogleBot</a> crawler or <a href='http://www.google.com/feedfetcher.html'>FeedFetcher</a> collector scripts that run on Google servers, " .
           "or a user that follows a link from a Google Web or Google Desktop search results page, or " .
           "from Google Maps or Google Earth etcetera. <p>Technically speaking three fields in the <a href='http://wikitech.wikimedia.org/view/Squid_log_format'>squid log records</a> are checked for this: " .
           "client ip address, referer header and user agent header. A request can originate from an ip address which has been registered by Google and/or it can carry a referer tag that tells us a user clicked a link " .
           "on a Google results page and/or it can carry an agent string that mentions a Google application which can reasonably be assumed to be genuinely Google's. See bottom of page for <a href='#details'>further details</a>." .
           "PERC_GOOGLE\n" ;

  $html .= "<tr><td width=50%>\n" ;

  # SORTED BY FREQUENCY
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In order of request volume</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from a Google ip address</th></tr>\n" ;
# $html .= "<tr><th colspan=99 class=l><small>x 1000</small></th>\n" ;
  my $total_total_direct ;
  my $total_page_direct ;
  my $total_image_direct ;
  my $total_rest_direct ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_count)
  {
    if ($key !~ /Y$/) { next ; } # googleIp
    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,Y"} ;
    $page  = $searches_service_mimecat {"$key2,page,Y"} ;
    $image = $searches_service_mimecat {"$key2,image,Y"} ;
    $rest  = $searches_service_mimecat {"$key2,other,Y"} ;
    $total_total_direct += $total ;
    $total_page_direct  += $page ;
    $total_image_direct += $image ;
    $total_rest_direct  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$key2</a></td><td class=r>$total</td><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_page_all = $total_page_direct ;

  $total_page_requests_external_fmt = &FormatCount ($total_page_requests_external*1000) ;

  $perc_google_direct = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_google_direct = sprintf ("%.1f",100 * $total_page_direct/$total_page_requests_external) ; }
  $total_page_direct_fmt = &FormatCount ($total_page_direct*1000) ;
  $perc_google_msg_direct = "<p>Including all of its different search crawlers and services hosted on its servers, Google itself requested another $total_page_direct_fmt page pages per day, representing $perc_google_direct% of our external page requests.\n" ;

  $total_total_direct = &FormatCount ($total_total_direct) ;
  $total_page_direct  = &FormatCount ($total_page_direct) ;
  $total_image_direct = &FormatCount ($total_image_direct) ;
  $total_rest_direct  = &FormatCount ($total_rest_direct) ;

  $html .= "<tr><th class=l>Total</a></th><th class=r>$total_total_direct</th><th class=r>$total_page_direct</th><th class=r>$total_image_direct</th><th class=r>$total_rest_direct</th></tr>\n" ;

  my $total_total_indirect ;
  my $total_page_indirect ;
  my $total_image_indirect ;
  my $total_rest_indirect ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from elsewhere</th></tr>\n" ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_count)
  {
    if ($key =~ /Y$/) { next ; } # googleIp
    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,N"} ;
    $page  = $searches_service_mimecat {"$key2,page,N"} ;
    $image = $searches_service_mimecat {"$key2,image,N"} ;
    $rest  = $searches_service_mimecat {"$key2,other,N"} ;
    $total_total_indirect += $total ;
    $total_page_indirect  += $page ;
    $total_image_indirect += $image ;
    $total_rest_indirect  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$key2</a></td><td class=r>$total</td><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_page_all += $total_page_indirect ;

  $perc_google_indirect  = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_google_indirect = sprintf ("%.1f",100 * $total_page_indirect/$total_page_requests_external) ; }
  $total_page_indirect_fmt = &FormatCount ($total_page_indirect*1000) ;
  $perc_google_msg_indirect = "<p>Google referred to our sites, through its services including search, maps, and Google Earth, $total_page_indirect_fmt page views per day, representing $perc_google_indirect% of our external page requests.\n" ;

  $total_total_indirect = &FormatCount ($total_total_indirect) ;
  $total_page_indirect  = &FormatCount ($total_page_indirect) ;
  $total_image_indirect = &FormatCount ($total_image_indirect) ;
  $total_rest_indirect  = &FormatCount ($total_rest_indirect) ;

  $html .= "<tr><th class=l>Total</a></th><th class=r>$total_total_indirect</th><th class=r>$total_page_indirect</th><th class=r>$total_image_indirect</th><th class=r>$total_rest_indirect</th></tr>\n" ;
  $html .= "<tr><th class=l colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l><a href='http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains'>Top level domains</a></th></tr>\n" ;

  $total_page_all_fmt = &FormatCount ($total_page_all*1000) ;

  $perc_google = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_google  = sprintf ("%.1f",100 * $total_page_all/$total_page_requests_external) ; }

  $perc_google_msg_all = "<p>In total Google was somehow involved in $perc_google\% of daily external page<sup>*<\/sup> requests \n" ;
  $html =~ s/PERC_GOOGLE/<hr width=90%>$perc_google_msg_all $perc_google_msg_indirect $perc_google_msg_direct<p><small>* = mime type <a href='VisitorsSampledLogRequests.htm'>text\/html<\/a> only<\/small>/ ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $key (@searches_toplevel_count)
  {
    $total = $searches_toplevel_mimecat {"$key,total"} ;
    $page  = $searches_toplevel_mimecat {"$key,page"} ;
    $image = $searches_toplevel_mimecat {"$key,image"} ;
    $rest  = $searches_toplevel_mimecat {"$key,other"} ;
    $total_total += $total ;
    $total_page  += $page ;
    $total_image += $image ;
    $total_rest  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /^[\_\.]/)
    { $key = ".$key" ; }
#   else
#   { $key =~ s/^[\.]// ; }
    if ($key =~ /^\_/)
    { $key = "<i>" . substr ($key,1) . "</i>" ; }
    $html .= "<tr><td class=l>$key</a></td><td class=r>$total</td><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_no_tld = $searches_mimecat_tld_not_found {"total"}  ;
  $page_no_tld  = $searches_mimecat_tld_not_found {"page"}  ;
  $image_no_tld = $searches_mimecat_tld_not_found {"image"}  ;
  $other_no_tld = $searches_mimecat_tld_not_found {"other"}  ;

  $total_total += $total_no_tld ;
  $total_page  += $page_no_tld ;
  $total_image += $image_no_tld ;
  $total_rest  += $other_no_tld ;

  $total_no_tld = &FormatCount ($total_no_tld)  ;
  $page_no_tld  = &FormatCount ($page_no_tld)  ;
  $image_no_tld = &FormatCount ($image_no_tld)  ;
  $other_no_tld = &FormatCount ($other_no_tld)  ;
  $html .= "<tr><td class=l>undefined</a></td><td class=r>$total_no_tld</td><td class=r>$page_no_tld</td><td class=r>$image_no_tld</td><td class=r>$other_no_tld</td></tr>\n" ;

  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>Total</a></th><th class=r>$total_total</th><th class=r>$total_page</th><th class=r>$total_image</th><th class=r>$total_rest</th></tr>\n" ;

  $html .= "</table>\n" ;

  $html .= "</td><td width=50%>\n" ;

  # SORTED BY ALPHABETICALLY
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In alphabetical order</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from a Google ip address</th></tr>\n" ;
# $html .= "<tr><th colspan=99 class=l><small>x 1000</small></th>\n" ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_alpha)
  {
    if ($key !~ /Y$/) { next ; } # googleIp
    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,Y"} ;
    $page  = $searches_service_mimecat {"$key2,page,Y"} ;
    $image = $searches_service_mimecat {"$key2,image,Y"} ;
    $rest  = $searches_service_mimecat {"$key2,other,Y"} ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /(?:undefined|unspecified|crawler|feedfetcher|wireless transcoder)/)
    { $key = ucfirst ($key) ; }
    else
    { $key = "<i>$key</i>" ; }
    $html .= "<tr><td class=l>$key2</a></td><td class=r>$total</td><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $html .= "<tr><th class=l>Total</a></th><th class=r>$total_total_direct</th><th class=r>$total_page_direct</th><th class=r>$total_image_direct</th><th class=r>$total_rest_direct</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from elsewhere</th></tr>\n" ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_alpha)
  {
    if ($key =~ /Y$/) { next ; } # googleIp
    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,N"} ;
    $page  = $searches_service_mimecat {"$key2,page,N"} ;
    $image = $searches_service_mimecat {"$key2,image,N"} ;
    $rest  = $searches_service_mimecat {"$key2,other,N"} ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /(?:undefined|unspecified|crawler|feedfetcher|wireless transcoder)/)
    { $key = ucfirst ($key) ; }
    else
    { $key = "<i>$key</i>" ; }
    $html .= "<tr><td class=l>$key2</a></td><td class=r>$total</td><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $html .= "<tr><th class=l>Total</a></th><th class=r>$total_total_indirect</th><th class=r>$total_page_indirect</th><th class=r>$total_image_indirect</th><th class=r>$total_rest_indirect</th></tr>\n" ;
  $html .= "<tr><th class=l colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Top level domains</th></tr>\n" ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $key (@searches_toplevel_alpha)
  {
    $total = $searches_toplevel_mimecat {"$key,total"} ;
    $page  = $searches_toplevel_mimecat {"$key,page"} ;
    $image = $searches_toplevel_mimecat {"$key,image"} ;
    $rest  = $searches_toplevel_mimecat {"$key,other"} ;
    $total_total += $total ;
    $total_page  += $page ;
    $total_image += $image ;
    $total_rest  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /^[\_\.]/)
    { $key = ".$key" ; }
    if ($key =~ /^\_/)
    { $key = "<i>" . substr ($key,1) . "</i>" ; }
    $html .= "<tr><td class=l>$key</a></td><td class=r>$total</td><td class=r>$page</td><td class=r>$image</td><td class=r>$rest</td></tr>\n" ;
  }
  $total_no_tld = $searches_mimecat_tld_not_found {"total"}  ;
  $page_no_tld  = $searches_mimecat_tld_not_found {"page"}  ;
  $image_no_tld = $searches_mimecat_tld_not_found {"image"}  ;
  $other_no_tld = $searches_mimecat_tld_not_found {"other"}  ;

  $total_total += $total_no_tld ;
  $total_page  += $page_no_tld ;
  $total_image += $image_no_tld ;
  $total_rest  += $other_no_tld ;

  $total_no_tld = &FormatCount ($total_no_tld)  ;
  $page_no_tld  = &FormatCount ($page_no_tld)  ;
  $image_no_tld = &FormatCount ($image_no_tld)  ;
  $other_no_tld = &FormatCount ($other_no_tld)  ;
  $html .= "<tr><td class=l>undefined</a></td><td class=r>$total_no_tld</td><td class=r>$page_no_tld</td><td class=r>$image_no_tld</td><td class=r>$other_no_tld</td></tr>\n" ;

  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>Total</a></th><th class=r>$total_total</th><th class=r>$total_page</th><th class=r>$total_image</th><th class=r>$total_rest</th></tr>\n" ;

  $html .= "</table>\n" ;
  $html .= "</td></tr>\n" ;


  $breakdown = "Here is detailed breakdown per service of indicators that pointed to Google <small>(total &ge; 3)</small><br>&nbsp;<br>" .
               "<table width=100%><tr><th class=l>Service</th><th class=c>Total</th><th class=c>Originating from<br>Google ip address</th><th class=c>Referer mentions<br>Google url</th><th class=c>Agent mentions<br>Google service</th></tr>\n" ;
  foreach $key (@searches_service_matches_alpha)
  {
    $count = $searches_service_matches {$key} ;
    if ($count <= 2) { next ; }
    $count = &FormatCount ($count) ;
    ($service,$matches) = split (',', $key) ;
    if ($matches =~ /x/) { $x = 'Y' } else { $x = '-' } ;
    if ($matches =~ /y/) { $y = 'Y' } else { $y = '-' } ;
    if ($matches =~ /z/) { $z = 'Y' } else { $z = '-' } ;
    $breakdown .= "<tr><td class=l>$service</td><td class=r>$count</td><td class=c>$x</td><td class=c>$y</td><td class=c>$z</td></tr>" ;
  }
  $breakdown .= "</table><br.&bsp;<br>\n" ;


  $html .= "<tr><td class=l colspan=99><a name='details' id='details'></a>&nbsp;<p>" .
  $google_ip_ranges .
  "<b>Agents</b>: as for genuine agent strings: too many crawlers indentify themselves as 'GoogleBot' to take this at face value. " .
  "They are accepted as genuine Google crawler requests only when the ip address matches a known range (see above). " .
  "Other records that mention GoogleBot are counted as GoogleBot? (question mark, as this may include partners, like DoCoMo). " .
  "However when the agent string mentions Google Desktop or Google Earth this is always accepted" .
  "<p><b>Service</b>: the service name is based on the agent string (plus for GoogleBot check for ip address, see above), if this is inconclusive it is based on the referer string." .
  "<p>$breakdown" .
  "<p><b>Top Level Domain 'undefined'</b>: requests with top level domain 'undefined' are nearly all requests from anonymous ip addresses (crawler and other services)" .
  "<p><b>Note</b>: averages below 1 are always rounded up to 1\n" .
  "</small></td></tr>\n";

  $html .= "</table>\n" ;

  $html .= $colophon ;

  print FILE_HTML_SEARCH $html ;
  close FILE_HTML_SEARCH ;
}

sub WriteReportSkins
{
  open FILE_HTML_SKINS, '>', "$dir_reports/$file_html_skins" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Visitor Log Analysis Report - Skins/ ;
  $html =~ s/HEADER/Wikimedia Visitor Log Analysis Report - Skins/ ;
  $html =~ s/LINKS/$link_requests $link_origins \/ $link_methods \/ $link_scripts \/ $dummy_skins \/ $link_crawlers \/ $link_opsys \/ $link_browsers \/ $link_google/ ;
  $html =~ s/NOTES// ;

  $html .= "<table border=1>\n" ;

  $html .= "<tr><td colspan=99 class=l><b>Skin</b><br>Files (&ge; 3)</td></tr>\n" ;
  $rows = 0 ;
  $nameprev = "" ;
  foreach $skin (@skins_sorted_skin)
  {
    $count = &FormatCount ($skins {$skin}) ;
    if ($count < 3) { next ; }
    $skin =~ s/^skins\/// ;
    ($name,$rest) = split ('\/', $skin, 2) ;
    if ($skin_set {$name} < 3) { next ; }
    if ($name ne $nameprev)
    { $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>" . ucfirst ($name) . "</b></th></tr>\n" ; }
    $nameprev = $name ;
    $html .= "<tr><td class=l>$skin</td><td class=r>$count</td></tr>\n" ;
    $rows++ ;
  }
  $html .= "</table>\n" ;

  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon ;

  print FILE_HTML_SKINS $html ;
  close FILE_HTML_SKINS ;
}

  $html .= "</td></tr></table>\n" ;
# $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon ;

  print FILE_HTML_ORIGINS $html ;
  close FILE_HTML_ORIGINS ;
}

sub WriteCsvGoogleBots
{
  open CSV_GOOGLE_BOTS_OUT, '>', "$dir_reports/$file_csv_google_bots" ;
  print CSV_GOOGLE_BOTS_OUT "Date Time,Ip Range,Hits\n" ;
  foreach $dir_process (@dirs_process)
  {
    open CSV_GOOGLE_BOTS_IN, '<', "$dir_process/$file_csv_google_bots" ;
    while ($line = <CSV_GOOGLE_BOTS_IN>)
    {
      if ($line =~ /^#/) { next ; }
      if ($line =~ /^:/) { next ; }
      chomp $line ;
      ($datetime,$range,$hits) = split (',', $line) ;
      ($date,$time) = split (' ', $datetime) ;
      ($year,$month,$day) = split ('\/', $date) ;
      $hour = substr ($time,0,2) ;
      $datetime = "\"=DATE($year,$month,$day)+TIME($hour,0,0)\"" ;
      print CSV_GOOGLE_BOTS_OUT "$datetime,$hits,$range\n" ;
      $googlebots {$datetime} += $hits ;
    }
    close CSV_GOOGLE_BOTS_IN ;
  }
  foreach $datetime (sort keys %googlebots)
  { print CSV_GOOGLE_BOTS_OUT "$datetime,${googlebots{$datetime}},*\n" ; }
  close CSV_GOOGLE_BOTS_OUT ;
}

sub FormatCount
{
  my $count = shift ;
  if ($count eq "")
  { return ("&nbsp;") ; }
  if ($count < 1)
  { return ("1") ; }
  $count =~ s/^(\d{1,3})(\d\d\d)$/$1,$2/ ;
  $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
  $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)(\d\d\d)$/$1,$2,$3,$4/ ;
  return ($count) ;
}

sub GetDateTimeEnglishShort
{
  my @weekdays_en = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
  my @months_en   = qw (January February March April May June July
                        August September October November December);
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  return (substr ($weekdays_en[$wday],0,3) . ", " .
          substr ($months_en[$mon],0,3) . " " .
          $mday . ", " .
          (1900 + $year) .
          " " . sprintf ("%2d:%02d", $hour, $min)) ;
}

sub SortMime
{
  my $mime = shift ;
  if ($mime eq "text/html")
  { return (2000000000 + $mimetypes {$mime}) ; }
  elsif ($mime =~ /image\/(?:png|jpeg|gif)/)
  { return (1000000000 + $mimetypes {$mime}) ; }
  else
  { return ($mimetypes {$mime}) ; }
}

sub ExpandAbbreviation
{
  my $text = shift ;
  # reverse (more or less) abbreviations
  $text =~ s/^[\@\*]// ;
  $text =~ s/^xx:upload/upload:&nbsp;/;
  $text =~ s/^wb:/wikibooks:/;
  $text =~ s/^wk:/wiktionary:/;
  $text =~ s/^wn:/wikinews:/;
  $text =~ s/^wp:/wikipedia:/;
  $text =~ s/^wq:/wikiquote:/;
  $text =~ s/^ws:/wikisource:/;
  $text =~ s/^wv:/wikiversity:/;
  $text =~ s/^wx:/wikispecial:/;
  $text =~ s/^mw:/wikispecial:/; # eg bugzilla
  $text =~ s/:!mw/:mediawiki/;
  $text =~ s/^wm:/wikimedia:/;
  $text =~ s/:wm$/:wikimedia/;
  $text =~ s/^wmf:/foundation:/;
  $text =~ s/:www$/:portal/;
# $text =~ s/^wikispecial:(.*)$/$1:&nbsp;/;
  return ($text) ;
}

sub GetSecondaryDomain
{
  $pattern_url_post = "\\.(?:biz|com|info|name|net|org|pro|aero|asia|cat|coop|edu|gov|int|jobs|mil|mobi|museum|tel|travel|arpa|[a-zA-Z0-9-]{2}|(?:com?|ne)\\.[a-zA-Z0-9-]{2})\$" ;

  my $domain = shift ;
  $domain =~ s/http:\/\/// ;
  $domain =~ s/\/.*$// ;

  if ($domain !~ /\./)
  { return ($domain) ; }

  $domain =~ s/$pattern_url_post// ;
  $domain =~ s/^.*?\.([^\.]+)$/$1/ ;
  return ($domain) ;
}

sub OpenLog
{
# only shrink log when same log file is appended daily, is no longer the case
# $fileage  = -M "$dir_reports/$file_log" ;
# if ($fileage > 5)
# {
#   open "FILE_LOG", "<", "$dir_reports/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
#   @log = <FILE_LOG> ;
#   close "FILE_LOG" ;
#   $lines = 0 ;
#   open "FILE_LOG", ">", "$dir_reports/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
#   foreach $line (@log)
#   {
#     if (++$lines >= $#log - 5000)
#     { print FILE_LOG $line ; }
#   }
#   close "FILE_LOG" ;
# }
# open "FILE_LOG", ">>", "$dir_reports/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
  open "FILE_LOG", ">>", "$dir_reports/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
  &Log ("\n\n===== Wikimedia Sampled Visitors Log Report / " . &GetDateTimeEnglishShort (time) . " =====\n\n") ;
}

sub Normalize
{
  my $count = shift ;
  $count *= $multiplier ;
# if ($count < 1) { $count = 1 ; } -> do this at FormatCount
  return (sprintf ("%.0f", $count)) ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}

sub Abort
{
  $msg = shift ;
  &Log ("Abort program\nReason: '$msg'\n") ;
  exit ;
}



