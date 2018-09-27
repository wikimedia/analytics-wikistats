#!/usr/local/bin/perl

# count visitors per project per day
#                per project per week (smoother, no workday/weekend fluctuation)
#                per project per month
#                            same, but calculated as visits per second
#                            same, as percentage of total traffic
#                per project per month, per hour of the day (is en: visited mostly at US daylight times ?)

# http://leuksman.com/log/2007/06/07/wikimedia-page-views/

# note: all projectcounts files are always processed, since these are tiny that will do for now,
#       but some day make this incremental, once functionality is stable

# to do: AdjustForMissingFilesAndUndercountedMonths for week and day level files

# Added May 2001:
# For analytics database one file is written for all projects and languages combined,
# with per month, not normalized and normalized page view counts in one row.

  use Archive::Tar;
  $tar = Archive::Tar->new;

  use lib "/home/ezachte/wikistats/dammit.lt/perl" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (4) ;

  # set defaults mainly for tests on local machine
  default_argv "-i 'w:/# In Dammit.lt/projectcounts/test_in'|-o 'w:/# In Dammit.lt/projectcounts/test_out'" ;

  # by default process up to and including last completed month,
  # to recreate older stats, set following variables which will be used instead of system time
  # $assume_current_year  = 2012 ;
  # $assume_current_month = 4 ;
  # (to do: make this scripts parameters)

  $| = 1; # flush screen output
  $true  = 1 ;
  $false = 0 ;
  $timestart = time ;
  $maxpopularwikis = 25 ;
  $do_normalize = $true ;
  $no_normalize = $false ;

  $wc1 = '1.0' ; # webstats collector version 
  $wc3 = '3.0' ;

# %descriptions = (day     => PageViewsPerDay,
#                  week    => PageViewsPerWeek,
#                  weekday => PageViewsPerWeekday,
#                  month   => PageViewsPerMonth,
#                  hour    => PageViewsPerHour ) ;
# renamed to:
 
  %descriptions = (day     => projectviews_per_day,
                   week    => projectviews_per_week,
                   weekday => projectviews_per_weekday,
                   month   => projectviews_per_month,
                   hour    => projectviews_per_hour ) ;

  &LogArguments ;
  &ParseArguments ;
  &SetComparisonPeriods ;
  &InitProjectNames ;

# &ScanFiles ; # (legacy) flat files
  &ReadMetaLanguages ;
  &ScanWhiteList ;
  &ScanTarFiles ; # fill @files with sorted list of file names starting with 'projectcounts'
  &FindMissingFiles ;
  &CountProjectViews ;
  &AdjustForMissingFilesAndUndercountedMonths ;

  &WriteCsvFilesPerPeriod ($no_normalize);
# &WriteCsvHtmlFilesPopularWikis ($no_normalize) ; # used for old report card  

  # normalize to 30 days
  foreach $project (sort keys %{$totals {"month"}})
  {
    foreach $key (keys %{$totals {"month"} {$project}})
    {
      ($lang,$date) = split ',', $key ;
      ($year,$month) = split "\/", $date ;
      $count = $totals {"month"} {$project} {$key} ;
      $count2 = sprintf ("%.0f", 30 / days_in_month ($year, $month) * $count) ;
      $totals {"month"} {$project} {$key} = $count2 ;
    }
  }

  # only after normalization, also get counts per project
  foreach $project (sort keys %{$totals {"month"}})
  {
    foreach $key (keys %{$totals {"month"} {$project}})
    {
      ($lang,$date) = split ',', $key ;
      $count = $totals {"month"} {$project} {$key} ;

      next if $project eq 'wx' and $lang ne 'commons' ;

      if ($lang eq 'commons')
      { $project2 = 'Commons' ; }
      elsif ($lang =~ /\.m/)
      { $project2 = ucfirst "$project mobile" ; }
      else { $project2 = ucfirst $project ; }

      $projects2 {$project2}++ ;
      $projects2 {'all'}++ ;

      ($project3 = $project2) =~ s/ .*$// ;

      $projects3 {$project3}++ ;
      $projects3 {'all'}++ ;

      # split is mobile or non-mobile
      # combined is mobile plus non-mobile views for one project
      # all = views for all wikis from all projects

      # $totals_project_month_split {$project2} {$date} += $count ;
      # if ($totals_project_month_split {$project2} {$date} > $totals_project_month_split_max {$project2})
      # { $totals_project_month_split_max {$project2} = $totals_project_month_split {$project2} {$date} ; }

      if ($lang =~ /\.m/)
      {
        $totals_project_month_mobile {"$project3"} {$date} += $count ;
        $totals_project_month_mobile {"all"}       {$date} += $count ;
      }
      else
      {
        $totals_project_month_non_mobile {"$project3"} {$date} += $count ;
        $totals_project_month_non_mobile {"all"}       {$date} += $count ;
      }

      $totals_project_month_combined {"$project3"} {$date} += $count ;
      if ($totals_project_month_combined {$project3} {$date} > $totals_project_month_combined_max {$project3})
      { $totals_project_month_combined_max {$project3} = $totals_project_month_combined {$project3} {$date} ; }

      $totals_project_month_combined {"all"} {$date} += $count ;
      if ($totals_project_month_combined {"all"} {$date} > $totals_project_month_combined_max {"all"})
      { $totals_project_month_combined_max {"all"} = $totals_project_month_combined {"all"} {$date} ; }
    }
  }

  &WriteCsvFilesPerPeriod ($do_normalize);
  &WriteCsvHtmlFilesPopularWikis ($do_normalize) ; 

  print "\nErrors:\n\n" ;
  foreach $error (sort {$errors1 {$b} <=> $errors1 {$a}} keys %errors1)
  { print $errors1 {$error} . ": $error\n" ; }
  foreach $error (sort {$errors2 {$b} <=> $errors2 {$a}} keys %errors2)
  { print $errors2 {$error} . ": $error\n" ; }

  &WriteTrendsMobileViews ;
  &WriteRatioMobileViews ;
  
  &LogT ("\nReady\n") ;
  exit ;

#  open OUT, ">", "$path_csv/viewcounts.csv" ;
#  $out = "date," ;
#  foreach $project (sort  {$total {$b} <=> $total {$a}} keys %projects)
#  {
#    if ($project =~ /^[a-z\-]+$/)
#    { $out .= "$project," ; }
#  }
#  $out =~ s/,$/\n/ ;
#  print OUT $out ;

#  foreach $date (sort  {$a cmp $b} keys %dates)
#  {
#    # &LogT ("Date $date\n") ;
#    $out = substr ($date,6,2) . "/" . substr ($date,4,2) . "/" . substr ($date,0,4) . "," ;
#    foreach $project (sort  {$total {$b} <=> $total {$a}} keys %projects)
#    {
#      if ($project =~ /^[a-z\-]+$/)
#      {
#        $key = "$date $project" ;
#        $count = $counts {$key} ;
#        $out .= "$count," ;
#      }
#    }
#    $out =~ s/,$/\n/ ;
#    print OUT $out ;
#  }

#  close OUT ;

#  # Excel default x axis 1-24
#  # should be 0-23 and 0 is actually 23.00-00.00 hrs   1 = 00.00-01.00 hrs
#  # 2nd dip on nl: at 18 - 19 is actually period 1600-1800

#  open OUT, ">", "$path_csv/viewcountsperhour.csv" ;
#  $out = "hour," ;
#  foreach $project (sort  {$total {$b} <=> $total {$a}} keys %projects)
#  {
#    if ($project =~ /^[a-z\-]+$/)
#    { $out .= "$project," ; }
#  }
#  $out =~ s/,$/\n/ ;
#  print OUT $out ;

#  foreach ($h = 0 ; $h < 24 ; $h++)
#  {
#    $hour = sprintf ("%02d",$h) ;
#    # &LogT ("Date $date\n") ;
#    $out = "$hour," ;
#    foreach $project (sort  {$total {$b} <=> $total {$a}} keys %projects)
#    {
#      if ($project =~ /^[a-z\-]+$/)
#      {
#        $key = "$hour $project" ;
#        $count = (sprintf "%.2f", (100 * $hours {$key}) / $total {$project}) . "%" ;
#        $out .= "$count," ;
#      }
#    }
#    $out =~ s/,$/\n/ ;
#    print OUT $out ;
#  }

#  close OUT ;

#  open OUT, ">", "$path_csv/viewcountsperweekday.csv" ;
#  $out = "weekday," ;
#  foreach $project (sort  {$total {$b} <=> $total {$a}} keys %projects)
#  {
#    if ($project =~ /^[a-z\-]+$/)
#    { $out .= "$project," ; }
#  }
#  $out =~ s/,$/\n/ ;
#  print OUT $out ;

#  foreach ($d = 0 ; $d < 7 ; $d++)
#  {
#    $weekday = sprintf ("%02d",$d) ;
#    $out = (qw(Mon Tue Wed Thu Fri Sat Sun))[$d] . "," ;
#    foreach $project (sort  {$total {$b} <=> $total {$a}} keys %projects)
#    {
#      if ($project =~ /^[a-z\-]+$/)
#      {
#        $key = "$weekday $project" ;
#        $count = (sprintf "%.2f", (100 * $weekdays {$key}) / $total {$project}) . "%" ;
#        $out .= "$count," ;
#      }
#    }
#    $out =~ s/,$/\n/ ;
#    print OUT $out ;
#  }

  close OUT ;

#  foreach $key (sort  {$a cmp $b} keys %counts)
#  {
#    ($date,$project) = split (' ', $key) ;
#    if ($project !~ /^[\w\-]+$/)
#    { next ; }
#    &LogT ("$date $project\n") ;
#  }

  &Log ("Ready") ;
  close LOG ;
  exit ;

sub LogArguments
{
  my $arguments ;
  getopt ("ijolmpftw", \%options) ;
  foreach $arg (sort keys %options)
  { $arguments .= " -$arg " . $options {$arg} . "\n" ; }
  print ("\nArguments\n$arguments\n") ;
# &Log ("\nArguments\n$arguments\n") ;
}

sub ParseArguments
{
  foreach $key (keys %options)
  {
    $options {$key} =~ s/^\s*(.*?)\s*$/$1/ ;
    $options {$key} =~ s/^'(.*?)'$/$1/ ;
    $options {$key} =~ s/\@/\\@/g ;
  }

  getopt ("ijoalpftws", \%options) ;

  die ("Specify input folder for projectcounts files as: -i path")  if (! defined ($options {"i"})) ;
  die ("Specify input folder 2 for projectviews files as: -j path") if (! defined ($options {"j"})) ;
  die ("Specify output folder as: -o path'")                        if (! defined ($options {"o"})) ;
  die ("Specify date to switch from input -i to -j as: -s yyyy-mm") if (! defined ($options {"s"})) ;
 
  $path_in1    = $options {"i"} ;
  $path_in2    = $options {"j"} ;
  $path_csv    = $options {"o"} ;
  $path_white  = $options {"w"} ;
  $file_meta   = $options {"m"} ;
  $date_switch = "201505" ; # $options {"s"} ; # hmm doesn't rcv -s arg

  die "Input folder '$path_in' does not exist"         if (! -d $path_in1) ;
  die "Output folder '$path_csv' does not exist"       if (! -d $path_csv) ;
  die "White list folder '$path_white' does not exist" if (! -d $path_white) ;
  die "Languages meta data file '$file_meta' does not exist" if (! -e $file_meta) ;
  die "Always specify project (-p) when you specify language (-l)" if ((! defined ($options {"p"})) && (defined ($options {"l"})));
  die "Specify date to switch from input -i to -j as: -s yyyy-mm" if $date_switch !~ /^\d\d\d\d\d\d$/ ;
  die "Input folder 2 '$path_in2' does not exist" if $path_in2 ne '' and ! -d $path_in2 ;

  $select_project  = $options {"p"} ;
  $select_language = $options {"l"} ;

  if ($select_project eq "")
  { $select_project = '+' ; } # '*' is more intuitive for 'all' but invalid in Windows
  if ($select_language eq "")
  { $select_language = '+' ; }

  # $suffix_out = "\-$select_project\-$select_language" ;
  $suffix_out = "\-$select_language" ;
  $suffix_out =~ s/\-\+$/_all/g ;

  print "Input  folder: $path_in1\n" ;
  print "Input  folder 2: $path_in2\n" ;
  print "Output folder: $path_csv\n" ;
  print "White list in: $path_white\n" ;
  print "Select project: $select_project\n" ;
  print "Select language: $select_language\n" ;
  print "Suffix: $suffix_out\n\n" ;
  print "Date switch input processing from -i to -j: $date_switch\n" ;

  if (defined ($options {"f"}))
  {
    $date_from = $options {"f"} ;
    if (($date_from !~ /^2\d\d\d$/) &&
        ($date_from !~ /^2\d\d\d\d\d$/) &&
        ($date_from !~ /^2\d\d\d\d\d\d\d$/))
    { die "Invalid end date $date_till: format=yyyy[mm[dd]]\n" ; }
    $date_from = substr ($date_from . "0101", 0,8) ;
    print "Select from date (yyyymmdd): $date_from\n" ;
  }

  if (defined ($options {"t"}))
  {
    $date_till = $options {"t"} ;
    if (($date_till !~ /^2\d\d\d$/) &&
        ($date_till !~ /^2\d\d\d\d\d$/) &&
        ($date_till !~ /^2\d\d\d\d\d\d\d$/))
    { die "Invalid end date $date_till: format=yyyy[mm[dd]]\n" ; }
    if ($date_till =~ /^\d\d\d\d$/)
    { $date_till .= "12" ; }
    if ($date_till =~ /^\d\d\d\d\d\d$/)
    { $date_till .= "31" ; }
    print "Select till date (yyyymmdd): $date_till\n" ;
  }
  my ($dd,$mm,$yy) = (localtime(time))[3,4,5] ;
  my $date = sprintf ("%04d%02d%02d", $yy+1900, $mm+1, $dd) ;
  if (($date_till eq "") || ($date_till gt $date))
  {
    print "Force till date (yyyymmdd): $date\n" ;
    $date_till = $date ;
  }
  if (($date_from gt $date_till) && ($date_till ne ""))
  { die "You specified invalid date range: $date_from - $date_till\n" ; }

  print "\n" ;

  $file_trends_mobile_csv   = "$path_csv/csv_wp/projectviews_per_month_mobile_trends.csv" ;
  $file_ratio_mobile_wp_csv = "$path_csv/csv_wp/projectviews_per_month_mobile_trends_matrix_wp.csv" ;
  $file_ratio_mobile_csv    = "$path_csv/csv_wp/projectviews_per_month_mobile_ratio.csv" ;
  $file_perc_mobile_txt     = "$path_csv/csv_wp/projectviews_per_month_mobile_ratio_per_lang_or_region.txt" ;
}

