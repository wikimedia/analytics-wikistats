#!/usr/local/bin/perl

# 4/27/2010 renamed from WikiStatsCompactDammitFiles.pl

# 17/11/2011 removed most dead code
# removed WriteTotalsPerNameSpace, these dayta were discarded anyway on next step: merging daily aggregates into monthly aggregate

  use lib "/home/ezachte/lib" ;
  use EzLib ;

  $trace_on_exit = $true ;
  ez_lib_version (13) ;

  # set defaults mainly for tests on local machine
  default_argv "-i C:/bayes_backup/a/dammit.lt/pagecounts|-t C:/bayes_backup/a/dammit.lt|-f C:/bayes_backup/a/dammit.lt|-o C:/bayes_backup/a/dammit.lt|-d 20101215" ;

  use CGI qw(:all);
  use URI::Escape;
  use Getopt::Std ;
  use Cwd ;

  $bayes = -d "/a/dammit.lt" ;
  $path_7za = "/usr/lib/p7zip/7za" ;
  if (! $bayes)
  {
    print "Test on Windows\n" ;
    use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ; # install IO-Compress-Zlib
    use IO::Compress::Gzip     qw(gzip   $GzipError) ;   # install IO-Compress-Zlib
  }

  $| = 1; # flush screen output

  $true  = 1 ;
  $false = 0 ;
  $threshold = 0 ;

  $filter = "^(?:outreach|quality|strategy|usability)\.m\$" ;
  print "Filter: $filter\n" ;
  $reg_exp_filter = qr"$filter" ;

  $track = "NonExistingPageForSquidLogMonitoring" ;
  print "Track: $track\n" ;
  $reg_exp_track = qr"$track" ;

# -i "D:/\@Wikimedia/!Perl/#Projects/Visitors Compact Log Files/in" -o "D:/\@Wikimedia/!Perl/#Projects/Visitors Compact Log Files/out"

  my $options ;
  getopt ("iodft", \%options) ;

  if (! defined ($options {"i"})) { &Abort ("Specify input dir: -i dirname") } ;
  if (! defined ($options {"o"})) { &Abort ("Specify output dir: -o dirname") } ;
  if (! defined ($options {"f"})) { &Abort ("Specify filter dir: -f dirname") } ;
  if (! defined ($options {"t"})) { &Abort ("Specify tracking dir: -t dirname") } ;
  if (! defined ($options {"d"})) { &Abort ("Specify date range: as yyyymmdd, yyyymm*, yyyy* or *") } ;

  $dir_in       = $options {"i"} ;
  $dir_out      = $options {"o"} ;
  $dir_filtered = $options {"f"} ;
  $dir_track    = $options {"t"} ;
  $daterange    = $options {"d"} ;

  $work = cwd() ;
  print "Work dir $work\n" ;

  if ($dir_in !~ /[\/\\]/)
  { $dir_in = "$work/$dir_in" ; }

  if ($dir_out !~ /[\/\\]/)
  { $dir_out = "$work/$dir_out" ; }

  if ($dir_filtered !~ /[\/\\]/)
  { $dir_filtered = "$work/$dir_filtered" ; }

  if ($dir_track !~ /[\/\\]/)
  { $dir_track = "$work/$dir_track" ; }

  if (! -d $dir_in)
  { &Abort ("Input dir not found: $dir_in") } ;

  if (! -d $dir_out)
  {
    print "Create output dir $dir_out\n" ;
    mkdir $dir_out ;
    if (! -d $dir_out)
    { &Abort ("Output dir could not be created.") } ;
  }

  if (($daterange !~ /^\d{8}$/) && ($daterange !~ /^\d{6}\*$/) && ($daterange !~ /^\d{4}\*$/) && ($daterange !~ /^\*$/))
  { &Abort ("Specify date range: as yyyymmdd, yyyymm*, yyyy* or *") ; }

  print "\nCompress pagecount files\nin:  $dir_in\nout: $dir_out\nflt: $dir_filtered\ntrack: $dir_track\ndate range: $daterange" ;
  $daterange =~ s/\*/\\d+/ ;

  open LOG, ">>", "$work/WikiStatsCompactDammitFiles.log" ;

  &CompactVisitorStats ($dir_in, $dir_out, $dir_filtered, $dir_track, $daterange) ;
