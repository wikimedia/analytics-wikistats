#!/usr/bin/perl

# Produce concise annotated dump status for all Wikimedia wikis
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

  $url_index  = "http://download.wikimedia.org/backup-index.html" ;
  $url_matrix = "http://www.mediawiki.org/wiki/Special:SiteMatrix" ;

  $file_matrix          = "site_matrix.html" ;
  $file_test_input      = "backup-index.html" ;
  $file_htm             = "WikimediaDownload.htm" ;
  $file_csv_lastrun     = "WikimediaDumpsLastRun.csv" ;
  $file_csv_lastsuccess = "WikimediaDumpsLastSuccess.csv" ;
  $file_log             = "WikimediaDumpsLog.txt" ;

  $test = $true ;
  if (-d "/[.. path ..]")
  {
    $test = $false ;
    $file_index           = "/[.. path ..]/WikimediaSiteMatrix.htm" ;
    $file_htm             = "/[.. path ..]/WikimediaDownload.htm" ;
    $file_csv_lastrun     = "/[.. path ..]/WikimediaDumpsLastRun.csv" ;
    $file_csv_lastsuccess = "/[.. path ..]/WikimediaDumpsLastSuccess.csv" ;
    $file_log             = "/[.. path ..]/WikimediaDumpsLog.txt" ;
  }

  open LOG, '>', $file_log ;

  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime(time);
  $now_gm = sprintf ("%4d-%02d-%02d %02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min) ;
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  $now = sprintf ("%4d-%02d-%02d %02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min) ;
  $month_now = yyyymmdd2i (sprintf ("%4d%02d%02d",$year+1900,$mon+1,$mday)) ;

  if ((! -e $file_matrix) || (-M $file_matrix > 1))
  {
    ($succes, $matrix) = &GetPage ($url_matrix, $checkhtml) ;
    if ($succes)
    {
      open MATRIX, '>', $file_matrix ;
      print MATRIX $matrix ;
      close MATRIX ;
    }
  }
  else
  {
    open MATRIX, '<', $file_matrix ;
    @lines = <MATRIX> ;
    close MATRIX ;
    $matrix = join '', @lines ;
  }

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
      next if $line =~ /^\s*$/ ;
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
  { ($succes, $content) = &GetPage ($url_index, $checkhtml) ; }

  $projectinfo_lastsuccess_new = 0 ; # paces csv file updates

  if ((length ($content) < 1000) || ($content !~ /<\/html>/i))
  { &ShowCachedVersion ("The original dump progress report could not be retrieved from the Wikimedia server. This report is based on cached data.") ; }
  else
  {
    &ParseMatrix ($matrix) ;
    $content = &PrepareInput ($content) ;
    $content = &FilterInput  ($content) ; # build %projectsinfo_lastsuccess via UpdateProject, plus filter $content (retain few lines for output)
    &CollectProjectStats ;                # analyze %projectsinfo_lastsuccess
    $content  = &WriteOutput ($content) ;
    &DisplayOutput ($content) ;
  }

  close LOG ;
  exit ;

sub ParseMatrix
{
  my $matrix = shift ;
  $matrix =~ s/<a\s+href=\"([^\"]+)\"\s+class="new">/(push @new_wikis,$1)/gesi ;

  foreach $wiki (sort @new_wikis)
  {
    $wiki =~ s/http:\/\/// ;
    $wiki =~ s/\.org// ;
    $wiki =~ s/pedia// ;
    $wiki =~ s/\.//g ;

    next if $wiki !~ /^z/ ;
    $new_wiki {$wiki} = $true ;
  }
}

sub PrepareInput
{
  &Log ("PrepareInput\n") ;
  my $content = shift ;

  $content =~ s/<h1>.*?<\/div>/<h3>Concise version of the <a href='$url_index'>Wikimedia database dump service report<\/a><\/h3>/s ;
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

  $wikimisc    = &FormatProjects (@wikimisc) ;
  $wikibooks   = &FormatProjects (@wikibooks) ;
  $wikiquote   = &FormatProjects (@wikiquote) ;
  $wikinews    = &FormatProjects (@wikinews) ;
  $wikisource  = &FormatProjects (@wikisource) ;
  $wiktionary  = &FormatProjects (@wiktionary) ;
  $wikiversity = &FormatProjects (@wikiversity) ;
  $wikimedia   = &FormatProjects (@wikimedia) ;
  $wikipedia   = &FormatProjects (@wikipedia) ;

  $msg_wikis_open = "All together there are $wikis_open active public wikis" ;

  $wikilocked  = &FormatProjectsLocked (@wikilocked) ;
  $wikiprivate = &FormatProjects (@wikiprivate) ;

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
  $content2 .= "<b>Locked</b> <small>$wikilocked</small><p>" ;

  if ($#lines_fail > -1)
  { $content2 .= "<p><b>Fail</b><br>" . join ("\n", @lines_fail) ; }

  $content2 .= "<p><b>Summary</b><p>$msg_wikis_open\n\n" ;

  @cntperday = sort {$b <=> $a} keys %cntperday ;

  my @months   = qw (January February March April May June July
                     August September October November December);

  $monprev = -1 ;
  $history = "<b>Dump jobs per start date</b>\n<br><small><font color=#808080><small>(start date, rather than end date, because dump will only contain all revisions for all articles up to this date)</font></small></small><p><small>" ; # <font face='courier new'>" ;

  foreach $key (@cntperday)
  {
    $time = time - ($key * 24*60*60) ;
    ($sec,$min,$hour,$mday,$mon,$year_now,$wday,$yday,$isdst)=localtime(time);
    ($sec,$min,$hour,$mday,$mon,$year    ,$wday,$yday,$isdst)=localtime($time);
    $year_now += 1900 ;
    $year += 1900 ;
  # if ($monprev == -1)
  # {
  #   $history =~ s/\/ $// ;
  #  $history .= "<br>" . $months [$mon] . ": " ;
  # }
  # elsif (($mon != $monprev) && ($monprev != -1))
  # { $history .= "<br>" . $months [$mon] . ": " ; }
  # $history .= "<b>$mday, $year</b>:" . $cntperday {$key} . " jobs started<br><small>" . $cntperday_projects {$key} . "</small><br>" ;
    ($cntperday_projects = $cntperday_projects {$key}) =~ s/,\s*$// ;

    $history .= "<b>" . $months [$mon] . " $mday" . ($year < $year_now ? ", $year" : '') . ": " . $cntperday {$key} . "</b><br><small>$cntperday_projects</small><br>" ;
    $monprev = $mon ;
  }
  $history =~ s/\/ $// ;
  $history .= "<\/small>" ;

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

# $table = "<a name='legend' id='legend'></a><p><table width=100%><tr><td valign=top><small>$history</small></td><td valign=top><small><b>Legend</b><br>$colorsused</small></td></tr></table>" ;
  $table = "$history<hr><p><a name='legend' id='legend'></a><p><b>Legend</b><br><small>$colorsused</small>" ;
  $content =~ s/<\/body>/$content2<hr>$table<hr>$colophon$debug<\/body>/ ;

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

  if (&WikiLocked ($project))
  {
    chomp $projectinfo_lastsuccess ;
    $projectinfo_lastsuccess .= ",locked\n" ;
  }

  # update file often, for minimal duplication of effort after job restart
  if (($projectinfo_lastsuccess ne $projectinfo_lastsuccess_prev) && ($projectinfo_lastsuccess ne ''))
  {
    $projectsinfo_lastsuccess {$project} = $projectinfo_lastsuccess ;

    if (++ $projectinfo_lastsuccess_new % 10 == 0)
    {
      &Log ("\nUpdate csv files\n\n") ;

      open "FILE_CSV", ">", $file_csv_lastrun || &Abort ("CSV file $file_csv_lastrun could not be opened.") ;
      foreach $key (sort {$b cmp $a} keys %projectsinfo_lastrun)
      { print FILE_CSV "${projectsinfo_lastrun {$key}}\n" ; }
      close "FILE_CSV" ;

      open "FILE_CSV", ">", $file_csv_lastsuccess || &Abort ("CSV file $file_csv_lastsuccess could not be opened.") ;
      foreach $key (sort {$b cmp $a} keys %projectsinfo_lastsuccess)
      { print FILE_CSV "${projectsinfo_lastsuccess {$key}}\n" ; }
      close "FILE_CSV" ;
    }
  }
}

sub WikiLocked
{
  my $project = shift ;
  my $url = $project ;
  $url =~ s/wik/\.wik/ ;
  $url =~ s/wiki$/wikipedia/ ;
  $url = "http://$url\.org\/" ;

  my $content ;
  my ($pagefound, $content) = &GetPage ("$url", $checkhtml) ;

  if ($pagefound && ($content =~ /has been locked/si))
  {
    &Log ("This wiki has been locked: $project\n") ;
    return ($true) ;
  }

  return $false ;
}


sub CollectProjectStats
{
  &Log ("CollectProjectStats\n") ;

  foreach $key (sort {$b cmp $a} keys %projectsinfo_lastsuccess)
  {
    $projectinfo_lastsuccess = $projectsinfo_lastsuccess {$key} ;

    if ($projectinfo_lastsuccess =~ 'locked')
    {
    # push @wikilocked, "<font color='#808080'>$key</font>" ;
      ($lang,$project) = split ('wik',$key) ;
      $key = "wik$project,$lang" ;
      push @wikilocked, "$key" ;
      next ;
    }

    ($date,$project,$href,$usable_dumps) = split (',', $projectinfo_lastsuccess) ;

    if ($project =~ /^(?:tlh|strategyapp)/) # obsolete info, project abandoned
    { next ; }

    if ($date =~ /^\d{8}$/)
    {
      $year  = substr ($date,0,4) ;
      $month = substr ($date,4,2) ;
      $day   = substr ($date,6,2) ;
      $months_ago = $month_now - &yyyymmdd2i ($date) ;
      $time_gm = timegm (0, 0, 0, $day, $month-1, $year-1900) ;
      $days_ago = (time - $time_gm) / (24*60*60) ;
    }
    else
    {
      $days_ago = 999 ;
      $months_ago = 999 ;
    }

    $days = int ($days_ago) ;
    $cntperday {$days}++ ;
    $cntperday_projects {$days} = "$project, " . $cntperday_projects {$days} ;

    $rgb = "#FF0000" ;
    if ($months_ago >= 3)
    { $rgb = "#800000" ; }
    elsif ($months_ago == 2)
    { $rgb = "#C08000" ; }
    elsif ($months_ago == 1)
    { $rgb = "#000060" ; }
    elsif ($months_ago == 0) # wikistats up to date, contains data up to previous month
    { $rgb = "#008000" ; }

    $code = $project ;
    $code =~ s/^(.+)wik.*/$1/ ;

    $code = "$code<sup>$days</sup>" ;

    if (($usable_dumps !~ /stub.*7z.*bz2/) && ($usable_dumps ne ''))
    { $code = "$code <sup><b>[$usable_dumps only]</b></sup>" ; }
  # { $code = "$code <font color='#808080'><sup><b>[$usable_dumps only]</b></sup></font>" ; }

    if ($jobs_in_progress {$project})
    { $code = "<u><b>$code</b></u>" ; }

#   if ($jobstatus =~ /progress/)
#   { $code = "</small><font color='#000080'><big><b>$code</b></big></font><small>" ; }
#   elsif ($jobstatus =~ /failed/)
#   { $code = "<font color='#FF0000'><b>$code</b></font>" ; }
#   elsif ($jobstatus =~ / aborted/)
#   { $code = "<font color='#800000'><i>$code</i></font>" ; }

    if ($project ne '')
    { $project = "<a href='$href' title='$date'><font color='$rgb'>$code</font></a>" ; }


    if ($project =~ /(?:mania|mediawiki|closed|foundation|test|incubator|strategy|outreach|usability)/)
    { push @wikimisc, $project ; }
    elsif ($project =~ /books/)
    { push @wikibooks, $project ; }
    elsif ($project =~ /quote/)
    { push @wikiquote, $project ; }
    elsif ($project =~ /news/)
    { push @wikinews, $project ; }
    elsif ($project =~ /source/)
    { push @wikisource, $project ; }
    elsif ($project =~ /wiktionary/)
    { push @wiktionary, $project ; }
    elsif ($project =~ /versity/)
    { push @wikiversity, $project ; }
    elsif ($project =~ /wikimedia/)
    { push @wikimedia, $project ; }
    elsif ($project ne '')
    { push @wikipedia, $project ; }
  }

# foreach $project (keys %projectsinfo_lastsuccess)
# {
#   ($date,$project)  = split (',', $projectsinfo_lastsuccess {$project}) ;
#   $startdates {$date} ++ ;
# }
}

sub FormatProjects
{
  my @projects = @_ ;
  my $count = $#projects + 1 ;
  $wikis_open += $count ;
  @projects = sort {$a cmp $b} @projects ;
  $projects = join (', ', @projects) ;
  return ("[$count] $projects") ;
}

sub FormatProjectsLocked
{
  my @projects = @_ ;
  my $count = $#projects + 1 ;
  @projects = sort {$a cmp $b} @projects ;
  my $projects = "[$count] " ;

  my $project_prev = '' ;
  foreach my $project (@projects)
  {
    my ($project, $lang) = split (',', $project) ;
    if ($project eq 'wiki')
    { $project = 'wikipedia' ; }
    if ($project ne $project_prev)
    {
      $projects =~ s/,$// ;
      $projects .= "<font color='#000000'><b>$project:</b></font> " ;
    }
    $projects .= "<a href='http://$lang.$project.org'><font color='#808080'>$lang</font></a>, " ;
    $project_prev = $project ;
  }
  $projects =~ s/,\s*$// ;
  return ("<font color='#808080'>$projects</font>") ;
}

sub GetInfoLastSuccesfulDump
{
  my ($project, $href) = @_ ;
  my ($succes, $content, $line, @lines) ;

  my $link = "http://download.wikimedia.org/$href" ;
  &Log ("\nGetInfoLastSuccesfulDump $project\n") ;

  $usable_dump_folder_found = $false ;
  $pagefound = $true ;
  while ($pagefound)
  {
    &Log ("\nFolder $link\n") ;

    # detect endless loop
    if ($links_followed {$link} > 0)
    {
      &Log ("Endless loop\n") ;
      return ('') ;
    }

    ($pagefound, $content) = &GetPage ("$link/index.html", $checkhtml) ; # make index.html explicit for logging
     $links_followed {$link}++ ;

    ( $lastdumped = $content) =~ s/^.*?(?:Last dumped on|previous dump from) (\d\d\d\d)-(\d\d)-(\d\d).*$/$1$2$3/s ;

    if (length ($lastdumped) > 8) # check: occurs also on first dump for new wiki ?!?!
    {
      &Log (substr ($lastdumped,1,80)) ;
      return ('')  ;
    }

    $dumps_usable = "" ;

    if ($content =~ /<span class='\w+'>done<\/span> <span class='title'>First-pass for page XML data dumps/)
    {
      # &Log ("Complete stub dumps found\n") ;
      $usable_dump_folder_found = $true ;
      $dumps_usable .= "stub|" ;
    }

    if ($content =~ /<span class='\w+'>done<\/span> <span class='title'>All pages with complete edit history.{0,10}?7z/)
    {
      # &Log ("Complete full archive dumps found (7z)\n") ;
      $dumps_usable .= "7z|" ;
    }

    if ($content =~ /<span class='\w+'>done<\/span> <span class='title'>All pages with complete page edit history.{0,10}?bz2/)
    {
      # &Log ("Complete full archive dumps found (bz2)\n") ;
      $dumps_usable .= "bz2|" ;
    }
    $dumps_usable =~ s/\|$// ;

    if ($usable_dump_folder_found) # means at least stub dump is usable
    {
       # dump should contain all data for full month to qualify for wikistats
       my @lines = split ("\n", $content) ;
       foreach $line (@lines)
       {
       # if ($line =~ /User account data/) start of job was safest date, but instead use start of stub dump step
       # this is very sharp (maybe stub dump uses extract produced earlier) but use it anyway
         if ($line =~ /Extracted page abstracts for Yahoo/) # start of stub dump step
         {
           ($date = $line) =~ s/^.*?(\d\d\d\d-\d\d-\d\d).*$/$1/i ;
           last ;
         }
       }
       if ($date =~ /\d\d\d\d-\d\d-\d\d/)
       {
         $year  = substr ($date,0,4) ;
         $month = substr ($date,5,2) ;
         $day   = substr ($date,8,2) ;
         $date = "$year$month$day" ;
         &Log ("Usable dump found: date $date, project $project, href $href, dumps usable '$dumps_usable'\n\n") ;
         return ("$date,$project,$href,$dumps_usable") ;
       }
    }

    # dumps in this folder unusable: prepare to track back for earlier dump run
    $href = "$project\/$lastdumped" ;
    $link = "http:\/\/download.wikimedia.org\/$href" ;
  }
  &Log ("No usable dump found: date $date, project $project, href $href, dumps usable '$dumps_usable'\n\n") ;
  return ('') ;
}

sub GetPage
{
  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  my $raw_url = shift ;
  my $is_html = shift ;
  my ($success, $content, $attempts) ;
  my $file = $raw_url ;
  $file =~ s/.*\/(.*\/)$/$1/g ;
  $file =~ s/.*\/(.*[^\/])$/$1/g ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikimedia Perl job / EZ");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  if ($calls++ % 5   == 0)
  { sleep (1) ; }

  my $succes = $false ;

  &Log ("Fetch '$file' on $raw_url\n") ;
  for ($attempts = 1 ; ($attempts <= 3) && (! $succes) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { &Log (" -> 404\n") ; }
      else
      { &Log (" -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
      return ($false) ;
    }
    # else
    # { &Log ("\n") ; }

    $content = $response->content();

    if ($is_html && ($content !~ m/<\/html>/i))
    {
      &Log ("Page is incomplete:\n  '$raw_url'\n") ;
      next ;
    }

    $succes = $true ;
  }

  if (! $succes)
  {
    &Log (" -> error: \nPage not retrieved after " . (--$attempts) . " attempts !!\n\n") ;
    &ShowCachedVersion ("The original dump progress report could not be retrieved from the Wikimedia server. This derived concise version is based on cached data.") ;
  }
  else
  { &Log (" -> OK\n") ; }

  return ($succes,$content) ;
}

sub ShowCachedVersion
{
  my $msg = shift ;
  &Log ("ShowCachedVersion $msg\n") ;

  if ($msg =~ /cached/)
  {
    my $time = -M $file_htm ;
    $ago .= int($time) . ' days, ' ;
    $ago .= sprintf ("%.0f",(24    * $time) % 24) . ' hours, ' ;
    $ago .= sprintf ("%.0f",(24*60 * $time) % 60) . ' minutes ' ;
    $msg =~ s/\.$/ from $ago ago\./ ;
  }

  open "FILE_IN", "<", $file_htm || &Abort ("Input file could not be opened.") ;
  binmode FILE_IN ;
  @in = <FILE_IN> ;
  foreach $line (@in)
  {
           if ($line =~ /<\/body>/i)
           { $line =~ s/<\/body>/<font color='#800000'>$msg<\/font><\/body>/i ; }
  }
  print "Content-type: text/html\n\n" ;
  print @in ;
  exit ;
}

sub Log
{
  my $msg = shift ;
  if ($test)
  { print $msg ; }
  print LOG $msg ;
}

sub Abort
{
  my $msg = shift ;
  if ($test)
  { print $msg ; }
  print LOG $msg ;
  exit ;
}


# determine months since january 2000
sub yyyymmdd2i
{
  my $yyyymmdd = shift ;
  my $year  = substr ($yyyymmdd,0,4) ;
  my $month = substr ($yyyymmdd,4,2) ;
  my $months = ($year - 2000) * 12 + $month ;
  return ($months) ;
}
