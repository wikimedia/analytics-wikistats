
#!/usr/bin/perl

# use SquidCountryScanConfig ;
# print "use EzLib from '$cfg_liblocation'\n" ;
# use lib $cfg_liblocation ;

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

  use Time::Local ;
  use Getopt::Std ;
  use Cwd;
  use File::Basename;
  use File::Path qw/make_path/;

  $timestart = time ;

  my %options ;
  getopt ("siol", \%options) ;

  $yyyymm_start = $options {"s"} ;
  die "Specify start month as '-s yyyy-dd'" if $yyyymm_start !~ /^\d\d\d\d-\d\d$/ ;

  $path_in  = $options {"i"} ;
  $path_out = $options {"o"} ;
  $path_log = $options {"l"} ;

  die ("Specify input folder as -i [..]") if not defined $path_in ;
  die ("Specify output folder as -o [..]") if not defined $path_out ;
  die ("Specify log folder as -l [..]")   if not defined $path_log ;

  die ("Input folder '$path_in' not found")   if ! -d $path_in ;
  die ("Output folder '$path_out' not found") if ! -d $path_out ;
  die ("Log folder '$path_log' not found")    if ! -d $path_log ;

  if (! defined ($options {"e"}) && ! defined ($options {"v"}))
  {
    &Log ("Specify '-e' for edits or '-v for views\n") ;
    exit ;
 }

# $path_in = $job_runs_on_production_server ? $cfg_path_csv : $cfg_path_csv_test ;
# $path_log = $job_runs_on_production_server ? $cfg_path_log : $cfg_path_log_test ;
  $file_log = "$path_log/SquidCountryAggregate.log" ;

  if (defined ($options {"v"})) 
  {
    &AggregateHourlyData ('visits', $yyyymm_start, $path_in, $path_out, $path_log) ;
  }
 
  if (defined ($options {"e"})) 
  {
    die "Edits not supported yet\n" ;  
  }

  print "\n\nReady\n\n" ;

  exit ;

