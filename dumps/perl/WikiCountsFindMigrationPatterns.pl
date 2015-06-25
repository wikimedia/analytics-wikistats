#!/usr/bin/perl

# =~

  #to do check $ns against 'content' namespaces for that wiki

  use Time::Local ;
  use Getopt::Std ;

  # ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time) [6] ;
  $yyyy = (localtime(time)) [5] + 1900 ;
  for ($n = 2001 ; $n < $yyyy ; $n++)  # report up till , but not including, (incomplete) current year
  { push @periods, $n ; }

  $| = 1; # Flush output
  our $verbose = 0 ;
  our $time_start = time ;
  our $true = 1 ;
  our $false = 0 ;

  # copy aggregated lines to stdout?
  our $trace   = $true ;
  our $notrace = $false ;

  our $absolute = 1 ;
  our $relative = 0 ;

  our $sort_by_frequency = 0 ;
  our $sort_alphabetical = 1 ;

  our $threshold_perc_dominant_project = 60 ; # only when edit exceeds this threshold on some project, that project will be considered main project for that user for that period
  our $threshold_active_enough = 5 ;

  our $skip_users_before_logging = 50000 ;
  our $first_lines_only          = 0 ;
  if ($first_lines_only > 0)
  { $skip_users_before_logging = 0 ; }

  our %names ;
  $names {'wb'} = 'Wikibooks' ;
  $names {'wk'} = 'Wiktionary' ;
  $names {'wn'} = 'Wikinews' ;
  $names {'wo'} = 'Wikivoyage' ;
  $names {'wp'} = 'Wikipedia' ;
  $names {'wq'} = 'Wikiquote' ;
  $names {'ws'} = 'Wikisource' ;
  $names {'wv'} = 'Wikiversity' ;
  $names {'wx'} = 'Other projects' ;
  $names {'co'} = 'Commons' ;
  $names {'wd'} = 'Wikidata' ;

  our %editors_migrating_in ;
  our $users_upd_counts ; # used for spare logging
  our $period_max ;       # used for reporting

  my %options ;
  getopt ("c", \%options) ;
  $path_csv  = $options {'c'} ;

  if (-d "d:/\@wikimedia/") # test code on local machine
  { $path_csv = "d:/\@wikimedia/\# out stat1/csv_mw" ; }

  $file_in                       = "$path_csv/EditsPerUserMonthNamespaceAllWikisSortedByUserByPeriod.tsv" ;
  $file_bots                     = "$path_csv/BotsAllProjects.csv" ;

  $file_out_projects_yyyymm      = "$path_csv/EditsPerUserPerProjectAggregatedMonthly.tsv" ;
  $file_out_projects_yyyy        = "$path_csv/EditsPerUserPerProjectAgregatedYearly.tsv" ;
  $file_out_projects_yyyy_matrix = "$path_csv/EditsPerUserPerProjectMigrationsPerYearMatrix-Edits$threshold_active_enough-Perc$threshold_perc_dominant_project.csv" ;

  $file_out_wikis_yyyymm         = "$path_csv/EditsPerUserPerWikiAggregatedMonthlyWp.tsv" ;
  $file_out_wikis_yyyy           = "$path_csv/EditsPerUserPerWikiAggregatedYearlyWp.tsv" ;
  $file_out_wikis_yyyy_matrix    = "$path_csv/EditsPerUserPerWikiMigrationsPerYearMatrix-Edits$threshold_active_enough-Perc$threshold_perc_dominant_project.csv" ;

  die "Specify path to csv files as: -c [path]" if ! -d $path_csv ;
  die "Input file '$file_in' not found" if ! -e $file_in ;
  print "Path to csv files: $path_csv\n" ;

# &Aggregate ;
# &FindMigrations ('projects') ;
  &FindMigrations ('wikis') ;
  &WriteOutput ('wikis') ;;

  print "\nReady\n" ;
  exit ;

