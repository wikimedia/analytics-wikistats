#!/usr/bin/perl

  use Time::Local ;

  $|       = 1; # Flush output
  $verbose = 1 ;
  $true    = 1 ;
  $false   = 0 ;

#  $file_bots = "d:/\@wikimedia/# out stat1/csv_wo/BotsAll.csv" ;
  $file_xml = "d:/\@wikimedia/# in dumps/itwikivoyage-20131211-stub-meta-history.xml" ;
  $file_xml = "/mnt/data/xmldatadumps/public/itwikivoyage/20131110/itwikivoyage-20131110-pages-meta-history.xml.bz2" ;
#  die "Bot file not found!" if ! -e $file_bots ;
  die "Xml file not found!" if ! -e $file_xml ;

#  open CSV_IN, '<', $file_bots ;
#  binmode CSV_IN ;
#  @botsall = <CSV_IN> ;
#  close CSV_IN ;

  &ProcessDump ("wo", "it", "/mnt/data/xmldatadumps/public/itwikivoyage/20131110/itwikivoyage-20131110-pages-meta-history.xml.bz2") ;
# &ProcessDump ("wo", "it", "d:/\@wikimedia/# in dumps/itwikivoyage-20131211-stub-meta-history.xml") ;

  print "\nReady\n" ;
  exit ;

