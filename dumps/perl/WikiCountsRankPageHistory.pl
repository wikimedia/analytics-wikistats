#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (4) ;

  $Kb        = 1024 ;
  $Mb        = $Kb * $Kb ;
  $Gb        = $Kb * $Kb * $Kb ;

  $out_gigabytes = "Gb" ;
  $out_megabytes = "Mb" ;
  $out_kilobytes = "kb" ;

  $out_myname = "Erik Zachte" ;
  $out_mymail = "ezachte@###.org (no spam: ### = wikimedia)" ;
  $out_mysite = "http://infodisiac.com/" ;

# hard coded paths, yes I know :)
  $dir_in      = "W:/# Out Bayes" ;
  $file_html_1 = "TableRankArticleHistoryByArchiveSize.html" ;
  $file_html_2 = "TableRankArticleHistoryByTotalEdits.html" ;
  $dir_out     = "W:/# Out Test/htdocs/EN" ;
  if ($job_runs_on_production_server)
  {
    print "Job runs on bayes\n" ;
    $dir_in  = "/a/wikistats" ;
    $dir_out = "/mnt/htdocs/EN" ;
  }

  @projects {"wb"} = "wikibooks" ;
  @projects {"wk"} = "wiktionary" ;
  @projects {"wn"} = "wikinews" ;
  @projects {"wp"} = "wikipedia" ;
  @projects {"wq"} = "wikiquote" ;
  @projects {"ws"} = "wikisource";
  @projects {"wv"} = "wikiversity" ;
  @projects {"wx"} = "wikipedia" ; # for url use original name, not wikispecial

  &ReadStatsCsv ("wb") ;
  &ReadStatsCsv ("wk") ;
  &ReadStatsCsv ("wn") ;
  &ReadStatsCsv ("wp") ;
  &ReadStatsCsv ("wq") ;
  &ReadStatsCsv ("ws") ;
  &ReadStatsCsv ("wv") ;
  &ReadStatsCsv ("wx") ;

  $language = "en" ;
  $header = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>\n" .
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
            "td   {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top}\n" .
            "th   {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top ; font-width:bold}\n" .
            "td.h {text-align:left;}\n" .
            "td.r {text-align:right;  border: inset 1px #FFFFFF}\n" .
            "td.c {text-align:center; border: inset 1px #FFFFFF}\n" .
            "td.l {text-align:left;   border: inset 1px #FFFFFF}\n" .
            "th.c {text-align:center; border: inset 1px #FFFFFF}\n" .
            "th.l {text-align:left;   border: inset 1px #FFFFFF}\n" .
            "a:link { color:blue;text-decoration:none;}\n" .
            "a:visited {color:#0000FF;text-decoration:none;}\n" .
            "a:active  {color:#0000FF;text-decoration:none;}\n" .
            "a:hover   {color:#FF00FF;text-decoration:underline}\n" .
            "-->\n" .
            "</style>\n" .
            "<body bgcolor='\#FFFFDD'>\n<table width=100%>\n<tr><td class=h>\n<h2>TITLE</h2>\n</td>\n<td>" .
            "<input type='button' value=' Home ' onclick='window.location=\"http://stats.wikimedia.org\"'>" .
            "</td></tr>\n</table><hr>" ;
  # to be localized some day like amny reports
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

  $colophon = "<p><small>\n" .
               $out_generated . date_time_english (time) . "\n<br>" .
               $out_author . ":" . $out_myname .
               " (<a href='" . $out_mysite . "'>" . $out_site . "</a>)\n<br>" .
               "$out_mail: $out_mymail<br>\n" .
               "$out_license" .
               "</small>\n" ;

  open HTML, '>', "$dir_out/$file_html_1" ;
  $header2 = $header ;
  $header2 =~ s/TITLE/Wikimedia articles in any project ranked by uncompressed archive size/g ;
  print HTML $header2 ;

  print HTML "See also <a href='$file_html_2'>Wikimedia articles in any project ranked by total edit count</a><p>" ;
  print HTML "<table border=1>\n" ;
  print HTML "<tr><th class=l valign=top>Rank</th><th class=l>Total<br>Size</th><th class=l>Edits</th><th class=l>Avg bytes/<br>Submit</th><th class=l>Lang</th><th class=l>Project</th><th class=l>Article</th></tr>\n" ;
  foreach $key (sort {$archivesizes {$b} <=> $archivesizes {$a}} keys %archivesizes)
  {
    if (++$archivecnt > 100) { last ; }
    ($project,$language,$title,$edits) = split (',', $key) ;
    $title =~ s/&comma;/,/g ;
    $project = $projects {$project} ;
    $size = $archivesizes {$key} ;
    if ($edits == 0)
    { $avgsize = "..." ; }
    else
    { $avgsize = sprintf ("%.0f", $size/$edits) ; }
    $size = i2KbMb ($size) ;
    $size =~ s/&nbsp;/ /g ;
    $cnt++ ;
    print "$cnt,$size,$edits,$project,$language,$title\n" ;
    $link = "<a href='http://$language.$project.org/wiki/" . encode_url($title) . "'>" . unicode_to_html ($title) . "</a>" ;
    print HTML "<tr><td class=c>$cnt</td><td class=r>$size</td><td class=r>$edits</td><td class=r>$avgsize</td><td class=l>$language</td><td class=l>$project</td><td class=l>$link</td></tr>\n" ;
  }
  print HTML "</table>$colophon</body></html>\n" ;
  close HTML ;

  $cnt = 0 ;

  open HTML, '>', "$dir_out/$file_html_2" ;
  $header2 = $header ;
  $header2 =~ s/TITLE/Wikimedia articles in any project ranked by total edit count/g ;
  print HTML $header2 ;
  print HTML "See also <a href='$file_html_1'>Wikimedia articles in any project ranked by uncompressed archive size</a><p>" ;
  print HTML "<table border=1>\n" ;
  print HTML "<tr><th class=l valign=top>Rank</th><th class=l>Total<br>Size</th><th class=l>Edits</th><th class=l>Avg bytes/<br>Submit</th><th class=l>Lang</th><th class=l>Project</th><th class=l>Article</th></tr>\n" ;
  foreach $key (sort {&Edits($b) <=> &Edits($a)} keys %archivesizes)
  {
    if (++$archivecnt2 > 100) { last ; }
    ($project,$language,$title,$edits) = split (',', $key) ;
    $title =~ s/&comma;/,/g ;
    $project = $projects {$project} ;
    $size = $archivesizes {$key} ;
    if ($edits == 0)
    { $avgsize = "..." ; }
    else
    { $avgsize = sprintf ("%.0f", $size/$edits) ; }
    $size = i2KbMb ($size) ;
    $size =~ s/&nbsp;/ /g ;
    $cnt++ ;
    print "$cnt,$size,$edits,$project,$language,$title\n" ;
    $link = "<a href='http://$language.$project.org/wiki/" . encode_url($title) . "'>" . unicode_to_html ($title) . "</a>" ;
    print HTML "<tr><td class=c>$cnt</td><td class=r>$size</td><td class=r>$edits</td><td class=r>$avgsize</td><td class=l>$language</td><td class=l>$project</td><td class=l>$link</td></tr>\n" ;
  }
  print HTML "</table>$colophon</body></html>\n" ;
  print "\nReady\n" ;
  exit ;

