#!/usr/local/bin/perl

# 27 April 2010 renamed from WikiStatsScanCompactedDammitFiles.pl

  use CGI qw(:all);
  use URI::Escape;
  use Getopt::Std ;
  use Cwd ;

# grep pagecounts-20090428_fdt  -f pandemic.txt > scan.txt
# utf-8 encoder for non western article titles: http://www.motobit.com/util/url-encoder.asp

# &UncompactVisitorStats ('.') ;
# exit ;

  $bayes     = -d "/a/dammit.lt/pagecounts" ;
  $path_7za  = "/usr/lib/p7zip/7za" ;
  $path_grep = "/bin/grep" ;

# if (! $bayes)
# {
#    print "Test on Windows\n" ;
#   include IO::Uncompress::Gunzip qw(gunzip $GunzipError) ; # install IO-Compress-Zlib
#    include IO::Compress::Gzip     qw(gzip   $GzipError) ;   # install IO-Compress-Zlib
# }

  $| = 1; # flush screen output
  $true  = 1 ;
  $false = 0 ;
  $threshold = 5 ;
  $jobstart = time ;

# -i "D:/\@Wikimedia/!Perl/#Projects/Dammit Log Files/Scan Log Files/in" -o "D:/\@Wikimedia/!Perl/#Projects/Dammit Log Files/Scan Log Files/out" -f 20090429 -t 20090429 -p ''
  my $options ;
  getopt ("ioftp", \%options) ;

  if (! defined ($options {"i"})) { &Abort ("Specify input dir as -i dirname") } ;
  if (! defined ($options {"o"})) { &Abort ("Specify output dir as -o dirname") } ;
  if (! defined ($options {"f"})) { &Abort ("Specify from date as -f yyyymmdd") } ;
  if (! defined ($options {"t"})) { &Abort ("Specify till date as -t yyyymmdd") } ;
  if (! defined ($options {"p"})) { &Abort ("Specify pattern as -p \".....\"") } ;

  $dir_in   = $options {"i"} ;
  $dir_out  = $options {"o"} ;
  $datefrom = $options {"f"} ;
  $datetill = $options {"t"} ;
  $pattern  = $options {"p"} ;

  print "Pattern '$pattern'\n" ;
  if ($pattern eq "html")
  { $pattern = &GetPattern ; }

  $work = cwd() ;
  print "Work dir $work\n" ;
  if ($dir_in !~ /[\/\\]/)
  { $dir_in = "$work/$dir_in" ; }
  if ($dir_out !~ /[\/\\]/)
  { $dir_out = "$work/$dir_out" ; }

  if (! -d $dir_in)  { &Abort ("Input dir not found: $dir_in") } ;
  if (! -d $dir_out)
  {
    print "Create output dir $dir_out\n" ;
    mkdir $dir_out ;
    if (! -d $dir_out)
    { &Abort ("Output dir could not be created.") } ;
  }

  print "\nParm pattern: $pattern\n\n" ;
