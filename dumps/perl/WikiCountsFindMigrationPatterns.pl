#!/usr/bin/perl

  #to do check $ns against 'content' namespaces for that wiki

  use Time::Local ;
  use Getopt::Std ;

  # ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time) [6] ;
  $yyyy = (localtime(time)) [5] + 1900 ;
  for ($n = 2001 ; $n <= $yyyy ; $n++)
  { push @periods, $n ; }

  $| = 1; # Flush output
  our $verbose = 0 ;
  our $time_start = time ;
  our $true = 1 ;
  our $false = 0 ;

  our $absolute = 1 ;
  our $relative = 0 ;

  our $sort_by_frequency = 1 ;
  our $sort_alphabetical = 0 ;

  our $threshold_perc_dominant_project = 66 ; # only when edit exceeds this threshold on some project, that project will be considered main project for that user for that period
  our $threshold_active_enough = 25 ;

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
  
  my %options ;
  getopt ("c", \%options) ;
  $path_csv  = $options {'c'} ;

  $file_in              = "$path_csv/EditsPerUserMonthNamespaceAllWikisSortedByUser.csv" ;
  $file_out_yyyymm      = "$path_csv/EditsPerUserAllWikisSortedByUserAggregatedMonthly.csv" ;
  $file_out_yyyy        = "$path_csv/EditsPerUserAllWikisSortedByUserAggregatedYearly.csv" ;
  $file_out_yyyy_migr   = "$path_csv/EditsPerUserAllWikisSortedByUserAggregatedYearlyMigrations.csv" ;
  $file_out_yyyy_matrix = "$path_csv/EditsPerUserAllWikisSortedByUserAggregatedYearlyMigrationsMatrix.csv" ;

  die "Specify path to csv files as: -c [path]" if ! -d $path_csv ;
  print "Path to csv files: $path_csv\n" ;
  
 &Aggregate ;
  &FindMigrations ;

  print "\nReady\n" ;
  exit ;

