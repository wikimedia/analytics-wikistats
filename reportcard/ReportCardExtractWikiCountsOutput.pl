#!/usr/local/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (2) ;

  $month_last = "12" ;
  $year_last  = 2010 ;

  $month_start = "1" ;
  $year_start  = 2008 ;

  $m_start    = &months_since_2000_01 ($year_start, $month_start) ;
  $m_last     = &months_since_2000_01 ($year_last,  $month_last) ;
  $m_last_12  = $m_last - 12 ;
  $m_last_1   = $m_last - 1 ;

  $month_last = sprintf ("%02d", $month_last) ; # 1 -> 01

  # set defaults mainly for tests on local machine
  default_argv "-i 'W:/# Out Bayes'|-o 'W:/@ Report Card/Data'" ;

  use Getopt::Std ;

# $file_regions_UV    = "Multi-Country Media Trend, UVs by region (July 2008 - September 2009)_27290.csv" ;
# $file_regions_Reach = "Multi-Country Media Trend, % reach by region (July 2008 - September 2009)_10786.csv" ;

  $maxpopularwikis = 25 ;
  @projects = ('wb','wk','wn','wp','wq','ws','wv','wx','commons','*') ;

  &LogArguments ;
  &ParseArguments ;
  &InitProjectNames ;
  &InitReportNames ;
  &ReadStatisticsMonthly ;
  &WriteMonthlyData ;
  exit ;

sub LogArguments
{
  my $arguments ;
  getopt ("iolpft", \%options) ;
  foreach $arg (sort keys %options)
  { $arguments .= " -$arg " . $options {$arg} . "\n" ; }
  print ("\nArguments\n$arguments\n") ;
# &Log ("\nArguments\n$arguments\n") ;
}

sub ParseArguments
{
#  my @options ;
#  getopt ("io", \%options) ;

#  die ("Specify input folder for projectcounts files as: -i path") if (! defined ($options {"i"})) ;
#  die ("Specify output folder as: -o path'")                       if (! defined ($options {"o"})) ;

#  $path_in  = $options {"i"} ;
#  $path_out = $options {"o"} ;

#  die "Input folder '$path_in' does not exist"   if (! -d $path_in) ;
#  die "Output folder '$path_out' does not exist" if (! -d $path_out) ;

  $path_in  = "w:/# out bayes" ;
  $path_out = "w:/@ report card/data" ;

  print "Input  folder: $path_in\n" ;
  print "Output folder: $path_out\n" ;
  print "\n" ;

  $file_csv_out = "$path_out/StatisticsMonthly_${year_last}_${month_last}.csv" ;

  &SetComparisonPeriods ;
}

sub ReadStatisticsMonthly
{
  &ReadStatisticsMonthlyForProject ("wb") ;
  &ReadStatisticsMonthlyForProject ("wk") ;
  &ReadStatisticsMonthlyForProject ("wn") ;
  &ReadStatisticsMonthlyForProject ("wp") ;
  &ReadStatisticsMonthlyForProject ("wq") ;
  &ReadStatisticsMonthlyForProject ("ws") ;
  &ReadStatisticsMonthlyForProject ("wv") ;
  &ReadStatisticsMonthlyForProject ("wx") ;

  &ReadStatisticsPerBinariesExtensionCommons ;
}

