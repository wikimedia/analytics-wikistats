#!/usr/bin/perl

  use warnings ;
  use strict ;

  our $threshold = 5 ;

  our $true  = 1 ;
  our $false = 0 ;

  our $verbose = $true ;
  our $timestart = time ;
  our %bots ;

  my $time_format = '%2d hrs %2d min %2d sec' ;

# Q&D script, hard coded paths

# current approach only works for wiki with multiple dump files, numbers 1,2 etc
# caveat wp:en dump has even finer segmentation

# my $dir_dumps = "w:/# In Dumps/" ; #  tests on EZ PC
# my $dir_dumps = "/mnt/data/xmldatadumps/public/dewiki/20131008" ; # original dump(s)
  my $dir_dumps = "/a/wikistats_git/dumps/tmp" ; # extract from original dumps(s) 

# my $dir_csv   = "w:/# Out Stat1/csv_wp" ; # tests on EZ PC
# my $dir_csv   = "/a/wikistats_git/dumps/csv/csv_wp" ; # normal destination for dump counts
  my $dir_csv   = "/a/wikistats_git/dumps/tmp" ;

  my $file_bots = "$dir_csv/BotsAll.csv" ;
  my $file_csv  = "$dir_csv/EditsEditorsPerArticleGermanWpMedicines2.csv" ;

  my @bots = &ReadBots ($file_bots, 'de') ;

  our @dumps = &CollectDumps ($dir_dumps) ;
  &ParseDump ($file_csv, @bots) ;

  print "\n\nReady\n\n" ;
  exit ;


sub ReadBots
{
  print "ReadBots ->" ;

  my ($file_bots, $lang) = @_ ; # function arguments

  my $wiki = 'commons' ;
  my ($line,$bots,@bots,%bots) ;

  die "Bots file '$file_bots' not found" if ! -e $file_bots ;

  open FILE_BOTS, '<', $file_bots ;
  binmode FILE_BOTS ;
  while ($line = <FILE_BOTS>)
  {
    if ($line =~ /^$lang,/)
    { $bots = $line ; last ; }
  }
  close FILE_BOTS ;

  if ($bots eq '')
  { print "No line found for '$wiki' in '$file_bots'\n" ; }
  else
  {
    chomp $bots ; # remove eol char
    ($lang,$bots) = split (",", $bots,2) ;
    @bots = split ('\|', $bots) ; # split into array
    foreach my $bot (@bots)
    { $bot =~ s/\&comma;/,/g ; } # comma's in user name were encoded
  }

  return (@bots) ;
}

sub CollectDumps
{
  my ($dir_dumps) = @_ ;

  chdir $dir_dumps ;
  my @files = <*>;

  foreach my $file (@files)
  {
  # next if $file !~ /pages-meta-history.*?bz2/ ;
    next if $file !~ /stub-meta-history.*?bz2/ ;
    push @dumps, "$dir_dumps/$file" ;
  }
  @dumps = sort @dumps ;
  print "\n\n" . join ("\n", @dumps) . "\n";
  return @dumps ;
}