sub Aggregate
{
  my $user_prev = '' ;
  my $yyyymm_prev = '' ;
  my $yyyy_prev = '' ;

  # read merged editor activity for all wikis
  # user, yyyy-mm, project, language, namespace, edits
  open  TSV_IN, '<', $file_in || die "Could not open $file_in" ;
  binmode TSV_IN ;

  &ReadBots ;

  # output one line per user per month, with total edits per project
  open (my $fh_out_projects_yyyymm, '>', $file_out_projects_yyyymm || die "Could not open $file_out_projects_yyyymm") ;
  binmode  $fh_out_projects_yyyymm ;
  print    $fh_out_projects_yyyymm "user,period,edits wb,edits wk,edits wn,edits wo,edits wp,edits,wq,edits ws,edits wv,edits wx\n" ;

  # output one line per user per year with total edits per project
  open (my $fh_out_projects_yyyy, '>', $file_out_projects_yyyy || die "Could not open $file_out_projects_yyyy") ;
  binmode  $fh_out_projects_yyyy ;
  print    $fh_out_projects_yyyy "user,period,edits wb,edits wk,edits wn,edits wo,edits wp,edits,wq,edits ws,edits wv,edits wx\n" ;

  # output one line per user per month, with total edits per wiki
  open (my $fh_out_wikis_yyyymm, '>', $file_out_wikis_yyyymm || die "Could not open $file_out_wikis_yyyymm") ;
  binmode  $fh_out_wikis_yyyymm ;
  print    $fh_out_wikis_yyyymm "user\tperiod\tmain wiki\tperc edits on main wiki\ttotal edits\tedits per wiki\n" ;

  # output one line per user per year with total edits per wiki
  open (my $fh_out_wikis_yyyy, '>', $file_out_wikis_yyyy || die "Could not open $file_out_wikis_yyyy") ;
  binmode  $fh_out_wikis_yyyy ;
  print    $fh_out_wikis_yyyy "user\tperiod\tmain wiki\tperc edits on main wiki\ttotal edits\tedits per wiki\n" ;

  my $lines_in ;
  while ($line = <TSV_IN>)
  {
    chomp $line ;
    ($user,undef,$yyyymm,$project,$wiki,$ns,$edits) = split ("\t", $line) ;

    next if $bots {$project}{$wiki}{$user} ;

    last if (($first_lines_only) && ($lines_in++ > $first_lines_only)) ;

    if ($lines_in++ % 10000 == 0)
    { print "$user\n" ; }
    # debug:
# if ($user eq 'Jimbo_Wales')
# { $a = 1 ; }
    if ($wiki eq 'commons')
    { $project = 'co' ; }
    if ($wiki eq 'wikidata')
    { $project = 'wd' ; }

    next if $ns != 0 ; # and $ns != 6 ; # to do check $ns against 'content' namespaces for that wiki
    $yyyy = substr ($yyyymm,0,4) ;

# next if substr ($yyyymm,5,2) ne '01' ;
# next if $project ne 'wp' ;
# next if $wiki ne 'en' ;
 ## next if $yyyy != 2004 ;

    if (($user ne $user_prev) || # if all edits for this user for this month are collected, send to output
        ($yyyymm ne $yyyymm_prev))
    {
      &WriteProjectCounts ($notrace, $fh_out_projects_yyyymm, $user_prev, $yyyymm_prev, \%yyyymm_projects) ;
      &WriteWikiCounts    ($notrace, $fh_out_wikis_yyyymm,    $user_prev, $yyyymm_prev, \%yyyymm_wikis) ;
      undef %yyyymm_projects ;
      undef %yyyymm_wikis ;
    }

    if (($user ne $user_prev) || # if all edits for this user for this year are collected, send to output
        ($yyyy ne $yyyy_prev))
    {
      &WriteProjectCounts ($notrace, $fh_out_projects_yyyy, $user_prev, $yyyy_prev, \%yyyy_projects) ;
      &WriteWikiCounts    ($notrace, $fh_out_wikis_yyyy,    $user_prev, $yyyy_prev, \%yyyy_wikis) ;
      undef %yyyy_projects ;
      undef %yyyy_wikis ;
    }

    $user_prev   = $user ;
    $yyyymm_prev = $yyyymm ;
    $yyyy_prev   = $yyyy ;

    # aggregate per month/year, per project and all projects
    $yyyymm_projects {'tot'} += $edits ;
    $yyyy_projects   {'tot'} += $edits ;
    $yyyymm_projects {$project} += $edits ;
    $yyyy_projects   {$project} += $edits ;

    # aggregate per month/year, per wiki and all wikis
    if ($project eq 'wp')
    {
      $yyyymm_wikis {'tot'} += $edits ;
      $yyyy_wikis   {'tot'} += $edits ;
      $yyyymm_wikis {$wiki} += $edits ;
      $yyyy_wikis   {$wiki} += $edits ;
    }

    # debug:
    # print "$user $yyyymm $yyyy $edits $lang\n" ;
  }

  print "\nAll input processed\n\n" ;
  &WriteProjectCounts ($notrace, $fh_out_projects_yyyymm, $user_prev, $yyyymm_prev, \%yyyymm_projects) ;
  &WriteProjectCounts ($notrace, $fh_out_projects_yyyy,   $user_prev, $yyyy_prev,   \%yyyy_projects) ;
  &WriteWikiCounts    ($notrace, $fh_out_wikis_yyyymm,    $user_prev, $yyyymm_prev, \%yyyymm_wikis) ;
  &WriteWikiCounts    ($notrace, $fh_out_wikis_yyyy,      $user_prev, $yyyy_prev,   \%yyyy_wikis) ;

  close TSV_IN ;
}