sub AggregateHourlyData
{
  my ($mode, $yyyymm_start, $file_per_country, $file_per_country_old, $file_raw_data_monthly, $file_raw_data_daily, $file_raw_data_daily_wiki, $file_raw_data_daily_project, $file_raw_data_daily_detailed) = @_ ;

# my ($visits_total, $visits_total_non_bot, $visits_wp_total, $visits_total_wp_en, $visits_per_day, $visits_other, $yyyymmdd, $yyyymm) ;
# my (%visits_monthly, $visits_monthly_non_bot, %visits_daily, %visits_daily_wiki, %visits_daily_project, %visits_wp_yyyymm, %visits_per_project, %visits_per_language, %visits_per_country, %visits_per_day, %visits_wp_b, %visits_wp_u, %correct_for_missing_days) ;
# my (%visits_wp_en, %visits_per_project_language_country, %yyyymmdd_found) ;
# my ($project,$language,$country,$project_language_country,$project_language_country2,$bot,$wiki) ;
# my ($day,$month,$year,$days_in_month,$days_found) ;
# my ($dir,$file,$line) ;
# my ($total, $correction, $total_corrected, $total_corrected_share) ;

  print "Aggregate hourly data for $mode, starting $yyyymm_start\n\n" ;

  $yyyy = substr ($yyyymm_start,0,4) ;
  $mm   = substr ($yyyymm_start,5,2) ;

  $time_start = timegm (0,0,0,1, $mm-1, $yyyy-1900) ; 
  $time_stop  = time - 24 * 60 * 60 ;
  $time = $time_start ;

  while ($time < $time_stop)
  {
    ($ss,$nn,$hh,$dd,$mm,$yyyy) = gmtime ($time) ;
    $mm ++ ;
    $yyyy += 1900 ;
    $yyyymm   = sprintf ("%4d-%02d",$yyyy,$mm) ;
    $yyyymmdd = sprintf ("%4d-%02d-%02d",$yyyy,$mm,$dd) ;

    $path_yyyymm          = "$path_out/$yyyymm/" ;
    $path_yyyymmdd        = "$path_out/$yyyymm/$yyyymmdd/" ;
    $path_yyyymmddpublic  = "$path_out/$yyyymm/$yyyymmdd/public" ;
    $path_yyyymmddprivate = "$path_out/$yyyymm/$yyyymmdd/private" ;

    if (! -d $path_yyyymmdd)
    { 
      make_path ($path_yyyymm) ;   
      make_path ($path_yyyymmdd) ; 
      make_path ($path_yyyymmddpublic) ; 
      make_path ($path_yyyymmddprivate) ; 
      print "new folders created: $path_yyyymmdd\n" ;  
    }  

    # one time action, already done 
    # if (-e "$path_yyyymmddpublic/SquidDataCountriesViews.csv")
    # {
    #   print "\nrename\n$path_yyyymmddpublic/SquidDataCountriesViews.csv ->\n$path_yyyymmddpublic/SquidDataCountriesViews.old_def.csv\n"  ;
    #   rename "$path_yyyymmddpublic/SquidDataCountriesViews.csv", "$path_yyyymmddpublic/SquidDataCountriesViews.old_def.csv"  ;
    # }

    if (! -e "$path_yyyymmddpublic/SquidDataCountriesViews.csv") # qqq temp force always false
  # if (1) # for unconditional rerun
    {
       print "\nAggregate hourly files into $path_yyyymmddpublic/SquidDataCountriesViews.csv\n"  ;

       $files  = 0 ;
       $factor = 1 ;
       undef @finds ; 
       undef %counts ;
       undef %counts_granular ;

       for ($h = 0 ; $h <= 23; $h++)
       {
         my $file = "$path_in$yyyy/$yyyymm/" . sprintf ("projectviews-geo-%04d%02d%02d-%02d0000.gz",$yyyy,$mm,$dd,$h) ;
         if (-e $file)
         { push @finds, "$file found\n" ; $files++ ; }
         else         
         { push @finds, "$file not found\n" ; }
       }

       if ($files < 24)
       { 
         $factor = sprintf ("%03f",24 / $files) ;

         print @finds ;
         print "\nNot all files found at $path_in for $yyyymmdd, only $files files -> factor = $factor\n" ; 
         push @err, "Not all files found at $path_in for $yyyymmdd, only $files files -> factor = $factor\n" ; 
       }
       
       if ($files == 0)
       { 
         print @finds ;
         print "\nNo files found at $path_in for $yyyymmdd\n" ; 
         push @err, "No files found at $path_in for $yyyymmdd\n" ; 
         return ; 
       }
       else
       {
         if ($factor == 1)
         { print "Process files found at $path_in for $yyyymmdd, all 24 hourly files found\n\n" ; }
         else
         { print "Process files found at $path_in for $yyyymmdd, rescale factor = $factor\n\n" ; }
       }

       # collect, extrapolate (if needed) and store ocunts
       for ($h = 0 ; $h <= 23; $h++)
       {
         my $file = "$path_in$yyyy/$yyyymm/" . sprintf ("projectviews-geo-%04d%02d%02d-%02d0000.gz",$yyyy,$mm,$dd,$h) ;
         next if !-e $file ;
         print "Process $file\n" ;
	 open IN, "-|", "gzip -dc \"$file\"" || die ("Input file $file could not be opened for processing.") ;
         # open IN, '<', $file || die "file $file could not be opened for processing" ;
         while ($line = <IN>)
         {
           chomp $line ;
           ($continent,$country,$country_code,$wiki,$platform,$usage_type,$count) = split ("\t", $line) ; 

           if ($factor != 1)
           { $count = sprintf ("%.3f", $count * $factor) ; }

           # convert coding system, from hive based stats to old wikistats  
           if ($usage_type eq 'spider') 
           { $bot = "bot=Y" ; } 
           else
           { $bot = "bot=N" ; } 
           
           $counts_granular {"$continent,$country,$country_code,$wiki,$platform,$usage_type"} += $count ; 

           # convert to legacy encoding of wiki plus desktop/mobile
           $wiki_abbr = &Abbreviate ($wiki,$platform) ;
           $counts {"$bot,$wiki_abbr,$country_code"} += $count ; 
         } 
         close IN ;
       }

       # write counts to daily page views file (after rounding to integers)
       $file  = "$path_yyyymmddpublic/SquidDataCountriesViews.csv" ;
       print "\nWrite $file\n" ;
       open OUT, '>', $file || die ("Output file $file can not be written") ;
       foreach $key (sort keys %counts)
       {
         # debug
         # print "$key\n" ; # qqq 
         # if ($key =~ /wmf/) # qqq
         # { print "$key\n" ;} 
         print OUT "$key," . sprintf ("%.0f", $counts {$key}) . "\n" ; 
       }  
       close OUT ; 

       $file = "$path_yyyymmddpublic/SquidDataCountriesViewsGranular.csv" ;
       print "\nWrite $file\n" ;
       open OUT, '>', $file || die ("Output file $file can not be written") ;
       foreach $key (sort keys %counts_granular)
       { print OUT "$key," . sprintf ("%.0f", $counts_granular {$key}) . "\n" ; }   
       close OUT ; 

       print "\nCheck if all clauses (1-17) in Abbreviate are touched at least once (no projects missing?)\n\n" ; 
       for ($clause = 1; $clause <= 17 ; $clause++)
       { print "$clause: " . $type {$clause} . "\n" ; } 
    }

    # /mnt/hdfs/wmf/data/archive/projectview/geo/hourly/2015/2015-05/projectviews-geo-20150531-230000.gz

    #  if (-e $path_yyyymmdd)
    #  { print "found $path_yyyymm\n" ; }
    #  else
    #  { print "not found $path_yyyymm\n" ; }

    $time += 24 * 60 * 60 ;
  }
}

