#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (4) ;

# add: counts jobs per day
# run Wikinews
# schedule progress report
# exclude underlined wikis
# check red non wikipedia wikis
# reports generated -> July ??

  use CGI qw(:all);
  use Time::Local ;
  use Getopt::Std ;
  use Cwd ;

  $timestart = time ;
  $false     = 0 ;
  $true      = 1 ;

  $out_billion  = 'B' ;
  $out_million  = 'M' ;
  $out_thousand = 'k' ;

  $Kb        = 1024 ;
  $Mb        = $Kb * $Kb ;
  $Gb        = $Kb * $Kb * $Kb ;

  $| = 1; # flush screen output

  $out_myname = "Erik Zachte" ;
  $out_mymail = "ezachte@###.org (no spam: ### = wikimedia)" ;
  $out_mysite = "http://infodisiac.com/" ;

# hard coded paths, yes I know :)
  $dir_in      = "W:/# Out Bayes" ;
  $dir_html    = "W:/# Out Test/htdocs/EN" ;
  $dir_csv     = "W:/# Out Bayes/" ;
  $dir_lists   = "W:/# Out Bayes/dblists" ;
  $file_html   = "$dir_html/WikiCountsJobProgress.html" ;
  $file_html_c = "$dir_html/WikiCountsJobProgressCurrent.html" ;
  $file_html_r = "$dir_html/WikiCountsJobRunTimes.html" ;
  $file_log    = "WikiCountsLogConcise.txt" ;

  if (-d "/mnt/htdocs")
  {
    print "Job runs on bayes\n" ;
    $dir_in            = "/a/wikistats" ;
    $dir_html          = "/mnt/htdocs" ;
    $dir_csv           = "/a/wikistats/" ;
    $dir_lists         = "/home/ezachte/wikistats/dblists" ;
    $dir_projectcounts = "/a/dammit.lt/projectcounts" ;
    $dir_pagecounts    = "/a/dammit.lt/pagecounts" ;
    $file_html         = "/mnt/htdocs/WikiCountsJobProgress.html" ;
    $file_html_c       = "/mnt/htdocs/WikiCountsJobProgressCurrent.html" ;
    $file_html_r       = "/mnt/htdocs/WikiCountsJobRunTimes.html" ;
    $file_log          = "/home/ezachte/wikistats/WikiCountsLogConcise.txt" ;

    &ReadWikiCountsThresholdEditsOnly ;
    &ReadDammitStats ;
  }

  ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst)=localtime(time);
  $year  = $year  + 1900 ;
  $month = $month + 1 ;

  @months = qw(Xxx Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec) ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ; # previous month is last month for which wikistats could gather data
  $yyyymm_dump = sprintf ("%04d%02d%02d", $year, $month, days_in_month($year,$month)) ;
  $month_minus_1 = $months [$month] . " "  . $year ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ;
  $month_minus_2 = $months [$month] . " "  . $year ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ;
  $month_minus_3 = $months [$month] . " "  . $year ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ;
  $month_minus_4 = $months [$month] . " "  . $year ;

  if (-e $file_log)
  {
    open LOG, '<', $file_log ;
    while ($line = <LOG>)
    {
      if (($line =~ / w.: /) || ($line =~ /suspended/))
      { undef @log ; undef @log2 ; $log_header = $line ; }
      else
      {
        if (($line !~ /^\s*$/) && ($line !~ / 0 min, \d sec/)) # '0 min, 0 sec' means job is skipped
        {
          push @log, $line ;
          unshift @log2, $line ;
        }
      }
    }
    close LOG ;
  }

  &ReadJobHistory ($dir_csv, "wb") ;
  &ReadJobHistory ($dir_csv, "wk") ;
  &ReadJobHistory ($dir_csv, "wn") ;
  &ReadJobHistory ($dir_csv, "wp") ;
  &ReadJobHistory ($dir_csv, "wq") ;
  &ReadJobHistory ($dir_csv, "ws") ;
  &ReadJobHistory ($dir_csv, "wv") ;
  &ReadJobHistory ($dir_csv, "wxp") ;

  $projects {"wb"} = "Wikibooks" ;
  $projects {"wk"} = "Wiktionary" ;
  $projects {"wn"} = "Wikinews" ;
  $projects {"wp"} = "Wikipedia" ;
  $projects {"wq"} = "Wikiquote" ;
  $projects {"ws"} = "Wikisource";
  $projects {"wv"} = "Wikiversity" ;
  $projects {"wx"} = "Wikispecial" ;

  &ReadStatsCsv ("wb") ;
  &ReadStatsCsv ("wk") ;
  &ReadStatsCsv ("wn") ;
  &ReadStatsCsv ("wp") ;
  &ReadStatsCsv ("wq") ;
  &ReadStatsCsv ("ws") ;
  &ReadStatsCsv ("wv") ;
  &ReadStatsCsv ("wx") ;

  &ReadStatsHtml ($dir_html,"") ;
  &ReadStatsHtml ($dir_html,"wikibooks") ;
  &ReadStatsHtml ($dir_html,"wiktionary") ;
  &ReadStatsHtml ($dir_html,"wikinews") ;
  &ReadStatsHtml ($dir_html,"wikiquote") ;
  &ReadStatsHtml ($dir_html,"wikisource") ;
  &ReadStatsHtml ($dir_html,"wikiversity") ;
  &ReadStatsHtml ($dir_html,"wikispecial") ;

  &ReadStatsDblist ($dir_lists,"wikibooks") ;
  &ReadStatsDblist ($dir_lists,"wiktionary") ;
  &ReadStatsDblist ($dir_lists,"wikinews") ;
  &ReadStatsDblist ($dir_lists,"wikipedia") ;
  &ReadStatsDblist ($dir_lists,"wikiquote") ;
  &ReadStatsDblist ($dir_lists,"wikisource") ;
  &ReadStatsDblist ($dir_lists,"wikiversity") ;
  &ReadStatsDblist ($dir_lists,"special") ;

  $colorsused = "<a name='legend' id='legend'></a>" .
                "<hr><b>Legend</b><small>\n" .
                "<br><font color=#000000>xx<sup>n</sup></font>: Data gathering job for language xx finished n days ago\n" .
              # "<br><font color=#008000>xx<sup>n</sup></font>: n &lt; 14 days\n" .
              # "<br><font color=#000060>xx<sup>n</sup></font>:  14 days &le; n &lt; 30 days\n" .
              # "<br><font color=#C08000>xx<sup>n</sup></font>: 30 days &le; n &lt; 60 days\n" .
              # "<br><font color=#800000>xx<sup>n</sup></font>: n &ge; 60 days\n" .
                "<br><font color=#008000>xx<sup>n</sup></font>: last month processed: $month_minus_1\n" .
                "<br><font color=#000060>xx<sup>n</sup></font>: last month processed: $month_minus_2\n" .
                "<br><font color=#C08000>xx<sup>n</sup></font>: last month processed: $month_minus_3\n" .
                "<br><font color=#800000>xx<sup>n</sup></font>: last month processed: $month_minus_4 or older\n" .
                "<br><font color=#808080>xx<sup>n</sup></font>: wiki is closed\n" .
                "<br>Bold text: job took an hour or more</small>\n" ;
  &WriteHtml ;
  &WriteHtmlCurrent ;
  &WriteHtmlJobRunTimes ;

  print "Ready in " . (time - $timestart) . " sec\n" ;
  exit;