# &UncompactVisitorStats ; # test only, to see if process is revertible

  &Log ("\nReady\n") ;
  close LOG ;
  exit ;

sub CompactVisitorStats
{
  my $dir_in       = shift ;
  my $dir_out      = shift ;
  my $dir_filtered = shift ;
  my $dir_track    = shift ;
  my $daterange    = shift ;

  chdir ($dir_in) || &Abort ("Cannot chdir to $dir_in\n") ;

  local (*DIR);
  opendir (DIR, ".");
  @files = () ;

  while ($file_in = readdir (DIR))
  {
    next if $file_in !~ /^pagecounts-$daterange-\d{6,6}.gz$/ ;

    push @files, $file_in ;
  }

  closedir (DIR, ".");

  @files = sort @files ;

  if (($daterange =~ /^\d{8}$/) and ($#files < 23))
  { &Abort ("Less than 24 files found for date $daterange\n" . @files) ; }

  foreach $file (@files)
  {
    $date = substr ($file,11,8) ;
    $process_dates {$date}++ ;
  }

  &Log ("\n\n") ;

  foreach $date (sort keys %process_dates)
  { &MergeFilesFullDay ($dir_in, $dir_out, $dir_filtered, $dir_track, $date) ; }
}

sub MergeFilesFullDay
{
  my $dir_in       = shift ;
  my $dir_out      = shift ;
  my $dir_filtered = shift ;
  my $dir_track    = shift ;
  my $date         = shift ;

  my $year  = substr ($date,0,4) ;
  my $month = substr ($date,4,2) ;
  my $day   = substr ($date,6,2) ;

  my ($file_out2, $out_gz) ;

  $dir_out = "$dir_out/${year}-${month}" ;
  if (! -d $dir_out)
  {
    mkdir $dir_out ;
    if (! -d $dir_out)
    { &Abort ("Output dir could not be created: $dir_out") } ;
  }

  my @files_today = () ;
  foreach $file (@files)
  {
    next if $file !~ /^pagecounts-$date-\d{6,6}.gz$/ ;

    push @files_today, $file ;
  }

  # very few times (nearly) dupiclate files are found for same hour
  # keep the largest and presumably most complete one
  for ($i = 0 ; $i < $#files_today ; $i++)
  {
    for ($j = $i+1 ; $j <= $#files_today ; $j++)
    {
      if (substr ($files_today [$i],0,25) eq substr ($files_today [$j],0,25))
      {
        $size_i = -s $files_today [$i] ;
        $size_j = -s $files_today [$j] ;
        print "${files_today [$i]}: $size_i\n" ;
        print "${files_today [$j]}: $size_j\n" ;
        if ($size_i > $size_j)
        {
          print "Keep ${files_today [$i]}\n\n" ;
          $files_today [$j]= "" ;
        }
        else
        {
          print "Keep ${files_today [$j]}\n\n" ;
          $files_today [$i]= "" ;
        }
      }
    }
  }

  $time_start = time ;
  $lines = 0 ;

  undef @in_gz ;
  undef $file_open ;
  my $time_start = time ;

  # $file_out = "pagecounts-$year$month$day_full_day" ;
  # open OUT, ">", $file_out ;
  # binmode $file_out ;

  # print "File_out2 $file_out2\n" ;

  if ($bayes)
  {
    $file_out2 = "$dir_out/pagecounts-$year$month$day" . "_h" ; # full day, hourly data

    if ((-e "$file_out2.7z") || (-e "$file_out2.bz2") || (-e "$file_out2.zip") || (-e "$file_out2.gz"))
    {
      &Log ("\nTarget file '$file_out2.[7z|bz2|zip|gz]' exists already. Skip this date.\n") ;
      return ;
    }
    if ($#files_today < 23)
    {
      &Log ("\nLess than 24 files found for target file '$file_out2.7z'. Skip this date.\n") ;
      return ;
    }

    open $out_gz2, ">", "$file_out2" || &Abort ("Output file '$file_out2' could not be opened.") ;
  }
  else
  {
    $file_out2 = "$dir_out/pagecounts-$year$month$day" . "_h.gz" ; # full day, count above threshold
    $out_gz2 = IO::Compress::Gzip->new ($file_out2) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
  }

  binmode $out_gz2 ;

  $file_filtered = "$dir_filtered/pagecounts-$year$month$day.txt" ;
  &Log ("\nFilter file: $file_filtered\n") ;
  open $out_filtered, '>', $file_filtered ;
  binmode $out_filtered ;

  $file_track = "$dir_track/_PageCountsForSquidLogTracking.txt" ;
  &Log ("Tracking file: $file_track\n\n") ;

  for ($hour = 0 ; $hour < 24 ; $hour++)
  { $file_in_found [$hour] = $false ; }

  $files_in_open  = 0 ;
  $files_in_found = 0 ;
  $langprev = "" ;
  foreach $file_in (@files_today)
  {
    next if $file_in eq "" ;

    ($hour = $file_in) =~ s/^pagecounts-\d+-(\d\d)\d+\.gz$/$1/ ;
    $hour = (0+$hour) ;
    # print "            file found '$file_in'\n" ;

    if ($bayes)
    { open $in_gz [$hour], "-|", "gzip -dc \"$file_in\"" || &Abort ("Input file '" . $file_in . "' could not be opened.") ; }
    else
    { $in_gz [$hour] = IO::Uncompress::Gunzip->new ($file_in) || &Abort ("IO::Uncompress::Gunzip failed for '$file_in': $GunzipError\n") ; }
    binmode $in_gz [$hour] ;

    $files_in_open++ ;
    $file_in_found [$hour] = $true ;
    $file_in_open  [$hour] = $true ;
    $files_in_found ++ ;
    $file = $in_gz [$hour] ;
    $line = <$file> ;
    $line =~ s/^(\w+)2 /$1.y /o  ;
    $line =~ s/^(\w+) /$1.z /o  ;

    ($lang,$title,$count [$hour],$dummy) = split (' ', $line) ;
    $key [$hour] = "$lang $title" ;
  }

  $comment = "# Wikimedia page request counts for $date, each line shows 'subproject title counts'\n" ;
  if ($threshold > 0 )
  { $comment .= "# Count for articles with less than $threshold requests per full day are omitted\n" ; }
  $comment .= "# Subproject is language code, followed by project code\n" ;
  $comment .= "# Project is b:wikibooks, k:wiktionary, n:wikinews, q:wikiquote, s:wikisource, v:wikiversity, z:wikipedia (z added by compression script: wikipedia happens to be sorted last in dammit.lt files)\n" ;
  $comment .= "# Counts format is total per day, followed by count per hour if larger than zero, hour 0..23 shown as A..X (saves up to 22 bytes per line compared to comma separated values)\n" ;
  $comment .= "# If data are missing for some hour (file missing or corrupt) a question mark (?) is shown (and for each missing hour the daily total is incremented with hourly average)\n" ;
  print $out_gz2 $comment ;

  if ($files_in_found < 24)
  {
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if (! $file_in_found [$hour])
      { $hours_missing .= "$hour," ; }
    }
    $hours_missing =~ s/,$// ;
    &Log ("Merge files: date = $date, only $files_in_found files found!\n") ;
  }
  else
  { &Log ("Merge files: date = $date\n") ; }

  if ($hours_missing ne '')
  {
    print $out_gz2 "#\n" ;
    print $out_gz2 "# In this file data are missing for hour(s) $hours_missing!\n" ;
  }

  $comment  = "#\n" ;
  $comment .= "# Lines starting with ampersand (@) show totals per 'namespace' (including omitted counts for low traffic articles)\n" ;
  $comment .= "# Since valid namespace string are not known in the compression script any string followed by colon (:) counts as possible namespace string\n" ;
  $comment .= "# Please reconcile with real namespace name strings later\n" ;
  $comment .= "# 'namespaces' with count < 5 are combined in 'Other' (on larger wikis these are surely false positives)\n" ;
  $comment .= "#\n" ;
  $comment .= "# Page titles are shown unmodified (preserves sort sequence)\n" ;
  $comment .= "#\n" ;

  print $out_gz2 $comment ;

  $key_low_prev = "" ;
  while ($files_in_open > 0)
  {
    $key_low = "\xFF\xFF";
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if (($files_in_open == 24) || ($file_in_found [$hour] && $file_in_open [$hour]))
      {
        if ($key [$hour] lt $key_low)
        { $key_low = $key [$hour] ; }
      }
    }

    if (($key_low =~ /^nov/) || ($key_low_prev =~ /^nov/))
    { &Log ("key_low '$key_low' (key_low_prev '$key_low_prev')\n") ; }

    $counts = "" ;
    $total  = 0 ;
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if (! $file_in_found [$hour])
      { $counts .= chr ($hour+ord('A')) . '?' ; }
      elsif (($files_in_open == 24) || $file_in_open [$hour])
      {
        if ($key [$hour] eq $key_low)
        {
          $counts .= chr ($hour+ord('A')) . $count [$hour] ;
          $total += $count [$hour] ;
          $file = $in_gz [$hour] ;
          # $line = <$file> ;

          while ($true)
          {
            if ($line = <$file>) #  =~ /^a/)
            {
              $line =~ s/^([\w\-]+)2 /$1.y /o  ;
              $line =~ s/^([\w\-]+) /$1.z /o  ;
             ($lang,$title,$count [$hour],$dummy) = split (' ', $line) ;
              $key [$hour] = "$lang $title" ;

              last if $lang !~ /\d/ ;
            }
            else
            {
              if ($bayes)
              { close $in_gz [$hour] ; }
              else
              { $in_gz [$hour] -> close () ; }
              $files_in_open-- ;
              $file_in_open [$hour] = $false ;
              $key [$hour] = "\xFF\xFF";

              last ;
            }
          }
        }
      }
    }
    if ($lines == 0)
    { &Log ("\nlines:  project key\n") ; }

    if (++$lines % 100000 == 0)
    { &Log ("$lines: $key_low\n") ; }

  # last if $lines > 10000 ; # test

    last if $key_low eq "\xFF\xFF" ;

    # Q&D fix for unexplained out of order error for what seems to be invalid language
    # remember : no suffix on language code gets replaced by .y or .z to fixed sort order
    # ^nov.mw nov1 1 8765
    # ^nov1.mw nov1 1 931 <--------------
    # ^nov 10_dw_oktobre 1 11421
    ($lang,$title) = split (' ', $key_low) ;
    if ($lang =~ /\d/)
    {
      $invalid_languages {$lang}++ ;
      &Log ("\nSkip invalid language '$lang'\n") ;
      next ;
    }


    if ($key_low_prev gt $key_low)
    {
      for ($hour = 0 ; $hour < 24 ; $hour++)
      { &Log ("hour $hour: key ${key[$hour]}\n") ; }

      &Abort ("Sequence error: '$key_low_prev' gt '$key_low'\n") ;
    }

    if (($key_low_prev eq $key_low)  && ($files_in_open > 0))
    {
      for ($hour = 0 ; $hour < 24 ; $hour++)
      {
         if ($file_in_open [$hour])
         { print "hour $hour: file open,   key ${key [$hour]}\n" ; }
         else
         { print "hour $hour: file closed, key ${key [$hour]}\n" ; }
      }
      &Abort ("Sequence error: '$key_low_prev' eq '$key_low'\n") ;
    }

    # print OUT "$key_low $total$counts\n" ;
    ($lang,$title) = split (' ', $key_low) ;

    $title =~ s/\%20/_/g ;
    $title =~ s/\%3A/:/gi ;
#   $title =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;
    if (($title !~ /\:/) || ($title =~ /^:[^:]*$/)) # no colon or only on first position
    { $namespace = 'NamespaceArticles' ; }
    else
    { ($namespace = $title) =~ s/([^:])\:.*$/$1/ ; }
    # print "KEY $key_low -> $namespace\n" ;

    if (($lang ne $langprev) && ($langprev ne ""))
    {
      $filter_matches = $lang =~ $reg_exp_filter ;
      if ($filter_matches)
      { print "F $lang\n" ; }
      # else
      # { print "- $lang\n" ; }
    }
    $langprev = $lang ;

    if (($files_in_found < 24) && ($files_in_found > 0)) # always > 0 actually
    { $total = sprintf ("%.0f",($total / $files_in_found) * 24) ; }

    if ($filter_matches)
    { print $out_filtered "$key_low $total$counts\n" ; }

    if ($key_low =~ $reg_exp_track) # track count for NonExistingPageForSquidLogMonitoring on en.z
    {
      open $out_track, '>>', $file_track ;
      binmode $out_track ;
      print $out_track "$key_low $total$counts\n" ;
      close $out_track ;
    }

    if ($total >= $threshold)
    { print $out_gz2 "$key_low $total$counts\n" ; }

    $key_low_prev = $key_low ;
  # print "OUT $key_low $counts\n" ;
  }

  &WriteTotalsPerNamespace ($out_gz2, $langprev) ;

  &Log ("File production took " . (time-$time_start) . " seconds\n\n") ;

  &Log ("[$lines, $files_in_open] $key_low\n") ;
# close OUT ;

  if ($bayes)
  {
    close $out_gz2 ;
    close $out_filtered ;

#    $cmd = "$path_7za a $file_out2.7z $file_out2" ;
#    $result = `$cmd` ;
#    if ($result =~ /Everything is Ok/s)
#    {
#      $result =~ s/^.*?(Updating.*?)\n.*$/$1 -> OK/s ;
#      unlink $file_out2 ;
#      foreach $file_in (@files_today)
#      {
#        print "unlink $dir_in/$file_in\n" ;
#        unlink "$dir_in/$file_in" ;
#      }
#    }
#    else
#    {
#      print "Delete $file_out2.7z\n" ;
#      unlink "$file_out2.7z" ;
#    }


    $cmd = "bzip2 -9 -v $file_out2" ;
    &Log ("\n\n$cmd ->\n") ;
    $result = `$cmd` ;
    &Log ("\n\n") ;

  # if ($true)  # qqq
    if ($false)
    {
      foreach $file_in (@files_today)
      {
        print "unlink $dir_in/$file_in\n" ;
        unlink "$dir_in/$file_in" ;
      }
    }
    else
    {
      # print "Delete $file_out2.7z\n" ;
      # unlink "$file_out2.7z" ;
    }

    &Log ("Compression took " . (time-$time_start_compression) . " seconds\n\n") ;
  }
  else
  {
    $out_gz2->close() ;
    close $out_filtered ;
  }

  &Log ("\nRecords skipped for invalid languages:\n") ;
  foreach $key (sort keys %invalid_languages)
  { &Log ("$key: ${invalid_languages {$key}}\n") ; }

  &Log ("\nTotals per namespace written: $lines_namespace_counts\n") ;
  &Log ("Processed in " . (time-$time_start) . " seconds\n\n") ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print LOG $msg ;
}

sub Abort
{
  $msg = shift ;
  print "Abort script\nError: $msg\n" ;
  print LOG "Abort script\nError: $msg\n" ;
  exit ;
}

# http://article.gmane.org/gmane.science.linguistics.wikipedia.technical/38154/match=new+statistics+stuff
# http://svn.wikimedia.org/viewvc/mediawiki/trunk/webstatscollector/
# https://bugzilla.wikimedia.org/show_bug.cgi?id=13541
# http://de.wikipedia.org/w/api.php?action=query&meta=siteinfo&siprop=general|namespaces|namespacealiases

# Ideas:
# 1 namespace string -> namespace number ? (may not save much space: compress will deal with recurring patterns like these)
# 2 frequenty distribution hits per file per first letter _-> manifest crawler
#   assuming crawler collects articles in alphabetical order
# 3 first letter uppercase -> sort (in sections per first two chars ?)