sub Aggregate
{
  my $user_prev = '' ;
  my $yyyymm_prev = '' ;
  my $yyyy_prev = '' ;
      
  # read merged editor activity for all wikis
  # user, yyyy-mm, project, language, namespace, edits
  open  CSV_IN, '<', $file_in || die "Could not open $file_in" ;
  binmode CSV_IN ;

  # output one line per user per month, with total edits per project
  open  CSV_OUT_YYYYMM, '>', $file_out_yyyymm || die "Could not open $file_out_yyyymm" ;
  binmode CSV_OUT_YYYYMM ;
  print CSV_OUT_YYYYMM "user,period,edits wb,edits wk,edits wn,edits wo,edits wp,edits,wq,edits ws,edits wv,edits wx\n" ;
  
  # output one line per user per year with total edits per project
  open  CSV_OUT_YYYY, '>', $file_out_yyyy || die "Could not open $file_out_yyyy" ;
  binmode CSV_OUT_YYYY ;
  print CSV_OUT_YYYY "user,period,edits wb,edits wk,edits wn,edits wo,edits wp,edits,wq,edits ws,edits wv,edits wx\n" ;
  
  while ($line = <CSV_IN>) 
  {
    chomp $line ;	  
    ($user,$yyyymm,$proj,$lang,$ns,$edits) = split (',', $line) ;	  
    if ($lang eq 'commons')
    { $proj = 'co' ; }
    if ($lang eq 'wikidata')
    { $proj = 'wd' ; }

    next if $ns != 0 and $ns != 6 ; # to do check $ns against 'content' namespaces for that wiki
   
    $yyyy = substr ($yyyymm,0,4) ;

    if ($user_prev ne '') # not on first line
    {
      if (($user ne $user_prev) || # if all edits for this user for this month are collected, send to output
          ($yyyymm ne $yyyymm_prev))
      {
        print CSV_OUT_YYYYMM "$user_prev,$yyyymm_prev," . 
                    	     (0 + $yyyymm {'tot'}) . ',' .     
                    	     (0 + $yyyymm {'wb'}) . ',' .  
                    	     (0 + $yyyymm {'wk'}) . ','	.     
                    	     (0 + $yyyymm {'wn'}) . ','	.     
                    	     (0 + $yyyymm {'wo'}) . ','	.     
                    	     (0 + $yyyymm {'wp'}) . ','	.     
                    	     (0 + $yyyymm {'wq'}) . ','	.     
                    	     (0 + $yyyymm {'ws'}) . ','	.     
                    	     (0 + $yyyymm {'wv'}) . ','	.     
                    	     (0 + $yyyymm {'wx'}) . ','	.     
                    	     (0 + $yyyymm {'co'}) . ','	.     
                    	     (0 + $yyyymm {'wd'}) . "\n" ;
	foreach $key (keys %yyyymm) { $yyyymm {$key} = 0 ; } 		     
      }

      if (($user ne $user_prev) || # if all edits for this user for this year are collected, send to output
          ($yyyy ne $yyyy_prev))
      {
        print CSV_OUT_YYYY   "$user_prev,$yyyy_prev," . 
                    	     (0 + $yyyy   {'tot'}) . ',' .     
                    	     (0 + $yyyy   {'wb'}) . ',' .     
                    	     (0 + $yyyy   {'wk'}) . ','	.     
                    	     (0 + $yyyy   {'wn'}) . ','	.     
                    	     (0 + $yyyy   {'wo'}) . ','	.     
                    	     (0 + $yyyy   {'wp'}) . ','	.     
                    	     (0 + $yyyy   {'wq'}) . ','	.     
                    	     (0 + $yyyy   {'ws'}) . ','	.     
                    	     (0 + $yyyy   {'wv'}) . ','	.     
                    	     (0 + $yyyy   {'wx'}) . ','	.     
                    	     (0 + $yyyy   {'co'}) . ','	.     
                    	     (0 + $yyyy   {'wd'}) . "\n" ;   
	foreach $key (keys %yyyy) { $yyyy {$key} = 0 ; } 		     
      }
    }

    $user_prev   = $user ;
    $yyyymm_prev = $yyyymm ;  
    $yyyy_prev   = $yyyy ;  

    # aggregate per month/year, per project and all projects 
    $yyyymm {'tot'} += $edits ;
    $yyyy   {'tot'} += $edits ;
    $yyyymm {$proj} += $edits ;
    $yyyy   {$proj} += $edits ;
  
    # debug:  
    # print "$user $yyyymm $yyyy $edits $lang\n" ;
  }

  # send totals to output for last user
  print CSV_OUT_YYYYMM "$user_prev,$yyyymm_prev," . 
                       (0 + $yyyymm {'tot'}) . ',' .     
               	       (0 + $yyyymm {'wb'}) . ',' .     
                       (0 + $yyyymm {'wk'}) . ',' .     
                       (0 + $yyyymm {'wn'}) . ',' .     
                       (0 + $yyyymm {'wo'}) . ',' .     
                       (0 + $yyyymm {'wp'}) . ',' .     
                       (0 + $yyyymm {'wq'}) . ',' .     
                       (0 + $yyyymm {'ws'}) . ',' .     
                       (0 + $yyyymm {'wv'}) . ',' .     
                       (0 + $yyyymm {'wx'}) . ',' .     
                       (0 + $yyyymm {'co'}) . ',' .     
                       (0 + $yyyymm {'wd'}) . "\n" ;   
  print CSV_OUT_YYYYMM "$user_prev,$yyyy_prev," . 
                       (0 + $yyyy   {'tot'}) . ',' .     
               	       (0 + $yyyy   {'wb'}) . ',' .     
                       (0 + $yyyy   {'wk'}) . ',' .     
                       (0 + $yyyy   {'wn'}) . ',' .     
                       (0 + $yyyy   {'wo'}) . ',' .     
                       (0 + $yyyy   {'wp'}) . ',' .     
                       (0 + $yyyy   {'wq'}) . ',' .     
                       (0 + $yyyy   {'ws'}) . ',' .     
                       (0 + $yyyy   {'wv'}) . ',' .     
                       (0 + $yyyy   {'wx'}) . ',' .     
                       (0 + $yyyy   {'co'}) . ',' .     
                       (0 + $yyyy   {'wd'}) . "\n" ;   

  close CSV_IN ;
  close CSV_OUT_YYYYMM ;
  close CSV_OUT_YYYY ;
}