sub ReadJobHistory
{
  my $dir_in  = shift ;
  my $project = shift ;

  my $file = "$dir_in/csv_$project/StatisticsLogRunTime.csv" ;
  print "$file\n" ;
  open IN, '<', $file || die ("File not found: $file\n") ;

  while ($line = <IN>)
  {
     chomp $line ;
     ($wp, $dumpdate, $time, $time_english, $format, $file_size_compressed, $file_size_uncompressed, $host_name, $time_parse, $time_total, $edits_ns0, $edits_nsx, $mode) = split (',' , $line) ;

     next if $wp eq 'commons' and $project ne 'wx' ;
     next if $wp eq 'language' ;

     $wp = "$project:$wp" ;
     $wp =~ s/ //g ;
     # find last instance per project (, file format)
     $file_sizes_compressed   {$wp} {$format} = $file_size_compressed ;
     $file_sizes_uncompressed {$wp} {$format} = $file_size_uncompressed ;
     $compress_ratio = 'n.a.' ;
     if ($file_size_compressed > 0)
     { $compress_ratio = sprintf ("%.0f", $file_size_uncompressed / $file_size_compressed) ; }
     $compress_ratios {$wp} {$format} = $compress_ratio ;
     $edits_articles  {$wp} = $edits_ns0 ;
     $edits_other     {$wp} = $edits_nsx ;

     $times_total {$wp} {$format} = $time_total ;
     $sec = $time_total ;
     if ($sec < 60)
     { $jobtime = "$sec s" ; }
     else
     {
       $hrs = int ($sec / 3600) ;
       $min = int (($sec - $hrs * 3600) / 60) ;
       if ($hrs > 0)
       { $jobtime = sprintf ("%d h, %02d m", $hrs, $min) ; }
       else
       { $jobtime = "$min m" ; }
     }
     if ($edits_ns0+$edits_nsx == 0)
     { $perc_ns0 {$wp} = 'n.a.' ; }
     else
     { $perc_ns0 {$wp} = sprintf ("%.0f", 100 * ($edits_ns0 / ($edits_ns0+$edits_nsx))) . '%' ; }
     $times_total_dhm {$wp} {$format} = $jobtime ;

     $backlog {$wp} = ($dumpdate lt $yyyymm_dump) ;
  }

  foreach $wp (sort keys %backlog)
  {
    next if $wp !~ /$project/ ;
    next if ! $backlog {$wp} ;
    if ($edits_articles  {$wp} > $threshold_edits_only)
    {
      $job_togo += $times_total {$wp} {'gz'} ;
      # print "gz $wp ${times_total {$wp} {'gz'}} = $job_togo\n" ;
    }
    else
    {
      $job_togo += $times_total {$wp} {'7z'} ;
      # print "7z $wp ${times_total {$wp} {'7z'}} = $job_togo\n" ;
    }
  }
}