sub WriteProjectCounts
{
  my ($trace, $filehandle, $user, $period, $hash_userdata) = @_ ;
  my %userdata = %$hash_userdata ;

  return if $user eq '' ; # not on first line of input

  my ($edits_max, $project_main, $perc_main, $project, $line, $key) ;

  $project_main = 'xx' ;
  $edits_max = 0 ;
  foreach $project (qw (wb wk wn wo wp wq ws wv wx co wd))
  {
    if ($userdata {$project} > $edits_max)
    {
      $edits_max = $userdata {$project} ;
      $project_main = $project ;
    }
  }

  if ($userdata {'tot'} == 0)
  {
    print "total edits zero for user '$user' period $period" ;
    exit ;
  }
  $perc_main = sprintf ("%.0f", 100 * $edits_max / $userdata {'tot'}) ;
  $line =  "$user\t$period\t" .
           $project_main . "\t" .
           $perc_main . "\t" .
           (0 + $userdata {'tot'}) . "\t" .
           (0 + $userdata {'wb'}) . "\t" .
           (0 + $userdata {'wk'}) . "\t"        .
           (0 + $userdata {'wn'}) . "\t"        .
           (0 + $userdata {'wo'}) . "\t"        .
           (0 + $userdata {'wp'}) . "\t"        .
           (0 + $userdata {'wq'}) . "\t"        .
           (0 + $userdata {'ws'}) . "\t"        .
           (0 + $userdata {'wv'}) . "\t"        .
           (0 + $userdata {'wx'}) . "\t"        .
           (0 + $userdata {'co'}) . "\t"        .
           (0 + $userdata {'wd'}) ;

  if ($trace)
  { print "$line\n" ; }
  print $filehandle "$line\n" ;
}


sub WriteWikiCounts
{
  my ($trace, $filehandle, $user, $period, $hash_userdata) = @_ ;
  my %userdata = %$hash_userdata ;

  return if $user eq '' ; # not on first line of input

  my ($edits_max, $wiki_main, $perc_main, $wiki, $line, $key) ;

  $wiki_main = '?' ;
  $edits_max = 0 ;
  foreach $wiki (@wikis)
  {
    if ($userdata {$wiki} > $edits_max)
    {
      $edits_max = $userdata {$wiki} ;
      $wiki_main = $wiki ;
    }
  }

  return if $userdata {'tot'} == 0 ; # user did not edit on Wikipedia

  @wikis_this_user = sort {$userdata {$b} <=> $userdata {$a}} keys %userdata ;

  $perc_main = sprintf ("%.0f", 100 * $edits_max / $userdata {'tot'}) ;
  $line =  "$user\t$period\t" .
           $wiki_main . "\t" .
           $perc_main . "\t" .
           $userdata {'tot'} . "\t" ;

  foreach $wiki (@wikis_this_user)
  {
    next if $wiki eq 'tot' ;
    last if $userdata {$wiki} == 0 ;
    $line .= "$wiki:" . $userdata {$wiki} . "|" ;
  }

  $line =~ s/\|$// ;

  if ($trace)
  { print "$line\n" ; }
  print $filehandle "$line\n" ;
}