sub SetComparisonPeriods
{
  my ($month,$year) = (localtime(time))[4,5] ;
  my @months = qw(Xxx Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec) ;

  # by default process up to and including last completed month, may be overruled here
  if ($assume_current_year ne '')
  { $year = $assume_current_year - 1900 ; }
  if ($assume_current_month ne '')
  { $month = $assume_current_month - 1 ; }

  $year_now  = $year + 1900 ;
  $month_now = $month + 1 ;

  ($year,$month) = $month > 0 ? ($year,$month-1) : ($year-1,11) ;
  $year_  = $year ;
  $month_ = $month ;

  $month_0      = sprintf ("%04d/%02d",$year+1900,  $month+1) ;
  $month_0_file = sprintf ("%04d_%02d",$year+1900,  $month+1) ; # for filenames
  $month_0_minus_12 = sprintf ("%04d/%02d",$year+1900-1,$month+1) ;
  ($year,$month) = $month > 0 ? ($year,$month-1) : ($year-1,11) ;
  $month_0_minus_1 = sprintf ("%04d/%02d",$year+1900,$month+1) ;

  print "\nWrite trend data up till month: $month_0 to $month_0_file\n\n" ;
  print "Compare with previous month: $month_0_minus_1, previous year: $month_0_minus_12\n\n" ;

#  $csv_recent_months = "project," ;
#  $year  = $year_ - 1 ;
#  $month = $month_ ;
#  for ($m = 0 ; $m <= 12 ; $m++)
#  {
#    $recent_months [$m] = sprintf ("%04d/%02d", $year+1900, $month+1) ;
#    $csv_recent_months .= sprintf ("%02d/%04d", $month+1, $year+1900) . "," ;
#    ($year,$month) = $month < 11 ? ($year,$month+1) : ($year+1,0) ;
#  }
#  $csv_recent_months =~ s/,$// ;
#  $csv_recent_months .= "\n" ;

  $year_add  = 2008 ;
  $month_add = 7 ;

  $months_recent = 0 ;

  $csv_recent_months = "project," ;
  while (($year_add < $year_now) || (($year_add == $year_now) && ($month_add < $month_now)))
  {
    $recent_months [$months_recent] = sprintf ("%04d/%02d", $year_add, $month_add) ;
    $csv_recent_months .= sprintf ("%02d/%04d", $month_add, $year_add) . "," ;
    ($year_add,$month_add) = $month_add < 12 ? ($year_add,$month_add+1) : ($year_add+1,1) ;
    $months_recent ++ ;
  }
  $csv_recent_months =~ s/,$// ;
  $csv_recent_months .= "\n" ;
  # print $csv_recent_months ; exit ;
}

# legacy, now scan tar files
#sub ScanFiles
#{
#  &LogT ("ScanFiles\n") ;

#  @files = () ;

#  $hour_oldest = "\xFF" ;
#  $hour_newest = "" ;

#  chdir ($path_in) || die "Cannot chdir to $path_in\n";
#  local (*DIR);
#  opendir (DIR, ".");
#  while ($file_in = readdir (DIR))
#  {
#    next if $file_in !~ /^projectcounts/ ;
#    next if -d $file_in ;
#    next if -s $file_in == 0;
#    next if ($date_from ne "") && ($file_in lt "projectcounts-$date_from") ;
#    next if ($date_till ne "") && ($file_in gt "projectcounts-$date_till") ;

#    next if $file_in ge "projectcounts-20100611-000000" and $file_in lt "projectcounts-20100617-000000" ; # bad measurements on these dates
#    next if $file_in ge "projectcounts-20100627-000000" and $file_in lt "projectcounts-20100628-000000" ; # bad measurements on these dates

#    push @files, $file_in ;
#    $hour_in = substr ($file_in, 14, length ($file_in)-18) ; # ignore minutes and seconds
#    $hours_found {$hour_in} ++ ;

#    if ($hour_in lt $hour_oldest) { $hour_oldest = $hour_in ; }
#    if ($hour_in gt $hour_newest) { $hour_newest = $hour_in ; }
#  }
#  closedir (DIR);

#  $filecnt = $#files+1 ;
#  &LogT ("Oldest hour: $hour_oldest\n") ;
#  &LogT ("Newest hour: $hour_newest\n") ;
#  &LogT ("Files found: $filecnt\n\n") ;

#  @files = sort {$a cmp $b} @files ;
#}

sub ReadMetaLanguages
{
  open CSV_LANGUAGES, '<', $file_meta ;
  while ($line = <CSV_LANGUAGES>)
  {
    next if $line =~ /^#/ ;
    next if $line =~ /^\s*$/ ;

    chomp $line ;
    ($lang,$name,$speakers,$regions) = split (',', $line) ;

    $regions =~ s/\|C// ; # ignore China as separate region, is also tagged as Asia
    $regions =~ s/\|I// ; # ignore India as separate region, is also tagged as Asia
    $regions =~ s/\|/\//g ; # A|B -> A/B

    $names    {$lang} = "$name" ;
    $speakers {$lang} = "$speakers" ;
    $regions  {$lang} = "$regions" ;
  }
  close CSV_LANGUAGES ;
}

sub ScanWhiteList
{
  print "$path_white/WhiteListWikis.csv\n" ;
  open CSV_WHITE_LIST, '<', "$path_white/WhiteListWikis.csv" || die "Could not open $path_white/WhiteListWikis.csv" ;
  while ($line = <CSV_WHITE_LIST>)
  {
    chomp $line ;
    $whitelist {$line} ++ ;
    $whitelist {"$line.m"} ++ ;
    $whitelist {"$line.z"} ++ ;
  }
  close CSV_WHITE_LIST ;
}

sub ScanTarFiles
{
  &LogT ("ScanTarFiles\n") ;

  @files = () ;

  $hour_oldest = "\xFF" ;
  $hour_newest = "" ;

  &ScanTarFolder ($path_in1) ;
  &ScanTarFolder ($path_in2) ;

  $filecnt = $#files+1 ;

  die "No files to process! Abort" if $filecnt == 0 ;

  &LogT ("All tar files read\n") ;
  &LogT ("Oldest hour: $hour_oldest\n") ;
  &LogT ("Newest hour: $hour_newest\n") ;
  &LogT ("Files found: $filecnt\n\n") ;

  @files = sort {$a cmp $b} @files ;
}

sub ScanTarFolder
{
  my $path_in = shift ;
  print "\nScanTarFolder $path_in\n" ;
  
  chdir ($path_in) || die "Cannot chdir to $path_in\n";
  local (*DIR);
  opendir (DIR, ".");
  while ($file_in = readdir (DIR))
  {
    next if $file_in !~ /^project(counts|views)-\d\d\d\d\.tar$/ ;
    next if -d $file_in ;
    next if -s $file_in == 0;

    ($projectfilename = $file_in) =~ s/\-.*$// ; # keep projectcounts or projectviews

  # next if $file_in !~ /(?:2013|2014|2015)\.tar/ ; # qqq speedup tests
  # next if $file_in !~ /(?:2015)\.tar/ ; # 2016-02-21 qqq speedup tests

    print "Read tar file '$file_in'\n" ;
    $tar->read($file_in);
    @files_tar = $tar->list_files ;
    foreach my $file (@files_tar)
    {
    # next if $file lt "$projectfilename-20121100-000000" or  $file gt "$projectfilename-20130200-000000" ; # #test
 
    # next if $file !~ /2014(?:10)/ ; # qqq speedup tests
      next if $file !~ /^$projectfilename-\d{8}-\d{6}$/ ;
      next if $date_from ne "" and $file lt "$projectfilename-$date_from" ;
      next if $date_till ne "" and $file gt "$projectfilename-$date_till" ;

      if ($date_switch ne '')
      {
        next if (($path_in eq $path_in1) && ($file ge "$projectfilename-$date_switch")) ;
        next if (($path_in eq $path_in2) && ($file lt "$projectfilename-$date_switch")) ;
      }  

      next if $file ge "$projectfilename-20100611-000000" and $file lt "$projectfilename-20100617-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20100627-000000" and $file lt "$projectfilename-20100628-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20110908-000000" and $file lt "$projectfilename-20110915-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20111223-010000" and $file lt "$projectfilename-20111226-160000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20120413-000000" and $file lt "$projectfilename-20120417-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20121214-000000" and $file lt "$projectfilename-20130108-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20130723-000000" and $file lt "$projectfilename-20130724-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20140105-000000" and $file lt "$projectfilename-20140107-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20140827-000000" and $file lt "$projectfilename-20140828-000000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20150803-180000" and $file lt "$projectfilename-20150803-230000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20150810-150000" and $file lt "$projectfilename-20150810-210000" ; # bad measurements on these dates
      next if $file ge "$projectfilename-20150811-170000" and $file lt "$projectfilename-20150811-180000" ; # bad measurements on these dates

      push @files, $file ;
      $file_in_tar {$file} = "$path_in/$file_in" ;

      $hour_in = substr ($file, length ($projectfilename)+1, 11) ; # ignore minutes and seconds
      $hours_found {$hour_in} ++ ;

      $files_read ++ ;
      print "$files_read: Read file '$file' $hour_in\n" if $files_read <= 24 or $files_read % 168 == 0 ;
      print "\n" if $files_read == 24 ;

      if ($hour_in lt $hour_oldest) { $hour_oldest = $hour_in ; }
      if ($hour_in gt $hour_newest) { $hour_newest = $hour_in ; }

    # if ($file_in_found++ > 50) { last ; } # test
    }
  }
  closedir (DIR);
}


sub FindMissingFiles
{
  &LogT ("FindMissingFiles between $hour_oldest and $hour_newest\n\n") ;
  return if $hour_newest eq '' ;

  my ($file, $year, $month, $day, $hour) ;

# $hour_oldest = "20080801-00" ; # test
# $hour_newest = "20100624-23" ; # test

  $year  = substr ($hour_oldest,0,4) ;
  $month = substr ($hour_oldest,4,2) ;
  $day   = substr ($hour_oldest,6,2) ;
  $hour  = substr ($hour_oldest,9,2) ;

  $hour_check = $hour_oldest ;
  while ($hour_check lt $hour_newest)
  {
    if ($hour < 23)
    { $hour ++ ; }
    else
    {
      $hour = 0 ;
      if ($day < days_in_month ($year,$month))
      { $day ++ ; }
      else
      {
        $day = 1 ;
        if ($month < 12)
        { $month++ ; }
        else
        {
          $month = 1 ;
          $year ++ ;
        }
      }
    }
    $hour_check = sprintf ("%04d%02d%02d-%02d", $year, $month, $day, $hour) ;

    if (! $hours_found {$hour_check})
    {
      $no_projectcounts_file .= "$hour_check, " ;

      $month = sprintf ("%02d", $month) ;
      $day   = sprintf ("%02d", $day) ;
      $hour  = sprintf ("%02d", $hour) ;

      $timegm  = timegm (0,0,0,$day,$month-1,$year-1900) ;
      $weekday = (gmtime($timegm))[6] ;
      $weekday = (($weekday+6) % 7) + 1 ; # Sun .. Sat -> Mon .. Sun
      $weekday = sprintf ("%02d", $weekday) ;
      $week    = sprintf ("%02d", (gmtime($timegm))[7] / 7 + 1) ;

      $hours_missing {"month"}   {"$year/$month"} ++ ;
      $hours_missing {"week"}    {"$year,$week"}  ++ ;
      $hours_missing {"day"}     {"$year/$month/$day"} ++ ;
      $hours_missing {"weekday"} {"$weekday"} ++ ;
    }
  }
  if ($no_projectcounts_file ne '')
  {
    $no_projectcounts_file =~ s/,\s$// ;
    print "No project[counts|views] file(s) found or accepted for\n$no_projectcounts_file\n" ;
  }
  print "\n" ;
}