sub ReadDammitStats
{
  $files_projectcounts     = `ls $dir_projectcounts | wc -l` ;
  $files_pagecounts        = `ls $dir_pagecounts    | wc -l` ;
  $file_new_projectcounts  = `ls -1 -r $dir_projectcounts | grep projectcounts | head -1` ; # =~ s/^.*?(projectcounts.{38,38}).*$/$1/s ;
  $file_new_pagecounts     = `ls -1 -r $dir_pagecounts    | grep pagecounts.*gz | head -1` ; #  =~ s/^.*?(pagecounts{38,38}).*$/$1/s;
  chomp $file_new_projectcounts ;
  chomp $file_new_pagecounts ;
}

sub ReadStatsCsv
{
  my $project = shift ;
  my $file = "$dir_in/csv_$project/StatisticsLog.csv" ;
  open IN, '<', $file ;

  ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst)=localtime(time);
  ($year,$month) = ($month > 0) ? ($year,$month-1) : ($year-1, 11) ; # previous month is last month for which wikistats could gather data
  $yy0 = $year + 1900 ;
  $mm0 = $month + 1 ;

  $lines = 0 ;
  while ($line = <IN>)
  {
    if ($line !~ /.*,.*,.*,.*,.*,/)
    { next ; }
    $lines++ ;

    ($language, $contentdate, $rundate, $runlength) = split (',', $line) ;

    if ($language =~ /^tlh/) # obsolete, Klignon project abandoned
    { next ; }

    $yy = substr ($contentdate,0,4) ;
    $mm = substr ($contentdate,4,2) ;
    $dd = substr ($contentdate,6,2) ;
    $days2 = int (($timestart - timelocal (0,0,0,$dd,$mm-1,$yy-1900)) / (24 * 60 * 60)) ;
    $months2 = 12 * ($yy0 - $yy) + $mm0 - $mm ;

    $yy = substr ($rundate,6,4) ;
    $mm = substr ($rundate,0,2) ;
    $dd = substr ($rundate,3,2) ;
    $days1 = int (($timestart - timelocal (0,0,0,$dd,$mm-1,$yy-1900)) / (24 * 60 * 60)) ;
    $rundate2 = "$yy$mm$dd" ;

    $runlength =~ s/&#44;//g ;

    if ($runlength =~ /days.*?hrs.*?min.*?sec/)
    { $runlength =~ s/(\d+) days (\d+) hrs (\d+) min (\d+) sec/$seconds = ($1*24*3600)+($2*3600)+($3*60)+$4/e ; }
    elsif ($runlength =~ /hrs.*min.*sec/)
    { $runlength =~ s/(\d+) hrs (\d+) min (\d+) sec/$seconds = ($1*3600)+($2*60)+$3/e ; }
    elsif ($runlength =~ /min.*sec/)
    { $runlength =~ s/(\d+) min (\d+) sec/$seconds = ($1*60)+$2/e ; }

    # $runlength2 = sprintf ("%07d", 9999999 - $runlength) ;
    # print "$project, $language, $days1, $days2, $minutes\n" ;
    if ($project eq "wx")
    { if ($language !~ /^species|commons|nostalgia|incubator|meta|sources|foundation|mediawiki|sep11|strategy$/) { next ; } }

    if ($rundate2 gt $rundatemax)
    {
      $rundatemax = $rundate2 ;
      $activeproject = $project ;
    }
    $run = "$project,$language" ;
    $data_age {$run} = $days1 ;
    $months_age {$run} = $months2 ;
    $run_age  {$run} = $days2 ;
    $runtimes {$run} = $seconds ;
    $runlengths {$run} = $runlength ;
#   $runtimes2 {"$project,$rundate2,$runlength2,$language"} = $seconds ;
    $runtimes2 {"$project,$rundate2,$language"} = $seconds ;
    $runtime_total  += $seconds ;
    $runtime_project {$project} += $seconds ;
  }
  print "Read $file -> $lines lines\n" ;
  close IN ;
}