sub FindMigrations
{
  my ($mode) = @_ ;

  if ($mode eq 'projects')
  {
    $name_workspace = 'project' ;
    open  CSV_IN_YYYY,    '<', $file_out_projects_yyyy        || die "Could not open $file_out_projects_yyyy" ;
    open  CSV_OUT_MATRIX, '>', $file_out_projects_yyyy_matrix || die "Could not open $file_out_projects_yyyy_matrix" ;
  }
  else
  {
    $name_workspace = 'wiki' ;
    open  CSV_IN_YYYY,    '<', $file_out_wikis_yyyy        || die "Could not open $file_out_wikis_yyyy" ;
    open  CSV_OUT_MATRIX, '>', $file_out_wikis_yyyy_matrix || die "Could not open $file_out_wikis_yyyy_matrix" ;
  }

  binmode CSV_IN_YYYY ;
  binmode CSV_OUT_MATRIX ;

  my $user_prev = '' ;
  my (%workspace_main, %perc_main, %total_edits, $lines_read) ;
  my $periods_active_enough = 0 ;

  my $line = <CSV_IN_YYYY> ; # skip header line
  while ($line = <CSV_IN_YYYY>)
  {
    last if (($first_lines_only) && ($lines_migrations++ > $first_lines_only)) ;

    chomp $line ;
  # my ($user,$period,$workspace_main,$perc_main,$total,$wb,$wk,$wn,$wo,$wp,$wq,$ws,$wv,$wx,$co,$wd) = split (',', $line) ; # for projects
    my ($user,$period,$workspace_main,$perc_main,$total) = split ("\t", $line) ; # works for projects and wikis

    $workspaces_main {$workspace_main}++ ;

    if ($period gt $period_max)
    { $period_max = $period ; }

    if (($user ne $user_prev) && ($user_prev ne ''))
    {
      &UpdCountsForThisUser ($user_prev, $periods, \%workspace_main, \%perc_main, \%total_edits) ;

      undef %workspace_main ;
      undef %perc_main ;
      undef %total_edits ;
      undef $periods_active_enough ;
      $periods = 0 ;
    }

    $workspace_main {$period} = $workspace_main ;
    $perc_main      {$period} = $perc_main ;
    $total_edits    {$period} = $total ;
    $periods ++ ;

    $user_prev = $user ;
  }
  &UpdCountsForThisUser ($user_prev, $periods, \%workspace_main, \%perc_main, \%total_edits) ;
}