sub AdjustForMissingFilesAndUndercountedMonths
{
  &LogT ("AdjustForMissingFilesAndUndercountedMonths\n\n") ;

  my ($processed, $missing, $rescale, $rescale2) ;

  foreach $period (sort keys %{$hours_processed {"month"}})
  {
    $rescale  = 1 ; # compensate for hours which are missing or incomplete in input
    $rescale2 = 1 ; # compensate for underreporting due to server overload (summer 2010)
    $processed = $hours_processed {"month"}{$period} ;
    $missing   = $hours_missing   {"month"}{$period} ;
    if ($processed > 0)
    {
      if ($missing > 0)
      {
        $rescale = sprintf ("%4f", ($processed + $missing) / $processed) ;
        print "Month $period: $processed processed, $missing missing -> rescale * $rescale\n" ;
      }

      # summer 2010: correct for data loss (percentages derived from how much gaps between squid log sequence numbers exceeded expected 1000)
         if ($period eq '2010/04') { $rescale2 = 1.241 ; }
      elsif ($period eq '2010/05') { $rescale2 = 1.310 ; }
      elsif ($period eq '2010/06') { $rescale2 = 1.328 ; }
      elsif ($period eq '2010/07') { $rescale2 = 1.295 ; }

      if ($rescale2 != 1)
      { print "Month $period: rescale * $rescale2 to compensate for missed UDP messages at squid log processing servers\n" ; }

      next if $rescale == 1 and $rescale2 == 1 ;

      foreach $wiki (sort keys %wikis_processed)
      {
        ($project,$language) = split (',', $wiki) ;
        $before = $totals {"month"} {$project} {"$language,$period"} ;
        # for all projects first incomplete month is not included (too long ago to care)
        # except for latest added project wikivoyage (code wo) for which data capture started 17th January 2013
        # -> multiply by (31 days) / (31-16 days) = 2.067 (and $rescale is not equal 1 for Jan 2013, so recalc will happen anyway)
        if (($project eq 'wo') && ($period eq '2013/01'))
        { $after  = sprintf ("%.0f", $before * 2.067) ; }
        else
        { $after  = sprintf ("%.0f", $before * $rescale * $rescale2) ; }

        $totals {"month"} {$project} {"$language,$period"} = $after ;

        if ($language =~ /^(?:de|en)$/)
        { print "project $project, language $language, period $period: $before -> $after\n" ; }
      }
    }
  }
  print "\n" ;

#  foreach $period (sort keys %{$hours_processed {"week"}})
#  {
#    $rescale = 1 ;
#    $processed = $hours_processed {"week"}{$period} ;
#    $missing   = $hours_missing   {"week"}{$period} ;
#    if (($missing > 0) && ($processed > 0))
#    {
#      $rescale = sprintf ("%4f", ($processed + $missing) / $processed) ;
#      print "Week $period: $processed processed, $missing missing -> rescale * $rescale\n" ;
#    }
#  }
#  print "\n" ;

#  foreach $period (sort keys %{$hours_processed {"day"}})
#  {
#    $rescale = 1 ;
#    $processed = $hours_processed {"day"}{$period} ;
#    $missing   = $hours_missing   {"day"}{$period} ;
#    if (($missing > 0) && ($processed > 0))
#    {
#      $rescale = sprintf ("%4f", ($processed + $missing) / $processed) ;
#      print "Day $period: $processed processed, $missing missing -> rescale * $rescale\n" ;
#    }
#  }
#  print "\n" ;

#  foreach $period (sort keys %{$hours_processed {"weekday"}})
#  {
#    $rescale = 1 ;
#    $processed = $hours_processed {"weekday"}{$period} ;
#    $missing   = $hours_missing   {"weekday"}{$period} ;
#    if (($missing > 0) && ($processed > 0))
#    {
#      $rescale = sprintf ("%4f", ($processed + $missing) / $processed) ;
#      print "Weekday $period: $processed processed, $missing missing -> rescale * $rescale\n" ;
#    }
#  }
#  print "\n" ;
}

sub CountProjectViews
{
  &LogT ("CountProjectViews\n\n") ;

  $timestart_parse = time ;

  foreach $file (@files)
  {
    ($date = $file) =~ s/^\w+\-(\d+)\-.*/$1/ ;
    ($time = $file) =~ s/^\w+\-\d+\-(\d+)/$1/ ;

    $year  = substr ($date,0,4) ;
    $month = substr ($date,4,2) ;
    $day   = substr ($date,6,2) ;
    $hour  = substr ($time,0,2) ;

    $timegm  = timegm (0,0,0,$day,$month-1,$year-1900) ;
    $weekday = (gmtime($timegm))[6] ;
    $weekday = (($weekday+6) % 7) + 1 ; # Sun .. Sat -> Mon .. Sun
    $weekday = sprintf ("%02d", $weekday) ;
    $week    = sprintf ("%02d", (gmtime($timegm))[7] / 7 + 1) ;

    $yyyymm   = $year.$month ;

    $hours_processed {"month"}   {"$year/$month"} ++ ;
    $hours_processed {"week"}    {"$year,$week"}  ++ ;
    $hours_processed {"day"}     {"$year/$month/$day"} ++ ;
    $hours_processed {"weekday"} {"$weekday"} ++ ;

    $webstatscollector = '' ; 
    $tar_file = $file_in_tar {$file} ;
    if ($tar_file =~ /$path_in1/) { $webstatscollector = $wc1 ; }
    if ($tar_file =~ /$path_in2/) { $webstatscollector = $wc3 ; }
    if ($webstatscollector eq '') 
    { die ("Unexpected input path $tar_file, could not establish webstatscollector version") ; } 

    if ($tar_file ne $tar_file_prev)
    {
      $tar->read($tar_file);
      $tar_file_prev = $tar_file ;
    }

    $content = $tar->get_content ($file);
    @lines = split "\n", $content ;
    foreach $line (@lines)
    # open IN, "<", $file ;
    # while ($line = <IN>)
    {
      chomp ($line) ;
      ($project,$hyphen,$count,$size) = split (' ', $line) ;
      $project2 = $project ;

      if ($project =~ /^(?:commons|wikidata|meta|species|nostalgia|incubator|sources|foundation|sep11|strategy|outreach|usability|quality)$/) 
      {
        # .m (for special desktop) .m.m (for special mobile) .mw (all mobile, wc 1.0/2.0), no suffix happens only on certain date ranges
        # print "Ignore special project without suffix, should be .m .m.m .mw (wc 1.0/2.0):  date-hour $date-$hour, proj $project, count $count\n" ; 
        @errors1 {"Ignore special project without suffix, $project $yyyymm"} ++ ;  
        next ;
      }
    # next if $project !~ /\.f/ ; # qqq speed up tests
    # next if $line !~ /\.n/ ; # qqq speed up tests
      ($language,$project) = split ('\.', $project,2) ;
 
      # discard lines with invalid project names
      if (($language ne 'm') && ($language !~ /^[a-z-]{2,}(\.m)?$/))
      {
        $lines_skipped {$language} ++ ;
        next ;
      }

      # translate suffixes used in dammit.lt files into project codes as used in wikistats

      # due to extreme downward compatability webstatscollector 2.0 made the scheme quite complicated
      # see http://dumps.wikimedia.org/other/pagecounts-all-sites/README.txt
      # and https://wikitech.wikimedia.org/wiki/Analytics/Data/Pagecounts-all-sites

      # normalize codes: code mobile as .m, zero as .z, use wb|wk|wn|wo|wq|ws|wv|wx codes (Wikistats standard)  
      # quel horreur! what a nasty state machine! 

         if ($project eq "")      { $project = "wp"; }
      elsif ($project eq "b")     { $project = "wb"; } # wikibooks
      elsif ($project eq "d")     { $project = "wk"; } # wiktionary
#     elsif ($project eq "m")     { $project = "wx"; } # wikimedia (meta commons, species, ...)
      elsif ($project eq "n")     { $project = "wn"; } # wikinews
      elsif ($project eq "voy")   { $project = "wo"; } # wikivOyage
      elsif ($project eq "q")     { $project = "wq"; } # wikiquote
      elsif ($project eq "s")     { $project = "ws"; } # wikisource
      elsif ($project eq "v")     { $project = "wv"; } # wikiversity
      elsif ($project eq "w")     { $project = "wx"; } # miscellaneous
      elsif ($project eq "wd")   # wikidata
      { 
           if ($language eq 'www')   { $project = "wx"; $language = "wikidata" ; }   # wikidata 
        elsif ($language eq 'm')     { $project = "wx"; $language = "wikidata.m" ; } # wikidata
        elsif ($language eq 'zero')  { $project = "wx"; $language = "wikidata.z" ; } # wikidata
        else { @errors1 {"unexpected project code '$project2' -> [$language]$project"} ++ ; } 
      }

      elsif ($webstatscollector eq $wc1) # processing of webstatscollector 2.0 output was never implemented here, hence no $wc2
      {
           # in general .mw means total for all projects combined (relict of the past) 
           # in wc 1.0 .m is only for special projects
           # wc 2.0 introduces .m. which means mobile e.g. en.m.q is mobile wikiquote en.m (think en.m.p for wikipedia) means mobile wikipedia
           # in wc 2.0 there is en.m en.m.b en.m.n en.m.q etc and en.mw, the latter is total of all these 
           # in wc 3.0 .mw is gone, being redundant   
           if ($project eq "mw")  { $project = "wp"; $language .= ".m" }  
        elsif ($project eq "m")   { $project = "wx"; } 
        elsif ($project eq "f")   { $project = "wx"; $language = "foundation" ; } # foundation wiki
        else { @errors1 {"unexpected project code '$project2' -> [$language]$project"} ++ ; } 
      }
      elsif ($webstatscollector ge $wc3)
      {
        next if project eq 'mw' ; # total for all mobile traffic, lest this be re-introduced, now only in wc 1.0/2.0 
  
        if ($language =~ /^(?:commons|meta|species|nostalgia|incubator|sources|foundation|sep11)$/)
        { 
             if ($project eq "m.m")    { $language .= ".m" } 
          elsif ($project eq "zero.m") { $language .= ".z" } 
          else { @errors1 {"unexpected project code '$project2' -> [$language]$project"} ++ ; } 

          $project = "wx" ; 
        }
        elsif ($project eq "f")   # foundation wiki
        { 
             if ($language eq 'www')   { $project = "wx"; $language = "foundation" ; }   # foundation wiki
          elsif ($language eq 'm')     { $project = "wx"; $language = "foundation.m" ; } # foundation wiki
          elsif ($language eq 'zero')  { $project = "wx"; $language = "foundation.z" ; } # foundation wiki
          else { @errors1 {"unexpected project code '$project2' -> [$language]$project"} ++ ; } 
        }

        elsif ($project eq "m")     { $project = "wp"; $language .= ".m" }
        elsif ($project eq "m.b")   { $project = "wb"; $language .= ".m" } # wikibooks
        elsif ($project eq "m.d")   { $project = "wk"; $language .= ".m" } # wiktionary
      # elsif ($project eq "m.f")   { $project = "wx"; $language = "foundation.m" ; } # foundation wiki
        elsif ($project eq "m.n")   { $project = "wn"; $language .= ".m" } # wikinews
        elsif ($project eq "m.voy") { $project = "wo"; $language .= ".m" } # wikivOyage
        elsif ($project eq "m.q")   { $project = "wq"; $language .= ".m" } # wikiquote
        elsif ($project eq "m.s")   { $project = "ws"; $language .= ".m" } # wikisource
        elsif ($project eq "m.v")   { $project = "wv"; $language .= ".m" } # wikiversity
        elsif ($project eq "m.w")   { $project = "wx"; $language .= ".m" } # miscellaneous
      # elsif ($project eq "m.m")   { $project = "wx"; $language .= ".m" } # miscellaneous

        elsif ($project eq "zero")     { $project = "wp"; $language .= ".z" }
        elsif ($project eq "zero.b")   { $project = "wb"; $language .= ".z" } # wikibooks
        elsif ($project eq "zero.d")   { $project = "wk"; $language .= ".z" } # wiktionary
        elsif ($project eq "zero.n")   { $project = "wn"; $language .= ".z" } # wikinews
        elsif ($project eq "zero.voy") { $project = "wo"; $language .= ".z" } # wikivOyage
        elsif ($project eq "zero.q")   { $project = "wq"; $language .= ".z" } # wikiquote
        elsif ($project eq "zero.s")   { $project = "ws"; $language .= ".z" } # wikisource
        elsif ($project eq "zero.v")   { $project = "wv"; $language .= ".z" } # wikiversity
      # elsif ($project eq "zero.m")   { $project = "wx"; $language .= ".z" } 
        else { @errors1 {"unexpected project code '$project2' -> [$language]$project"} ++ ; } ;
      }

      else { @errors1 {"unexpected project code '$project2' -> [$language]$project"} ++ ; } ;

      # select number of wikipedia's are presented as group wikispecial
      # omit mediawiki, no counts for that one available
      if (($project eq "wp") && ($language =~ /^(?:commons|wikidata|meta|species|nostalgia|incubator|sources|foundation|sep11|strategy|outreach|usability|quality)(?:\.m)?$/))
      { $project = "wx" ; }

      next if $project eq "wx" and $language !~ /^(?:commons|wikidata|meta|species|nostalgia|incubator|sources|foundation|sep11|strategy|outreach|usability|quality)(?:\.m)?$/ ;
      
      # quick fix: fake counts for meta for a period where we had > 10 billion hits on meta due to fundraiser artefact, all to wiki/Special:RecordImpression
      if (($language =~ /^meta/) && (($yyyymm ge '201208') && ($yyyymm le '201504')))
      {
        next if $language =~ /^meta\./ ; # ignore mobile and zero, set fixed count for desktop   

        $count = sprintf ("%.0f",7000000 / (24 * 30)) ; 
      }

      # repeat value from Oct 2013 for following months, up to and incl April 2015, due to corruption HideBanner and mime type '-' (wrongly assumed text/html)  
      if (($language =~ /^en/) && ($project =~ /^(?:wb|wn|wq|ws|wv)$/) && (($yyyymm ge '201311') && ($yyyymm le '201504')) ) 
      {
        next if $language =~ /^en\./ ; # ignore mobile and zero, set fixed count for desktop   

           if ($project eq 'wb') { $estimate = 14400000 ; } # Wikibooks:   14.4M
        elsif ($project eq 'wn') { $estimate =  4400000 ; } # Wikinews:     4.4M
        elsif ($project eq 'wq') { $estimate = 10800000 ; } # Wikiquote:   10.8M
        elsif ($project eq 'ws') { $estimate =  8200000 ; } # Wikisource:   8.2M
        else                     { $estimate =  2400000 ; } # Wikiversity:  2.4M
       
        $count = sprintf ("%.0f",$estimate / (24 * 30)) ; 
      }

      next if $project eq "wx" and $year == 2007 and $month < 6 ; # shouldn't happen

      if (($language ne "www") && ($whitelist {"$project,$language"} == 0))
    # if (0)
      {
        # log on first encounter (disabled)
        # if ($blacklist {"$project,$language"} == 0)
        # { @errors2 {"Not in white list: $project,$language"} ++ ; }
        $blacklist {"$project,$language"}++ ;
        next ;
      }
      $wikis_used {"$project,$language"}++ ;

      # print "file $file == $projectfilename-$date_switch\n" ;

      if (($select_project  ne "+") && ($select_project  ne $project))  { next ; }
      if (($select_language ne "+") && ($select_language ne $language)) { next ; }

      if ("$year/$month/$day" gt $date_high {"$year/$month"})
      { $date_high {"$year/$month"} = "$year/$month/$day" ; }

      $wikis_processed {"$project,$language"}++ ;

      $totals {"month"}   {$project} {"$language,$year/$month"} += $count ;

      if ($language =~ /\.m/)
      { $totals_mobile {"month"} {$project} {"$language,$year/$month"} += $count ; }
      else
      { $totals_non_mobile {"month"} {$project} {"$language,$year/$month"} += $count ; }

      # print "$project $language $year/$month: " . $totals {"month"} {$project}{"$language,$year/$month"} . "\n" ;
      $totals {"week"}    {$project} {"$language,$year,$week"} += $count ;
      $totals {"day"}     {$project} {"$language,$year/$month/$day"} += $count ;
    # $totals {"hour"}    {$project} {"$language,$year/$month/$day,$hour"} = $count ; # huge file, reactivate when really used
      $totals {"weekday"} {$project} {"$language,$weekday"} += $count ;

      if ("$year/$month" eq $month_0) # determines sort order, no need to rescale for missing projectcount files
      { $totals_lastmonth {"$project,$language"} += $count ; }

    # $counts   {"$date $project"} += $count ;
    # $hours    {"$hour $project"} += $count ;
    # $weekdays {"$weekday $project"} += $count ;
    # $total    {$project} += $count ;
    # $dates    {$date}++ ;
    # $projects {$project}++ ;
    }
    # close IN ;

    if (++$filesparsed % 500 == 0)
    {
      $progress = sprintf ("%.0f",100 * $filesparsed / $filecnt) ;
      if ($progress > 20) # only predict run time from 20% , first months are going fast, only Wikipedia, no mobile views
      { $time_to_go = mmss ((100 - $progress)* (time - $timestart_parse) / $progress) . " to go" ; }

      &LogT ("$filesparsed/$filecnt files parsed ($progress\%, $time_to_go), last was $file\n") ;
    }
  }
  &LogT ("All files parsed\n\n") ;
  &LogT ("======================================================\n\n") ;
  &LogT ("Lines with invalid language code, sorted by frequency:\n\n") ;
  $line = "" ;
  foreach $language (sort {$lines_skipped {$b} <=> $lines_skipped {$a}} keys %lines_skipped)
  { $line .= "$language\[" . $lines_skipped {$language} . "\], " ; }
  $line =~ s/,\s*$// ;
  print "$line\n\n" ;

  &LogT ("=================================================\n\n") ;
  &LogT ("Lines with invalid language code, sorted by code:\n\n") ;
  $line = "" ;
  foreach $language (sort keys %lines_skipped)
  { $line .= "$language\[" . $lines_skipped {$language} . "\], " ; }
  $line =~ s/,\s*$// ;
  print "$line\n\n" ;

  print "========================================================================================================================\n" ;
  print "For each project a white list ..csv_[xx]/WhiteListWikis.csv contains all valid language codes for that project code 'xx'\n" ;
  print "To add a new language first add it to proper dblist in /a/wikistats_git/dumps/dblists/master\ copy,\n" ;
  print "then run ../dumps/bash/collect_countable_namespaces.sh to update whitelist files\n" ;
  print "========================================================================================================================\n\n" ;

  &LogT ("Valid codes not in white list, sorted by frequency:\n\n") ;
  $line = "" ;
  foreach $language (sort {$blacklist {$b} <=> $blacklist {$a}} keys %blacklist)
  { 
    $used = $blacklist {$language} ;
    $language =~ s/,/-/ ; 
    $line .= "$language\[$used\], " ; 
  }
  $line =~ s/,\s*$// ;
  print "$line\n\n" ;


  &LogT ("=====================================================================\n\n") ;
  &LogT ("Valid codes not in white list, sorted by project code, language code:\n\n") ;
  $line = "" ;
  $project_prev = '?' ;
  foreach $language (sort keys %blacklist)
  {
    ($project,$language) = split (",", $language,2) ;    
    if ($project ne $project_prev)
    {
      $line =~ s/,\s*$// ;
      print "$line\n" if $project_prev ne '?' ;
      $line = "\nproject $project: " ;
      $project_prev = $project ;
    } 
    $line .= "$language, " ; 
  }
  $line =~ s/,\s*$// ;
  print "$line\n\n" ;


  &LogT ("=================================\n\n") ;
  &LogT ("Valid codes used, sorted by code:\n\n") ;
  $line = "" ;
  $project_prev = '?' ;
  foreach $language (sort keys %wikis_used)
  {
  # $used = $wikis_used {$language} ;   
    ($project,$language) = split (',', $language) ;
    if ($project ne $project_prev)
    {
      $line =~ s/,\s*$// ;
      print "$line\n" if $project_prev ne '?' ;
      $line = "\nproject $project: " ;
      $project_prev = $project ;
    } 
  # $line .= "$language: $used, n" ;   
    $line .= "$language, " ;   
  }
  $line =~ s/,\s*$// ;
  print "$line\n\n\n" ;
}