# $pattern = "^nl.z Amsterdam\n^de.z Leiden\n" ;
  if ($pattern =~ /^\#/)
  { $file_pattern = substr ($pattern,1) ; }
  else
  {
    $pattern =~ s/\\n/\n/gs ;
    $file_pattern = "$dir_out/pattern.txt" ;
    print "Write pattern to $file_pattern\n" ;
    open  PATTERN, ">", $file_pattern ;
    print PATTERN $pattern ;
    close PATTERN ;
  }

  if (($datefrom !~ /^20\d{6}$/))
  { &Abort ("Specify from date: as -f yyyymmdd") ; }
  if (($datetill !~ /^20\d{6}$/))
  { &Abort ("Specify till date: as -t yyyymmdd") ; }

  $dirfrom = substr ($datefrom,0,4) . "-" . substr ($datefrom,4,2) ;
  $dirtill = substr ($datetill,0,4) . "-" . substr ($datetill,4,2) ;

  print "\nScan pagecount files\nParm in:  $dir_in\nParm out: $dir_out\nParm from: $datefrom (in folder $dirfrom)\nParm till: $datetill (in folder $dirtill)\nParm pattern: $pattern\n\n" ;

  open LOG, ">>", "$work/WikiStatsScanVisitorstats.log" ;

  &ScanVisitorStats ($dir_in, $dir_out, $dirfrom, $dirtill, $datefrom, $datetill) ;
  &UncompactVisitorStats ($dir_out) ;

  &Log ("\nReady\n") ;
  close LOG ;
  exit ;

sub ScanVisitorStats
{
  my $dir_in   = shift ;
  my $dir_out  = shift ;
  my $dirfrom  = shift ;
  my $dirtill  = shift ;
  my $datefrom = shift ;
  my $datetill = shift ;

  my @dirs ;
  my @files ;

  chdir ($dir_in) || &Abort ("Cannot chdir to $dir_in\n") ;
  local (*DIR);
  opendir (DIR, ".");
  @files = () ;
  while ($file_in = readdir (DIR))
  {
    if (! -d $file_in)
    { next ; }
    if ($file_in !~ /^20\d\d-\d\d$/)
    { next ; }
    if (($file_in lt $dirfrom) || ($file_in gt $dirtill))
    { next ; }
    &Log ("Store folder $file_in\n") ;
    push @dirs, $file_in ;
  }
  &Log ("\n") ;
  closedir (DIR, ".");

  @dirs = sort @dirs ;

  foreach $dir (@dirs)
  {
    chdir ("$dir_in/$dir") || &Abort ("Cannot chdir to $dir_in/$dir\n") ;
    local (*DIR);
    opendir (DIR, ".");
    while ($file_in = readdir (DIR))
    {
      if (-d $file_in)
      { next ; }
      if ($file_in !~ /^pagecounts-\d{8,8}_fdt.7z$/)
      { next ; }
      if (($file_in lt "pagecounts-$datefrom") || ($file_in gt "pagecounts-$datetill\xFF"))
      { next ; }
      &Log ("Store file $file_in\n") ;
      push @files, "$dir/$file_in" ;
    }
    closedir (DIR, ".");
  }
  &Log ("\n") ;

  if ($#files > -1)
  {
    @files = sort @files ;

    unlink "$dir_out/scan.txt" ;
    foreach $file (@files)
    {
      my $filestart = time ;
      my $date = $file ;
      $date =~ s/^.*?-(\d{8,8})_.*$/$1/ ;
      $size = -s "$dir_in/$file" ;
      print "Scan file '$file' ($size bytes)\n" ;

      $cmd = "echo \"\# $date\" >> $dir_out/scan.txt" ;
      print "Cmd: $cmd\n" ;
      $result = `$cmd` ;

      $cmd = "7z -so e $dir_in/$file | grep -i -f $file_pattern >> $dir_out/scan.txt" ;
      print "Cmd: $cmd\n" ;
      $result = `$cmd` ;

      print "File done in " . &mmss(time - $filestart) . "\n\n" ;
    }

    print "Job done in " . &mmss(time - $jobstart) . "\n" ;
    print "Average file took " . &mmss(int (time - $jobstart)/($#files+1)) . "\n" ;
  }
  &Log ("\n\n") ;
}

sub UncompactVisitorStats
{
  &Log ("\nUncompact visitors stats\n\n") ;
  my $dir_out  = shift ;

  my $file_in  = "$dir_out/scan.txt" ;
  my $file_out1 = "$dir_out/CountsDailyPerLanguageTitles.csv" ;  # totals for full day per language:title
  my $file_out2 = "$dir_out/CountsHourlyPerLanguageTitle.csv" ; # hourly counts per language:title (hours vertical)
  my $file_out3 = "$dir_out/CountsHourlyPerLanguage.csv" ;      # hourly counts per language (hours vertical)
  my ($date,$time,$year,$month,$day) ; ;

  open IN,  '<', $file_in ;
  binmode IN ;

  while ($line = <IN>)
  {
    # process timestamp
    if ($line =~ /^#/)
    {
      $date  = substr ($line,2,8) ;
      $year  = substr ($date,0,4) ;
      $month = substr ($date,4,2) ;
      $day   = substr ($date,6,2) ;
      $date = "=DATE($year,$month,$day)" ;
      next ;
    }

    chomp ($line) ;
    ($lang,$title,$counts) = split (" ", $line) ;
    $title =~ s/,/&comma;/g ;
    $lang =~ s/\.z// ;
    $lang =~ s/\.y/2/ ;
    $counts =~ s/^\d+// ; # remove (redundant) preceding total

    # store hourly counts
    while ($counts ne "")
    {
      $letter = substr ($counts,0,1) ;
      $counts = substr ($counts,1) ;
      ($count = $counts) =~ s/^(\d+).*$/$1/ ;
      $counts =~ s/^\d+(.*)$/$1/ ;
      $h = sprintf ("%02d", ord ($letter) - ord ('A')) ;
      $time = $date . "+TIME($h,0,0)" ;

      $hits1 {"$lang,$title,\"$date\""} += $count ;
      $key = "$lang:$title" ;
      $times {$time}++ ;
      $keys  {$key} ++ ;
      $languages {$lang} ++ ;
      $hits2 {"$time,$key"} += $count ;
      $hits3 {"$time,$lang"} += $count ;
    }
  }

  close IN ;

  # file_out1: write totals for full day per language:title
  # quick way to see which titles are visisted significantly
  @lines = sort @lines ;
  open OUT, '>', $file_out1 ;
  binmode OUT ;
  foreach $key (sort keys %hits1)
  { print OUT "$key,${hits1{$key}}\n" ; }
  close OUT ;

  # file_out2: write hourly counts per language:title (hours vertical)
  open OUT, '>', $file_out2 ;
  binmode OUT ;

  # header line
  $line = "date / group" ;
  foreach $key (sort keys %keys)
  { $line .= ",$key" ; }
  $line .= "\n" ;
  print OUT $line ;

  foreach $time (sort keys %times)
  {
    $line = "\"$time\"" ;
    foreach $key (sort keys %keys)
    {
      $count = $hits2 {"$time,$key"} ;
      if ($count eq "")
      { $count = 0 ; }
      $line .= ",$count" ;
    }
    $line .= "\n" ;
    print OUT $line ;
  }
  close OUT ;

  # file_out3: write hourly counts per language (hours vertical)
  open OUT, '>', $file_out3 ;
  binmode OUT ;

  # header line
  $line = "date / group" ;
  foreach $lang (sort keys %languages)
  { $line .= ",$lang" ; }
  $line .= "\n" ;
  print OUT $line ;

  foreach $time (sort keys %times)
  {
    $line = "\"$time\"" ;
    foreach $lang (sort keys %languages)
    {
      $count = $hits3 {"$time,$lang"} ;
      if ($count eq "")
      { $count = 0 ; }
      $line .= ",$count" ;
    }
    $line .= "\n" ;
    print OUT $line ;
  }
  close OUT ;

}

sub GetPattern
{
  print "GetPattern\n" ;
  open HTML, '<', 'wikilinks.html' ;
  $pattern = "" ;
  while ($line = <HTML>)
  {
    if ($line =~ /class=\"interwiki/)
    {
      chomp ($line) ;
      $lang = $line ;
      $lang =~ s/^.*?interwiki-(\w+).*$/$1/ ;
      $title = $line ;
      $title =~ s/^.*?href=\"([^\"]+)\".*$/$1/ ;
      $title =~ s/^.*\/([^\/]+)$/$1/ ;
  #    print "[$lang] $title\n" ;
      @languages {$title} .= "$lang," ;
      @langcnt   {$title}++ ;
    }
  }
  print "\n\n\n" ;

  foreach $title (sort {$langcnt {$b} <=> $langcnt {$a}} keys %langcnt)
  {
    $count = $langcnt {$title} ;
    if ($count > 10)
    { $pattern .= "$title\n" ; }
    else
    {
      $langlist = $languages {$title} ;
      @langs = split (',', $langlist) ;
      foreach $lang (@langs)
      {
        print "$lang $title\n" ;
        $pattern .= "^$lang\.z $title\n"
      }
    }
  }
  return ($pattern) ;
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

sub mmss
{
  my $seconds = shift ;
  return (int ($seconds / 60) . " min, " . ($seconds % 60) . " sec") ;
}