sub FindMigrations
{
  open  CSV_IN_YYYY, '<', $file_out_yyyy || die "Could not open $file_out_yyyy" ;
  binmode CSV_IN_YYYY ;
  
  open  CSV_OUT_YYYY, '>', $file_out_yyyy_migr || die "Could not open $file_out_yyyy_migr" ;
  binmode CSV_OUT_YYYY ;
  
  open  CSV_OUT_MATRIX, '>', $file_out_yyyy_matrix || die "Could not open $file_out_yyyy_matrix" ;
  binmode CSV_OUT_MATRIX ;

  while ($line = <CSV_IN_YYYY>)
  {
    chomp $line ;	  
    
    my ($user,$period,$total,$wb,$wk,$wn,$wo,$wp,$wq,$ws,$wv,$wx,$co,$wd) = split (',', $line) ;	 


    if ($total < $threshold_active_enough)
    {
      $active_below_treshold {$period} ++ ;
      next ;	    
    }	    
  
    # calc distribution of edits per project for this user 
    $perc {'wb'} = sprintf ('%.0f', 100 * $wb / $total) ;
    $perc {'wk'} = sprintf ('%.0f', 100 * $wk / $total) ;
    $perc {'wn'} = sprintf ('%.0f', 100 * $wn / $total) ;
    $perc {'wo'} = sprintf ('%.0f', 100 * $wo / $total) ;
    $perc {'wp'} = sprintf ('%.0f', 100 * $wp / $total) ;
    $perc {'wq'} = sprintf ('%.0f', 100 * $wq / $total) ;
    $perc {'ws'} = sprintf ('%.0f', 100 * $ws / $total) ;
    $perc {'wv'} = sprintf ('%.0f', 100 * $wv / $total) ;
    $perc {'wx'} = sprintf ('%.0f', 100 * $wx / $total) ;
    $perc {'co'} = sprintf ('%.0f', 100 * $co / $total) ;
    $perc {'wd'} = sprintf ('%.0f', 100 * $wd / $total) ;

    # scan all projects for this user and period until main project found
    # on main project (when found) count user as 'stayed on same project' or 'migrated'
    $main_project_found = $false ;
    foreach $proj (qw (wb wk wn wo wp wq ws wv wx co wd))
    {
      # reset for new user
      if ($user ne $user_prev)
      {
	$proj_prev   = '' ;
	$perc_prev   = 0 ;
	$total_prev  = 0 ;
	$period_prev = 0 ;
        $main_project_found_prev = $main_project_found ;
      }

      # if there is one project which received most edits
      # compare with previous project which received most edits
      # if different project count as 'migration'
      if ($perc {$proj} >= $threshold_perc_dominant_project) 	
      { 
	$active_above_treshold {'all'} {$period} ++ ;
	$active_above_treshold {$proj} {$period} ++ ;

	$perc = $perc {$proj} ;
	# print "$user,$period,$proj ($perc\%}}\%\n" ;      
        
	# next period for same user ?
	if (($user eq $user_prev) && ($proj_prev ne '')) 
        {	
          # user migrated to other main project ?  
	  if ($proj ne $proj_prev)    
          {
	    $active_above_treshold_incoming {$proj} {$period} ++ ;
	    $active_above_treshold_leaving  {$proj} {$period} ++ ;
	    
            # log migration
	    print "$user,$period,$proj_prev ($perc_prev\% of $total_prev) -> $proj ($perc\% of $total)})\n" ;   
	    
	    $path = "$proj_prev->$proj" ;  	
	    $migrations {"$period,$path"} ++ ;
	    $migrations_total {$path} ++ ; # used as column sort in reporting
          } 
	  else
	  { $active_above_treshold_continuing {$proj} {$period} ++ ; }
        }

	# mark this project as dominant for next iteration(s)
	$proj_prev   = $proj ;
	$perc_prev   = $perc ;
	$total_prev  = $total ;
	$period_prev = $period ;
	
	# main project has been found -> stop scan
        $main_project_found = $true ;
	last ;
      }

      $user_prev = $user ;
    }

    # if not main project found this period, but it was found on previous period, count user as 'drop-out'
    if (! $main_project_found)
    {
      if ($main_project_found_prev)
      {
        $gone_or_dropped_below_treshold {$proj} {$period} ++ ;
      } 	      
    }
    $main_project_found_prev = $main_project_found ;
  }  

  print CSV_OUT_MATRIX "Only editors with at least $threshold_active_enough namespace 0 edits in a year are examined here for migration behavior\n" ;
  print CSV_OUT_MATRIX "An editor is considered to have a 'main project of interest' when at least threshold_perc_dominant_project\% of ns 0 edits are on that project\n" ;
  print CSV_OUT_MATRIX "An editor is considered to have 'migrated' when this main project differs in consecutive qualifying (enough edits) periods\n" ;
  print CSV_OUT_MATRIX "An editor can migrate from one project to another and migrate back later on\n" ;

  &WriteMigrationsPerPath ($absolute, $sort_alphabetical) ;
  &WriteMigrationsPerPath ($absolute, $sort_by_frequency) ;

  &WriteMigrationsPerProject ($absolute) ; 
  &WriteMigrationsPerProject ($relative) ; 
}

 
sub WriteMigrationsPerPath
{
  my ($absolute, $sort_order)  = @_ ;

  $absolute = $true ; # not sure yet about how to calc best relative migrations -> relative not yet implemented

  if ($absolute)
  { print CSV_OUT_MATRIX "Absolute migrations\n\n" ; }
  else
  { print CSV_OUT_MATRIX "Relative migrations (percentage of editors above threshold $threshold_perc_dominant_project in that period (migrating + non migrating)\n\n" ; }

  if ($sort_order == $sort_alphabetical)
  { 
    print CSV_OUT_MATRIX "Migration paths ordered alphabetically\n" ; 
    @sequence_paths = sort {$migrations_total {$b} <=>  $migrations_total {$a}} keys %migrations_total ; 
  }
  else
  { 
    print CSV_OUT_MATRIX "Migration paths ordered by frequency of occurrence\n" ; 
    @sequence_paths = sort {$a cmp $b} keys %migrations_total ; 
  }

  # print headers   
  $line = "," ;
  foreach $path (@sequence_paths)
  { $line .= "$path," ; }
  print CSV_OUT_MATRIX "$line\n" ;
  $line =~ s/,/\t/g ;
  print "$line\n" ;

  # print per period for each significant migration pair (from->to) number of migrations
  foreach $period (sort keys %periods) 
  { 
    $line = "$period," ;
    foreach $path (@sequence_paths)
    { $line .= $migrations {"$period,$path"} . "," ; }
    print CSV_OUT_MATRIX "$line\n" ;
    $line =~ s/,/\t/g ;
    print "$line\n" ;
  }
  print CSV_OUT_MATRIX "\n" ;
}  