sub WriteCsvFilesPerPeriod
{
  &LogT ("WriteCsvFilesPerPeriod\n\n") ;

  my $normalize = shift ;
  if ($normalize)
  { &LogT ("\nWriteCsvFilesPerPeriod (normalized)\n") ; }
  else
  { &LogT ("\nWriteCsvFilesPerPeriod (not normalized)\n") ; }

  foreach $period (sort keys %totals)
  {
    next if $normalize && ($period ne 'month') ;
    &LogT ("\nWrite totals per $period:\n") ;
    $desc = $descriptions {$period} ;

    foreach $project (sort keys %{$totals {$period}})
    {
#next if project ne 'wp' ; # qqq
#&LogT ("project $project period $period 1\n") ; # qqq

      $dir_out = "$path_csv/csv_$project" ;
      if (! -d $dir_out)
      { mkdir $dir_out, 0777 ; }

      $file_csv = "$dir_out/$desc$suffix_out.csv" ;
      if ($normalize)
      { $file_csv =~ s/\.csv/_normalized.csv/ ; }
      &Log ("project code $project, write $file_csv\n") ;

      # removal disabled, file is very useful for spotting anomalies, when they start and how they build up
      # if (-e "$dir_out/projectviews_perhour_all.csv") # huge file, remove for now, reactivate when really used
      # {
      #   print "unlink $dir_out/projectviews_perhour_all.csv (reactivate when really used)\n" ;
      #   unlink "$dir_out/projectviews_perhour_all.csv" ;
      # }

      open CSV, ">", $file_csv ;

#&LogT ("project $project period $period 2\n") ; # qqq
      foreach $key (sort  {$a cmp $b} keys %{$totals {$period}{$project}})
      {
#&LogT ("project $project period $period key $key\n") ; # qqq
        ($language,$yearmonth) = split (",", $key) ;
        # print "PERIOD $period PROJECT $project KEY $key\n" ;
        if ($period eq "month")
        {
          $count = $totals{$period}{$project}{$key} ;
          next if $count == 0 ;

          print CSV "$language," . $date_high {"$yearmonth"} . "," . $count . "\n" ;

          ($yyyymm = $yearmonth) =~ s/\//-/ ;

          $is_mobile = ($language =~ /\.m/) ;
          $language =~ s/\.m// ;

          $project_language_yymmmm = "$project,$language,$yyyymm" ;
          $csv_analytics_in_page_views_keys {$project_language_yymmmm}++ ;
          if ($normalize)
          {
            if (! $is_mobile)
            {
              $csv_analytics_in_page_views_normalized_non_mobile     {$project_language_yymmmm}  = $count ;
            }
            else
            {
              $project_language_yymmmm =~ s/\.// ;
              $csv_analytics_in_page_views_normalized_mobile         {$project_language_yymmmm}  = $count ;
            }
          }
          else
          {
            if (! $is_mobile)
            {
              $csv_analytics_in_page_views_non_normalized_non_mobile {$project_language_yymmmm}  = $count ;
            }
            else
            {
              $project_language_yymmmm =~ s/\.// ;
              $csv_analytics_in_page_views_non_normalized_mobile     {$project_language_yymmmm}  = $count ; 
            }
          }
        }
        else
        { 
          $count = $totals{$period}{$project}{$key} ; 
#&LogT ("project $project period $period key $key count $count\n") ; # qqq
          print CSV "$key,$count\n" if $count > 0 ;
        }
      }
      close CSV ;
    }

  }
  
  if ($normalize)
  {
    &LogT ("\nWrite totals per month for analytics database\n") ;
    $file_csv = "$path_csv/csv_wp/analytics_in_page_views.csv" ;
    &Log ("\n\nFile out for analytics database: $file_csv\n\n") ;
    open CSV, ">", $file_csv ;
    binmode CSV ; # enforce UNIX style linebreaks \012
    foreach $project_language_yymmmm (sort keys %csv_analytics_in_page_views_keys)
    {
      print CSV $project_language_yymmmm . ',' .
                ($csv_analytics_in_page_views_non_normalized_non_mobile {$project_language_yymmmm} + 0) . ',' .
                ($csv_analytics_in_page_views_non_normalized_mobile     {$project_language_yymmmm} + 0) . ',' .
                ($csv_analytics_in_page_views_normalized_non_mobile     {$project_language_yymmmm} + 0) . ',' .
                ($csv_analytics_in_page_views_normalized_mobile         {$project_language_yymmmm} + 0) .
                "\n";
    }
    close CSV ;

    # read data back and summarize per project
    open CSV_IN, "<", $file_csv ;
    $file_csv =~ s/analytics_in_page_views.csv/analytics_chk_page_views_totals_normalized.csv/ ;
    open CSV_OUT, ">", $file_csv ;
    binmode CSV_IN ;  # enforce UNIX style linebreaks \012
    binmode CSV_OUT ; # enforce UNIX style linebreaks \012
    while ($line = <CSV_IN>)
    {
      chomp $line ;
      ($project,$lang,$month,$non_normalized_non_mobile,$non_normalized_mobile,$normalized_non_mobile,$normalized_mobile) = split (',', $line) ;

      $csv_analytics_chk_months   {$month}++ ;
      $csv_analytics_chk_projects {$project}++ ;

      $csv_analytics_chk_page_views_non_normalized_non_mobile {"$month,$project"} += $non_normalized_non_mobile ;
      $csv_analytics_chk_page_views_non_normalized_mobile     {"$month,$project"} += $non_normalized_mobile ;
      $csv_analytics_chk_page_views_normalized_non_mobile     {"$month,$project"} += $normalized_non_mobile ;
      $csv_analytics_chk_page_views_normalized_mobile         {"$month,$project"} += $normalized_mobile ;
    }


    print CSV_OUT "month," ;
    foreach $project (sort {$a cmp $b} keys %csv_analytics_chk_projects)
    {
      next if $project !~ /^w/ ;
      print CSV_OUT "$project,,," ;
    }
    print CSV_OUT "overall\n" ;

    print CSV_OUT "," ;
    foreach $project (sort {$a cmp $b} keys %csv_analytics_chk_projects)
    {
      next if $project !~ /^w/ ;
      print CSV_OUT "non-mobile,mobile,total," ;
    }
    print CSV_OUT "non-mobile,mobile,total\n" ;

    foreach $month (sort {$b cmp $a} keys %csv_analytics_chk_months)
    {
      print CSV_OUT "$month," ;
      $csv_analytics_normalized_non_mobile = 0 ;
      $csv_analytics_normalized_mobile    = 0 ;

      foreach $project (sort {$a cmp $b} keys %csv_analytics_chk_projects)
      {
        next if $project !~ /^w/ ;
        print CSV_OUT
                    # $csv_analytics_chk_page_views_non_normalized_non_mobile {"$month,$project"} . ',' .
                    # $csv_analytics_chk_page_views_non_normalized_mobile     {"$month,$project"} . ',' .
                      $csv_analytics_chk_page_views_normalized_non_mobile     {"$month,$project"} . ',' .
                      $csv_analytics_chk_page_views_normalized_mobile         {"$month,$project"} . ',' .
                     ($csv_analytics_chk_page_views_normalized_non_mobile     {"$month,$project"} +
                      $csv_analytics_chk_page_views_normalized_mobile         {"$month,$project"}) . ',' ;
        $csv_analytics_normalized_non_mobile += $csv_analytics_chk_page_views_normalized_non_mobile  {"$month,$project"} ;
        $csv_analytics_normalized_mobile     += $csv_analytics_chk_page_views_normalized_mobile      {"$month,$project"} ;
      }
      print CSV_OUT
                    $csv_analytics_normalized_non_mobile . ',' .
                    $csv_analytics_normalized_mobile     . ',' .
                   ($csv_analytics_normalized_non_mobile +
                    $csv_analytics_normalized_mobile)    . "\n" ;
    }
  }
}