sub ReadStatisticsMonthlyForProject
{
  my $project = shift;

  $all_projects = "*" ;

  my $file_csv_in_1 = "$path_in/csv_$project/StatisticsMonthly.csv" ;
  my $file_csv_in_2 = "$path_in/csv_$project/StatisticsUserActivitySpread.csv" ;

  if (! -e $file_csv_in_1)
  { &Abort ("Input file '$file_csv_in_1' not found") ; }
  if (! -e $file_csv_in_2)
  { &Abort ("Input file '$file_csv_in_2' not found") ; }

  print "Read '$file_csv_in_1'\n" ;
  open CSV_IN, '<', $file_csv_in_1 ;

  undef %lines ;
  while ($line = <CSV_IN>)
  {
    ($language,$date,$counts) = split (',', $line, 3) ;

    next if $language eq 'commons' and $project ne 'wx' ;
    next if $language eq 'sr'      and $project eq 'wn' ; # ignore insane bot spam on

    ($month,$day,$year) = split ('\/', $date) ;
    my $m = &months_since_2000_01 ($year,$month) ;
    next if $m < $m_start ;

    $lines {$language}{$m} = $line ;
    $languages {$language}++ ;
  }

  foreach $language (sort keys %languages)
  {
    for ($m = $m_start + 1 ; $m <= $m_last ; $m++)
    {
      if ($lines {$language}{$m} eq '')
      { $lines {$language}{$m} = $lines {$language}{$m -1} ; }
    }

    for ($m = $m_start ; $m <= $m_last ; $m++)
    {
      $line = $lines {$language}{$m} ;
      chomp $line ;
      ($language,$date,$counts) = split (',', $line, 3) ;
      @fields = split (',', $counts) ;

      if ($project eq "wp")
      {
        foreach $f (1,4,6,11) # new editors, articles, new articles, edits
        {
          $values           {"$f,$m"} {"$project,$language"}  = $fields [$f] ;

          $totals           {"$f,$m"}                        += $fields [$f] ;

          $totals_project   {"$f,$m"} {$project}             += $fields [$f] ;
          $totals_project   {"$f,$m"} {$all_projects}        += $fields [$f] ;

        #  print "TOTALS $f $m = . " . $totals {"$f,$m"} . "\n" ;
        }
      }
      else
      {
        foreach $f (1,4)
        {
          if ($f <= 3)
          {
            $values         {"$f,$m"} {"$project,$language"}  = $fields [$f] ;
            $totals         {"$f,$m"}                        += $fields [$f] ;
          }


          # ignore editor count on commons for totals, most editors are already counted for other project
          # (even for several projects, to be tuned after centralauth dump is available)
          # count for all_projects only Wikipedia articles
          if (($f <= 3) && ($language ne 'commons'))  # 0 = Contributors, 1 = New Wikimedians, 2 = Active Editors (5+ edits), 3 = Very Active Editors (100+ edits),
          { $totals_project {"$f,$m"} {$all_projects} += $fields [$f] ; }

          if ($language eq 'commons')
          { $totals_project {"$f,$m"} {'commons'}          += $fields [$f] ; }
          else
          { $totals_project {"$f,$m"} {$project}           += $fields [$f] ; }

        #  print "TOTALS $f $m = . " . $totals {"$f,$m"} . "\n" ;
        }
        foreach $f (6,11)
        {
          $totals_project {"$f,$m"} {$all_projects}        += $fields [$f] ;
          if ($language eq 'commons')
          { $totals_project {"$f,$m"} {'commons'}          += $fields [$f] ; }
          else
          { $totals_project {"$f,$m"} {$project}           += $fields [$f] ; }
        #  print "TOTALS $f $m = . " . $totals {"$f,$m"} . "\n" ;
        }

      }
    }
  }
  close CSV_IN ;

  # now read (very) active editors from newer more accurate file (split data for reg users and bots, unlike StatisticsMonthly.csv)
  # but use f = column count in StatisticsMonthly.csv

  print "Read '$file_csv_in_2'\n" ;
  open CSV_IN, '<', $file_csv_in_2 ;

  undef %lines ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    ($language,$date,$reguser_bot,$group,$counts) = split (',', $line, 5) ;

    next if $language eq 'commons' and $project ne 'wx' ; # commons also in wikipedia csv files (bug, hard to cleanup, just skip)
  # next if $language eq 'commons' ; # ignore editor count on commons alltogether, most are already counted for other project
                                     # (even for several projects, to be tuned after centralauth dump is available)

    if ($reguser_bot ne "R") { next ; }  # R: reg user, B: bot
    if ($group       ne "A") { next ; }  # A: articles, T: talk pages, O: other namespaces

    ($month,$day,$year) = split ('\/', $date) ;
    my $m = &months_since_2000_01 ($year,$month) ;
    next if $m < $m_start ;

    $lines {$language}{$m} = $line ;
    $languages {$language}++ ;
  }

  foreach $language (sort keys %languages)
  {
    for ($m = $m_start+1 ; $m <= $m_last ; $m++)
    {
      if ($lines {$language}{$m} eq '')
      { $lines {$language}{$m} = $lines {$language}{$m -1} ; }
    }

    for ($m = $m_start ; $m <= $m_last ; $m++)
    {
      $line = $lines {$language}{$m} ;
      chomp $line ;
      ($language,$date,$reguser_bot,$group,$counts) = split (',', $line, 5) ;
      @fields = split (',', $counts) ;

      foreach $f (2,3) # editors_gt_5, editors_gt_100
      {
        # count user with over x edits
        # threshold starting with a 3 are 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10), etc
        # thresholds = 1,3,5,10,25,32,50,100,etc
        if ($f == 2) { $f2 = 2 ; }
        if ($f == 3) { $f2 = 7 ; }

        $values {"$f,$m"} {"$project,$language"}  = $fields [$f2] ;
        $totals {"$f,$m"} += $fields [$f2] ;

        # ignore editor count on commons for totals, most editors are already counted for other project
        # (even for several projects, to be tuned after centralauth dump is available)
        if (($f <= 3) && ($language ne 'commons'))  # 0 = Contributors, 1 = New Wikimedians, 2 = Active Editors (5+ edits), 3 = Very Active Editors (100+ edits),
        { $totals_project {"$f,$m"} {$all_projects} += $fields [$f2] ; }

        if ($language eq 'commons')
        { $totals_project {"$f,$m"} {'commons'}  += $fields [$f2] ; }
        else
        { $totals_project {"$f,$m"} {$project}   += $fields [$f2] ; }
      }
    }
  }
  close CSV_IN ;
}

