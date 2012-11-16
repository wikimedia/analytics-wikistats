#!/usr/bin/perl

# Produce concise but annotate dump status info for all Wikimedia wikis
# Screen scrape official download page: http://download.wikimedia.org/backup-index.html
# For each project scan all folders for earlier runs, parse status html page, determine most recent folder usable for wikistats
# Parse status page as follows: find status of both full archive xml dumps (7z and bz2) and full archive stub dump
# Add status of last dump to overview (color code for age of last usable dump)
# Cache results in local csv files

  $| = 1; # Flush output

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;

  $false     = 0 ;
  $true      = 1 ;

$tracker = <<__SCRIPT_TRACKER__ ;
<!-- Start eXTReMe Non Public Tracker Code V3/5
Login:    infodis
Help:     https://www.extremetracking.com
Installation instructions:
Copy and paste this code between the two body tags into the
*source* of your pages or in your footer/template. Best is
to use a normal text editor such as notepad. -->
<script type="text/javascript"><!--
EXs=screen;EXw=EXs.width;navigator.appName!="Netscape"?
EXb=EXs.colorDepth:EXb=EXs.pixelDepth;
navigator.javaEnabled()==1?EXjv="y":EXjv="n";
EXd=document;EXw?"":EXw="na";EXb?"":EXb="na";
location.protocol=="https:"?EXprot="https":EXprot="http";
top.document.referrer?EXref=top.document.referrer:EXref=EXd.referrer;
EXd.write("<img src="+EXprot+"://nht-2.extreme-dm.com",
"/n3.g?login=infodis&amp;url="+escape(document.URL)+"&amp;pv=&amp;",
"jv="+EXjv+"&amp;j=y&amp;srw="+EXw+"&amp;srb="+EXb+"&amp;",
"l="+escape(EXref)+" height=1 width=1>");//-->
</script><noscript><div id="nneXTReMe"><img height="1" width="1" alt=""
src="http://nht-2.extreme-dm.com/n3.g?login=infodis&amp;url=nojs&amp;j=n&amp;jv=n&amp;pv=" />
</div></noscript>
<!-- End eXTReMe Non Public Tracker Code -->
__SCRIPT_TRACKER__

  $url  = "http://download.wikimedia.org/backup-index.html" ;

  $file_test_input      = "backup-index.html" ;
  $file_htm             = "WikimediaDownload.htm" ;
  $file_csv_lastrun     = "WikimediaDumpsLastRun.csv" ;
  $file_csv_lastsuccess = "WikimediaDumpsLastSuccess.csv" ;
  $file_log             = "WikimediaDumpsLog.txt" ;

  $test = $true ;
  if (-d "/home/infod2/public_html/cgi-bin")
  {
    $test = $false ;
    $file_htm             = "/home/infod2/public_html/cgi-bin/WikimediaDownload.htm" ;
    $file_csv_lastrun     = "/home/infod2/public_html/cgi-bin/WikimediaDumpsLastRun.csv" ;
    $file_csv_lastsuccess = "/home/infod2/public_html/cgi-bin/WikimediaDumpsLastSuccess.csv" ;
    $file_log             = "/home/infod2/public_html/cgi-bin/WikimediaDumpsLog.txt" ;
  }

  open LOG, '>', $file_log ;

  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime(time);
  $now_gm = sprintf ("%4d-%02d-%02d %02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min) ;
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  $now = sprintf ("%4d-%02d-%02d %02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min) ;
  $month_now = yyyymmdd2i (sprintf ("%4d%02d%02d",$year+1900,$mon+1,$mday)) ;

  if (-e $file_htm)
  {
    $time = time - ((-M $file_htm) * 24 * 60 * 60) ;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($time);

    $diff = time - $time ;
    if ((! $test) && ($diff < 60))
    { &ShowCachedVersion ("This page has been generated $diff secs earlier.") ; }
  }

  if (-e $file_csv_lastrun)
  {
    open "FILE_CSV", "<", $file_csv_lastrun || &Abort ("CSV file could not be opened.") ;
    while ($line = <FILE_CSV>)
    {
      chomp ($line) ;
      ($date,$project) = split (',', $line) ;
      $projectsinfo_lastrun {$project} = $line ;
    }
    close "FILE_CSV" ;
  }

  if (-e $file_csv_lastsuccess)
  {
    open "FILE_CSV", "<", $file_csv_lastsuccess || &Abort ("CSV file could not be opened.") ;
    while ($line = <FILE_CSV>)
    {
      chomp ($line) ;
      ($date,$project) = split (',', $line) ;
      $projectsinfo_lastsuccess {$project} = $line ;
    }
    close "FILE_CSV" ;
  }

  if ($test)
  {
    open "FILE_TEST", "<", $file_test_input || &Abort ("File $file_test_input could not be read\n") ;
    @content = <FILE_TEST> ;
    $content = join "\n", @content ;
    $succes = $true ;
  }
  else
  { ($succes, $content) = &GetPage ($url, $checkhtml) ; }

  $projectinfo_lastsuccess_new = 0 ; # paces csv file updates

  if ((length ($content) < 1000) || ($content !~ /<\/html>/i))
  { &ShowCachedVersion ("The original dump progress report could not be retrieved from the Wikimedia server. This report is based on cached data.") ; }
  else
  {
    $content = &PrepareInput ($content) ;
    $content = &FilterInput  ($content) ; # build %projectsinfo_lastsuccess via UpdateProject, plus filter $content (retain few lines for output)
    &CollectProjectStats ;                # analyze %projectsinfo_lastsuccess
    $content  = &WriteOutput ($content) ;
    &DisplayOutput ($content) ;
  }

  close LOG ;
  exit ;

sub PrepareInput
{
  &Log ("PrepareInput\n") ;
  my $content = shift ;

  $content =~ s/<h1>.*?<\/div>/<h3>Concise version of the <a href='$url'>Wikimedia database dump service report<\/a><\/h3>/s ;
  $content =~ s/<\/h3>/<\/h3><small>Page generated: <b>$now<\/b> PST = <b>$now_gm<\/b> GMT<br>See <a href='http:\/\/www.infodisiac.com\/cgi-bin\/WikimediaDownload.pl#legend'>legend<\/a><\/small>\n/ ;
  $content =~ s/<\/head>/<base href='http:\/\/download.wikimedia.org'>\n<\/head>/ ;
  $content =~ s/<li class='detail'>[^<]*?<\/li>//gs ;
  $content =~ s/<li class='missing'>[^<]*?<\/li>//gs ;

  $content =~ s/\(.bz2,\)/(.bz2)/g ; # recently introduced error on source
  if ($content =~ /bz2,/)
      { &Abort ("Content still contains bz2:\n$content\n") ; }

  return ($content) ;
}

sub FilterInput
{
  &Log ("FilterContent\n") ;
  my $content = shift ;

  @lines = split ("\n", $content) ;
  foreach $line (@lines)
  {
    $project = '' ;
    $private = $false ;

    if ($line =~ /ETA \d\d\d\d-\d\d-\d\d/)
    {
      my ($eta,$yy,$mm,$dd,$hh,$nn,$togo,$left,$days,$hours,$time) ;
      $time = time ;
      ($eta = $line) =~ s/^.*?ETA (\d\d\d\d-\d\d-\d\d \d\d\:\d\d).*$/$1/ ;
      $yy = substr ($eta,0,4) ;
      $mm = substr ($eta,5,2) ;
      $dd = substr ($eta,8,2) ;
      $hh = substr ($eta,11,2) ;
      $nn = substr ($eta,14,2) ;

      $time_eta = timegm (0, $nn, $hh, $dd, $mm-1, $yy-1900) ; # - 8 * 60 * 60 ; # GMT -> PST
      $togo = ($time_eta - $time) / (24*60*60) ;

      $days  = int ($togo) ;
      $hours = ($togo-$days) * 24 ;
      $minutes = int (($hours - int ($hours)) * 60) ;
      $hours  = int ($hours) ;

      if ($days + $hours + $minutes > 0) # any of these non zero => 60 seconds or more
      {
        $left = "" ;
        if ($days > 0)
        { $left =  "$days days, " ; }
        if ($hours > 0)
        { $left .=  "$hours hrs" ; }
        if ($minutes > 0)
        { $left .=  ", $minutes min" ;            }
        $left = "<b>($left to go)<\/b>" ;
        if ($days > 0)
        { $left = "<font color='#FF0000'>$left<\/font>" ; }
        $line =~ s/(ETA \d\d\d\d-\d\d-\d\d \d\d\:\d\d\:\d\d)/$1 $left/ ;
      }
    }

    if ($line =~ /^\s*<li>/)
    {
      if ($line =~ /private/)
      {
        $private = $true ;
        ($project = $line) =~ s/^.*?(\w+)wiki.*$/$1/ ;
        push @wikiprivate, "<font color='#808080'>$project</font>" ;
        $line = '' ;
        next ;
      }
      else
      {
        $href = $line ;
        $href =~ s/^.*href=\"([^\"]+)\".*$/$1/ ;
        if ($href eq $line)
        { $href =~ s/^.*?([a-z_]+wiki).*$/$1/ ; }
        if ($href eq $line)
        { $href = 'n.a.' ; }

        ($date = $line) =~ s/^.*\/(20\d{6}).*$/$1/ ;
        if ($date =~ /\d{8,8}/)
        {
          $year  = substr ($date,0,4) ;
          $month = substr ($date,4,2) ;
          $day   = substr ($date,6,2) ;
          $date = "$year$month$day" ;
        }
        else
        { $date = "?" ; }

        ($project = $href) =~ s/([^\/]+)\/.*$/$1/ ;
      }

      $projectcount++ ;
      &Log ("\n=== $projectcount: Project $project ===\n\n") ;

      $jobstatus = "" ;
      if ($line =~ / failed/)
      { $jobstatus = "failed|" ; }
      if ($line =~ / aborted/)
      { $jobstatus .= "aborted|" ; }
      if ($line =~ / \(new\)/)
      { $jobstatus .= "new|" ; }
      if ($line =~ / progress/)
      {
        $jobstatus .= "progress|" ;
        $jobs_in_progress {$project} = $true ;
      }
      $jobstatus =~ s/\|$// ;

      $projectinfo_lastrun      = "$date,$project,$href,$jobstatus" ;
      $projectinfo_lastrun_prev = $projectsinfo_lastrun {$project} ;

      if ($projectinfo_lastrun_prev eq "")
      {
        $status = "new" ;
        &Log ("\nNew project $project: -> $projectinfo_lastrun\n") ;
      }
      elsif ($projectinfo_lastrun_prev ne $projectinfo_lastrun)
      {
        $status = "changed" ;
        &Log ("\nUpdated project $project: $projectinfo_lastrun_prev -> $projectinfo_lastrun\n") ;
      }
      else
      {
        $status = "unchanged" ;
        &Log ("\nUnchanged project $project: $projectinfo_lastrun_prev -> $projectinfo_lastrun\n") ;
      }

      $projectsinfo_lastrun {$project} = $projectinfo_lastrun ;

      &Log ("Status $status, last run $projectinfo_lastrun \n") ;

      if (($status ne "unchanged") || ($jobstatus =~ /progress/))
      { &UpdateProject ($projectinfo_lastrun) ; }

      if (($line =~ /Dump complete/) && ($line !~ /item/))
      { $line = '' ; }

      if (($line =~ / failed/) && ($line !~ / progress/))
      {
        $line =~ s/<span[^>]*>(.*?)<\/span>/$1/ ;
        $line =~ s/<\/a>(.*)/<\/a><font color='#800000'><b>$1<\/b><\/font>/ ;
        push @lines_fail, $line ;
        $line = '' ;
      }
    }
    if ($line =~ /in.progress/)
    {
      $line =~ s/(<li[^>]*>)(.*?)(<\/li>)/$1<small>$2<\/small>$3/ ;
      $line =~ s/(<ul><li[^>]*>)(.*?)(<\/div>)/$1<small>$2<\/small>$3/ ;
    }
    $line =~ s/<\/?big>//g ;
    # $line =~ s/.in-progress/.in-progress {font-size:12px;/ ;
  }

  $content  = join ("\n", @lines) ;
  return ($content) ;
}

sub WriteOutput
{
  &Log ("WriteOutput\n") ;
  my $content = shift ;

  $wikiprivate = &FormatProjects (@wikiprivate) ;
  $wikimisc    = &FormatProjects (@wikimisc) ;
  $wikibooks   = &FormatProjects (@wikibooks) ;
  $wikiquote   = &FormatProjects (@wikiquote) ;
  $wikinews    = &FormatProjects (@wikinews) ;
  $wikisource  = &FormatProjects (@wikisource) ;
  $wiktionary  = &FormatProjects (@wiktionary) ;
  $wikiversity = &FormatProjects (@wikiversity) ;
  $wikimedia   = &FormatProjects (@wikimedia) ;
  $wikipedia   = &FormatProjects (@wikipedia) ;

  $content2  = "<p><a name='projects' id='projects'></a>" ;
  $content2 .= "<b>Wikibooks</b> <small>$wikibooks</small><p>" ;
  $content2 .= "<b>Wikinews</b> <small>$wikinews</small><p>" ;
  $content2 .= "<b>Wikipedia</b> <small>$wikipedia</small><p>" ;
  $content2 .= "<b>Wikiquote</b> <small>$wikiquote</small><p>" ;
  $content2 .= "<b>Wikisource</b> <small>$wikisource</small><p>" ;
  $content2 .= "<b>Wikiversity</b> <small>$wikiversity</small><p>" ;
  $content2 .= "<b>Wiktionary</b> <small>$wiktionary</small><p>" ;
  $content2 .= "<b>Wikimedia</b> <small>$wikimedia</small><p>" ;
  $content2 .= "<b>Miscellaneous</b> <small>$wikimisc</small><p>" ;
  $content2 .= "<b>Private</b> <small>$wikiprivate</small><p>" ;

  if ($#lines_fail > -1)
  { $content2 .= "<p><b>Fail</b><br>" . join ("\n", @lines_fail) ; }

  @cntperday = sort {$b <=> $a} keys %cntperday ;

  my @months   = qw (January February March April May June July
                     August September October November December);

  $monprev = -1 ;
  $history = "<b>Dump jobs per start date</b>\n" ; # <font face='courier new'>" ;
  foreach $key (@cntperday)
  {
    $time = time - ($key * 24*60*60) ;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($time);
    if ($monprev == -1)
    {
      $history =~ s/\/ $// ;
      $history .= "<br>" . $months [$mon] . ": " ;
    }
    elsif (($mon != $monprev) && ($monprev != -1))
    { $history .= "<br>" . $months [$mon] . ": " ; }
    $history .= "<b>$mday</b>:" . $cntperday {$key} . " / " ;
    $monprev = $mon ;
  }
  $history =~ s/\/ $// ;

#  $history .= "<p><pre>" ;
#  for ($day = 1 ; $day <= 31 ; $day++)
#  { $line .= sprintf (" %2d" , $day) ; }
#  $history .= "$line" ;
#  foreach $date (sort {$a cmp $b} keys %startdates)
#  {
#    $count = $startdates {$date} ;
#    $history .= "$date: $count\n" ;
#  }
#  $history .= "</pre>" ;

  $content =~ s/\n\s*\n/\n/gs ;

  $debug = join ("\n", @debug) ;

  ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst)=localtime(time);
  $year  = $year  + 1900 ;
  $month = $month + 1 ;

  @months = qw(Xxx Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec) ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ; # previous month is last month for which wikistats could gather data
  $month_minus_1 = $months [$month] . " "  . $year ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ;
  $month_minus_2 = $months [$month] . " "  . $year ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ;
  $month_minus_3 = $months [$month] . " "  . $year ;
  ($year,$month) = ($month > 1) ? ($year,$month-1) : ($year-1, 12) ;
  $month_minus_4 = $months [$month] . " "  . $year ;

  $colorsused = "<font color='#000000'>xx<sup>n</sup></font>: dump for language xx started n days ago\n" .
                "<br><font color='#008000'>xx<sup>n</sup></font>: last full month processed: $month_minus_1 (ready to be picked up by wikistats job)\n" .
                "<br><font color='#000060'>xx<sup>n</sup></font>: last full month processed: $month_minus_2\n" .
                "<br><font color='#C08000'>xx<sup>n</sup></font>: last full month processed: $month_minus_3\n" .
                "<br><font color='#800000'>xx<sup>n</sup></font>: last full month processed: $month_minus_4 or older\n" .
                "<br><font color='#808080'>xx<sup>n</sup></font>: wiki is closed or private (no files for download)\n" .
                "<br><font color='#000000'><u>xx<sup>n</sup></u></font>: dump job is in progress\n" ;
              # "<br><font color='#800000'><i>xx<sup>n</sup></i></font>: last dump attempt aborted\n" .
              # "<br><font color='#FF0000'>xx<sup>n</sup></font>: dump failed (at least partially)\n" .
              # "<br><font color='#000080'><big><b>xx<sup>n</sup></b></big></font>: dump running (started n days ago)<p>\n" .

  $colophon = "<small>Author: Erik Zachte (<a href='http://infodisiac.com'>Web site</a>)<br>\n" .
              "Mail: erikzachte@###.com (&lt;nospam&gt; ### = infodisiac &lt;/nospam&gt;)<p></small>\n" ;

  $table = "<a name='legend' id='legend'></a><p><table width=100%><tr><td valign=top><small>$history</small></td><td valign=top><small><b>Legend</b><br>$colorsused</small></td></tr></table>" ;
  $content =~ s/<\/body>/$content2<hr>$table<hr>$colophon$debug$tracker<\/body>/ ;

  open "FILE_OUT", ">", $file_htm || &Abort ("Output file could not be opened.") ;
  binmode FILE_OUT ;
  print FILE_OUT $content ;
  close "FILE_OUT" ;

  open "FILE_CSV", ">", $file_csv_lastrun || &Abort ("CSV file $file_csv_lastrun could not be opened.") ;
  foreach $key (sort {$a cmp $b} keys %projectsinfo_lastrun)
  { print FILE_CSV "${projectsinfo_lastrun {$key}}\n" ; }
  close "FILE_CSV" ;

  open "FILE_CSV", ">", $file_csv_lastsuccess || &Abort ("CSV file $file_csv_lastsuccess could not be opened.") ;
  foreach $key (sort {$a cmp $b} keys %projectsinfo_lastsuccess)
  { print FILE_CSV "${projectsinfo_lastsuccess {$key}}\n" ; }
  close "FILE_CSV" ;

  return ($content)
}

sub DisplayOutput
{
  &Log ("DisplayOutput\n") ;
  my $content = shift ;

  if (! $test)
  {
    print "Content-type: text/html\n\n";
    print "$content" ;
  }
}

sub UpdateProject
{
  my ($projectinfo_lastrun) = @_ ;

  &Log ("\nUpdateProject $projectinfo_lastrun\n") ;

  ($date,$project,$href) = split (',', $projectinfo_lastrun) ;

  $projectinfo_lastsuccess      = &GetInfoLastSuccesfulDump ($project, $href) ;
  $projectinfo_lastsuccess_prev = $projectsinfo_lastsuccess {$project} ;

  # update file often, for minimal duplication of effort after job restart
  if (($projectinfo_lastsuccess ne $projectinfo_lastsuccess_prev) && ($projectinfo_lastsuccess ne ''))
  {
    $projectsinfo_lastsuccess {$project} = $projectinfo_lastsuccess ;

    if (++ $projectinfo_lastsuccess_new % 10 =