sub WriteTrendsMobileViews
{
  print "\nWriteTrendsMobileViews\n" ;
  &Log ("File out: $file_trends_mobile_csv\n") ;
  open CSV, ">", $file_trends_mobile_csv ;
  print CSV "# projectviews ~ html requests with url pattern [language].[wiki].org/wiki/[title]\n" .
            "# as collected with webstatscollector tool and reported in 'projectcounts' files (hourly page views per wiki)\n" .
            "# See https://dumps.wikimedia.org/other/pagecounts-ez/ (sanitized version; correcting for missing data)\n" .
            "# Note: 'mobile' refers to requests for mobile site (not from mobile devices; which is entirely different)\n" .
            "# For 'normalized' view counts (often used at Wikistats): multiply daily counts by days in month\n" .
            "# Project codes: wb=Wikibooks wk=Wiktionary wn=Wikinews wo=Wikivoyage wp=Wikipedia wq=Wikiquote ws=Wikisource wv=Wikiversity wx=Wikispecial\n" .
            "#\n" .
            "# project,language,language code,month,perc mobile views,all views,non mobile views,mobile views,days in month,days in full month,is full month,views daily,non mobile views daily,mobile views daily\n" ;
  foreach $key (sort keys %csv_analytics_in_page_views_non_normalized_non_mobile)
  {
    ($project,$lang,$yyyymm) = split (',', $key) ;
    next if $lang =~ /\.z/ ; # ignore zero (for now)
    $yyyymm =~ s/-/\//g ;
    $yyyymmdd = $date_high {$yyyymm} ;
    $yyyy = substr ($yyyymmdd,0,4) ;
    $mm   = substr ($yyyymmdd,5,2) ;
    $dd   = substr ($yyyymmdd,8,2) ;
    $days_in_month = days_in_month ($yyyy,$mm) ;
    $full_month = ($dd == $days_in_month) ? 'Y' : 'N' ;
    $month = sprintf ("%4d-%02d",$yyyy,$mm) ;

    next if $full_month eq 'N' and $dd < 10 ;

    $views_non_mobile = 0 + $csv_analytics_in_page_views_non_normalized_non_mobile {$key} ;
    $views_mobile     = 0 + $csv_analytics_in_page_views_non_normalized_mobile     {$key} ;
    $views_all        = $views_non_mobile + $views_mobile ;

    if ($views_all > 0)
    {
      $perc_mobile = sprintf ("%.1f",100 * $views_mobile / $views_all) ;
      if ($days_in_month > 0)
      {
        $views_daily_non_mobile = sprintf ("%.0f", $views_non_mobile / $dd) ;
        $views_daily_mobile     = sprintf ("%.0f", $views_mobile     / $dd) ;
        $views_daily_all        = sprintf ("%.0f", $views_all        / $dd) ;
      }
      else
      { $views_daily_all = $views_daily_non_mobile = $views_daily_mobile  = '-' ; }

      print CSV "$project," . $names{$lang} . ",$lang,$month,$perc_mobile\%,$views_all,$views_non_mobile,$views_mobile,$dd,$days_in_month,$full_month,$views_daily_all,$views_daily_non_mobile,$views_daily_mobile\n" ;

      if (($project eq 'wp') && ($views_mobile > 0))
      {
        $month_perc_mobile {"$yyyy-$mm"}++ ;

        if (! $full_month)
        { 
          $month_perc_mobile_incomplete {"$yyyy-$mm"} = "$yyyy-$mm-$dd" ; 
          print "month_perc_mobile_incomplete $yyyy-$mm $yyyy-$mm-$dd\n" ; 
        }
        
        $perc_mobile {"$lang|$yyyy-$mm"} = $perc_mobile ;
        $views_mobile {$lang} = $views_mobile ;
        $views_all    {$lang} = $views_all ;
        $csv_analytics_perc_mobile {"$yyyy-$mm"} = $perc_mobile ;
      }
    }
  }
  close CSV ;

  # write Wikipedias ordered by total mobile views in last month
  &Log ("\nFile out: $file_ratio_mobile_wp_csv\n") ;

  (@languages_sorted_by_mobile_pageviews) = sort {$views_mobile {$b} <=> $views_mobile {$a}} keys %views_mobile ;
  open CSV, ">", $file_ratio_mobile_wp_csv ;

  print CSV "Wikipedias ordered by total mobile views in last month\n" ;
  print CSV "Meta data as in e.g. http://stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryOverview2014Q2.htm\n" ;
  print CSV "All meta data from Wikipedia. Speakers includes non-native speakers.\n" ;
# print     "Wikipedias ordered by total mobile views in last month\n" ;
# print     "Meta data as in e.g. http://stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryOverview2014Q2.htm\n" ;
# print     "All meta data from Wikipedia. Speakers includes non-native speakers.\n" ;

  $line = "Speakers (M),";
  foreach $lang (@languages_sorted_by_mobile_pageviews)
  { $line .= "$speakers{$lang}," ; }
  $line =~ s/,$// ;
  print CSV "$line\n" ;
# print     "$line\n" ;

  $line = "Regions," ;
  foreach $lang (@languages_sorted_by_mobile_pageviews)
  { $line .= "$regions{$lang}," ; }
  $line =~ s/,$// ;
  print CSV "$line\n" ;
# print     "$line\n" ;

  $line = "All views last month," ;
  foreach $lang (@languages_sorted_by_mobile_pageviews)
  {
    $views = $views_all {$lang} ;
  # $views = sprintf ("%.1f",$views / 1000000) ;
  # or
  # $views =~ s/\d(\d\d\d\d\d\d\d\d\d)$/$1,$2/ ;
  # $views =~ s/\d(\d\d\d\d\d\d)$/$1,$2/ ;
  # $views =~ s/\d(\d\d\d)$/$1,$2/ ;
    $line .= "$views," ;
  }
  $line =~ s/,$// ;
  print CSV "$line\n" ;
# print     "$line\n" ;

  $line = "Mobile views," ;
  foreach $lang (@languages_sorted_by_mobile_pageviews)
  {
    $views = $views_mobile {$lang} ;
  # $views = sprintf ("%.1f",$views / 1000000) ;
  # or
  # $views =~ s/\d(\d\d\d\d\d\d\d\d\d)$/$1,$2/ ;
  # $views =~ s/\d(\d\d\d\d\d\d)$/$1,$2/ ;
  # $views =~ s/\d(\d\d\d)$/$1,$2/ ;
    $line .= "$views," ;
  }
  $line =~ s/,$// ;
  print CSV "$line\n" ;
# print     "$line\n" ;

  $line = "lang code," ;
  foreach $lang (@languages_sorted_by_mobile_pageviews)
  { $line .= "$lang," ; }
  $line =~ s/,$// ;
  print CSV "$line\n" ;
# print     "$line\n" ;

  $line = "language," ;
  foreach $lang (@languages_sorted_by_mobile_pageviews)
  { $line .= "$names{$lang}," ; }
  $line =~ s/,$// ;
  print CSV "$line\n" ;
# print     "$line\n" ;

  # show percentage mobile per month per language
  print "Show percentage mobile per month per language\n\n" ;
  foreach $yyyymm (sort keys %month_perc_mobile)
  {
  # print "yyyymm $yyyymm\n" ;    
    $line = "$yyyymm," ;
    if ($month_perc_mobile_incomplete {"$yyyy-$mm"} ne '')
    { $line = $month_perc_mobile_incomplete {"$yyyy-$mm"} ; }
    
    foreach $lang (@languages_sorted_by_mobile_pageviews)
    { $line .= $perc_mobile {"$lang|$yyyymm"} . "," ; }
    $line =~ s/,$// ;
    print CSV "$line\n" ;
  # print     "[$line]\n" ;
  }
  close CSV ;
}