sub ReadStatisticsPerBinariesExtensionCommons
{
  my $file_csv_in = "$path_in/csv_wx/StatisticsPerBinariesExtension.csv" ;
  my $mmax = -1 ;

  if (! -e $file_csv_in)
  { &Abort ("Input file '$file_csv_in' not found") ; }

  print "Read '$file_csv_in'\n" ;
  open CSV_IN, '<', $file_csv_in ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    ($language,$date,$counts) = split (',', $line, 3) ;

    if ($language ne "commons") { next ; }

    if ($date eq "00/0000")
    {
      @fields = split (',', $counts) ;
      $field_ndx = 0 ;
      foreach $field (@fields)
      {
        $ext_cnt {-1}{$field_ndx} = $field ;
      # print "EXT_CNT $field_ndx : $field\n" ;
        $field_ndx ++ ;
      }
      next ;
    }

    ($month,$year) = split ('\/', $date) ;
    my $m = &months_since_2000_01 ($year,$month) ;
    next if $m < $m_start ;

    if ($m > $mmax)
    { $mmax = $m ; }

    @fields = split (',', $counts) ;
    $field_ndx = 0 ;
    foreach $field (@fields)
    {
      $ext_cnt {$m}{$field_ndx}  = $field ;
      $ext_tot {$m}             += $field ;
      $field_ndx ++ ;
    }
  }
  close CSV_IN ;

  %ext_cnt_mmax = %{$ext_cnt {$mmax}} ;
  @ext_cnt_mmax = (sort {$ext_cnt_mmax {$b} <=> $ext_cnt_mmax {$a}} keys %ext_cnt_mmax) ;

  $extcnt = 0 ;
  foreach $extndx (@ext_cnt_mmax)
  {
    # print "$extndx < ${ext_cnt {-1}{$extndx}} > : ${ext_cnt_mmax {$extndx}}\n" ;
    push @extndxs, $extndx ;
    if ($extcnt++ >= 9) { last ; }
  }
}

sub ReadMediaTrends
{
# open FILE_UV, '<', $file_regions_UV ;
# close FILE-UV ;

# open FILE_REACH, '<', $file_regions_Reach ;
# close FILE_REACH ;
}