sub ProcessDump
{
  my ($project,$wiki,$path) = @_ ;
  my $in_text = $false;

  ($wp = $wiki) =~ s/wiki//g ;

  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;
  my $titles = 0 ;

  print "$time Process project $project, wiki $wiki:\n\n" ;
  $timestart = time ;

#  my $bots = '' ;
#  my @bots ;
#  my %bots ;

#  foreach $line (@botsall)
#  {
#    if ($line =~ /$wp,/)
#    { $bots = $line ; last ; }
#  }

#  if ($bots eq '')
#  { print "No line found for $wiki in BotsAll.csv\n" ; }
#  else
#  {
#    chomp $bots ;
#    ($lang,$bots) = split (",", $bots,2) ;
#    @bots = split ('\|', $bots) ;
#    foreach $bot (@bots)
#    {
#      $bot =~ s/\&comma;/,/g ;
#      $bots {$bot} ++ ;
#    }
#  }

  if ($path =~ /\.xml$/)
  {
    open XML, "<", $path || die ("Input file could not be opened: $path") ;
    binmode XML ;
  }
  elsif ($path =~ /\.gz$/)
  {
    open XML, "-|", "gzip -dc \"$path\"" || die ("Input file could not be opened: $path") ;
    binmode XML ;
  }
  elsif ($path =~ /\.bz2$/)
  {
    open XML, "-|", "bzip2 -dc \"$path\"" || die ("Input file could not be opened: $path") ;
    binmode XML ;
  }
  else
  {  print "Unexpected extension: $path\n" ; exit ; }

#  open CSV_OUT, '>', "/a/wikistats/csv/csv_wp/EditsTimestampsOldest" . uc ($wp) . ".csv" ;
## open CSV_OUT, '>', "/a/wikistats/csv/csv_wp/EditsTimestamps" . uc ($wp) . ".csv" ;
## open CSV_OUT, '>', "/a/wikistats/csv/csv_wx/EditsTimestamps" . uc ($wp) . ".csv" ;
#  binmode CSV_OUT ;
#  print CSV_OUT "# n=namespace, t=title, e=edit, R=registered user, B=bot. A=anonymous\n" ;
  my $raw_text = '' ;
  my $redirect = $false ;
  my $redirects = 0 ;
  open TMP, '>', '/a/wikistats_git/tmp/itwikivoyage_titles.txt' ;
  while ($line = <XML>)
  {
    if ($line =~ /\s*\<timestamp\>/) # Q&D: no check on right xml level (below <page>)
    {
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($timestamp = $line) =~ s/<[^>]+>//g ;
      # print "e $timestamp\n" ;
      # print CSV_OUT "e,$timestamp\n" ;
    }

    if ($line =~ /\s*\<username\>/) # Q&D: no check on right xml level (below <revision>)
    {
      $user =~ s/,/&comma;/g ;
      if ($bots {$user} > 0)
      { $usertype = 'R' ; }
      else
      { $usertype = 'B' ; }
    # print "e $usertype $timestamp $user\n" if $verbose ;
    # print CSV_OUT "e,$usertype,$timestamp,$user\n" ;
    }

    if ($line =~ /\s*\<ip\>/) # Q&D: no check on right xml level (below <revision>)
    {
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($user = $line) =~ s/<[^>]+>//g ;
      $user =~ s/,/&comma;/g ;
    # print "e A $timestamp $user\n" if $verbose ;
    # print CSV_OUT "e,A,$timestamp,$user\n" ;
    }

    if ($line =~ /\s*\<title\>/) # Q&D: no check on right xml level (below <page>)
    {
      $redirect = $false ;

      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($title = $line) =~ s/<[^>]+>//g ;
    }

    if ($line =~ /\s*\<redirect/)
    {
      $redirect = $true ;
    }

    if ($line =~ /\s*\<text/)
    {
      $in_text = $true ;
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      $raw_text = $line ;
    }

    if ($in_text)
    {
      chomp $line ;
      $raw_text .= $line ;
# {{Wiki Loves Monuments 2012|in}}
    }

    if ($line =~ /<\/text/)
    {
      chomp $line ;
      $raw_text .= $line ;
      $in_text = $false ;
    }

    if ($line =~ /<\/page>/)
    {
      next if $title =~ /^Discussion[ei]/ ;
      next if $title =~ /^(?:Media|Speciale|Utente|Wikivoyage|File|MediaWiki|Template|Aiuto|Categoria|Portale|Tematica|Modulo):/ ;
      if ($redirect)
      {
        print TMP "r,$title\n" ; 
        next ;
      }
      if ($raw_text !~ /\[\[.*?\]\]/)
      {
        print TMP "l,$title\n" ;
        next ;
      }

    # if ($title =~ /:/)
    # { print "XXXXX >> $title\n" ; }
      $titles++ ;
      if ($titles % 10000 == 0)
      { print "." ; }
      if ($titles % 100000 == 0)
      { print "\n$titles " ; }
      print "t $title\n" if $verbose ;
      # $title =~ s/,/\&comma\;/g ;
      print TMP "t,$title\n" ;
    }
  }
  close TMP ;
#  close CSV_OUT ;

  print ("$titles titles, " . &ddhhmmss (time - $timestart). "\n") ;

}

sub ddhhmmss
{
  my $seconds = shift ;
  my $format  = shift ;

  $days = int ($seconds / (24*3600)) ;
  $seconds -= $days * 24*3600 ;
  $hrs = int ($seconds / 3600) ;
  $seconds -= $hrs * 3600 ;
  $min = int ($seconds / 60) ;
  $sec = $seconds % 60 ;

  if ($format eq '')
  {
    $days = ($days > 0) ? (($days > 1) ? "$days days, " : "$days day, ") : "" ;
    $hrs  = (($days + $hrs > 0) ? (($hrs > 1) ? "$hrs hrs" : "$hrs hrs") : "") . ($days + $hrs > 0 ? ", " : ""); # 2 hrs/1 hr ?
    $min  = ($days + $hrs + $min > 0) ? "$min min, " : "" ;
    $sec  = "$sec sec" ;
    return ("$days$hrs$min$sec") ;
  }
  else
  {
    return sprintf ($format,$days,$hrs,$min,$sec) if $format =~ /%.*%.*%.*%/ ;
    return sprintf ($format,      $hrs,$min,$sec) if $format =~ /%.*%.*%/ ;
    return sprintf ($format,           $min,$sec) if $format =~ /%.*%/ ;
    return sprintf ($format,                $sec) ;
  }
}