# encode $wiki so that it is compatible with legacy code scheme, see Abbreviate in SquidCountArchiveProcessLogRecord.pm 
# expect much more formalized input $wiki code, no random input where anything goes, but 'en.wikipedia' or 'de.wikiquote'
# old scheme certainly had its flaws, but for now strive to max compatability 
sub Abbreviate
{
  my ($wiki,$platform) = @_ ;
  ($lang,$project) = split ('\.', $wiki) ;
# print "$wiki -> '$lang' '$project'\n" ; # debug

     if ($project eq 'wikipedia')   { $wiki = "wp:$lang" ;           $type {1}++ ; } 
  elsif ($project eq 'wikibooks')   { $wiki = "wb:$lang" ;           $type {2}++ ; }
  elsif ($project eq 'wiktionary')  { $wiki = "wk:$lang" ;           $type {3}++ ; }
  elsif ($project eq 'wikinews')    { $wiki = "wn:$lang" ;           $type {4}++ ; }
  elsif ($project eq 'wikiquote')   { $wiki = "wq:$lang" ;           $type {5}++ ; }
  elsif ($project eq 'wikisource')  { $wiki = "ws:$lang" ;           $type {6}++ ; }
  elsif ($project eq 'wikiversity') { $wiki = "wv:$lang" ;           $type {7}++ ; }
  elsif ($project eq 'wikivoyage')  { $wiki = "wo:$lang" ;           $type {8}++ ; }
  
  elsif ($wiki eq 'wikimediafoundation') { $wiki = 'wmf.www' ;       $type {9}++ ; }  
  elsif ($wiki eq 'commons.wikimedia')   { $wiki = 'wx.commons' ;    $type {10}++ ; }  
  elsif ($wiki eq 'meta.wikimedia')      { $wiki = 'wx.meta' ;       $type {11}++ ; }  
  elsif ($wiki eq 'species.wikimedia')   { $wiki = 'wx.species' ;    $type {12}++ ; }  
  elsif ($wiki eq 'wikidata')            { $wiki = "wx:wikidata" ;   $type {13}++ ;} # test.wikidata not covered in old scheme
  
  elsif ($project eq 'wikimedia')   { $wiki = "wm:$lang" ;           $type {14}++ ; }
  elsif ($project eq 'wikidata')    { $wiki = "wx:wikidata-$lang" ;  $type {15}++ ;} # wikidata not covered in old scheme

  elsif ($lang    eq 'mediawiki')   { $wiki = "wx:mw" ;              $type {16}++ ;}
  elsif ($lang    eq 'wikisource')  { $wiki = "ws:www" ;             $type {17}++ ; }

  else { print "Unexpected wiki code $wiki -> lang '$lang', project '$project'\n" ; $wiki = 'other' ; }

  if ($wiki ne 'other')
  {
    if ($platform ne 'desktop')
    { $wiki = "\%$wiki" ; } 
  }

  return $wiki ;
}

sub Log
{
  my $msg = shift ;
  print $msg ;
}