sub ReadStatsHtml
{
  my $dir     = shift ;
  my $project = shift ;

  $dir = "$dir/$project" ;
  my $lastdir = getcwd();
  chdir ($dir) || die "Cannot chdir to $dir\n";
  local (*DIR);
  opendir (DIR, ".");
  undef %languages ;
  while (my $file = readdir (DIR))
  {
    if (! -d $file)
    { next ; }
    if ($file !~ /^[A-Z]+$/)
    { next ; }
    push @languages, $file ;
  }
  closedir DIR;

  foreach $language (sort @languages)
  {
    $file_age  = int (-M "$dir/$language/index.html") ;
    $file_date = time - int (24*60*60*(-M "$dir/$language/index.html")) ;
    if ($language eq "EN")
    {
      if ($project eq "")
      { $project = "wikipedia" ; }
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($file_date);
      my $now_gm = sprintf ("%02d-%02d-%04d %02d:%02d\n",$mday,$mon+1,$year+1900,$hour,$min) ;
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($file_date);
      my $now = sprintf ("%02d-%02d-%04d %02d:%02d\n",$mday,$mon+1,$year+1900,$hour,$min) ;
      $project2 = ucfirst ($project) ;
      $reports      {$project} = "<tr><td><small>$project2</small></td><td><small>$now EST</small></td><td><small>=</small></td><td><small>$now_gm GMT</small></td></tr>" ;
      $report_dates {$project} = $file_date ;
      $reports_total ++ ;
    }
  }
  chdir ($lastdir) ;
}