sub UpdCountsForThisUser
{
  my ($username,$periods,$hash_workspace_main,$hash_perc_main,$hash_total_edits) = @_ ;

  my %workspace_main = %$hash_workspace_main ;
  my %perc_main      = %$hash_perc_main ;
  my %total_edits    = %$hash_total_edits ;

  my ($log_migrations_lines,$userline,$loglines,
      $path,$flag,$flag_prev,$period,$total,$total_prev,$perc,$perc_prev,$period_prev,$workspace,$workspace_prev,
      %qualifying_period, $qualifying_periods, $first_qualifying_period, $last_qualifying_period) ;

  foreach $period (sort keys %total_edits)
  {
    $perc      = $perc_main   {$period} ;
    $total     = $total_edits {$period} ;

    if (($total >= $threshold_active_enough) && ($perc >= $threshold_perc_dominant_project))
    {
      $qualifying_period {$period} ++ ;
      $qualifying_periods ++ ;
      $qualifying_periods_overall ++ ;
      $last_qualifying_period = $period ;

      if ($first_qualifying_period eq '')
      { $first_qualifying_period = $period ; }
    }
    else
    {
      if ($total >= $threshold_active_enough)
      { $non_qualifying_periods_overall ++ ; }
    }
  }

  foreach $period (sort keys %total_edits)
  {
    $flag = '-' ;

    if ($qualifying_period {$period})
    {
      $workspace = $workspace_main {$period} ;
      $perc      = $perc_main   {$period} ;
      $total     = $total_edits {$period} ;

      $editors {'all'} {$period} ++ ;
      $editors {$workspace} {$period} ++ ;

      if ($qualifying_periods == 1)
      {
        $editors_once {$workspace} {$period} ++ ; # matrix metric
        $flag = '1' ; # only edited in one period
      }
      # user new or back after no or too few edits?
      # if (($period_prev eq '') || ($period > $period_prev + 1))
      elsif ($period eq $first_qualifying_period) # ($flag_prev eq '') || ($flag_prev =~ /[ep]/))
      {
        $editors_new {$workspace} {$period} ++ ; # matrix metric
        $flag = 'N' ; # new
      }
      # user enough active on consecutive periods
      else
      {
        # did main workspace stay the same in those years?
        if ($workspace eq $workspace_prev)
        {
          $editors_staying {$workspace} {$period} ++ ; # matrix metric
          $flag = 'S' ; # staying
        }
        else
        {
          # user migrated to other main workspace
          $editors_migrating_in  {$workspace}      {$period}      ++ ;  # matrix metric
          $editors_migrating_out {$workspace_prev} {$period_prev} ++ ;  # matrix metric
          $flag = 'M' ; # M

          # log migration
          if (((++ $log_migrations_lines) % 1) == 0)
          { $loglines .= sprintf ("%30s",$user) . "\t$user,$period,$workspace_prev ($perc_prev\% of $total_prev) -> " .
                                                  "$workspace ($perc\% of $total)})\n" ; }

          $path     = "$workspace_prev->$workspace" ;
          $path_out = "$workspace_prev->" ;
          $path_in  = "->$workspace" ;

          $migrations {"$period,$path"} ++ ;
          $migrations_total {$path} ++ ; # used as column sort in reporting

          $migrations_in  {"$period,$path_in"}  ++ ;
          $migrations_out {"$period_prev,$path_out"} ++ ;
         }
      }

      if ($period eq $last_qualifying_period)
      {
        $editors_lost {$workspace_prev} {$period} ++ ; # matrix metric
        $flag = 'X' ; # X = last qualifying period, overrides earlier set flag (for trace only)
      }

      $period_prev     = $period ;
      $workspace_prev  = $workspace ;
      $perc_prev       = $perc ;
      $total_prev      = $total ;
    }
    elsif ($total < $threshold_active_enough)
    { $flag = "e" ; } # not enough edits
    else
    { $flag = "p" ; } # not enough percentage edits on main project

    $userline .= "$period:$flag:${workspace_main{$period}}:${perc_main{$period}}\%[ed:${total_edits{$period}}], " ;

    $flag_prev       = $flag ;
  }

  $userline =~ s/,\s*$// ;
  if (($skip_users_before_logging == 0) || ($users_upd_counts++ % $skip_users_before_logging == 0))
  { print sprintf ("%30s",$username) . "\t$userline\n$loglines\n\n" ; }
}

sub WriteOutput
{
  my ($workspace) = @_ ;

# &print_comment ("Only editors with at least $threshold_active_enough namespace 0 edits in a year are examined here for migration behavior\n") ;
# &print_comment ("An editor is considered to have a 'main project of interest' when at least $threshold_perc_dominant_project\% of ns 0 edits are on that project\n") ;

  &print_comment ("This report is about a subset of editors who contributed substantially to one or more Wikimedia wikis and most of those edits to one $name_workspace\n") ;
  &print_comment ("Edits are page changes in 'content' namespaces") ;
  &print_comment ("Editors qualify when they made at least $threshold_active_enough edits in a year, and at least $threshold_perc_dominant_project\% of those edits in one ('main') project\n") ;
  &print_comment ("An editor is considered to have 'migrated' when this main project differs in consecutive qualifying (= enough edits) periods") ;
  &print_comment ("An editor can migrate from one project to another and migrate back later on") ;
  &print_comment ("Each editor is counted at most once a year, on their 'main' $name_workspace only") ;

  &WriteMigrationsPerPath ($absolute, $sort_by_frequency, $workspace) ;
# &WriteMigrationsPerPath ($absolute, $sort_by_frequency) ;

  &WriteMigrationsPerWorkspace ($workspace) ;
}


