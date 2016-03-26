#!/usr/bin/perl

  use Time::Local ;
  use Cwd;

  $| = 1; # Flush output


  # Q&D hard coded paths
  $file_input     = "/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthly.csv" ;
  $file_output    = "/a/wikistats_git/squids/csv/SquidDataVisitsPerRegionMonthly.csv" ;

  $region_names {'AF'} = 'Europe' ; 
  $region_names {'AS'} = 'Asia' ; 
  $region_names {'CA'} = 'Central-America' ; 
  $region_names {'EU'} = 'Europe' ; 
  $region_names {'NA'} = 'North-America' ; 
  $region_names {'OC'} = 'Oceania' ; 
  $region_names {'SA'} = 'South-America' ; 

# &ReadCountryCodes ;
  &ReadRegionCodes ;

  open IN,  '<', $file_input  || die "Could not open '$file_input'\n" ;

  while ($line = <IN>)
  {
if ($line =~ /wmf/) 
{ print "1 $line\n" ; }
    next if $line =~ /^#/ ; # comments   

    ($yyyymm,$project_site_lang,$country_code,$user_type,$count) = split (',', $line) ;

# print "'$country_code','$user_type','$count'\n" ;
    next if $user_type ne 'U' ;

    ($project_site,$lang) = split ('\.', $project_site_lang) ;

    if ($project_site =~ /[^a-z]/) 
    { $site = 'mobile' ; } # e.g. %wp @wp 
    else
    { $site = 'desktop' ; } 

    ($project = $project_site) =~ s/[^a-z]//g ;

if ($line =~ /wmf/) 
{ print "2 $line|$project_site|$lang|$site|$project\n" ; }
    
    
    $country_name = $country_names {$country_code} ;
    $region_code  = $region_codes  {$country_code} ;
    $north_south  = $north_south   {$country_code} ;
    $region_name  = $region_names  {$region_code} ;

    $country_data = "$country_code:$country_name" ;
    $region_data  = "$region_code:$region_name" ;

       if ($project eq 'wb') { $project = 'wikibooks' ; }
    elsif ($project eq 'wk') { $project = 'wiktionary' ; }
    elsif ($project eq 'wn') { $project = 'wikinews' ; }
    elsif ($project eq 'wp') { $project = 'wikipedia' ; }
    elsif ($project eq 'wq') { $project = 'wikiquote' ; }
    elsif ($project eq 'wo') { $project = 'wikivoyage' ; }
    elsif ($project eq 'ws') { $project = 'wikisource' ; }
    elsif ($project eq 'wv') { $project = 'wikiversity' ; }
    elsif ($project eq 'wx') { $project = 'other-projects' ; } 
    else  { $codes_undefined {$project}++ ; }

    # print "$project_site -> $project,$site\n" ; 
    $counts {"$yyyymm,country,$country_data,$project,$site"}        += $count ;
    $counts {"$yyyymm,country,$country_date,$project,sites_combined"}    += $count ;
    $counts {"$yyyymm,region,$region_data,$project,$site"}          += $count ;
    $counts {"$yyyymm,region,$region_date,$project,sites_combined"}      += $count ;
    $counts {"$yyyymm,north_south,$north_south,$project,$site"}     += $count ;
    $counts {"$yyyymm,north_south,$north_south,$project,sites_combined"} += $count ;
  }

  close IN ;

  print "Undefined project codes:\n\n" ;

  foreach $key (keys %codes_undefined)
  {
    print "$key:" . $codes_undefined {$key} . "\n" ;
  }

  open OUT, '>', $file_output || die "Could not open '$file_output'\n" ;
  print OUT "yyyymm,aggregation,geo,project,level,site,count" . $counts {$key} . "\n" ;
  foreach $key (sort keys %counts)
  { print OUT "$key," . $counts {$key} . "\n" ; }
  close OUT ;

  print "Ready\n\n" ;
  exit ;

sub ReadCountryCodes
{
  $file_countries = "/a/wikistats_git/squids/csv/meta/CountryCodes.csv" ;
  open COUNTRIES, '<', $file_countries || die "Could not open '$file_countries'" ;

  while ($line = <COUNTRIES>)
  {
    next if $line =~ /^#/ ;
    next if $line !~ /,/ ;
  
    chomp $line ;
    $line =~ s/"//g ;
    ($code,$name) = split (',', $line) ;
    $country_names {$code} = "'$name'" ;
  } 
  close COUNTRIES ;
}

sub ReadRegionCodes
{
  $file_regions = "/a/wikistats_git/squids/csv/meta/RegionCodes.csv" ;
  open REGIONS, '<', $file_regions || die "Could not open '$file_regions'" ;

  while ($line = <REGIONS>)
  {
    next if $line =~ /^#/ ;
    next if $line !~ /,/ ;
  
    chomp $line ;
    $line =~ s/"//g ;
    ($country_code,$region_code,$north_south,$country_name) = split (',', $line) ;
    $country_names {$country_code} = "'$country_name'" ;
    $region_codes  {$country_code} = $region_code ;
    $north_south   {$country_code} = $north_south ;
  } 
}