sub ReadStatsDblist
{
 my $dir     = shift ;
 my $project = shift ;

 if (! -d $dir)
 { print "Dir $dir not found\n" ; return ; }
 if (! -e "$dir/$project.dblist")
 { print "File $dir/$project.dblist not found\n" ; }

 if (-e "$dir/$project.dblist_full")
 { $file_dblist = "$dir/$project.dblist_full" ; }
 else
 { $file_dblist = "$dir/$project.dblist" ; }

 print "Process list $file_dblist\n" ;
 open DBLIST, '<', "$file_dblist" ;

 while ($wiki = <DBLIST>)
 {
   $wiki =~ s/\s*//g ;
   chomp ($wiki) ;
   if ($wiki !~ /wik/) { next ; }

   if ($wiki =~ /wikiwiki/)
   { $wiki =~ s/wikiwiki/wiki/ ; }
   else
   { $wiki =~ s/wik.*$// ; }

   $project =~ s/wikibooks/wb/ ;
   $project =~ s/wiktionary/wk/ ;
   $project =~ s/wikinews/wn/ ;
   $project =~ s/wikipedia/wp/ ;
   $project =~ s/wikiquote/wq/ ;
   $project =~ s/wikisource/ws/ ;
   $project =~ s/wikiversity/wv/ ;
   $project =~ s/wikispecial/wx/ ;

   if ($wiki =~ /^species|commons|nostalgia|incubator|meta|sources|foundation|mediawiki|sep11$/)
   { $project = "wx" ; }

   @dblists {"$project,$wiki"} = $true ;
 }
 close DBLIST ;
}

sub WriteHtml
{
  open HTML, '>', $file_html ;
  print HTML "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN" .
             "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n" .
             "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n" .
             "<head>\n" .
             "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>\n" .
             "<meta http-equiv=\"refresh\" content=\"60\">\n" .
             "<title>WikiStats data gathering progress</title>\n" .
             # "<style type=\text/css\">\n" .
             # "li    { background-color: #f4f4f4; list-style-type: none; }\n" .
             # "li li { background-color: white; }\n" .
             # "li ul { margin-top: 4px; margin-bottom: 8px; text-color: #900000}\n" .
             # "</style>\n" .
             "<body bgcolor=#CCCCCC>\n" ;

  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime(time);
  $now_gm = sprintf ("%02d-%02d-%04d %02d:%02d\n",$mday,$mon+1,$year+1900,$hour,$min) ;
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  $now = sprintf ("%02d-%02d-%04d %02d:%02d\n",$mday,$mon+1,$year+1900,$hour,$min) ;

  print HTML "<h3><a href='http://stats.wikimedia.org/'>WikiStats</a> data gathering progress</h3>\n" .
             "See <a href='#explanation'>explanation<\/a> and <a href='#legend'>legend<\/a> below<\/small>\n" ;

  foreach $run (sort keys %runtimes)
  {
    ($project,$language) = split (',',$run) ;

    if (! @dblists {"$project,$language"})
    { next ; }

    if ($project ne $project_prev)
    {
      if ($project_prev ne "")
      {
        $html =~ s/,\s*$// ;
        $project2 = $projects {$project_prev} ;
        if ($project_prev eq $activeproject)
        { $project2 = "<u>$project2</u>" ; }
        print HTML "<p><b>$project2</b> <small>[$languages] $html</small>\n" ;
        $html = "" ;
        $languages = 0 ;
      }
    }
    $languages++ ;

    $days = $data_age {$run} ;
#   $rgb = "#FF0000" ;
#   if ($language eq "sep11")
#   { $rgb = "#808080" ; }
#   elsif ($days > 60)
#   { $rgb = "#800000" ; }
#   elsif ($days > 30)
#   { $rgb = "#C08000" ; }
#   elsif ($days < 14)
#   { $rgb = "#008000" ; }
#   else
#   { $rgb = "#000060" ; }

    $months = $months_age {$run} ;
    $rgb = "#FF0000" ;
    if ($language eq "sep11")
    { $rgb = "#808080" ; }
    elsif ($months >= 3)
    { $rgb = "#800000" ; }
    elsif ($months == 2)
    { $rgb = "#C08000" ; }
    elsif ($months == 1)
    { $rgb = "#000060" ; }
    elsif ($months == 0) # wikistats up to date, contains data up to previous month
    { $rgb = "#008000" ; }

    $runtime = int ($runtimes {$run} / 60) ;

    if (! @dblists {"$project,$language"})
    # { $language = "<u>$language</u>" ; }
    { next ; }

    if ($runtime >= 60)
    { $language = "<b>$language</b>" ; }

    $html .= "<font color=$rgb>$language<sup>$days</sup></font>, " ;
    $project_prev = $project ;
  }

  $html =~ s/,\s*$// ;
  $project2 = $projects {$project_prev} ;
  if ($project_prev eq $activeproject)
  { $project2 = "<u>$project2</u>" ; }
  print HTML "<p><b>$project2</b> <small>[$languages] $html</small>\n" ;

  print HTML "<p><a name='explanation' id='explanation'></a><b>Explanation</b><small>\n" .
             "The number behind each language code shows how many days ago the processing of the full archive dump for that language has been completed." .
             "This data gathering is only the first step in the wikistats job. Production of reports (tables, bar charts and plots) in over 25 languages is scheduled weekly, " .
             "so it could take one more week before the new data are presented online.<p>\n" .
             "Please be aware that data are only gathered for months up to but not including the month in which the data gathering job was run. " .
             "For the largest wikis the dump process can take days or even weeks. Therefore data gathering for the current month would produce unbalanced results.<p>\n" .
             "Underlined project name is for the project that was most recently updated (may still be running)\n" .
             "<p>See also the <a href='http://www.infodisiac.com/cgi-bin/WikimediaDownload.pl'>database dump service progress report</a></small>\n" ;

  print HTML $colorsused ;

  if ($reports_total > 0)
  {
    print HTML "<a name='reports' id='reports'></a>" .
               "<hr><b>Reports generated</b>\n" .
               "<table>\n";
    foreach $report (sort {$report_dates {$b} <=> $report_dates {$a}} keys %report_dates)
    { print HTML $reports {$report} . "\n" ; }
    print HTML "</table>\n</small>\n" ;
  }


  print HTML "<hr><p><b>Longest jobs</b> <small>\n" ;
  $html = "<table border=1 spacing=0><tr><td valign=top><table>\n" ;
  $jobs = 0 ;
  foreach $run (sort {$runtimes {$b} <=> $runtimes {$a}} keys %runtimes)
  {
    $runtime = int ($runtimes {$run} / 60) ;
    if ($runtime < 60) { last ; }

    ($project,$language) = split (',',$run) ;
    if ($runtime >= 1440)
    { $runtime = int ($runtime/1440) .' days ' . sprintf ("%.0f", ($runtime%1440)/60) . ' hrs' ; }
    elsif ($runtime >= 120)
    { $runtime = sprintf ("%.0f", ($runtime%1440)/60) . ' hrs' ; }
    else
    { $runtime = "$runtime min" ; }

    if (($jobs > 0) && ($jobs % 10 == 0))
    { $html .= "</table></td><td valign=top><table>" ; }
    $jobs++ ;

    if ($project eq "wp")
#   { $html .= "<b>$language</b> $runtime, " ; }
    { $html .= "<tr><td><small><b>$language</b></small>&nbsp;</td><td align=right><small>$runtime</small></td></tr>" ; }
    else
#   { $html .= "<b>$project\:$language</b> $runtime, " ; }
    { $html .= "<tr><td><small><b>$project\:$language</b>&nbsp;</small></td><td align=right><small>$runtime</small></td></tr>" ; }
  }
  $html .= "</table></td></tr></table>\n" ;
  $html =~ s/,\s*$// ;

  $html .= "<p>Project is Wikipedia unless noted otherwise:<br>wb=Wikibooks, wk=Wiktionary, wq=Wikiquote, ws=Wikisource, wv=Wikiversity, wx=Wikispecial" ; # <br>d=days, h=hours, m=minutes" ;

  $html .= "<p><h3>Total job length per project</h3>" ;
  $html .= "<table>\n" ;
  foreach $project (sort keys %runtime_project)
  { $html .= "<tr><td align><small>${projects {$project}}&nbsp;&nbsp;</small></td><td align=right><small>" . &DHM($runtime_project {$project}) . "</small></td></tr>\n" ; }
  $html .= "<tr><td align><small>Total&nbsp;&nbsp;</small></td><td align=right><small>" . &DHM($runtime_total) . "</small></td></tr>\n" ;

  $html .= "</table>\n" ;

  print HTML $html ;

#  if (-e $file_log)
#  {
#    print HTML "<hr><p><b>Current/Last job</b><br><small><pre>\n" ;
#    print HTML "$log_header\n" ;
#    foreach $line (@log)
#    {
#      chomp $line ;
#      print HTML "$line\n" ;
#    }
#    print HTML "</pre></small>" ;
#  }

  print HTML "<small><hr><p>Author: Erik Zachte (<a href='http://infodisiac.com'>Web site</a>)<br>\n" .
             "Mail: ezachte@### (no spam: ### = wikimedia.org)<p></small>\n".
             "<small>Page generated: $now PST = $now_gm GMT<br>\n" ;

  print HTML "</body>\n</html>\n" ;
  close HTML ;
}

sub WriteHtmlCurrent
{
  @free = `df -H /dev/sda1 /dev/sda6 /mnt/dumps` ;
  chomp $free [3] ;
  $free [3] .= $free [4] ;
  $free [4] = "" ;
  foreach $line (@free)
  {
    if ($line eq "") { next ; }
    $line =~ s/\s+/\t/g ;
    $line .= "\n" ;
    $line =~ s/\d+\.\d+\.\d+\.\d+\:// ;
    push @lines, $line ;
  }

  push @lines, "\n" ;
  @used = `du --si /home/ezachte/wikistats /a/tmp/wikistats --si` ;
  foreach $line (@used)
  {
    if ($line =~ /\d[MG]/)
    { push @lines, $line ; }
  }

  @used = `du --si /a | grep [0-9]G` ;
  foreach $line (@used)
  {
    if ($line =~ /\d[MG]/)
    { push @lines, $line ; }
  }

  open HTML, '>', $file_html_c ;
  print HTML "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN" .
             "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n" .
             "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n" .
             "<head>\n" .
             "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>\n" .
             "<meta http-equiv=\"refresh\" content=\"60\">\n" .
             "<title>WikiStats data gathering progress current job</title>\n" .

             "<style type='text/css'>\n" .
             "<!--\n" .
             "td      {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px}\n" .
             "th      {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px}\n" .
             "td.c    {text-align:center }\n" .
             "td.l    {text-align:left;}\n" .
             "th.cb   {text-align:center; border: inset 1px #FFFFFF}\n" .
             "th.lb   {text-align:left;   border: inset 1px #FFFFFF}\n" .
             "th.rb   {text-align:right;  border: inset 1px #FFFFFF}\n" .
             "td.cb   {text-align:center; border: inset 1px #FFFFFF}\n" .
             "td.lb   {text-align:left;   border: inset 1px #FFFFFF}\n" .
             "td.rb   {text-align:right;  border: inset 1px #FFFFFF}\n" .
             "-->\n" .
             "</style>\n" .

             "<body bgcolor=#CCCCCC>\n" ;
  print HTML "<h3>Cached files from <a href='http://dammit.lt/wikistats'>http://dammit.lt/wikistats</a></h3>\n" ;
  print HTML "<p><small><pre>\n" ;
  print HTML "../projectcounts: " . sprintf ("%4d", $files_projectcounts) . " files, newest file $file_new_projectcounts\n" ;
  print HTML "../pagecounts:    " . sprintf ("%4d", $files_pagecounts)    . " files, newest file $file_new_pagecounts\n" ;
  print HTML "</pre></small>\n" ;
  print HTML "<h3>Resources</h3>\n<pre>@lines</pre>\n" ;
  print HTML "<h3>WikiStats data gathering progress for current/last job</h3><p><small><pre>\n" ;
  print HTML "$log_header\n" ;

  foreach $line (@log2)
  {
    chomp $line ;
    print HTML "$line\n" ;
  }

  print HTML "</pre></small>" ;

  print HTML "<hr><p><h3>Progress per project</h3>" ;
  $html = "" ;
  $project_prev = "" ;
  foreach $run (sort keys %runtimes2)
  {
#   ($project,$rundate,$runlength,$language) = split (',',$run) ;
    ($project,$rundate,$language) = split (',',$run) ;
    $run = "$project,$language" ;

    if (! @dblists {"$project,$language"})
    { next ; }

    if ($project ne $project_prev)
    {
      if ($project_prev ne "")
      {
        $html =~ s/,\s*$// ;
        $project2 = $projects {$project_prev} ;
        if ($project_prev eq $activeproject)
        { $project2 = "<u>$project2</u>" ; }
        print HTML "<p><b>$project2</b> <small>[$languages] $html</small>\n" ;
        $html = "" ;
        $languages = 0 ;
      }
    }
    $languages++ ;

    $days   = $data_age {$run} ;
    $months = $months_age {$run} ;

    $rgb = "#FF0000" ;
    if ($language eq "sep11")
    { $rgb = "#808080" ; }
    elsif ($months >= 3)
    { $rgb = "#800000" ; }
    elsif ($months == 2)
    { $rgb = "#C08000" ; }
    elsif ($months == 1)
    { $rgb = "#000060" ; }
    elsif ($months == 0) # wikistats up to date, contains data up to previous month
    { $rgb = "#008000" ; }

    $runtime = int ($runtimes {$run} / 60) ;
    $runlength = int ($runlengths {$run} / 60) ; # eun  length in minutes
    if ($runlength < 10)
    { $runlength = "" ; }
    else
    {
      if ($runlength >= 60)
      { $runlength = sprintf ("%d:%02d", int ($runlength/60), $runlength % 60) ; }
      $runlength = " [$runlength]" ;
    }

    if (! @dblists {"$project,$language"})
    # { $language = "<u>$language</u>" ; }
    { next ; }

    $run_info_key = "$project:$language" ;

    if ($runtime >= 60)
    { $language = "<b>$language</b>" ; }

    $runinfo {$run_info_key} = "<font color=$rgb>$language<sup>" . $data_age {$run} . "$runlength</sup></font>" ;

    $html .= "<font color=$rgb>$language<sup>" . $data_age {$run} . "$runlength</sup></font>, " ;
    $project_prev = $project ;
  }

  $html =~ s/,\s*$// ;
  $project2 = $projects {$project_prev} ;
  if ($project_prev eq $activeproject)
  { $project2 = "<u>$project2</u>" ; }
  print HTML "<p><b>$project2</b> <small>[$languages] $html</small>\n" ;

  print HTML "<hr>" ;
  &WriteHtmlJobRunTimes ;

  print HTML $colorsused ;
  print HTML "<small><p>xx<sup>y [z]</sup>: z=job run length in minutes if &ge; 10</small>" ;

  print HTML "<small><p>Author: Erik Zachte (<a href='http://infodisiac.com'>Web site</a>)<br>\n" .
             "Mail: ezachte@### (no spam: ### = wikimedia.org)<p>\n".
             "Page generated: $now PST = $now_gm GMT</small>\n" ;

  print HTML "</body>\n</html>\n" ;
  close HTML ;
}

sub WriteHtmlJobRunTimes
{
#  open HTML, '>', $file_html_r ;
#  print HTML "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN" .
#             "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n" .
#             "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>\n" .
#             "<head>\n" .
#             "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>\n" .
#             "<meta http-equiv='refresh' content='60'>\n" .
#             "<title>WikiStats job info</title>\n" .
#             "<style type='text/css'>\n" .
#             "<!--\n" .
#             "body    {font-family:arial,sans-serif; font-size:12px }\n" .
#             "h2      {margin:0px 0px 3px 0px; font-size:18px}\n" .
#             "h3      {margin:0px 0px 1px 0px; font-size:15px}\n" .
#             "h4      {margin:0px 0px 9px 0px; font-size:14px}\n" .
#             "hr,form {margin-top:1px;margin-bottom:2px}\n" .
#             "hr.b    {margin-top:1px;margin-bottom:4px}\n" .
#             "td      {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px}\n" .
#             "td.c    {text-align:center }\n" .
#             "td.l    {text-align:left;}\n" .
#             "th.cb   {text-align:center; border: inset 1px #FFFFFF}\n" .
#             "th.lb   {text-align:left;   border: inset 1px #FFFFFF}\n" .
#             "th.rb   {text-align:right;  border: inset 1px #FFFFFF}\n" .
#             "td.cb   {text-align:center; border: inset 1px #FFFFFF}\n" .
#             "td.lb   {text-align:left;   border: inset 1px #FFFFFF}\n" .
#             "td.rb   {text-align:right;  border: inset 1px #FFFFFF}\n" .
#             "-->\n" .
#             "</style>\n" .
#             "<body bgcolor=#CCCCCC>\n" ;

  print HTML "<p><h3>Job statistics</h3>\n" ;

  if ($threshold_edits_only > 0)
  {
    print HTML $msg_threshold_edits_only ;
    print HTML "<small>Estimated time to go: 105% of $job_togo sec = " . ddhhmmss (int ($job_togo * 1.05)) . "</small><p>\n" ;
  }

  print HTML "<p><table border=1>\n" ;

  print HTML "<tr><th class=lb rowspan=3 valign=top>Lang<br>code</th>" .
                 "<th class=lb colspan=3 valign=top>Edits</th>" .
                 "<th class=lb colspan=9 valign=top>Last file size + compression ratio + process time</th>" ;
  print HTML "<tr><th class=lb rowspan=2 valign=top>Articles</th>" .
                 "<th class=lb rowspan=2 valign=top>Other</th>" .
                 "<th class=lb rowspan=2 valign=top>Share<br>articles</th>" .
                 "<th class=lb colspan=6 valign=top>Full history dump</th>" .
                 "<th class=lb colspan=3     valign=top>Stub dump</th>" ;
  print HTML "<tr><th class=lb colspan=3 valign=top>Fmt 7z</th>" .
                 "<th class=lb colspan=3 valign=top>Fmt bz2</th>" .
                 "<th class=lb colspan=3 valign=top>Fmt gz</th></tr>\n" ;

  foreach $wp (sort {$edits_articles {$b} <=> $edits_articles {$a}} keys %edits_articles)
  {
    $edits_ns0 = $edits_articles {$wp} ;
    $edits_ns0b = i2KMB ($edits_ns0) ;
    $edits_nsx = $edits_other {$wp} ;
    $edits_nsxb = i2KMB ($edits_nsx) ;

    foreach $format (qw (7z bz2 gz))
    {
      $compress_ratio = 'n.a.' ;
      $file_size_compressed   {$format} = &i2KMB2 ($file_sizes_compressed   {$wp} {$format}) ;
      $file_size_uncompressed {$format} = &i2KMB2 ($file_sizes_uncompressed {$wp} {$format}) ;
    }

    $wp2 = $runinfo {$wp} ;
    ($project) = split ('\:', $wp) ;

    if ($backlog {$wp})
    {
      if ($edits_articles  {$wp} > $threshold_edits_only)
      { ${times_total_dhm {$wp}{'gz'}} = "<font color=#FF0000>${times_total_dhm {$wp}{'gz'}}</font>" ; }
      else
      { ${times_total_dhm {$wp}{'7z'}} = "<font color=#FF0000>${times_total_dhm {$wp}{'7z'}}</font>" ; }
    }


    print HTML "<tr><td class=lb>$project:$wp2</td>" .
                   "<td class=rb>$edits_ns0b</td>" .
                   "<td class=rb>$edits_nsxb</td>" .

                   "<td class=rb>${perc_ns0 {$wp}}</td>" .
                   "<td class=rb>${file_size_compressed {'7z'}}</td>" .
                   "<td class=rb>${compress_ratios {$wp}{'7z'}}</td>" .
                   "<td class=rb>${times_total_dhm {$wp}{'7z'}}</td>" .
                   "<td class=rb>${file_size_compressed {'bz2'}}</td>" .
                   "<td class=rb>${compress_ratios {$wp}{'bz2'}}</td>" .
                   "<td class=rb>${times_total_dhm {$wp}{'bz2'}}</td>" .
                   "<td class=rb>${file_size_compressed {'gz'}}</td>" .
                   "<td class=rb>${compress_ratios {$wp}{'gz'}}</td>" .
                   "<td class=rb>${times_total_dhm {$wp}{'gz'}}</td>" .
                   "</td></tr>\n" ;
  }
  print HTML "</table>\n" ;


#  print HTML "<small><p>Author: Erik Zachte (<a href='http://infodisiac.com'>Web site</a>)<br>\n" .
#             "Mail: ezachte@### (no spam: ### = wikimedia.org)<p>\n".
#             "Page generated: $now PST = $now_gm GMT</small>\n" ;

#  print HTML "</body>\n</html>\n" ;
#  close HTML ;
}


sub DHM
{
  my $time = shift ;
  my $text ;

  $runtime_minutes = $time % 60 ;
  $runtime_days    = int ($time/(24*60*60)) ;
  $runtime_hours   = sprintf ("%.0f", ($time%(24*60*60))/(60*60)) ;
  if ($runtime_hours == 24)
  {
    $runtime_hours = 0 ;
    $runtime_days++ ;
  }

  if ($time < 120)
  { $text = "$runtime_minutes minutes" ; }
  elsif ($time < 24*60*60)
  { $text = "$runtime_hours hours" ; }
  else
  { $text = "$runtime_days days $runtime_hours hours" ; }

# print "\nDHM $time => $text\n" ;
  return ($text) ;
}

sub i2KMB
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 1000000000)
  { $v = sprintf ("%.1f",($v / 1000000000)) . "&nbsp;" . $out_billion ; }
  if ($v >= 1000000)
  { $v = sprintf ("%.1f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 10000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  elsif ($v >= 1000)
  { $v = sprintf ("%.1f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

sub i2KMB2
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 1000000000)
  { $v = sprintf ("%.1f",($v / 1000000000)) . "&nbsp;" . $out_billion ; }
  if ($v >= 1000000)
  { $v = sprintf ("%.0f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

sub ReadWikiCountsThresholdEditsOnly
{
  my $text = '' ;
  my $file_perl = "/home/ezachte/wikistats/WikiCounts.pl" ;
  open PERL, '<', $file_perl ;
  while ($line = <PERL>)
  {
    if ($line =~ /threshold_edits_only/)
    {
      $line =~ s/\#.*$// ;
      $line =~ s/[^\d]//g ;
      $threshold_edits_only = $line ;
      $msg_threshold_edits_only = "<small>Job switches to stub dump processing when articles edits on previous run exceeds " . &i2KMB2 ($threshold_edits_only) . " edits, to save time</small><p>" ;
      last ;
    }

  }
  return ($text) ;
}