sub WriteMigrationsPerPath
{
  my ($absolute, $sort_order, $workspace)  = @_ ;

  $absolute = $true ; # not sure yet about how to calc best relative migrations -> relative not yet implemented

  my $line ;

  if ($sort_order == $sort_alphabetical)
  {
    $msg_sort = "paths ordered alphabetically" ;
    @sequence_paths = sort {$a cmp $b} keys %migrations_total ;
    @sequence_workspaces = sort {$editors {$b} {$period_max} <=> $editors {$a} {$period_max}} keys %workspaces_main ;
  }
  else
  {
    $msg_sort = "paths ordered by frequency of occurrence" ;
    @sequence_paths = sort {$migrations_total {$b} <=>  $migrations_total {$a}} keys %migrations_total ;
    @sequence_workspaces = sort {$editors {$b} {$period_max} <=> $editors {$a} {$period_max}} keys %workspaces_main ;
  }

  if ($absolute)
  {
    $line = "\n\nMigrations per path (= from $name_workspace xx -> to $name_workspace yy), as absolute numbers, $msg_sort\n" ;
    if ($namespace eq 'project')
    { $line .= "wb:wikibooks, wk:wiktionary, wn:wikinews, wo:wikivoyage, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, co:commons, wd:wikidata, wx:other projects\n" ; }
  }
  else
  {
    $line = "\n\nMigrations per path (= from $name_workspace xx -> to $name_workspace yy), as relative numbers, $msg_sort\n" ;
    if ($namespace eq 'project')
    { $line .= "wb:wikibooks, wk:wiktionary, wn:wikinews, wo:wikivoyage, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, co:commons, wd:wikidata, wx:other projects\n" ; }
    $line .= "Relative migrations (percentage of editors above threshold $threshold_perc_dominant_project in that period (migrating + non migrating)" ;
  }
  &print_comment ($line) ;

  if ($qualifying_periods_overall + $non_qualifying_periods_overall > 0 )
  { $line = sprintf ("%.1f", 100 - 100 * $qualifying_periods_overall / ($qualifying_periods_overall + $non_qualifying_periods_overall)) .
            "\% user-periods were discarded where user had enough edits but no 'main' $name_workspace (> $threshold_perc_dominant_project\% edits)\n" ;
    &print_comment ($line) ;
  }

  # print headers
  $line = "," ;
  $column = 0 ;
  foreach $path (@sequence_paths)
  {
    $line .= ralign ($path) . ',' ;
    last if ++$column >= 20 ;
  }
  &print_columns ($line) ;

  # print totals
  $line = "total," ;
  $column = 0 ;
  foreach $path (@sequence_paths)
  {
    $line .= ralign ($migrations_total {$path}) . ',' ;
    last if ++$column >= 20 ;
  }
  &print_columns ($line) ;

  # print per period for each significant migration pair (from->to) number of migrations
  foreach $period (@periods)
  {
    next if $period == $periods [0] ;
    $line = "$period," ;
    $column = 0 ;
    foreach $path (@sequence_paths)
    {
      $line .= ralign ($migrations {"$period,$path"}) . "," ;
      last if ++$column >= 20 ;
    }
    &print_columns ($line) ;
  }

  &print_comment ("\nEditors who migrated in or out - as percentage of total editors who qualified for that year and $name_workspace\n\n") ;

  # print headers
  $line = "," ;
  $column = 0 ;
  foreach $path (@sequence_workspaces)
  {
    $line .= ralign ("$path in") . ',' . ralign ("$path out") . ',' ;
    last if ++$column >= 20 ;
  }
  &print_columns ($line) ;

#  # print totals
#  $line = "total," ;
#  $column = 0 ;
#  foreach $path (@sequence_workspaces)
#  {
#    $line .= ralign ($migrations_total {$path}) . ',' ;
#    last if ++$column >= 20 ;
#  }
#  &print_columns ($line) ;

  # print per period for each significant migration pair (from->to) number of migrations
  foreach $period (@periods)
  {
    next if $period == $periods [0] ;
    $line = "$period," ;
    $column = 0 ;
    foreach $workspace (@sequence_workspaces)
    {
    #  $migrations_in  = $migrations_in  {"$period,->$workspace"} ;
    #  $migrations_out = $migrations_out {"$period,$workspace->"} ;
    # if ($migrations_in  eq '') { $migrations_in  = '-' ; }
    # if ($migrations_out eq '') { $migrations_out = '-' ; }

      $perc_in  = &percent ($editors {$workspace} {$period},$migrations_in  {"$period,->$workspace"}) ;
      $perc_out = &percent ($editors {$workspace} {$period},$migrations_out {"$period,$workspace->"}) ;

      $line .= ralign ($perc_in) . ',' . ralign ($perc_out) . ',' ;
      last if ++$column >= 20 ;
    }
    &print_columns ($line) ;
  }

  &print_comment ("\n") ;
}