sub WriteRatioMobileViews
{
  print "\nWriteRatioMobileViews\n" ;

  $file_pageviews_csv = "$path_csv/csv_wp/projectviews_per_month_all.csv" ;
  open CSV_IN, '<', $file_pageviews_csv ;
  while ($line = <CSV_IN>)
  {
    # last if $lines++ > 50 ;
    chomp $line ;

    ($lang,$date,$count) = split (',', $line) ;
    next if $lang =~ /\.z/ ; # ignore zero (for now)

    if ($lang eq $lang_prev) # store data for newer month, except for last (incomplete) month
    {
      # remember previous for every language -> print one but last
      $counts {$lang} = $count_prev ;
      $dates  {$lang} = $date_prev ;
    }
    $lang_prev  = $lang ;
    $count_prev = $count ;
    $date_prev  = $date ;
  }
  close CSV_IN ;

  open  CSV_OUT, '>', $file_ratio_mobile_csv ;
  print CSV_OUT "Meta data as in e.g. http://stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryOverview2014Q2.htm\n" ;
  print CSV_OUT "All meta data from Wikipedia. Speakers in millions - also includes non-native speakers.\n" ;
  print CSV_OUT "Regions: AF=Africa AS=Asia EU=Europe NA=North America OC=Oceania SA=South America W=World AL=Artificial Languages.\n" ;
  print CSV_OUT "language,language code,regions,perc mobile,speakers,all views,main site,mobile site,month\n" ;
# print         "Meta data as in e.g. http://stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryOverview2014Q2.htm\n" ;
# print         "All meta data from Wikipedia. Speakers in millions - also includes non-native speakers.\n" ;
# print         "Regions: AF=Africa AS=Asia EU=Europe NA=North America OC=Oceania SA=South America W=World AL=Artificial Languages.\n" ;
# print         "language,language code,regions,perc mobile,speakers,all views,main site,mobile site,month\n" ;

  foreach $lang (sort keys %counts)
  {
print "lang $lang\n" ;
    next if $lang =~ /\.m/ ; # mobile
    next if $lang eq 'www' ; # portal

print "lang $lang " . $dates{$lang} . " - " . $dates{"$lang.m"} . "\n" ;
  # print "$key\n" ;
    if ($dates {$lang} ne $dates {"$lang.m"})
  # { print "unequal dates or missing info for $lang (date:'${dates {$lang}}') and $lang.m (date: '${dates {$lang.m}}')\n" ; }
    { print "unequal dates or missing info for $lang (date:'${dates {$lang}}') and $lang.m (date: '" . $dates {"$lang.m"} . "')\n" ; }
    else
    {
      $count_main   = $counts {$lang} ;
      $count_mobile = $counts {"$lang.m"} ;
      $count_all    = $count_main + $count_mobile ;
      $date         = $dates {$lang} ;
      if ($count_all == 0)
      { $perc_mobile = 'n.a.' ; }
      else
      { $perc_mobile = sprintf ("%.1f", 100 * ($count_mobile / $count_all)) . '%' ; }
    }

    $date =~ s/\//-/g ;
    $date = substr ($date,0,7) ;
    print CSV_OUT $names {$lang} . ",$lang," . $regions {$lang} . ",$perc_mobile," . $speakers {$lang} . ",$count_all,$count_main,$count_mobile,$perc_mobile,$date\n" ;
    print         $names {$lang} . ",$lang," . $regions {$lang} . ",$perc_mobile," . $speakers {$lang} . ",$count_all,$count_main,$count_mobile,$perc_mobile,$date\n" ;
  # print         $names {$lang} . ",$lang," . $regions {$lang} . ',' . $speakers {$lang} . ",$count_all,$count_main,$count_mobile,$perc_mobile,$date\n" ;

    $regions = $regions {$lang} ;

    $regions_main   {$regions} += $count_main ;
    $regions_mobile {$regions} += $count_mobile ;
    $regions_all    {$regions} += $count_all ;
    $langs          {$regions} .= "$lang:" . $names {$lang} . ", " ;
  }
  close CSV_OUT ;

  print "\n\n" ;

  open TXT_OUT, '>', $file_perc_mobile_txt ;
  print TXT_OUT "Percentage mobile per group of languages, grouped by region(s) where the language is spoken\n\n" ;

  foreach $regions (sort keys %langs)
  {
    $langs {$regions} =~ s/,\s*$// ;

    $count_main   = $regions_main   {$regions} ;
    $count_mobile = $regions_mobile {$regions} ;
    $count_all    = $regions_all    {$regions} ;

    if ($count_all == 0)
    { $perc_mobile = 'n.a.' ; }
    else
    { $perc_mobile = sprintf ("%.1f", 100 * ($count_mobile / $count_all)) . '%' ; }

    $regions2 = $regions ;
    $regions2 =~ s/AF/Africa/ ;
    $regions2 =~ s/AS/Asia/ ;
    $regions2 =~ s/EU/Europe/ ;
    $regions2 =~ s/NA/North-America/ ;
    $regions2 =~ s/SA/South-America/ ;
    $regions2 =~ s/W/World/ ;
    $regions2 =~ s/OC/Oceania/ ;
    $regions2 =~ s/AL/Artificial/ ;

    if ($regions2 =~ /\//)
    { $region = 'regions' }
    else
    { $region = 'region' }

    print TXT_OUT "$region: $regions2\nlanguages:" . $langs {$regions} . "\nperc mobile: $perc_mobile\n\n" ;
  }
  close TXT_OUT ;
# exit ;
}

sub WriteCsvHtmlFilesPopularWikis
{
  &LogT ("WriteCsvHtmlFilesPopularWikis\n\n") ;

  my $normalize = shift ;
  if ($normalize)
  { &LogT ("\n\nWriteCsvHtmlFilesPopularWikis (normalized)\n") ; }
  else
  { &LogT ("\n\nWriteCsvHtmlFilesPopularWikis (not normalized)\n") ; }

  @totals_lastmonth = sort {$totals_lastmonth {$b} <=> $totals_lastmonth {$a}} keys %totals_lastmonth ;

  $dir_out  = "$path_csv/csv_wp" ;
  $file_csv = "$dir_out/projectviews_per_month_popular_wikis_$month_0_file.csv" ;
  $msg_normalized = "Page view data are not normalized to 30 day months" ;
  if ($normalize)
  {
    $file_csv =~ s/_(\d{4})/_normalized_$1/ ;
    $msg_normalized =~ s/not // ;
  }

# extend with normalized counts
# see manually created PageViewsPerMonthTop25PlusNormalizedTo100.csv

  &Log ("File csv: $file_csv\n") ;
  open CSV, ">", $file_csv ;

  print CSV "=== $msg_normalized ===\n" ;
  print     "=== $msg_normalized ===\n" ;

  print CSV "\n=== Page view totals non-mobile + mobile ===\n\n" ;
  print     "\n=== Page view totals non-mobile + mobile ===\n\n" ;

  print CSV ",,,,,,,," . $csv_recent_months ;
  print                  $csv_recent_months ;

  # write per popular language+wiki recent months of page view totals
  # non mobile + mobile
  $lines = 0 ;
  foreach $line (@totals_lastmonth)
  {
    next if $line =~ /\.m/ ;

    if (++$lines > $maxpopularwikis) { last ; }

    ($project, $language) = split (',', $line) ;
    $largest_projects {"$project-$language"} ++ ;

    $language_name = $out_languages {$language} ;
    if ($language_name eq '')
    { $language_name = "\($project-$language\)" ; }

    print CSV ",,,,,,,," ;

    if (($project ne "wp") && ($project ne "wx"))
    {
      print CSV "$language_name " . &GetProjectName ($project) . "," ;
      print     "$language_name " . &GetProjectName ($project) . "," ;
    }
    else
    {
      print CSV "$language_name," ;
      print     "$language_name," ;
    }

# %test = %{$totals {"month"} {"wp"} };
# %test2 = @recent_months ;

    for ($m = 0 ; $m < $months_recent ; $m++)
    {
      print CSV ($totals {"month"} {$project} {"$language,${recent_months [$m]}"} +
                 $totals {"month"} {$project} {"$language\.m,${recent_months [$m]}"}) . "," ;
      print      $totals {"month"} {$project} {"$language,${recent_months [$m]}"} +
                 $totals {"month"} {$project} {"$language\.m,${recent_months [$m]}"} . "," ;
    }

    if (($project ne "wp") && ($project ne "wx"))
    {
      print CSV "$language_name " . &GetProjectName ($project) . "\n" ;
      print     "$language_name " . &GetProjectName ($project) . "\n" ;
    }
    else
    {
      print CSV "$language_name\n" ;
      print     "$language_name\n" ;
    }

  }

  print CSV "\n=== Page view totals non-mobile ===\n\n" ;
  print     "\n=== Page view totals non-mobile ===\n\n" ;

  print CSV ",,,,,,,," . $csv_recent_months ;
  print                  $csv_recent_months ;

  # write per popular language+wiki recent months of page view totals
  # non mobile
  $lines = 0 ;
  foreach $line (@totals_lastmonth)
  {
    next if $line =~ /\.m/ ;

    if (++$lines > $maxpopularwikis) { last ; }

    ($project, $language) = split (',', $line) ;
    $largest_projects {"$project-$language"} ++ ;

    $language_name = $out_languages {$language} ;
    if ($language_name eq '')
    { $language_name = "\($project-$language\)" ; }

    print CSV ",,,,,,,," ;

    if (($project ne "wp") && ($project ne "wx"))
    {
      print CSV "$language_name " . &GetProjectName ($project) . "," ;
      print     "$language_name " . &GetProjectName ($project) . "," ;
    }
    else
    {
      print CSV "$language_name," ;
      print     "$language_name," ;
    }

# %test = %{$totals {"month"} {"wp"} };
# %test2 = @recent_months ;
    for ($m = 0 ; $m < $months_recent ; $m++)
    {
      print CSV $totals {"month"} {$project} {"$language,${recent_months [$m]}"} . "," ;
      print     $totals {"month"} {$project} {"$language,${recent_months [$m]}"} . "," ;
    }

    if (($project ne "wp") && ($project ne "wx"))
    {
      print CSV "$language_name " . &GetProjectName ($project) . "\n" ;
      print     "$language_name " . &GetProjectName ($project) . "\n" ;
    }
    else
    {
      print CSV "$language_name\n" ;
      print     "$language_name\n" ;
    }
  }

  print CSV "\n=== Page view totals mobile ===\n\n" ;
  print     "\n=== Page view totals mobile ===\n\n" ;

  print CSV ",,,,,,,,,,,,,,,,,,,,,,," . $csv_recent_months ;
  print                                 $csv_recent_months ;

  # write per popular language+wiki recent months of page view totals
  # mobile
  $lines = 0 ;

  foreach $line (@totals_lastmonth)
  {
    next if $line !~ /\.m/ ;
    if (++$lines > $maxpopularwikis) { last ; }
    ($project, $language) = split (',', $line) ;
    $largest_projects {"$project-$language"} ++ ;

    ($language,$mobile)   = split ('\.', $language) ;
    $language_name = $out_languages {$language} ;
    if ($language_name eq '')
    { $language_name = "\($project-$language\)" ; }
    if ($mobile eq 'm')
    { $language_name .= ' Mobile' ; }

    if (($project ne "wp") && ($project ne "wx"))
    {
      print CSV ",,,,,,,,,,,,,,,,,,,,,,," . "$language_name " . &GetProjectName ($project) . "," ;
      print                                 "$language_name " . &GetProjectName ($project) . "," ;
    }
    else
    {
      print CSV ",,,,,,,,,,,,,,,,,,,,,,," . "$language_name," ;
      print                                 "$language_name," ;
    }

# %test = %{$totals {"month"} {"wp"} };
# %test2 = @recent_months ;
    for ($m = 0 ; $m < $months_recent ; $m++)
    {
      print CSV $totals {"month"} {$project} {"$language\.m,${recent_months [$m]}"} . "," ;
      print     $totals {"month"} {$project} {"$language\.m,${recent_months [$m]}"} . "," ;
    }

    if (($project ne "wp") && ($project ne "wx"))
    {
      print CSV "$language_name " . &GetProjectName ($project) . "\n" ;
      print     "$language_name " . &GetProjectName ($project) . "\n" ;
    }
    else
    {
      print CSV "$language_name\n" ;
      print     "$language_name\n" ;
    }
  }

#  print CSV "\n=== Page view totals indexed non-mobile ===\n\n" ;
#  print     "\n=== Page view totals indexed non-mobile ===\n\n" ;

#  print CSV ",,,,,,,," . "$csv_recent_months" ;
#  print                  "$csv_recent_months" ;

#  # write per popular language+wiki recent months of page view totals, normalized to first month = 100
#  # non mobile
#  $lines = 0 ;
#  foreach $line (@totals_lastmonth)
#  {
#    next if $line =~ /\.m/ ;
#    if (++$lines > $maxpopularwikis) { last ; }

#    ($project, $language) = split (',', $line) ;
#    $language_name = $out_languages {$language} ;
#    if ($language_name eq '')
#    { $language_name = "\($project-$language\)" ; }

#    if (($project ne "wp") && ($project ne "wx"))
#    { print CSV ",,,,,,,," . "$language_name " . &GetProjectName ($project) . "," ; }
#    else
#    { print CSV ",,,,,,,," . "$language_name," ; }

#    $recent_month_0 = $totals {"month"} {$project} {"$language,${recent_months [ 0]}"} ;
#    for ($m = 0 ; $m < $months_recent ; $m++)
#    {
#      if ($recent_month_0 > 0)
#      {
#        print CSV sprintf ("%.2f", 100 * $totals {"month"} {$project} {"$language,${recent_months [$m]}"} / $recent_month_0) . "," ;
#        print     sprintf ("%.2f", 100 * $totals {"month"} {$project} {"$language,${recent_months [$m]}"} / $recent_month_0) . "," ;
#      }
#      else
#      {
#        print CSV "," ;
#        print     "," ;
#      }
#    }

#    if (($project ne "wp") && ($project ne "wx"))
#    { print CSV "$language_name " . &GetProjectName ($project) . "\n" ; }
#    else
#    { print CSV "$language_name\n" ; }
#  }

#  print CSV "\n=== Page view totals indexed mobile ===\n\n" ;
#  print     "\n=== Page view totals indexed mobile ===\n\n" ;

#  print CSV ",,,,,,,,,,,,,,,,,,,,,,," . $csv_recent_months ;
#  print                                 $csv_recent_months ;

#  # write per popular language+wiki recent months of page view totals, normalized to first month = 100
#  # mobile
#  $lines = 0 ;
#  foreach $line (@totals_lastmonth)
#  {
#    next if $line !~ /\.m/ ;
#    if (++$lines > $maxpopularwikis) { last ; }

#    ($project, $language) = split (',', $line) ;
#    ($language,$mobile)   = split ('\.', $language) ;
#    $language_name = $out_languages {$language} ;
     if ($language_name eq '')
     { $language_name = "\($project-$language\)" ; }
#    if ($mobile eq 'm')
#    { $language_name .= ' Mobile' ; }

#    if (($project ne "wp") && ($project ne "wx"))
#    { print CSV  ",,,,,,,,,,,,,,,,,,,,,,," . "$language_name " . &GetProjectName ($project) . "," ; }
#    else
#    { print CSV  ",,,,,,,,,,,,,,,,,,,,,,," . "$language_name," ; }

#    $m0 = &months_since_2000_01 (2010,5) ;
#    $recent_month_0 = $totals {"month"} {$project} {"$language,${recent_months [$m0]}"} ;
#    for ($m = $m0 ; $m < $months_recent ; $m++)
#    {
#      if ($recent_month_0 > 0)
#      {
#        print CSV sprintf ("%.2f", 100 * $totals {"month"} {$project} {"$language\.m,${recent_months [$m]}"} / $recent_month_0) . "," ;
#        print     sprintf ("%.2f", 100 * $totals {"month"} {$project} {"$language\.m,${recent_months [$m]}"} / $recent_month_0) . "," ;
#      }
#      else
#      {
#        print CSV "," ;
#        print     "," ;
#      }
#    }

#    if (($project ne "wp") && ($project ne "wx"))
#    { print CSV  "$language_name " . &GetProjectName ($project) . "\n" ; }
#    else
#    { print CSV  "$language_name\n" ; }

#    print     "\n" ;
#  }

  print CSV "\n=== Page view totals per project - non-mobile + mobile ===\n" ;
  print     "\n=== Page view totals per project - non-mobile + mobile ===\n" ;

  print CSV "\n,,,,,,,,$csv_recent_months" ;
  print     "\n$csv_recent_months" ;

  # write per project recent months of page view totals
  $lines = 0 ;
  foreach $project3 (sort { $totals_project_month_combined_max {$b} <=>  $totals_project_month_combined_max {$a}} keys %projects3)
  {
    print CSV ",,,,,,,," . &GetProjectName2 ($project3) . "," ;
    print                  &GetProjectName2 ($project3) . "," ;

    for ($m = 0 ; $m < $months_recent ; $m++)
    {
      print CSV $totals_project_month_combined {$project3} {"${recent_months [$m]}"} . "," ;
      print     $totals_project_month_combined {$project3} {"${recent_months [$m]}"} . "," ;
    }
    print CSV &GetProjectName2 ($project3) . "\n" ;
    print     &GetProjectName2 ($project3) . "\n" ;
  }

  print CSV "\n=== Page view totals per project - non-mobile ===\n" ;
  print     "\n=== Page view totals per project - non-mobile ===\n" ;

  print CSV "\n,,,,,,,,$csv_recent_months" ;
  print     "\n$csv_recent_months" ;

  # write per project recent months of page view totals - non mobile
  $lines = 0 ;
  foreach $project3 (sort { $totals_project_month_combined_max {$b} <=>  $totals_project_month_combined_max {$a}} keys %projects3)
  {
    print CSV ",,,,,,,," . &GetProjectName2 ($project3) . "," ;
    print                  &GetProjectName2 ($project3) . "," ;

    for ($m = 0 ; $m < $months_recent ; $m++)
    {
      print CSV $totals_project_month_non_mobile {$project3} {"${recent_months [$m]}"} . "," ;
      print     $totals_project_month_non_mobile {$project3} {"${recent_months [$m]}"} . "," ;
    }
    print CSV &GetProjectName2 ($project3) . "\n" ;
    print     &GetProjectName2 ($project3) . "\n" ;
  }

  print CSV "\n=== Page view totals per project - mobile ===\n" ;
  print     "\n=== Page view totals per project - mobile ===\n" ;

  print CSV "\n,,,,,,,,$csv_recent_months" ;
  print     "\n$csv_recent_months" ;

  # write per project recent months of page view totals - non mobile
  $lines = 0 ;
  foreach $project3 (sort { $totals_project_month_combined_max {$b} <=>  $totals_project_month_combined_max {$a}} keys %projects3)
  {
    print CSV ",,,,,,,," . &GetProjectName2 ($project3) . "," ;
    print                  &GetProjectName2 ($project3) . "," ;

    for ($m = 0 ; $m < $months_recent ; $m++)
    {
      print CSV $totals_project_month_mobile {$project3} {"${recent_months [$m]}"} . "," ;
      print     $totals_project_month_mobile {$project3} {"${recent_months [$m]}"} . "," ;
    }
    print CSV &GetProjectName2 ($project3) . "\n" ;
    print     &GetProjectName2 ($project3) . "\n" ;
  }

#  print CSV "\n=== Page view totals per project indexed - non-mobile + mobile ===\n" ;
#  print     "\n=== Page view totals per project indexed - non-mobile + mobile ===\n" ;

#  print CSV "\n",,,,,,,,"$csv_recent_months" ;
#  print     "\n$csv_recent_months" ;

#  # write per project recent months of page view totals
#  $lines = 0 ;

#  foreach $project3 (sort { $totals_project_month_combined_max {$b} <=>  $totals_project_month_combined_max {$a}} keys %projects3)
#  {
#    print CSV ",,,,,,,," . &GetProjectName2 ($project3) . "," ;
#    print                  &GetProjectName2 ($project3) . "," ;

#    $recent_month_0 = $totals_project_month_combined {$project3} {$recent_months [0]} ;

#    for ($m = 0 ; $m < $months_recent ; $m++)
#    {
#      if ($recent_month_0 > 0)
#      {
#        print CSV sprintf ("%.2f", 100 * $totals_project_month_combined {$project3} {$recent_months [$m]} / $recent_month_0) . "," ;
#        print     sprintf ("%.2f", 100 * $totals_project_month_combined {$project3} {$recent_months [$m]} / $recent_month_0) . "," ;
#      }
#      else
#      {
#        print CSV "," ;
#        print     "," ;
#      }
#    }

#    print CSV &GetProjectName2 ($project3) . "," ;
#    print     &GetProjectName2 ($project3) . "," ;
#  }

#  print CSV &GetProjectName2 ($project3) . "\n" ;
#  print     &GetProjectName2 ($project3) . "\n" ;

  close CSV ;

  my (%growth_figures_text,%growth_figures_html) ;

  # write ready made table rows for report card: page views top 25 movers shakers
  foreach $key (keys %largest_projects)
  {
    ($project,$language) = split ('-', $key) ;

    next if $language =~ /\.m/ ; # skip mobile for now

    $total_lastmonth = $totals {"month"} {$project} {"$language,$month_0"}          + $totals {"month"} {$project} {"$language\.m,$month_0"} ;
    $total_prevmonth = $totals {"month"} {$project} {"$language,$month_0_minus_1"}  + $totals {"month"} {$project} {"$language\.m,$month_0_minus_1"};
    $total_prevyear  = $totals {"month"} {$project} {"$language,$month_0_minus_12"} + $totals {"month"} {$project} {"$language\.m,$month_0_minus_12"};

    $perc_month = "no data" ;
    $perc_year  = "no data" ;

    if ($total_prevyear > 0)
    { $perc_year  = sprintf ("%.1f", 100 * $total_lastmonth/$total_prevyear - 100) ; }
    if ($total_prevyear > 0)
    { $perc_month = sprintf ("%.1f", 100 * $total_lastmonth/$total_prevmonth - 100) ; }

    $line = "$project-$language: $total_prevyear=>$total_lastmonth=$perc_year%, $total_prevmonth=>$total_lastmonth=$perc_month%" ;

    $total_lastmonth = sprintf ("%.0f", $total_lastmonth / 1000000) ;

    $project_name  = &GetProjectName ($project) ;
    $language_name = $out_languages {$language} ;

    $project = ucfirst ($project) ;

    $col1 = "<td class=detail-left>$project:$language_name</td>\n" ;
    $col2 = "<td class=detail-blue>$total_lastmonth</td>\n" ;
    $col3 = "<td class=detail-blue>$perc_month%</td>\n" ;
    $col4 = "<td class=detail-blue>$perc_year%</td>\n" ;
    $html = "<tr>\n$col1$col2$col3$col4</tr>\n" ;

    $growth_figures_text {"$perc_month-$project-$language"} = $line ;
    $growth_figures_html {"$perc_month-$project-$language"} = $html ;
  }

# html file was for inclusion into old Report Card
# $file_html = "$dir_out/projectviews_moversshakers_popularwikis_$month_0_file.html" ;
# if ($normalize)
# { $file_html =~ s/_(\d{4})/_normalized_$1/ ; }
# open HTML, ">", $file_html ;
# foreach $key (sort {$b <=> $a} keys %growth_figures_text)
# {
#   print "$key: ". $growth_figures_text {$key} . "\n" ;
#   print HTML $growth_figures_html {$key} ;
# }
# close HTML ;
# &Log ("File html: $file_html\n") ;

  &Log ("\nFile csv: $file_csv + copy to wikilytics_in_pageviews.csv\n") ;

  if ($normalize)
  {
    &Log ("Copy to wikilytics file '$dir_out/wikilytics_in_pageviews.csv'") ;
    open CSV_IN,  '<', $file_csv ;
    open CSV_OUT, '>', "$dir_out/wikilytics_in_pageviews.csv" ;
    while ($line = <CSV_IN>)
    {
      # QD hack, replace zeroes by spaces
      $line =~ s/\,0\,/,,/g ;
      $line =~ s/\,0\,/,,/g ;
      print CSV_OUT $line ;
    }
    close CSV_IN ;
    close CSV_OUT ;
  }
  else
  {
    &Log ("Not \$normalize. Do not copy to wikilytics file '$dir_out/wikilytics_in_pageviews.csv'") ;
  }
}

# rather than using already stored data make this step as isolated as possible: it could migrate to another job later

sub RereadAndCombineCsvFilesPerMonth
{

}

sub GetProjectName
{
  my $project = shift ;

     if ($project eq "wp") { $project_name = "Wp"; }
  elsif ($project eq "wb") { $project_name = "Wb"; }
  elsif ($project eq "wd") { $project_name = "Wd"; }
  elsif ($project eq "wk") { $project_name = "Wk"; }
  elsif ($project eq "wx") { $project_name = ""; }
  elsif ($project eq "wn") { $project_name = "Wn"; }
  elsif ($project eq "wo") { $project_name = "Wo"; }
  elsif ($project eq "wq") { $project_name = "Wq"; }
  elsif ($project eq "ws") { $project_name = "Ws"; }
  elsif ($project eq "wv") { $project_name = "Wv"; }
  else                     { $project_name = "[$project]" ; }

  return ($project_name) ;
}

sub GetProjectName2
{
  my $project = shift ;

  $project =~ s/Wb/Wikibooks/i ;
  $project =~ s/Wd/Wikidata/i ;
  $project =~ s/Wk/Wiktionary/i ;
  $project =~ s/Ws/Wikisource/i ;
  $project =~ s/Wn/Wikinews/i ;
  $project =~ s/Wo/Wikivoyage/i ;
  $project =~ s/Wp/Wikipedia/i ;
  $project =~ s/Wq/Wikiquote/i ;
  $project =~ s/Wv/Wikiversity/i ;
  $project =~ s/Wx/Wikispecial/i ;
  $project =~ s/Commons/Commons/i ;
  $project =~ s/all/Total/i ;

  return ($project) ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print LOG $msg ;
}

sub LogT
{
  $msg = shift ;
  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d ", $hh, $mm, $ss) ;
  $msg =~ s/^(\n*)/$1$time/s ;
  &Log ($msg) ;
}

#sub Abort
#{
#  my $msg = shift ;
#  print "$msg\nExecution aborted." ;
#  # to do: log also to file
#  exit ;
#}

sub InitProjectNames
{
  # copied from WikiReports.pl

  %wikipedias = (
# mediawiki=>"http://wikimediafoundation.org Wikimedia",
  nostalgia=>"http://nostalgia.wikipedia.org Nostalgia",
  sources=>"http://wikisource.org Old&nbsp;Wikisource",
  meta=>"http://meta.wikimedia.org Meta-Wiki",
  beta=>"http://beta.wikiversity.org Beta",
  species=>"http://species.wikipedia.org WikiSpecies",
  commons=>"http://commons.wikimedia.org Commons",
  foundation=>"http://wikimediafoundation.org Wikimedia&nbsp;Foundation",
  sep11=>"http://sep11.wikipedia.org In&nbsp;Memoriam",
  nlwikimedia=>"http://nl.wikimedia.org Wikimedia&nbsp;Nederland",
  plwikimedia=>"http://pl.wikimedia.org Wikimedia&nbsp;Polska",
  mediawiki=>"http://www.mediawiki.org MediaWiki",
  dewikiversity=>"http://de.wikiversity.org Wikiversit&auml;t",
  frwikiversity=>"http://fr.wikiversity.org Wikiversit&auml;t",
  wikimania2005=>"http://wikimania2005.wikimedia.org Wikimania 2005",
  wikimania2006=>"http://wikimania2006.wikimedia.org Wikimania 2006",
  aa=>"http://aa.wikipedia.org Afar",
  ab=>"http://ab.wikipedia.org Abkhazian",
  af=>"http://af.wikipedia.org Afrikaans",
  ak=>"http://ak.wikipedia.org Akan", # was Akana
  als=>"http://als.wikipedia.org Alemannic", # was Elsatian
  am=>"http://am.wikipedia.org Amharic",
  an=>"http://an.wikipedia.org Aragonese",
  ang=>"http://ang.wikipedia.org Anglo-Saxon",
  ar=>"http://ar.wikipedia.org Arabic",
  arc=>"http://arc.wikipedia.org Aramaic",
  as=>"http://as.wikipedia.org Assamese",
  ast=>"http://ast.wikipedia.org Asturian",
  av=>"http://av.wikipedia.org Avar", # was Avienan
  ay=>"http://ay.wikipedia.org Aymara",
  az=>"http://az.wikipedia.org Azeri", # was Azerbaijani
  ba=>"http://ba.wikipedia.org Bashkir",
  bar=>"http://bar.wikipedia.org Bavarian",
  bat_smg=>"http://bat-smg.wikipedia.org Samogitian",
  "bat-smg"=>"http://bat-smg.wikipedia.org Samogitian",
  bcl=>"http://bcl.wikipedia.org Central Bicolano",
  be=>"http://be.wikipedia.org Belarusian",
  "be-x-old"=>"http://be.wikipedia.org Belarusian (Tarashkevitsa)",
  be_x_old=>"http://be.wikipedia.org Belarusian (Tarashkevitsa)",
  bg=>"http://bg.wikipedia.org Bulgarian",
  bh=>"http://bh.wikipedia.org Bihari",
  bi=>"http://bi.wikipedia.org Bislama",
  bm=>"http://bm.wikipedia.org Bambara",
  bn=>"http://bn.wikipedia.org Bengali",
  bo=>"http://bo.wikipedia.org Tibetan",
  bpy=>"http://bpy.wikipedia.org Bishnupriya Manipuri",
  br=>"http://br.wikipedia.org Breton",
  bs=>"http://bs.wikipedia.org Bosnian",
  bug=>"http://bug.wikipedia.org Buginese",
  bxr=>"http://bxr.wikipedia.org Buryat",
  ca=>"http://ca.wikipedia.org Catalan",
  cbk_zam=>"http://cbk-zam.wikipedia.org Chavacano",
  "cbk-zam"=>"http://cbk-zam.wikipedia.org Chavacano",
  cdo=>"http://cdo.wikipedia.org Min Dong",
  ce=>"http://ce.wikipedia.org Chechen",
  ceb=>"http://ceb.wikipedia.org Cebuano",
  ch=>"http://ch.wikipedia.org Chamorro", # was Chamoru
  cho=>"http://cho.wikipedia.org Choctaw", # was Chotaw
  chr=>"http://chr.wikipedia.org Cherokee",
  chy=>"http://chy.wikipedia.org Cheyenne", # was Sets&ecirc;hest&acirc;hese
  co=>"http://co.wikipedia.org Corsican",
  cr=>"http://cr.wikipedia.org Cree",
  crh=>"http://crh.wikipedia.org Crimean Tatar",
  cs=>"http://cs.wikipedia.org Czech",
  csb=>"http://csb.wikipedia.org Cashubian", # was Kashubian
  cu=>"http://cv.wikipedia.org Old Church Slavonic",
  cv=>"http://cv.wikipedia.org Chuvash", # was Cavas
  cy=>"http://cy.wikipedia.org Welsh",
  da=>"http://da.wikipedia.org Danish",
  de=>"http://de.wikipedia.org German",
  diq=>"http://diq.wikipedia.org Zazaki",
  dk=>"http://dk.wikipedia.org Danish",
  dsb=>"http://dsb.wikipedia.org Lower Sorbian",
  dv=>"http://dv.wikipedia.org Divehi",
  dz=>"http://dz.wikipedia.org Dzongkha",
  ee=>"http://ee.wikipedia.org Ewe",
  el=>"http://el.wikipedia.org Greek",
  eml=>"http://eml.wikipedia.org Emilian-Romagnol",
  en=>"http://en.wikipedia.org English",
  eo=>"http://eo.wikipedia.org Esperanto",
  es=>"http://es.wikipedia.org Spanish",
  et=>"http://et.wikipedia.org Estonian",
  eu=>"http://eu.wikipedia.org Basque",
  ext=>"http://ext.wikipedia.org Extremaduran",
  fa=>"http://fa.wikipedia.org Persian",
  ff=>"http://ff.wikipedia.org Fulfulde",
  fi=>"http://fi.wikipedia.org Finnish",
  "fiu-vro"=>"http://fiu-vro.wikipedia.org Voro",
  fiu_vro=>"http://fiu-vro.wikipedia.org Voro",
  fj=>"http://fj.wikipedia.org Fijian",
  fo=>"http://fo.wikipedia.org Faroese", # was Faeroese
  fr=>"http://fr.wikipedia.org French",
  frp=>"http://frp.wikipedia.org Arpitan",
  fur=>"http://fur.wikipedia.org Friulian",
  fy=>"http://fy.wikipedia.org Frisian",
  ga=>"http://ga.wikipedia.org Irish",
  gan=>"http://gan.wikipedia.org Gan",
  gay=>"http://gay.wikipedia.org Gayo",
  gd=>"http://gd.wikipedia.org Scots Gaelic", # was Scottish Gaelic
  gl=>"http://gl.wikipedia.org Galician", # was Galego
  glk=>"http://glk.wikipedia.org Gilaki",
  gn=>"http://gn.wikipedia.org Guarani",
  got=>"http://got.wikipedia.org Gothic",
  gu=>"http://gu.wikipedia.org Gujarati",
  gv=>"http://gv.wikipedia.org Manx", # was Manx Gaelic
  ha=>"http://ha.wikipedia.org Hausa",
  hak=>"http://hak.wikipedia.org Hakka",
  haw=>"http://haw.wikipedia.org Hawai'ian", # was Hawaiian
  he=>"http://he.wikipedia.org Hebrew",
  hi=>"http://hi.wikipedia.org Hindi",
  hif=>"http://hif.wikipedia.org Fiji Hindi",
  ho=>"http://ho.wikipedia.org Hiri Motu",
  hr=>"http://hr.wikipedia.org Croatian",
  hsb=>"http://hsb.wikipedia.org Upper Sorbian",
  ht=>"http://ht.wikipedia.org Haitian",
  hu=>"http://hu.wikipedia.org Hungarian",
  hy=>"http://hy.wikipedia.org Armenian",
  hz=>"http://hz.wikipedia.org Herero",
  ia=>"http://ia.wikipedia.org Interlingua",
  iba=>"http://iba.wikipedia.org Iban",
  id=>"http://id.wikipedia.org Indonesian",
  ie=>"http://ie.wikipedia.org Interlingue",
  ig=>"http://ig.wikipedia.org Igbo",
  ii=>"http://ii.wikipedia.org Yi",
  ik=>"http://ik.wikipedia.org Inupiak",
  ilo=>"http://ilo.wikipedia.org Ilokano",
  io=>"http://io.wikipedia.org Ido",
  is=>"http://is.wikipedia.org Icelandic",
  it=>"http://it.wikipedia.org Italian",
  iu=>"http://iu.wikipedia.org Inuktitut",
  ja=>"http://ja.wikipedia.org Japanese",
  jbo=>"http://jbo.wikipedia.org Lojban",
  jv=>"http://jv.wikipedia.org Javanese",
  ka=>"http://ka.wikipedia.org Georgian",
  kaa=>"http://kaa.wikipedia.org Karakalpak",
  kab=>"http://ka.wikipedia.org Kabyle",
  kaw=>"http://kaw.wikipedia.org Kawi",
  kg=>"http://kg.wikipedia.org Kongo",
  ki=>"http://ki.wikipedia.org Kikuyu",
  kj=>"http://kj.wikipedia.org Kuanyama", # was Otjiwambo
  kk=>"http://kk.wikipedia.org Kazakh",
  kl=>"http://kl.wikipedia.org Greenlandic",
  km=>"http://km.wikipedia.org Khmer", # was Cambodian
  kn=>"http://kn.wikipedia.org Kannada",
  ko=>"http://ko.wikipedia.org Korean",
  kr=>"http://kr.wikipedia.org Kanuri",
  ks=>"http://ks.wikipedia.org Kashmiri",
  ksh=>"http://ksh.wikipedia.org Ripuarian",
  ku=>"http://ku.wikipedia.org Kurdish",
  kv=>"http://kv.wikipedia.org Komi",
  kw=>"http://kw.wikipedia.org Cornish", # was Kornish
  ky=>"http://ky.wikipedia.org Kirghiz",
  la=>"http://la.wikipedia.org Latin",
  lad=>"http://lad.wikipedia.org Ladino",
  lb=>"http://lb.wikipedia.org Luxembourgish", # was Letzeburgesch
  lbe=>"http://lbe.wikipedia.org Lak",
  lg=>"http://lg.wikipedia.org Ganda",
  li=>"http://li.wikipedia.org Limburgish",
  lij=>"http://lij.wikipedia.org Ligurian",
  lmo=>"http://lmo.wikipedia.org Lombard",
  ln=>"http://ln.wikipedia.org Lingala",
  lo=>"http://lo.wikipedia.org Laotian",
  ls=>"http://ls.wikipedia.org Latino Sine Flexione",
  lt=>"http://lt.wikipedia.org Lithuanian",
  lv=>"http://lv.wikipedia.org Latvian",
  mad=>"http://mad.wikipedia.org Madurese",
  mak=>"http://mak.wikipedia.org Makasar",
  map_bms=>"http://map-bms.wikipedia.org Banyumasan",
  "map-bms"=>"http://map-bms.wikipedia.org Banyumasan",
  mdf=>"http://mdf.wikipedia.org Moksha",
  mg=>"http://mg.wikipedia.org Malagasy",
  mh=>"http://mh.wikipedia.org Marshallese",
  mi=>"http://mi.wikipedia.org Maori",
  min=>"http://min.wikipedia.org Minangkabau",
  minnan=>"http://minnan.wikipedia.org Minnan",
  mk=>"http://mk.wikipedia.org Macedonian",
  ml=>"http://ml.wikipedia.org Malayalam",
  mn=>"http://mn.wikipedia.org Mongolian",
  mo=>"http://mo.wikipedia.org Moldavian",
  mr=>"http://mr.wikipedia.org Marathi",
  ms=>"http://ms.wikipedia.org Malay",
  mt=>"http://mt.wikipedia.org Maltese",
  mus=>"http://mus.wikipedia.org Muskogee",
  my=>"http://my.wikipedia.org Burmese",
  myv=>"http://myv.wikipedia.org Erzya",
  mzn=>"http://mzn.wikipedia.org Mazandarani",
  na=>"http://na.wikipedia.org Nauruan", # was Nauru
  nah=>"http://nah.wikipedia.org Nahuatl",
  nap=>"http://nap.wikipedia.org Neapolitan",
  nds=>"http://nds.wikipedia.org Low Saxon",
  nds_nl=>"http://nds-nl.wikipedia.org Dutch Low Saxon",
  "nds-nl"=>"http://nds-nl.wikipedia.org Dutch Low Saxon",
  ne=>"http://ne.wikipedia.org Nepali",
  new=>"http://new.wikipedia.org Nepal Bhasa",
  ng=>"http://ng.wikipedia.org Ndonga",
  nl=>"http://nl.wikipedia.org Dutch",
  nov=>"http://nov.wikipedia.org Novial",
  nrm=>"http://nrm.wikipedia.org Norman",
  nn=>"http://nn.wikipedia.org Nynorsk", # was Neo-Norwegian
  no=>"http://no.wikipedia.org Norwegian",
  nv=>"http://nv.wikipedia.org Navajo", # was Avayo
  ny=>"http://ny.wikipedia.org Chichewa",
  oc=>"http://oc.wikipedia.org Occitan",
  om=>"http://om.wikipedia.org Oromo",
  or=>"http://or.wikipedia.org Oriya",
  os=>"http://os.wikipedia.org Ossetic",
  pa=>"http://pa.wikipedia.org Punjabi",
  pag=>"http://pag.wikipedia.org Pangasinan",
  pam=>"http://pam.wikipedia.org Kapampangan",
  pap=>"http://pap.wikipedia.org Papiamentu",
  pdc=>"http://pdc.wikipedia.org Pennsylvania German",
  pi=>"http://pi.wikipedia.org Pali",
  pih=>"http://pih.wikipedia.org Norfolk",
  pl=>"http://pl.wikipedia.org Polish",
  pms=>"http://pms.wikipedia.org Piedmontese",
  ps=>"http://ps.wikipedia.org Pashto",
  pt=>"http://pt.wikipedia.org Portuguese",
  qu=>"http://qu.wikipedia.org Quechua",
  rm=>"http://rm.wikipedia.org Romansh", # was Rhaeto-Romance
  rmy=>"http://rmy.wikipedia.org Romani",
  rn=>"http://rn.wikipedia.org Kirundi",
  ro=>"http://ro.wikipedia.org Romanian",
  roa_rup=>"http://roa-rup.wikipedia.org Aromanian",
  "roa-rup"=>"http://roa-rup.wikipedia.org Aromanian",
  roa_tara=>"http://roa-tara.wikipedia.org Tarantino",
  "roa-tara"=>"http://roa-tara.wikipedia.org Tarantino",
  ru=>"http://ru.wikipedia.org Russian",
  ru_sib=>"http://ru-sib.wikipedia.org Siberian",
  "ru-sib"=>"http://ru-sib.wikipedia.org Siberian",
  rw=>"http://rw.wikipedia.org Kinyarwanda",
  sa=>"http://sa.wikipedia.org Sanskrit",
  sah=>"http://sah.wikipedia.org Sakha",
  sc=>"http://sc.wikipedia.org Sardinian",
  scn=>"http://scn.wikipedia.org Sicilian",
  sco=>"http://sco.wikipedia.org Scots",
  sd=>"http://sd.wikipedia.org Sindhi",
  se=>"http://se.wikipedia.org Northern Sami",
  sg=>"http://sg.wikipedia.org Sangro",
  sh=>"http://sh.wikipedia.org Serbo-Croatian",
  si=>"http://si.wikipedia.org Sinhala", # was Singhalese
  simple=>"http://simple.wikipedia.org Simple English",
  sk=>"http://sk.wikipedia.org Slovak",
  sl=>"http://sl.wikipedia.org Slovene",
  sm=>"http://sm.wikipedia.org Samoan",
  sn=>"http://sn.wikipedia.org Shona",
  so=>"http://so.wikipedia.org Somali", # was Somalian
  sq=>"http://sq.wikipedia.org Albanian",
  sr=>"http://sr.wikipedia.org Serbian",
  srn=>"http://srn.wikipedia.org Sranan",
  ss=>"http://ss.wikipedia.org Siswati",
  st=>"http://st.wikipedia.org Sesotho",
  stq=>"http://stq.wikipedia.org Saterland Frisian",
  su=>"http://su.wikipedia.org Sundanese",
  sv=>"http://sv.wikipedia.org Swedish",
  sw=>"http://sw.wikipedia.org Swahili",
  szl=>"http://szl.wikipedia.org Silesian",
  ta=>"http://ta.wikipedia.org Tamil",
  te=>"http://te.wikipedia.org Telugu",
  test=>"http://test.wikipedia.org Test",
  tet=>"http://tet.wikipedia.org Tetum",
  tg=>"http://tg.wikipedia.org Tajik",
  th=>"http://th.wikipedia.org Thai",
  ti=>"http://ti.wikipedia.org Tigrinya",
  tk=>"http://tk.wikipedia.org Turkmen",
  tl=>"http://tl.wikipedia.org Tagalog",
  tlh=>"http://tlh.wikipedia.org Klingon", # was Klignon
  tn=>"http://tn.wikipedia.org Setswana",
  to=>"http://to.wikipedia.org Tongan",
  tokipona=>"http://tokipona.wikipedia.org Tokipona",
  tpi=>"http://tpi.wikipedia.org Tok Pisin",
  tr=>"http://tr.wikipedia.org Turkish",
  ts=>"http://ts.wikipedia.org Tsonga",
  tt=>"http://tt.wikipedia.org Tatar",
  tum=>"http://tum.wikipedia.org Tumbuka",
  turn=>"http://turn.wikipedia.org Turnbuka",
  tw=>"http://tw.wikipedia.org Twi",
  ty=>"http://ty.wikipedia.org Tahitian",
  udm=>"http://udm.wikipedia.org Udmurt",
  ug=>"http://ug.wikipedia.org Uighur",
  uk=>"http://uk.wikipedia.org Ukrainian",
  ur=>"http://ur.wikipedia.org Urdu",
  uz=>"http://uz.wikipedia.org Uzbek",
  ve=>"http://ve.wikipedia.org Venda", # was Lushaka
  vec=>"http://vec.wikipedia.org Venetian",
  vi=>"http://vi.wikipedia.org Vietnamese",
  vls=>"http://vls.wikipedia.org West Flemish",
  vo=>"http://vo.wikipedia.org Volap&uuml;k",
  wa=>"http://wa.wikipedia.org Walloon",
  war=>"http://war.wikipedia.org Waray-Waray",
  wo=>"http://wo.wikipedia.org Wolof",
  wuu=>"http://wuu.wikipedia.org Wu",
  xal=>"http://xal.wikipedia.org Kalmyk",
  xh=>"http://xh.wikipedia.org Xhosa",
  yi=>"http://yi.wikipedia.org Yiddish",
  yo=>"http://yo.wikipedia.org Yoruba",
  za=>"http://za.wikipedia.org Zhuang",
  zea=>"http://zea.wikipedia.org Zealandic",
  zh=>"http://zh.wikipedia.org Chinese",
  zh_min_nan=>"http://zh-min-nan.wikipedia.org Min Nan",
  "zh-min-nan"=>"http://zh-min-nan.wikipedia.org Min Nan",
  zh_classical=>"http://zh-classical.wikipedia.org Classical Chinese",
  "zh-classical"=>"http://zh-classical.wikipedia.org Classical Chinese",
  zh_yue=>"http://zh-yue.wikipedia.org Cantonese",
  "zh-yue"=>"http://zh-yue.wikipedia.org Cantonese",
  zu=>"http://zu.wikipedia.org Zulu",
  zz=>"&nbsp; All&nbsp;languages",
  zzz=>"&nbsp; All&nbsp;languages except English"
  );

  foreach $key (keys %wikipedias)
  {
    my $wikipedia = $wikipedias {$key} ;
    $out_urls      {$key} = $wikipedia ;
    $out_languages {$key} = $wikipedia ;
    $out_urls      {$key} =~ s/(^[^\s]+).*$/$1/ ;
    $out_languages {$key} =~ s/^[^\s]+\s+(.*)$/$1/ ;
    $out_article   {$key} = "http://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
    $out_article   {$key} =~ s/ /_/g ;
    $out_urls {$key} =~ s/(^[^\s]+).*$/$1/ ;
  }
}

# code year,month as monthes since january 2000 (1 byte)
sub months_since_2000_01
{
  my $year  = shift ;
  my $month = shift ;
  my $m = ($year - 2000) * 12 + $month ;
  return $m ;
}

sub mmss
{
  my $seconds = shift ;
  my $min = int ($seconds / 60) ;
  my $sec = $seconds % 60 ;

  $min  = ($min > 0) ? "$min min, " : "" ;
  $sec  = "$sec sec" ;
  return ("$min$sec") ;
}