sub ParseDump
{
  my ($file_csv, @bots) = @_ ;
  my ($file_dump, $bot, $titles) ;

  foreach $bot (@bots)
  { $bots {$bot} ++ ; }

  open CSV_OUT, '>', $file_csv || die "Could not open output file '$file_csv'\n" ;
  binmode CSV_OUT ;
  print CSV_OUT "title,edits,editors,editors_R,editors_B,editors_A\n" ;

  $titles = 0 ;
  while ($#dumps > -1)
  {
    $file_dump = shift @dumps ;
    $titles = &ParseDumpFile ($file_dump, $titles) ;
  }

  print CSV_OUT "\n" ;
  print         "\n" ;
  print CSV_OUT $#bots . " bots found for wiki 'de'\n\n" ;
  print         $#bots . " bots found for wiki 'de'\n\n" ;
  print CSV_OUT "$titles titles, " . &ddhhmmss (time - $timestart, '') . "\n" ;
  print         "$titles titles, " . &ddhhmmss (time - $timestart, '') . "\n" ;

  close CSV_OUT ;
}

sub ParseDumpFile
{
  my ($file_dump, $titles) = @_ ;
  my ($line, $lines, $user, $usertype, $edits_overall, $title) ;
  my ($timestamp, $in_text, $bot, %contributors) ;
  
  print "\nProcess '$file_dump'\n" ;
  die "File '$file_dump' not found" if ! -e $file_dump ;

  if ($file_dump =~ /\.xml$/)
  { open XML, "<", "$file_dump" || die ("Input file could not be opened: '$file_dump'") ; }
  elsif ($file_dump =~ /\.bz2$/)
  { open XML, "-|", "bzip2 -dc \"$file_dump\"" || die ("Input file could not be opened: '$file_dump'") ; }
  elsif ($file_dump =~ /\.gz$/)
  { open XML, "-|", "gzip -dc \"$file_dump\"" || die ("Input file could not be opened: '$file_dump'") ; }
  else
  {  print "Unexpected extension: $file_dump\n" ; exit ; }
  
  binmode XML ;
  
  $lines = 0 ;
  while ($line = <XML>)
  {
  # if ($line =~ /\s*\<timestamp\>/) # Q&D: no check on right xml level (below <page>)
  # {
  #   chomp $line ;
  #   $line =~ s/^\s*// ;
  #   $line =~ s/\s*$// ;
  #   ($timestamp = $line) =~ s/<[^>]+>//g ;
  #   print "e $timestamp\n" ;
  #   # print CSV_OUT "e,$timestamp\n" ;
  # }
    if ($line =~ /\s*\<username\>/) # Q&D: no check on right xml level (below <revision>)
    {
      $edits_overall ++ ;
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($user = $line) =~ s/<[^>]+>//g ;
      $user =~ s/,/&comma;/g ;
      if (defined $bots {$user})
      { $usertype = 'B' ; }
      else
      { $usertype = 'R' ; }
      print "e $title $usertype $user\n" if $verbose ;
      $contributors {"$usertype $user"} ++ ;
    # print CSV_OUT "e,$usertype,$timestamp,$user\n" ;
    }

    if ($line =~ /\s*\<ip\>/) # Q&D: no check on right xml level (below <revision>)
    {
      $edits_overall ++ ;
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($user = $line) =~ s/<[^>]+>//g ;
      $user =~ s/,/&comma;/g ;
      print "e $title A $user\n" if $verbose ;
      $contributors {"A $user"} ++ ;
    # print CSV_OUT "e,A,$timestamp,$user\n" ;
    }

    if ($line =~ /\s*\<title\>/) # Q&D: no check on right xml level (below <page>)
    {
      &WriteStats ($title, %contributors) if $titles > 0 ;
      $titles++ ;
      if ($titles % 10000 == 0)
      { print "." ; }
      if ($titles % 100000 == 0)
      { print "\n$titles " ; }
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($title = $line) =~ s/<[^>]+>//g ;
      print "t $title\n" if $verbose ;
      $title =~ s/,/\&comma\;/g ;
    # print CSV_OUT "t,$title\n" ;

      undef %contributors ;
    }

  # if ($line =~ /\s*\<text/)
  # { $in_text = $true ; }

  # if ($in_text)
  # { ; }

  # if ($line =~ /<\/text/)
  # { $in_text = $false ; }
  }
  &WriteStats ($title, %contributors) ;

  close XML ;

  return ($titles) ;
}

sub WriteStats
{
  my ($title, %contributors) = @_;
  my ($edits, $editors, $editors_R, $editors_B, $editors_A, $line, $contributor, $usertype) ;
#  my %contributors = %{$contributors} ;

# foreach $contributor (sort {$contributors {$b} <=> $contributors {$a}} keys %contributors)
  foreach $contributor (keys %contributors)
  {
    $edits   += $contributors {$contributor} ;
    $editors ++ ;

    $usertype = substr ($contributor,0,1) ;
       if ($usertype eq 'R') { $editors_R++ ; }
    elsif ($usertype eq 'B') { $editors_B++ ; }
    elsif ($usertype eq 'A') { $editors_A++ ; }
    else                     { print "Unexpected usertype '$usertype' for contributor '$contributor'\n" ; }
  }

  if (! defined $title)     { $title = 0 ; }
  if (! defined $edits)     { $edits = 0 ; }
  if (! defined $editors)   { $editors = 0 ; }
  if (! defined $editors_R) { $editors_R = 0 ; }
  if (! defined $editors_B) { $editors_B = 0 ; }
  if (! defined $editors_A) { $editors_A = 0 ; }

  print CSV_OUT "$title,$edits,$editors,$editors_R,$editors_B,$editors_A\n" ;
# print CSV_OUT sprintf ("%-20s",$title) . sprintf ("%5d",$edits) . sprintf ("%5d",$editors) . sprintf ("%5d",$editors_R) . sprintf ("%5d",$editors_B) . sprintf ("%5d",$editors_A)  . "\n" ; # not csv really
  print         "$title,$edits,$editors,$editors_R,$editors_B,$editors_A\n" if $verbose ;
}

# overcomplete routine (for this script) Q&D copied from other script
sub ddhhmmss
{
  my $seconds = shift ;
  my $format  = shift ;

  my ($days,$hrs,$min,$sec,$text_days,$text_hrs,$text_min,$text_sec) ;

  $days = int ($seconds / (24*3600)) ;
  $seconds -= $days * 24*3600 ;
  $hrs = int ($seconds / 3600) ;
  $seconds -= $hrs * 3600 ;
  $min = int ($seconds / 60) ;
  $sec = $seconds % 60 ;

  if ($format eq '')
  {
    $text_days = ($days > 0) ? (($days > 1) ? "$days days, " : "$days day, ") : "" ;
    $text_hrs  = (($days + $hrs > 0) ? (($hrs > 1) ? "$hrs hrs" : "$hrs hrs") : "") . ($days + $hrs > 0 ? ", " : ""); # 2 hrs/1 hr ?
    $text_min  = ($days + $hrs + $min > 0) ? "$min min, " : "" ;
    $text_sec  = "$sec sec" ;
    return ("$text_days$text_hrs$text_min$text_sec") ;
  }
  else
  {
    return sprintf ($format,$days,$hrs,$min,$sec) if $format =~ /%.*%.*%.*%/ ;
    return sprintf ($format,      $hrs,$min,$sec) if $format =~ /%.*%.*%/ ;
    return sprintf ($format,           $min,$sec) if $format =~ /%.*%/ ;
    return sprintf ($format,                $sec) ;
  }
}

sub commify
{
  my $num = shift ;
  $num =~ s/(\d)(\d\d\d)$/$1,$2/ ;
  $num =~ s/(\d)(\d\d\d,)/$1,$2/ ;
  $num =~ s/(\d)(\d\d\d,)/$1,$2/ ;
  return $num ;
}

# in xml dumps anonymous users are often not specified by address (4 triplets) but by provider
# at least in older edits
# # hence this complicated test, also a few exceptions for self-reported false positives
sub IpAddress
{
  my $user = shift ;
  if (($user eq "Emme.pi.effe") ||
      ($user eq ".mau.") || # exceptions on it:
      ($user eq "Crochet.david.bot") || # exception on en: (Wikiversity)
      ($user eq "A.R. Mamduhi"))        # exception  on eo:
  { return ($false) ; }

  if (($user =~ m/[^\.]{2,}\.[^\.]{2,}\.[^\.]{2,4}$/) ||
      ($user =~ m/^\d+\.\d+\.\d+\./) ||
      ($user =~ m/\.com$/i))
  { return ($true) ; }
  else
  { return ($false) ; }
}