sub WriteMigrationsPerWorkspace
{
  my ($workspace) = @_ ;


  &print_comment ("\n") ;

# if ($absolute)
# { print CSV_OUT_MATRIX "Percentages show how many editors came from other workspaces, as share of total editors on this workspace\n\n" ; }
#  else
#  { print CSV_OUT_MATRIX "Percentages show how many editors came from other workspaces, as share of total editors overall\n\n" ; }

  if ($workspace eq 'projects')
  { @sequence_workspaces = qw (wb wk wn wo wp wq ws wv co wd wx) ; }
  else
  {
    @sequence_workspaces = sort {$editors {$b} {$period_max} <=> $editors {$a} {$period_max}} keys %workspaces_main ;
    $#sequence_workspaces = 200 ;  # show 10 top workspaces
  }

# @sequence_workspaces = qw (wk wp co wd) ;

  &print_comment ("Edits are page changes in 'content' namespaces") ;
  &print_comment ("Editors qualify when they made at least $threshold_active_enough edits in a year, and at least $threshold_perc_dominant_project\% of those edits in one ('main') project\n") ;
  &print_comment ("Columns:\n") ;
  &print_comment ("* one year only = editors who only qualified in one year") ;
  &print_comment ("* new = editors who never edited earlier, or edited but did not qualify in earlier years, and qualified again in later year") ;
  &print_comment ("* staying = editors who qualified in earlier year, and kept their focus on this $name_workspace") ;
  &print_comment ("* migrating in = editors who qualified in earlier year, and changed their focus to this $name_workspace") ;
  &print_comment ("* total = one year only + new + staying + migrating in") ;
  &print_comment ("* migrating in = editors who qualified in this year, and changed their focus in next qualifying year to other $name_workspace") ;
  &print_comment ("* last year = editors who qualified in this year, and stopped editing or did not qualify in later years") ;

# # print headers
#  $line = "proj->," ;
#  foreach $project (@sequence_workspaces)
## { $line .= &ralign ($project) . ',' . &ralign ($project) . ',' ; }
#  { $line .= $names {$project} . " ($project),,," ; }
#  print CSV_OUT_MATRIX "$line\n" ;                                                         absolute

#  $line =~ s/,/\t/g ;
#  print "$line\n" ;

#  $line = "period," ;
#  foreach $project (@sequence_workspaces)
#  { $line .= &ralign ('abs') . ',' . &ralign ('rel %%') . ',' . &ralign ('rel2 %%') . ',,' ; }
#  print CSV_OUT_MATRIX "$line\n" ;
#  $line =~ s/,/\t/g ;
#  print "$line\n" ;

  # print data per period per project
  foreach $project (@sequence_workspaces)
  {
    $line = "\n\n" . $names {$project} . " ($project)\n" ;
    print CSV_OUT_MATRIX "$line\n" ;
    $line =~ s/,/\t/g ;
    print "$line\n" ;

    &print_columns ("period,absolute ->-------------------------------------------------------------<- absolute,,,,,,,,relative->-------------------------------------------------------------<-relative") ;
    $line = "," .  ralign ('one yr') . "," .  ralign ('new') . ',' . ralign ('staying') . ',' . ralign ('migr') . ',' . ralign ('total') . ',' . ralign ("migr") . ',' . ralign ("last") .
            ",," . ralign ('one yr') . ',' . ralign ('new') . ',' . ralign ('staying') . ',' . ralign ('migr') . ',' . ralign ('total') . ',' . ralign ("migr") . ',' . ralign ("last") ;
    &print_columns ($line) ;

    $line = "," . ralign ('only') . ",,," .   ralign ('in') . ',,' . ralign ('out') . ',' . ralign ('year') . ',' .
             "," . ralign ('only') . ",,," . ralign ('in') . ',,' . ralign ('out') . ',' . ralign ('year')  ;
    &print_columns ($line) ;

    foreach $period (@periods)
    {
      # skip first period, no relative changes
      # next if $period == $periods [0] ;

      $editors_total_this_period = $editors {'all'} {$period} ;

      $count_total          = &dash   ($editors               {$project} {$period}) ;
      $count_new            = &dash   ($editors_new           {$project} {$period}) ;
      $count_once           = &dash   ($editors_once          {$project} {$period}) ;

      $percent_total         = &percent ($editors_total_this_period,$count_total) ;
      $percent_new           = &percent ($editors_total_this_period,$count_new) ;
      $percent_once          = &percent ($editors_total_this_period,$count_once) ;

      if ($period > $periods [0])
      {
        $count_staying        = &dash   ($editors_staying       {$project} {$period}) ;
        $count_lost           = &dash   ($editors_lost          {$project} {$period}) ;
        $count_migrating_in   = &dash   ($editors_migrating_in  {$project} {$period}) ;
        $count_migrating_out  = &dash   ($editors_migrating_out {$project} {$period}) ;

        $percent_staying       = &percent ($editors_total_this_period,$count_staying) ;
        $percent_lost          = &percent ($editors_total_this_period,$count_lost) ;
        $percent_migrating_in  = &percent ($editors_total_this_period,$count_migrating_in) ;
        $percent_migrating_out = &percent ($editors_total_this_period,$count_migrating_out) ;

        # do not present lost editors on last year shown (which is last complete year)
        # some may return later in current year
        if ($period eq $periods [$#periods])
        {
          $dash = ralign ('-') ;
          $count_lost   = $dash ;
          $percent_lost = $dash ;
        }
      }
      else
      {
        $dash = ralign ('-') ;

        $count_staying        = $dash ;
        $count_lost           = $dash ;
        $count_migrating_in   = $dash ;
        $count_migrating_out  = $dash ;

        $dash = ralign ('-    ') ;

        $percent_staying       = $dash ;
        $percent_lost          = $dash ;
        $percent_migrating_in  = $dash ;
        $percent_migrating_out = $dash ;
      }

      &print_columns ("$period,$count_once,$count_new,$count_staying,$count_migrating_in,$count_total,$count_migrating_out,$count_lost,," .
                               "$percent_once,$percent_new,$percent_staying,$percent_migrating_in,$percent_total,$percent_migrating_out,$percent_lost") ;
    }
  }
}

sub ReadBots
{
  die "Bots file '$file_bots' not found" if ! -e $file_bots ;

  open CSV_BOTS, '<', $file_bots ;

  while ($line = <CSV_BOTS>)
  {
    chomp $line ;
    ($project,$wiki,$bots) = split (',', $line) ;

    $wikis {$wiki} ++ ;
    @bots = split ('\|', $bots) ;
    foreach $bot (@bots)
    { $bots {$project} {$wiki} {$bot} ++ ; }
  }

  @wikis = keys %wikis ; # for iterating over all wiki codes
}

sub ralign
{
  return (sprintf ("%6s", shift)) ;
}

# format as permils (1 per mil = 0.1 percent)
sub percent
{
  my ($total,$part) = @_ ;
  if ($total > 0)
  {
    $percent = 100 * ($part/$total) ;
    if ($percent < 0.1)
    { $percent = '-  ' ; }
    elsif ($percent < 1)
    { $percent = sprintf ("%.2f", $percent) . ' ' ; }
    else
    { $percent = sprintf ("%.1f", $percent) . '  ' ; }
  }
  else
  { $percent = ' -  ' ; }

  if ($percent =~ "100\.0")
  { $percent = '100  ' ; }
# $permil =~ s/^0\././ ;

  if ($percent =~ /\./)
  { return ralign ($percent) ; }
  else
  { return ralign ($percent . '  ') ; }
}

sub dash
{
  my $value = shift ;
  if ($value eq '')
  { $value = '-' ; }
  return ralign ($value) ;
}

sub print_comment
{
  my $comment = shift ;

  print "$comment\n" ;

  if ($comment =~ /,/)
  {
    chomp $comment ;
    $comment = "\"$comment\"" ;
  }

  print CSV_OUT_MATRIX "$comment\n" ;
}

sub print_columns
{
  my $data = shift ;

  print CSV_OUT_MATRIX "$data\n" ;
  $data =~ s/,/\t/g ;
  print                "$data\n" ;
}