sub ReadStatsCsv
{
  my $project = shift ;
  my $dir = "$dir_in/csv_$project" ;
  chdir $dir ;
# my @files = glob("$dir/EditsPerArticle*.csv") ;
  my @files = glob("EditsPerArticle*.csv") ;
  print "$dir file cnt: " . $#files . "\n" ;

  foreach $file (@files)
  {
    if (! -s $file) { next ; }
    # ($code = $file) =~ s/^.*?EditsPerArticle(\w+)\.csv.*$// ;
    open IN, '<', $file ;
    $lines = 0 ;
    while ($line = <IN>)
    {
      chomp $line ;
      ($language, $edits, $edits_reg, $size, $users_reg, $users_ip, $title) = split (",", $line, 7) ;
      $title =~ s/,/&comma;/g ;
      @archivesizes {"$project,$language,$title,$edits"} = $size ;
    }
  }
  close IN ;
}


sub i2KbMb
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 10 * $Gb)
  { $v = sprintf ("%.0f",($v / $Gb)) . "&nbsp;" . $out_gigabytes ; }
  elsif ($v >= $Gb)
  { $v = sprintf ("%.1f",($v / $Gb)) . "&nbsp;" . $out_gigabytes ; }
  elsif ($v >= 10 * $Mb)
  { $v = sprintf ("%.0f",($v / $Mb)) . "&nbsp;" . $out_megabytes ; }
  elsif ($v >= $Mb)
  { $v = sprintf ("%.1f",($v / $Mb)) . "&nbsp;" . $out_megabytes ; }
  elsif ($v >= 10 * $Kb)
  { $v = sprintf ("%.0f",($v / $Kb)) . "&nbsp;" . $out_kilobytes  ; }
  elsif ($v >= $Kb)
  { $v = sprintf ("%.1f",($v / $Kb)) . "&nbsp;" . $out_kilobytes  ; }
  else
  { $v .= "&nbsp;" . $byte ; }
  return ($v) ;
}

sub Edits
{
  my $key = shift ;
  ($project,$language,$title,$edits) = split (',', $key) ;
  return ($edits) ;
}