sub WriteMigrationsPerProject
{
  my ($absolute) = @_ ;

  print "\n\n" ;
  print CSV_OUT_MATRIX "\n\n," ;

  print CSV_OUT_MATRIX "wb:wikibooks, wk:wiktionary, wn:wikinews, wo:wikivoyage, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, co:commons, wd:wikidata, wx:other projects\n" ;

  print CSV_OUT_MATRIX "Editors who did most editing on one project (> threshold_perc_dominant_project\%), per project\n" ; 
  if ($absolute)
  { print CSV_OUT_MATRIX "Percentages show how many editors came from other projects, as share of total editors on this project\n\n" ; }
  else
  { print CSV_OUT_MATRIX "Percentages show how many editors came from other projects, as share of total editors overall\n\n" ; }

  @sequence_projects = qw (wb wk wn wo wp wq ws wv co wd wx) ;

  print "1 per mil = 0.1 percent = 0.1% = 1%%\n\n" ;

 # print headers  
  $line = "proj->," ;  
  foreach $proj (@sequence_projects)
# { $line .= &ralign ($proj) . ',' . &ralign ($proj) . ',' ; }
  { $line .= $names {$proj} . " ($proj),,," ; }
  print CSV_OUT_MATRIX "$line\n" ;
  $line =~ s/,/\t/g ;
  print "$line\n" ;

  $line = "period," ;  
  foreach $proj (@sequence_projects)
  { $line .= &ralign ('abs') . ',' . &ralign ('rel %%') . ',' . &ralign ('rel2 %%') . ',,' ; }
  print CSV_OUT_MATRIX "$line\n" ;
  $line =~ s/,/\t/g ;
  print "$line\n" ;

  # print data per period per project
  foreach $period (sort keys %periods) 
  { 
    $line = "$period," ;
    foreach $proj (@sequence_projects)
    { 
      $active_incoming = $active_above_treshold_incoming {$proj} {$period} ;
      $active_project  = $active_above_treshold {$proj} {$period} ; 
      if ($absolute) # calc perc as relative to total editors on this project
      { $active_total = $active_above_treshold {'all'} {$period} ; }
      else
      { $active_total = $active_project ; }

      $perc = '-' ;

      if ($active_total > 0)
      { 
	# $perc1 = ralign (sprintf ("%.0f", 1000 * $active_project  / $active_total) . '%%') ;
	# $perc2 = ralign (sprintf ("%.0f", 1000 * $active_incoming / $active_total) . '%%') ;
        $perc1 = ralign (sprintf ("%.0f", 1000 * $active_project  / $active_total)) ;
        $perc2 = ralign (sprintf ("%.0f", 1000 * $active_incoming / $active_total)) ;
      }
      # if (! $absolute)
      # { $perc = &ralign (sprintf ("%.0f", $perc1) . '%%') ; }

      if ($active_project eq '')
      { $active_project = '-' ; }
      $line .= &ralign ($active_project) . ",$perc1,$perc2,," ; 
    }
    print CSV_OUT_MATRIX "$line\n" ;
    $line =~ s/,/\t/g ;
    print "$line\n" ;
  }
} 

sub ralign
{
  return (sprintf ("%6s", shift)) ;	
}