sub WriteMonthlyData
{
  print "Write file '$file_csv_out'\n" ;
  open CSV_OUT, '>', $file_csv_out ;
  $output = "" ;
  foreach $f (1,2,3,4,6,11) # new editors, editors_gt_5, editors_gt_100, articles, new articles, edits
  {

    $output .= "\n,${out_report_descriptions [$f]} - Absolute - Per Wiki\n" ;
    $output .= "$csv_recent_months,%inc year, %inc month\n" ;

    $line = ",Total," ;
    for ($m = $m_start ; $m <= $m_last ; $m++)
    { $line .= $totals {"$f,$m"} . ","  ; }

    # growth in one year
    if ($totals {"$f,$m_last_12"} != 0)
    { $line .= sprintf ("%.1f", 100 * ($totals {"$f,$m_last"} / $totals {"$f,$m_last_12"}) - 100). "%,"  ; }
    else
    { $line .= "n.a.," ; }

    # growth in one month
    if ($totals {"$f,$m_last_1"} != 0)
    { $line .= sprintf ("%.1f", 100 * ($totals {"$f,$m_last"} / $totals {"$f,$m_last_1"}) - 100). "%,"  ; }
    else
    { $line .= "n.a.," ; }

    $line =~ s/,$// ;
    $output .= "$line\n" ;

    # sort by absolute amount for last month
    %values_f_12 = %{$values {"$f,$m_last"}} ;
    $index = 1 ;
    foreach $key (sort {$values_f_12 {$b} <=> $values_f_12 {$a}} keys %values_f_12)
    {
      ($project,$language) = split (",", $key) ;
      $language_name = $out_languages {$language} ;
      if (($project ne "wp") && ($project ne "wx"))
      { $line = "$index,$language_name " . &GetProjectName ($project) . "," ; }
      else
      { $line = "$index,$language_name," ; }

      for ($m = $m_start ; $m <= $m_last ; $m++)
      { $line .= $values {"$f,$m"} {$key} . ","  ; }

      if ($values {"$f,$m_last_12"} {$key} != 0)
      { $line .= sprintf ("%.1f", 100 * ($values {"$f,$m_last"} {$key} / $values {"$f,$m_last_12"} {$key}) - 100). "%,"  ; }
      else
      { $line .= "n.a.," ; }

      if ($values {"$f,$m_last_1"} {$key} != 0)
      { $line .= sprintf ("%.1f", 100 * ($values {"$f,$m_last"} {$key} / $values {"$f,$m_last_1"} {$key}) - 100). "%,"  ; }
      else
      { $line .= "n.a.," ; }

      $line =~ s/,$// ;
      $output .= "$line\n" ;

      if ($index++ >= 25) { last ; }
    }

    $output .= "\n,${out_report_descriptions [$f]} - Absolute - Per Project\n" ;
    if ($f <= 3)  # 0 = Contributors, 1 = New Wikimedians, 2 = Active Editors (5+ edits), 3 = Very Active Editors (100+ edits),
    { $output .= ",Note: All projects does not include Commons\n" ; }
    $output .= "$csv_recent_months,%inc year, %inc month\n" ;
    foreach $project (sort {$totals_project {"$f,$m_last"} {$b} <=> $totals_project {"$f,$m_last"} {$a}} @projects)
    {
#     next if $project eq 'commons' and ($f ==2 or $f == 3) ; # (very) active editors no longer counted for commons

      if ($project eq 'commons')
      { $line = ",Commons," ; }
      else
      { $line = "," . &GetProjectName ($project) . "," ; }

      for ($m = $m_start ; $m <= $m_last ; $m++)
      { $line .= $totals_project {"$f,$m"} {$project} . ","  ; }

      if ($totals_project {"$f,$m_last_12"} {$project} != 0)
      { $line .= sprintf ("%.1f", 100 * ($totals_project {"$f,$m_last"} {$project} / $totals_project {"$f,$m_last_12"} {$project}) - 100). "%,"  ; }
      else
      { $line .= "n.a.," ; }

      if ($totals_project {"$f,$m_last_1"} {$project} != 0)
      { $line .= sprintf ("%.1f", 100 * ($totals_project {"$f,$m_last"} {$project} / $totals_project {"$f,$m_last_1"} {$project}) - 100). "%,"  ; }
      else
      { $line .= "n.a.," ; }

      $line =~ s/,$// ;
      $output .= "$line\n" ;
    }

    $output .= "\n,${out_report_descriptions [$f]} - Indexed - Per Wiki\n" ;
    $output .= "$csv_recent_months\n" ;

    # sort by absolute amount for last month
    $index = 1 ;
    foreach $key (sort {$values_f_12 {$b} <=> $values_f_12 {$a}} keys %values_f_12)
    {
      # print "$index $f: $key -> ${values_f_12 {$key}}\n" ;

      ($project,$language) = split (",", $key) ;
      $language_name = $out_languages {$language} ;
      if (($project ne "wp") && ($project ne "wx"))
      { $line = "$index,$language_name " . &GetProjectName ($project) . "," ; }
      else
      { $line = "$index,$language_name," ; }

    # $value_100 = $values {"$f,$m_last_12"} {$key} ;
      $value_100 = $values {"$f,$m_start"} {$key} ;
      for ($m = $m_start ; $m <= $m_last ; $m++)
      {
        if ($value_100 != 0)
        { $line .= sprintf ("%.1f", 100 * ($values {"$f,$m"} {$key} / $value_100)) . ","  ; }
        else
        { $line .= "," ; }
      }
      $line =~ s/,$// ;
      $output .= "$line\n" ;

      # put totals last in chart to show line on top of others
      if ($index == 9)
      {
        $line = ",Total," ;
        $total_100 = $totals {"$f,$m_last_12"} ;
        for ($m = $m_start ; $m <= $m_last ; $m++)
        {
          if ($total_100 != 0)
          { $line .= sprintf ("%.1f", 100 * ($totals {"$f,$m"} / $total_100)) . ","  ; }
          else
          { $line .= "," ; }
        }
        $line .= ",(sorted here to make it top-most line out of 10 in Excel)" ;
        $output .= "$line\n" ;
      }

      if ($index++ >= 25) { last ; }
    }

    $output .= "\n,${out_report_descriptions [$f]} - Indexed - Per Project\n" ;
    $output .= "$csv_recent_months,%inc year, %inc month\n" ;
    foreach $project (sort {$totals_project {"$f,$m_last"} {$b} <=> $totals_project {"$f,$m_last"} {$a}} @projects)
    {
#     next if $project eq 'commons' and ($f ==2 or $f == 3) ; # (very) active editors no longer counted for commons

      if ($project eq 'commons')
      { $line = ",Commons," ; }
      else
      { $line = "," . &GetProjectName ($project) . "," ; }

    # $value_100 = $totals_project {"$f,$m_last_12"} {$project} ;
      $value_100 = $totals_project {"$f,$m_start"} {$project} ;
      for ($m = $m_start ; $m <= $m_last ; $m++)
      {
        if ($value_100 != 0)
        { $line .= sprintf ("%.1f", 100 * ($totals_project {"$f,$m"} {$project} / $value_100)) . ","  ; }
        else
        { $line .= "," ; }
      }
      $line =~ s/,$// ;
      $output .= "$line\n" ;
    }
    $output .= "\n," . '=' x 150 . "\n" ;
  }

  print CSV_OUT $output ;

  $output  = "\n,Binaries per month - Absolute\n" ;
  $output .= "$csv_recent_months,%inc year, %inc month\n" ;
  $output .= "\n$csv_recent_months,%inc year,%inc month\n" ;

  $line = ",Total," ;
  for ($m = $m_start ; $m <= $m_last ; $m++)
  { $line .= $ext_tot {$m} . ","  ; }

  if ($ext_tot {$m_last_12} != 0)
  { $line .= sprintf ("%.1f", 100 * ($ext_tot {$m_last} / $ext_tot {$m_last_12}) - 100). "%,"  ; }
  else
  { $line .= "n.a.," ; }

  if ($ext_tot {$m_last_1} != 0)
  { $line .= sprintf ("%.1f", 100 * ($ext_tot {$m_last} / $ext_tot {$m_last_1}) - 100). "%,"  ; }
  else
  { $line .= "n.a.," ; }

  $line =~ s/,$// ;
  $output .= "$line\n" ;

  $index = 0 ;
  # feed the 10 extensions with most pages, largest one last (comes on top in Excel chart)
  for ($e = $#extndxs - 9 ; $e <= $#extndxs ; $e++)
  {
    $index++ ;

    if ($e < 0)
    {
      $line = "$index,xxx," ;
      for ($m = $m_start ; $m <= $m_last ; $m++)
      { $line .= ","  ; }
    }
    else
    {
      $extndx = $extndxs [$e] ;
      $line = "$index,${ext_cnt {-1}{$extndx}}," ;

      for ($m = $m_start ; $m <= $m_last ; $m++)
      { $line .= $ext_cnt {$m}{$extndx} . ","  ; }

      if ($ext_cnt {$m_last_12}{$extndx} != 0)
      { $line .= sprintf ("%.1f", 100 * ($ext_cnt {$m_last}{$extndx} / $ext_cnt {$m_last_12}{$extndx}) - 100). "%,"  ; }
      else
      { $line .= "n.a.," ; }

      if ($ext_cnt {$m_last_1}{$extndx} != 0)
      { $line .= sprintf ("%.1f", 100 * ($ext_cnt {$m_last}{$extndx} / $ext_cnt {$m_last_1}{$extndx}) - 100). "%,"  ; }
      else
      { $line .= "n.a.," ; }
    }

    $line =~ s/,$// ;
    $output .= "$line\n" ;
  }

  print CSV_OUT $output ;

  $output  = "\n,Binaries per month - Indexed\n" ;
  $output .= "$csv_recent_months\n" ;

  $index = 0 ;
  # feed the 10 extensions with most pages, largest one last (comes on top in Excel chart)
  for ($e = $#extndxs - 9 ; $e <= $#extndxs ; $e++)
  {
    $index++ ;

    if ($e < 0)
    {
      $line = "$index,xxx," ;
      for ($m = $m_start ; $m <= $m_last ; $m++)
      { $line .= ","  ; }
    }
    else
    {
      $extndx = $extndxs [$e] ;
      $line = "$index,${ext_cnt {-1}{$extndx}}," ;
      $ext_cnt_m0 = $ext_cnt {$m_last-12}{$extndx} ;
    # $ext_cnt_m0 = $ext_cnt {$m_start}{$extndx} ;
      for ($m = $m_start ; $m <= $m_last ; $m++)
      {
        if ($ext_cnt_m0 > 0)
        { $line .= sprintf ("%.1f", 100 * ($ext_cnt {$m}{$extndx} / $ext_cnt_m0)). ","  ; }
        else
        { $line .= ","  ; }
      }
    }

    $line =~ s/,$// ;
    $output .= "$line\n" ;
  }
  print CSV_OUT $output ;
  close CSV_OUT  ;

  print "\nOutput written to $file_csv_out\n\n" ;
}

sub SetComparisonPeriods
{
  my @months = qw(Xxx Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec) ;

  my ($file_year_month_last, $year_month_last, $year_month_last_minus_12, $year_month_last_minus_1) ;

  $year_month_last          = sprintf ("%04d/%02d",$year_last,    $month_last) ; # for filenames
  $file_year_month_last     = sprintf ("%04d_%02d",$year_last,    $month_last) ; # for filenames
  $year_month_last_minus_12 = sprintf ("%04d/%02d",$year_last - 1,$month_last) ;
  $year_month_last_minus_1 = $month_last > 1 ? sprintf ("%04d/%02d",$year_last,$month_last-1):  sprintf ("%04d/%02d",$year_last - 1 ,12) ;

  print "\nWrite trend data up till $year_month_last\n\n" ;
  print "Compare with previous month: $year_month_last_minus_1, previous year: $year_month_last_minus_12\n\n" ;

  $csv_recent_months = ",project," ;
  $year  = $year_start ;
  $month = $month_start ;
  for ($m = $m_start ; $m <= $m_last ; $m++)
  {
    $recent_months [$m] = sprintf ("%04d/%02d", $year, $month) ;
    $csv_recent_months .= sprintf ("%02d/%04d", $month, $year) . "," ;
    ($year,$month) = $month < 12 ? ($year,$month+1) : ($year+1,1) ;
  }
  $csv_recent_months =~ s/,$// ;
}

#sub WriteCsvFilesPerPeriod
#{
#  foreach $period (sort keys %totals)
#  {
#    &LogT ("\nWrite totals per $period: ") ;
#    $desc = $descriptions {$period} ;

#    foreach $project (sort keys %{$totals {$period}})
#    {
#      &Log ("$project ") ;

#      $dir_out = "$path_out/csv_$project" ;
#      if (! -d $dir_out)
#      { mkdir $dir_out, 0777 ; }

#      $file_out = "$dir_out/$desc.csv" ;

#      open CSV, ">", $file_out ;
#      foreach $key (sort  {$a cmp $b} keys %{$totals {$period}{$project}})
#      {
#        ($language,$yearmonth) = split (",", $key) ;
#        # print "PERIOD $period PROJECT $project KEY $key\n" ;
#        if ($period eq "month")
#        { print CSV "$language," . $date_high {"$yearmonth"} . "," . $totals{$period}{$project}{$key} . "\n" ; }
#        else
#        { print CSV "$key," . $totals{$period}{$project}{$key} . "\n" ; }
#      }
#      close CSV ;
#    }
#  }
#}

#sub WriteCsvHtmlFilesPopularWikis
#{
#  @totals_lastmonth = sort {$totals_lastmonth {$b} <=> $totals_lastmonth {$a}} keys %totals_lastmonth ;

#  $dir_out  = "$path_out/csv_wp" ;
#  $file_out = "$dir_out/PageViewsPerMonthPopularWikis_$file_year_month_last.csv" ;

## extend with normalized counts
## see manually created PageViewsPerMonthTop25PlusNormalizedTo100.csv

#  open CSV, ">", $file_out ;
#  print CSV $csv_recent_months ;

#  # write per popular language+wiki 13 months of page view totals
#  $lines = 0 ;
#  foreach $line (@totals_lastmonth)
#  {
#    if (++$lines > $maxpopularwikis) { last ; }

#    ($project, $language) = split (',', $line) ;
#    $largest_projects {"$project-$language"} ++ ;

#    $language_name = $out_languages {$language} ;

#    if (($project ne "wp") && ($project ne "wx"))
#    { print CSV "$language_name " . &GetProjectName ($project) . "," ; }
#    else
#    { print CSV "$language_name," ; }

## %test = %{$totals {"month"} {"wp"} };
## %test2 = @recent_months ;
#    for ($m = 0 ; $m <= 12 ; $m++)
#    { print CSV $totals {"month"} {$project} {"$language,${recent_months [$m]}"} . "," ; }
#    print CSV "\n" ;
#  }

#  print CSV "\n$csv_recent_months" ;

#  # write per popular language+wiki 13 months of page view totals, normalized to first month = 100
#  $lines = 0 ;
#  foreach $line (@totals_lastmonth)
#  {
#    if (++$lines > $maxpopularwikis) { last ; }

#    ($project, $language) = split (',', $line) ;
#    $language_name = $out_languages {$language} ;

#    if (($project ne "wp") && ($project ne "wx"))
#    { print CSV "$language_name " . &GetProjectName ($project) . "," ; }
#    else
#    { print CSV "$language_name," ; }

#    $recent_month_0 = $totals {"month"} {$project} {"$language,${recent_months [ 0]}"} ;
#    for ($m = 0 ; $m <= 12 ; $m++)
#    {
#      if ($recent_month_0 > 0)
#      { print CSV sprintf ("%.2f", 100 * $totals {"month"} {$project} {"$language,${recent_months [$m]}"} / $recent_month_0) . "," ; }
#      else
#      { print CSV "," ; }
#    }

#    print CSV "\n" ;
#  }
#  close CSV ;

#  # write ready made table rows for report card: page views top 25 movers shakers
#  foreach $key (keys %largest_projects)
#  {
#    ($project,$language) = split ('-', $key) ;

#    $total_lastmonth = $totals {"month"} {$project} {"$language,$month_last"} ;
#    $total_prevmonth = $totals {"month"} {$project} {"$language,$year_month_last_minus_1"} ;
#    $total_prevyear  = $totals {"month"} {$project} {"$language,$year_month_last_minus_12"} ;

#    $perc_month = "no data" ;
#    $perc_year  = "no data" ;

#    if ($total_prevyear > 0)
#    { $perc_year  = sprintf ("%.1f", 100 * $total_lastmonth/$total_prevyear - 100) ; }
#    if ($total_prevyear > 0)
#    { $perc_month = sprintf ("%.1f", 100 * $total_lastmonth/$total_prevmonth - 100) ; }

#    $line = "$project-$language: $total_prevyear=>$total_lastmonth=$perc_year%, $total_prevmonth=>$total_lastmonth=$perc_month%" ;

#    $total_lastmonth = sprintf ("%.0f", $total_lastmonth / 1000000) ;

#    $project_name  = &GetProjectName ($project) ;
#    $language_name = $out_languages {$language} ;

#    $col1 = "<td class=detail-left>$language_name $project_name</td>\n" ;
#    $col2 = "<td class=detail-blue>$total_lastmonth</td>\n" ;
#    $col3 = "<td class=detail-blue>$perc_month%</td>\n" ;
#    $col4 = "<td class=detail-blue>$perc_year%</td>\n" ;
#    $html = "<tr>\n$col1$col2$col3$col4</tr>\n" ;

#    $growth_figures_text {"$perc_month-$project-$language"} = $line ;
#    $growth_figures_html {"$perc_month-$project-$language"} = $html ;
#  }

#  $file_html = "$dir_out/PageViewsMoversShakersPopularWikis_$file_year_month_last.html" ;

#  open HTML, ">", $file_html ;
#  foreach $key (sort {$b <=> $a} keys %growth_figures_text)
#  {
#    print "$key: ". $growth_figures_text {$key} . "\n" ;
#    print HTML $growth_figures_html {$key} ;
#  }
#  close HTML ;
#}


sub GetProjectName
{
  my $project =shift ;

     if ($project eq "wp") { $project_name = "Wikipedia"; }
  elsif ($project eq "wb") { $project_name = "Wikibooks"; }
  elsif ($project eq "wk") { $project_name = "Wiktionary"; }
  elsif ($project eq "wx") { $project_name = "Other Wikis"; }
  elsif ($project eq "wn") { $project_name = "Wikinews"; }
  elsif ($project eq "wq") { $project_name = "Wikiquote"; }
  elsif ($project eq "ws") { $project_name = "Wikisource"; }
  elsif ($project eq "wv") { $project_name = "Wikiversity"; }
  elsif ($project eq "*")  { $project_name = "All projects"; }

  return ($project_name) ;
}

sub MonthsSinceYearAgo
{
  my $year  = shift ;
  my $month = shift ;
  return 12 - (($year_last - $year) * 12 + $month_last - $month) ;
}

sub MonthsSinceFirstMonthToShow
{
  my $year  = shift ;
  my $month = shift ;
  return ($year - 2008) * 12 + ($month - 1) ;
}

# code year,month as monthes since january 2000 (1 byte)
sub months_since_2000_01
{
  my $year  = shift ;
  my $month = shift ;
  my $m = ($year - 2000) * 12 + $month ;
  return $m ;
}

#sub Log
#{
#  $msg = shift ;
#  print $msg ;
#  print LOG $msg ;
#}

#sub LogT
#{
#  $msg = shift ;
#  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
#  my $time = sprintf ("%02d:%02d:%02d ", $hh, $mm, $ss) ;
#  $msg =~ s/^(\n*)/$1$time/s ;
#  &Log ($msg) ;
#}

sub MmSs
{
  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  return (sprintf ("%02d:%02d:%02d ", $hh, $mm, $ss)) ;
}

sub Abort
{
  my $msg = shift ;
  print "$msg\nExecution aborted." ;
  # to do: log also to file
  exit ;
}

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

# copied from WikiReports_EN.pl
sub InitReportNames
{
 @out_report_descriptions = (
  "Contributors",
  "New editors",
  "Active editors",
  "Very active editors",
  "Article count (official)",
  "Article count (alternate)",
  "New articles per day",
  "Edits per article",
  "Bytes per article",
  "Articles over 0.5 Kb",
  "Articles over 2 Kb",
  "Edits per month",
  "Database size",
  "Words",
  "Internal links",
  "Links to other Wikipedias",
  "Binaries",
  "External links",
  "Redirects",
  "Page requests per day",
  "Visits per day",
  "Overview recent months"
  ) ;
}

