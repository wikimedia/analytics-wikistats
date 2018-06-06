#!/usr/bin/perl

use Text::CSV_XS;
# to do

# data for Egypt and Venezuela exist , see this script line 500

# years starts with 1999 (?)
# Nu/NIU no data (?)
# 'inc.perc.' vs +perc +pp zie e.g. "NLD"
# decode JSON? use https://stackoverflow.com/questions/34377827/iterating-through-a-hash-in-perl

# 020 World Bank IT.NET.USER.ZS id: iso2 not (yet) known for iso3  Arab Rep. => skip
# 020 World Bank IT.NET.USER.ZS id: iso2 not (yet) known for iso3 ARB => skip

# iso2 = short hand for 'ISO 3166-1 alpha-2' (2 letter country code) see also https://en.wikipedia.org/wiki/ISO_3166
# iso3 = short hand for 'ISO 3166-1 alpha-3' (3 letter country code) see also https://en.wikipedia.org/wiki/ISO_3166

  $| = 1 ; # flush output
  
  use warnings ;
  use strict ;
  use JSON;

  my %json_out ;
  my $json_out ;

  $json_out = new JSON ;

  our $true  = 1 ;
  our $false = 0 ;
  our $verbose  = $false ;
  our $dev_mode = $false ;

  our $worldbank_names_override = $false ; 
  our $do_not_import_years_before = 2000 ;
  our $only_allow_new_codes = '*' ;
  our $add_derived_values = $true ; 
  our $maxmind_extra_codes = "A1,A2,AP,EU,O1" ;
  our $codes_maxmind    = "codes with (non-)region 'MM' are non-country codes (A1,A2,AP,EU,O1) from MaxMind, see http://www.maxmind.com/app/iso3166" ;
  our $codes_world_bank = "codes with (non-)region 'WB' are non-country codes from World Bank" ;
  our $languages_countries_names = "de,en,es,fr,it,ja,nl,pl,pt,ru,sv,zh" ;

  our %json_about ;
  my %json_all ;
  
  my %json_flags ;
  my %json_countries ;
  my %json_regions ;
  my %json_languages ;
  my %iso2_by_name ; 
  my %iso2_by_iso3 ; 
  my %iso2_codes ;
  my %region_codes ;
  my %messages ;

# my $folder = 'd:\\@Wikimedia\datamaps\datafiles\meta' ; # test folder in Windows
  my $folder = '/home/ezachte/wikistats/worldbank' ;      # folder on Wikimedia server

# this script processes local copies of the files, download can be done in bash file

  my $file_json_population              = "$folder/SP.POP.TOTL.json" ;
  my $file_json_internet_users          = "$folder/IT.NET.USER.json" ;

  my $file_csv_internet_users           = "$folder/API_IT.NET.USER.ZS_DS2_en_csv_v2.csv" ;
  my $file_csv_mobile_subscriptions     = "$folder/API_IT.CEL.SETS.P2_DS2_en_csv_v2.csv" ;
  my $file_csv_gdp_per_capita           = "$folder/API_NY.GDP.PCAP.KD_DS2_en_csv_v2_9908764.csv" ;
  
  my $file_csv_out                      = "$folder/geo_codes_countries.csv" ;
  my $file_csv_out_internet_users       = "$folder/internet_users.csv" ;
  my $file_csv_out_mobile_subscriptions = "$folder/mobile_subscriptions.csv" ;
  my $file_csv_out_internet_plus_mobile = "$folder/internet_plus_mobile_subscriptions.csv" ;
  my $file_csv_out_gdp_plus_mobile      = "$folder/gdp_plus_mobile_subscriptions.csv" ;
  
  my $file_json_out                     = "$folder/demographics.json" ;
  my $file_country_stats                = "$folder/datamaps-country-stats.csv" ; # not for WiViVi viz. (yet), so not actually for datamaps, calling it this to keep files names uniform
  my $file_flags                        = "$folder/datamaps-flags.csv" ;
  
  my $file_csv_geo_codes                = "$folder/geo_codes_countries.csv" ;

  my $inc_perc        = "growth (+%)" ;    # growth in percentage
  my $inc_perc_points = "increase (+pp)" ; # increase in percentage points
  my $key_last_updated                         = 'last updated' ;
  my $key_iso3                                 = 'iso_3166_1_alpha_3' ;
  my $key_options                              = 'options' ;
  my $key_year                                 = 'year' ;
  my $key_about                                = 'about' ;
  my $key_sources                              = 'sources' ;
  my $key_world_bank                           = 'world bank' ;
  my $key_countries                            = 'countries' ;
  my $key_latest                               = 'latest' ;
  my $key_years                                = 'years' ;
  my $key_codes                                = 'codes' ;
  my $key_names                                = 'names' ;
  my $key_region                               = 'region' ;
  my $key_abbreviations                        = 'abbreviations' ;
  my $key_north_south                          = 'north_south' ;
  my $key_population                           = 'population' ;
  my $key_data                                 = 'data' ; 
  my $key_license                              = 'license' ; 
  my $key_code                                 = 'code' ; 
  my $key_notes                                = 'notes' ; 
  my $key_population_inc_perc                  = "$key_population $inc_perc" ;
  my $key_internet_users                       = 'internet users per 100' ;
  my $key_internet_users_inc_perc_points       = "$key_internet_users $inc_perc_points" ;
  my $key_mobile_subscriptions                 = 'mobile subscriptions per 100' ;
  my $key_mobile_subscriptions_inc_perc_points = "$key_mobile_subscriptions $inc_perc_points" ;
  my $key_gdp_per_capita                       = 'GDP per capita' ;
  my $key_gdp_per_capita_inc_perc              = "$key_gdp_per_capita $inc_perc" ;
  my $key_population_counts                    = 'population counts' ;
  my $key_internet_users_per_100               = 'internet users per 100' ;
  my $key_mobile_subscriptions_per_100         = 'mobile subscriptions per 100' ;
  my $key_gdp_per_capita_constant_us_dollars   = 'GDP per capita (constant 2010 USD)' ;
  
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
  my $year_now = $year + 1900 ;
  
  $json_out {$key_about} {'file_generated'} = sprintf ("%4d-%02d-%02d %02d:%02d",$year+1900,$mon+1,$mday,$hour,$min) ;

  $json_out {$key_about} {'layout'} = {'version'  => '0.1',
                                       'comments' => '0.1 = initial release'} ;

  $json_out {$key_about} {'created by'} = {'author'                  => 'Erik Zachte, Data Analyst',
                                           'organization_name'       => 'Wikimedia Foundation',
                                           'organization_url'        => 'https://wikimediafoundation.org/',
                                           'organization_department' => 'Research'} ;

  $json_out {$key_about} {$key_abbreviations} {$inc_perc}        = "increase as percentage (3->3.3 is +10% , but +0.3 %%)" ;
  $json_out {$key_about} {$key_abbreviations} {$inc_perc_points} = "increase as percentage points (3->3.3 is +10% , but +0.3 %%)" ;

  $json_out {$key_about} {$key_codes} {'0'} = "This json file is about World Bank demographics in a Wikimedia context" ;
  $json_out {$key_about} {$key_codes} {'1'} = "Codes stored for countries are ISO 3166-1 alpha-2, ISO 3166-1 alpha-3, region code, north_south code, see also https://en.wikipedia.org/wiki/ISO_3166" ;
  $json_out {$key_about} {$key_codes} {'2'} = "Primary key for countries is ISO 3166-1 alpha-2, for custom codes (starting with 'X') see 'geo_codes_countries.csv'" ;
  $json_out {$key_about} {$key_codes} {'4'} = "Note that some World Bank files use ISO 3166-1 alpha-2 (as does MaxMind), others use ISO 3166-1 alpha-3" ;
  $json_out {$key_about} {$key_codes} {'5'} = "ISO 3166-1 alpha-2 codes without ISO 3166 alpha-3 code are non-country codes from MaxMind" ;
  $json_out {$key_about} {$key_codes} {'6'} = "For MaxMind see http://www.maxmind.com/app/iso3166; non country codes as used by MaxMind: $maxmind_extra_codes" ;
  $json_out {$key_about} {$key_codes} {'7'} = "For World Bank see \{$key_about\} \{$key_sources\} \{$key_world_bank\}" ;
  $json_out {$key_about} {$key_codes} {'8'} = "For every country or region key \{years\} \{latest\} contains copy of data for last year with all metrics available" ;

  if ($worldbank_names_override)
  { $json_out {$key_about} {$key_options} {'1'} = "\$worldbank_names_override == \$true  => World Bank names override Wikistats names" ; }
  else
  { $json_out {$key_about} {$key_options} {'1'} = "\$worldbank_names_override == \$false  => Wikistats names override World Bank names" ; }

  $json_out {$key_about} {$key_options} {'2'} = "\$do_not_import_years_before = 2000" ; 
  $json_out {$key_about} {$key_options} {'3'} = "Only accept id's from World Bank unknown to Wikistats: \$only_allow_new_codes '$only_allow_new_codes' (use * for all)" ; 
  if ($add_derived_values)
  { $json_out {$key_about} {$key_options} {'4'} = "Add derived values (like YoY growth percentage)" ; }
  else
  { $json_out {$key_about} {$key_options} {'4'} = "Do not add derived values (like YoY growth percentage)" ; }

  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_population_counts}   {$key_data}    = "https://api.worldbank.org/v2/en/country/all/indicator/SP.POP.TOTL?format=json&per_page=20000&source=2" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_population_counts}   {$key_license} = "CC BY-4.0, for details see https://datacatalog.worldbank.org/public-licenses#cc-by" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_population_counts}   {$key_code}    = "SP.POP.TOTL" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_population_counts}   {$key_notes}   = "country id is ISO 3166-1 alpha2" ; 

  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_internet_users_per_100} {$key_data}    = "https://data.worldbank.org/indicator/it.net.user.zs" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_internet_users_per_100} {$key_license} = "CC BY-4.0, for details see https://datacatalog.worldbank.org/public-licenses#cc-by" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_internet_users_per_100} {$key_code}    = "IT.NET.USER.ZS" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_internet_users_per_100} {$key_notes}   = "country id is ISO 3166-1 alpha3" ; 

  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_mobile_subscriptions_per_100} {$key_data}    = "https://data.worldbank.org/indicator/IT.CEL.SETS.P2?" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_mobile_subscriptions_per_100} {$key_license} = "CC BY-4.0, for details see https://datacatalog.worldbank.org/public-licenses#cc-by" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_mobile_subscriptions_per_100} {$key_code}    = "IT.CEL.SETS.P2" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_mobile_subscriptions_per_100} {$key_notes}   = "country id is ISO 3166-1 alpha3" ; 

  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_gdp_per_capita_constant_us_dollars} {$key_data}    = "https://data.worldbank.org/indicator/NY.GDP.PCAP.KD" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_gdp_per_capita_constant_us_dollars} {$key_license} = "CC BY-4.0, for details see https://datacatalog.worldbank.org/public-licenses#cc-by" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_gdp_per_capita_constant_us_dollars} {$key_code}    = "NY.GDP.PCAP.KD" ; 
  $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_gdp_per_capita_constant_us_dollars} {$key_notes}   = "country id is ISO 3166-1 alpha3" ; 

  $json_out {$key_about} {$key_sources} {$key_world_bank} {'search'}                 = "https://datacatalog.worldbank.org/search" ; 
  
# &ImportCountriesISO2 ;
# &ImportCountriesISO3 ;
# &ImportRegionCodes ;
# replaced by new csv file, which was generated from these imports (code kept for reference)
  &ReadCsvGeoCodes ;

  &ImportCountriesNames ; # for other languages than English
# &WriteCsvGeoCodes ; # one-time merge of csv files, kept for reference

  &ImportPopulationCounts ;
  &ImportInternetUserPercentages ;
  &ImportMobileSubscriptions ;
  &ImportGdpPerCapita ;
  
  &DetermineLatestYearWithFullData ;
  
# &ExportInternetUserPercentages ;
# &ExportMobileSubscriptionsPercentages ;
  &ExportInternetPlusMobileSubscriptions ;
  &ExportGDPplusMobileSubscriptions ;

  &WriteJsonFile ;
  
  print "\n" ;
  foreach my $message (sort keys %messages) # Q&D way to avoid long series of duplicate messages, findings will be reported out of order 
  { print "$message\n" ; }
  
# extra visual cue to signal completion (bell character is silenced in Komodo IDE)
  print 'X ' x 40 . "\n\n" ; 
  print 'X ' x 40 . "\n\n" ; 
  print 'X ' x 40 . "\n\n" ; 
  print "\n\nReady" ;
  
  exit ;

sub WriteJsonFile
{
  $json_all {'about'}     = \%json_about ;
  $json_all {'countries'} = \%json_countries ;
  $json_all {'regions'}   = \%json_regions ;
  $json_all {'languages'} = \%json_languages ;

# print $json_out->pretty->canonical->encode(\%json_all);

  open  JSON_OUT, '>', $file_json_out ;
  print JSON_OUT $json_out->pretty->canonical->encode(\%json_out);
  close JSON_OUT ;

  my $json_file_size = -s $file_json_out ;
  print "\nFile $file_json_out: size $json_file_size bytes\n" ;

  my $json_text_demographics = do
  {
    open (my $json_fh, "<:encoding(UTF-8)", $file_json_out) or die("Can't open \$file_json_out\": $!\n");
    local $/;
    <$json_fh>
  };
  $json_text_demographics =~ s/[^\x00-\x7f]//g ; # drop 'wide characters'

  my $json = JSON->new ;
  my $data = $json->decode ($json_text_demographics) ;
  foreach my $iso2 (sort keys %{$data -> {'countries'}})
  {
    my $year = $data -> {'countries'}{$iso2}{'years'}{'latest'}{'year'} ;
    if (! defined $year)
    { print "\$year not defined for: '$iso2'\n" ; }
    # else
    # {  print "$iso2 $year\n"; }
  }
}

sub ImportCountriesISO2
{
  print "\nsub ImportCountriesISO2\n" ;
  
  open CSV_IN, '<', "$folder/CountryCodes.csv" ;
  
  while (my $line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;    # skip comments
    next if $line =~ /^\s*$/ ; # skip empty line2
    
    chomp $line ;
    my ($iso2,$name) = split (',', $line, 2) ;
    $name =~ s/\"//g ; # remove double quotations marks
    
    print "$iso2 ===> $name\n" if $verbose ;

    $json_out {$key_countries} {$iso2} {$key_names} {'en'} = $name ;
    $iso2_by_name {$name} = $iso2 ;
    $iso2_codes   {$iso2} ++ ;
  }
  close CSV_IN ;

  $iso2_by_name {'Anonymous Proxy'}                 = 'A1' ;  $json_out {$key_countries} {'A1'} {$key_names} {'en'} = 'Anonymous Proxy' ;
  $iso2_by_name {'Satellite Provider'}              = 'A2' ;  $json_out {$key_countries} {'A2'} {$key_names} {'en'} = 'Satellite Provider' ;
  $iso2_by_name {'Asia/Pacific Region Unspecified'} = 'AP' ;  $json_out {$key_countries} {'AP'} {$key_names} {'en'} = 'Asia/Pacific Region Unspecified' ;
  $iso2_by_name {'Europe Unspecified'}              = 'EU' ;  $json_out {$key_countries} {'EU'} {$key_names} {'en'} = 'Europe Unspecified' ;
  $iso2_by_name {'Other Country'}                   = 'O1' ;  $json_out {$key_countries} {'O1'} {$key_names} {'en'} = 'Other Country' ;
  $iso2_codes {'A1'}++ ;
  $iso2_codes {'A2'}++ ;
  $iso2_codes {'AP'}++ ;
  $iso2_codes {'EU'}++ ;
  $iso2_codes {'O1'}++ ;
}

sub ImportCountriesISO3
{
  print "\n\nsub ImportCountriesISO3\n\n" ;

  my ($iso2, $iso3) ;
  
  open CSV_IN, '<', "$folder/CountryCodesISO3.csv" ;
  
  while (my $line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;    # skip comments
    next if $line =~ /^\s*$/ ; # skip empty line2
    
    chomp $line ;
    my ($iso3,$name) = split (',', $line, 2) ;

    $name =~ s/\"//g ; # remove double quotations marks
                       # fix names also in input, e.g. "Iran," Islamic Republic of" -> "Iran, Islamic Republic of"
    print "$iso3 ===> $name\n" if $verbose ;
    
    my $iso2 = $iso2_by_name {$name} ;

    if ((! defined $iso2) || ($iso2 eq ''))
    { print "iso_3166_1_a2 code not found for name: $name\n" ; }
    else
    { $json_out {$key_countries} {$iso2} {$key_codes} {$key_iso3} = $iso3 ; }
  }
  
  close CSV_IN ;
}

sub ImportCountriesNames
{
  my ($languages_found, $code, $line, $iso2, $iso3, $name) ;

  foreach $code (split ',', $languages_countries_names)
  {
    my $file_names = "$folder/countries_iso3166_1_$code.csv" ;
    if (! -e $file_names)
    {
       $messages {"020 List of country names for '$code': '$file_names' not found => skip"} ++ ;
       next ;
    }
    $languages_found .= "$code," ;
    
    open NAMES, '<', $file_names ;
    while ($line = <NAMES>)
    {
       next if $line =~ /iso3166_1_a2/ ; # headers
       chomp $line ;
       ($iso2,$iso3,$name) = split (',', $line) ;
        $json_out {$key_countries} {$iso2} {$key_names} {$code} = $name ;
    }
    close NAMES ;
  } 
  $languages_found =~ s/,$// ;
  
  $json_out {$key_about} {$key_options} {'5'} = "Language codes requested (and found) for country names: $languages_found" ; 
}

sub ImportRegionCodes
{
  print "\n\nsub ImportRegionCodes\n\n" ;

  my ($line,$iso2,$region_code,$north_south_code,$name) ;
  
  open CSV_IN, '<', "$folder/RegionCodes.csv" ;
  
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;    # skip comments
    next if $line =~ /^\s*$/ ; # skip empty line2
    chomp $line ;
    ($iso2, $region_code, $north_south_code, $name) = split (',', $line) ;
    $region_codes {$region_code} ++ ;
    
    $json_out {$key_countries} {$iso2} {$key_codes} {$key_region}      = $region_code ; 
    $json_out {$key_countries} {$iso2} {$key_codes} {$key_north_south} = $north_south_code ; 
  } 
  close CSV_IN ;
}

sub ReadCsvGeoCodes
{
  print "\nsub ReadCsvGeoCodes\n" ;
  
  my ($line) ;
  
  open CSV_IN, '<', $file_csv_geo_codes ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;    # skip comments
    next if $line =~ /^\s*$/ ; # skip empty line2
    
    chomp $line ;
    my ($iso2,$iso3,$region_code,$north_south_code,$name) = split (',', $line) ;
    $region_codes {$region_code} ++ ;
    $name =~ s/"//g ; # fix typos

    if ($iso2 =~ /^X/) # list custom codes
    { $json_out {$key_about} {$key_codes} {'3'} .= "$iso2:$iso3, " ; }

    $json_out {$key_countries} {$iso2} {$key_codes} {$key_iso3}        = $iso3 ; 
    $json_out {$key_countries} {$iso2} {$key_names} {'en'}             = $name ;
    $json_out {$key_countries} {$iso2} {$key_codes} {$key_region}      = $region_code ; 
    $json_out {$key_countries} {$iso2} {$key_codes} {$key_north_south} = $north_south_code ; 

    $iso2_by_name {$name} = $iso2 ;
    $iso2_by_iso3 {$iso3} = $iso2 ;
    $iso2_codes   {$iso2} ++ ;
  }
  $json_out {$key_about} {$key_codes} {'3'} =~ s/,$// ; # remove last comma
}

sub WriteCsvGeoCodes
{
  my ($iso2,$iso3,$name,$region_code,$north_south_code) ;
  
  open CSV_OUT, '>', $file_csv_geo_codes ;

  print CSV_OUT "# $codes_maxmind\n" ;
  print CSV_OUT "# $codes_world_bank\n" ;
  print CSV_OUT "iso-3166-1 alpha-2,iso-3166-1 alpha-3,region code, north-south code,name\n" ;

  foreach $iso2 (sort keys %iso2_codes)
  {
     $iso3             = $json_out {$key_countries} {$iso2} {$key_codes} {$key_iso3} ;
     $name             = $json_out {$key_countries} {$iso2} {$key_names} {'en'} ;
     $region_code      = $json_out {$key_countries} {$iso2} {$key_codes} {$key_region} ;
     $north_south_code = $json_out {$key_countries} {$iso2} {$key_codes} {$key_north_south} ;
     $name =~ s/"//g ; # fix typo
     
     $iso3             = '--' if ! defined $iso3              or $iso3             eq 'XXX' ;
     $name             = '--' if ! defined $name ;
     $region_code      = '--' if ! defined $region_code       or $region_code      eq 'XX' ; 
     $north_south_code = '--' if ! defined $north_south_code  or $north_south_code eq 'X' ;
     
     print CSV_OUT "$iso2,$iso3,$region_code,$north_south_code,$name\n" ;
  }
  close CSV_OUT ;
}


sub ImportPopulationCounts
{
  print "\n\nsub ImportPopulationCounts\n\n" ;

  my ($id, $iso2_wb, $iso2_ws, $name_wb, $name_ws, $year, $population, $population_prev, $year_max) ; # _wb = World Bank, _ws = Wikistats
  my %most_recent_year ;
  $year_max = 0 ;

# https://stackoverflow.com/questions/15653419/parsing-json-file-using-perl  
  my $json_text_population = do
  {
    open (my $json_fh, "<:encoding(UTF-8)", $file_json_population) or die("Can't open \$file_json_population\": $!\n");
    local $/;
    <$json_fh>
  };

  my $json = JSON->new;
  my $data = $json->decode ($json_text_population) ;

# print ${ $data->[0] {'lastupdated'}}  ;
# $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_population} {$key_last_updated} = ${ $data->[0] {'lastupdated'}} ;
  $json_out {$key_about} {$key_sources} {$key_world_bank} {'population counts'} {$key_last_updated} = $data->[0] {'lastupdated'} ;
  
  my @elements = @{ $data->[1] } ; 
  foreach my $element ( @elements )
  {
    $name_wb = $name_ws = $year = $population = '' ;
    $iso2_wb = $element -> {'country'} {'id'} ;

    next if ! defined $iso2_wb ;
    
    if (! defined $json_out {$key_countries} {$iso2_wb}) 
    {
       $messages {"001 World Bank SP.POP.TOTL id: $iso2_wb not (yet) known in Wikistats"} ++ ; 
       if (($only_allow_new_codes ne '*') &&
           (",$only_allow_new_codes," !~ $iso2_wb))
       {
         $messages {"002 World Bank SP.POP.TOTL id: $iso2_wb not in white list '$only_allow_new_codes' => reject"} ++ ; 
         next ;
       }   
       $messages {"003 World Bank SP.POP.TOTL id: $iso2_wb in white list '$only_allow_new_codes' => accept"} ++ ; 
     }
    
    $name_wb = $element -> {'country'} {'value'} ;
    $name_ws = $json_out {$key_countries} {$iso2_wb} {$key_names} {'en'}  ;

  # if ($name_wb ne $name_ws)
  # { print "out: wb:'$name_wb' - ws:$iso2:'$name_ws'\n" ; }
    
    if ((! defined $name_ws) || ($name_ws eq ''))
    {
      print "011: World Bank SP.POP.TOTL add name for $iso2_wb: '$name_wb'\n" ;
      $json_out {$key_countries} {$iso2_wb} {$key_names} {'en'} = $name_wb ;
    }
    else
    {
      if ($name_wb ne $name_ws)
      {
        $messages {"010: id '$iso2_wb': Wikistats '$name_ws' / World Bank SP.POP.TOTL: '$name_wb'"} ++ ;
        if ($worldbank_names_override)
        { $json_out {$key_countries} {$iso2_wb} {$key_names} {'en'} = $name_wb ; }
      } 
    }
    
    if ((defined $element -> {'country'} {'id'}) &&
        (defined $element -> {'date'}) &&
        (defined $element -> {'value'}))
    {
      $year       = $element -> {'date'} ; 
      $population = $element -> {'value'} ;
      
      next if $year < $do_not_import_years_before ;
      if (($year < 2100) && ($year_max < $year))
      { $year_max = $year ; }
      
      $json_out {$key_countries} {$iso2_wb} {$key_years} {$year} {$key_population} = $population ;
      
      if ((! defined $most_recent_year {$iso2_wb}) || ($most_recent_year {$iso2_wb} < $year)) 
      { $most_recent_year {$iso2_wb} = $year ; } 
    # print "$iso2:$name, $year/$population\n";
    } 
  }
  
  foreach my $iso2 (keys %most_recent_year)
  {
    if ($add_derived_values)
    { 
      for ($year = $do_not_import_years_before ; $year <= $year_max ; $year++)
      {
        $population      = $json_out {$key_countries} {$iso2} {$key_years} {$year}   {$key_population} ;
        $population_prev = $json_out {$key_countries} {$iso2} {$key_years} {$year-1} {$key_population} ;
        if ((defined $population) && (defined $population_prev) && ($population_prev != 0))
        { $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_population_inc_perc} = sprintf ("%.1f", (100 * $population / $population_prev) - 100) ; }
      }
    }  

    # my $year = $most_recent_year {$iso2} ;
    # $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_year}       = $year ;
    # $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_population} = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_population} ;
    # if ($add_derived_values)
    # { $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_population_inc_perc} = $json_out {$key_countries} {$iso2} {$key_years} {$year} {'population inc.perc.'} ; }
  }
}

sub ImportInternetUserPercentages
{
  print "\n\nsub ImportInternetUserPercentages\n\n" ;

  my ($line, $id, $iso2, $iso3, $description, $code, $name, $year, $year_max, $percentage, @years, @year_data, $year_data, $year_data_prev, $delta_percent_points) ;
  my ($dummy1, $dummy2, $dummy3, $dummy4) ;

  $year_max = 0 ;

  die "file not found '$file_csv_internet_users'" if ! -e $file_csv_internet_users ;

# https://perlmaven.com/how-to-read-a-csv-file-using-perl
  open FILE_CSV, '<', $file_csv_internet_users ;

  while ($line = <FILE_CSV>)
  {
     chomp $line ;

     # take care of commas inside names
     # to do: use Text::CSV_XS instead
     $line =~ s/"\,\s*$/"/g ; # remove comma at end of line
     $line =~ s/","/"~"/g ;   # replace field separators
     $line =~ s/,/;/g ;       # replace other commas
     $line =~ s/"~"/","/g ;   # restore field separators
     
     if ($line =~ /Last Updated Date/)
     {
        my ($text,$date) = split (',', $line) ;
        $date =~ s/"//g ;
        $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_internet_users} {$key_last_updated} = $date ;
        next ;
     }
     
     if ($line =~ /Country Name/)
     {
       $line =~ s/\"//g ;
       ($dummy1, $dummy2, $dummy3, $dummy4, @years) = split (',', $line) ;
       next ;
     }

     if ($line =~ /Individuals using the Internet/)
     {
       chomp $line ;
     # $line =~ s/\"//g ;
       ($name,$iso3,$description,$code,@year_data) = split ('\",\"', $line) ;
       $name        =~ s/\"//g ; 
       $name        =~ s/,//g ; 
       $iso3        =~ s/\"//g ; 
       $description =~ s/\"//g ; 
       $description =~ s/,//g ; 
       $code        =~ s/\"//g ;
       foreach my $year_data (@year_data)
       {
         $year_data =~ s/\"//g ;
         $year_data =~ s/,//g ;
         $year_data = 0 if $year_data eq '' ;
       }
     # print "1 '$name', 2 '$iso3', 3 '$description', 4 '$code', 5'" . join (':',@year_data) . "'\n" ;

     # next if $iso3 !~ /NLD/ ; # debug only

       $iso2 = $iso2_by_iso3 {$iso3} ;
     # print "name $name, iso2 $iso2, iso3 $iso3, description $description, code $code," . join (':', @year_data) . "\n" ;
     # print "years " . join (':', @years) . "\n" ;
       if ((! defined $iso2) || ($iso2 eq ''))
       {
         # $iso2 = "_$iso3" ; # debug
         # print "1 '$iso3' -> '$iso2' \n" ;
        
         $messages {"020 no custom iso2 code ('starting with 'X') found for World Bank IT.NET.USER.ZS id: $iso3 in 'geo_codes_countries.csv' => skip"} ++ ;
         next ;
       }
       
       $year_data_prev = '' ;
       foreach $year (@years)
       {
         $year_data = shift (@year_data) ;
         next if $year < $do_not_import_years_before ;

         if ((defined $year_data) && ($year_data ne '') && ($year_data != 0))
         {
           $year_data = sprintf ("%.2f", $year_data) ;
           $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_internet_users} = $year_data ;
           
           if ($year_data_prev ne '')
           {
             $delta_percent_points = sprintf ("%.2f", $year_data - $year_data_prev) ;
             $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_internet_users_inc_perc_points} = $delta_percent_points ;
           }
           $year_data_prev = $year_data ;
         }  
       }
       # $year = $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_year}  ;
       # if ((defined $year) && ($year =~ /^\d\d\d\d$/))
       # {
       #   $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_internet_users} =
       #   $json_out {$key_countries} {$iso2} {$key_years} {$year}       {$key_internet_users} ;
       #   $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_internet_users_inc_perc_points} =
       #   $json_out {$key_countries} {$iso2} {$key_years} {$year}       {$key_internet_users_inc_perc_points} ;
       # }
       
     }
  }
   close FILE_CSV ;
}

sub ImportMobileSubscriptions
{
  print "\n\nsub ImportMobileSubscriptions\n\n" ;

  my ($line, $id, $iso2, $iso3, $description, $code, $name, $year, $year_max, $percentage, @years, @year_data, $year_data, $year_data_prev, $delta_percent_points) ;
  my ($dummy1, $dummy2, $dummy3, $dummy4) ;

  $year_max = 0 ;
  die "file not found '$file_csv_mobile_subscriptions'" if ! -e $file_csv_mobile_subscriptions ;
  open FILE_CSV, '<', $file_csv_mobile_subscriptions ;

  while ($line = <FILE_CSV>)
  {
     chomp $line ;

     # take care of commas inside names
     # to do: use Text::CSV_XS instead
     $line =~ s/"\,\s*$/"/g ; # remove comma at end of line
     $line =~ s/","/"~"/g ;   # replace field separators
     $line =~ s/,/;/g ;       # replace other commas
     $line =~ s/"~"/","/g ;   # restore field separators
     
     if ($line =~ /Last Updated Date/)
     {
        my ($text,$date) = split (',', $line) ;
        $date =~ s/"//g ;
        $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_mobile_subscriptions} {$key_last_updated} = $date ;
        next ;
     }
     
     if ($line =~ /Country Name/)
     {
       $line =~ s/\"//g ;
       ($dummy1, $dummy2, $dummy3, $dummy4, @years) = split (',', $line) ;
       next ;
     }

     if ($line =~ /Mobile cellular subscriptions/)
     {
       chomp $line ;
       $line =~ s/\"//g ;
       ($name,$iso3,$description,$code,@year_data) = split (',', $line) ;

     # next if $iso3 !~ /NLD/ ; # debug only

       $iso2 = $iso2_by_iso3 {$iso3} ;
     # print "name $name, iso2 $iso2, iso3 $iso3, description $description, code $code," . join (':', @year_data) . "\n" ;
     # print "years " . join (':', @years) . "\n" ;
       if ((! defined $iso2) || ($iso2 eq ''))
       {
       # $iso2 = "_$iso3" ;
       # print "2 '$iso3' -> '$iso2' \n" ;
          $messages {"021 no custom iso2 code ('starting with 'X') found for World Bank IT.CEL.SETS.P2 id: $iso3 in 'geo_codes_countries.csv' => skip"} ++ ;
          next ;
       }
       
       $year_data_prev = '' ;
       foreach $year (@years)
       
       {
         $year_data = shift (@year_data) ;
         next if $year < $do_not_import_years_before ;

         if ((defined $year_data) && ($year_data ne ''))
         {
           $year_data = sprintf ("%.2f", $year_data) ;
           $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_mobile_subscriptions} = $year_data ;
           
           if ($year_data_prev ne '')
           {
             $delta_percent_points = sprintf ("%.2f", $year_data - $year_data_prev) ;
             $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_mobile_subscriptions_inc_perc_points} = $delta_percent_points ;
           }
           $year_data_prev = $year_data ;
         }  
       }
       # $year = $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_year}  ;
       # if ((defined $year) && ($year =~ /^\d\d\d\d$/))
       # {
       #   $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_mobile_subscriptions} =
       #   $json_out {$key_countries} {$iso2} {$key_years} {$year}       {$key_mobile_subscriptions} ;
       #   $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_mobile_subscriptions_inc_perc_points} =
       #   $json_out {$key_countries} {$iso2} {$key_years} {$year}       {$key_mobile_subscriptions_inc_perc_points} ;
       # }
    }
  }
   close FILE_CSV ;
}

sub ImportGdpPerCapita
{
  print "\n\nsub ImportGdpPerCapita\n\n" ;

  my ($line, $id, $iso2, $iso3, $description, $code, $name, $year, $year_max, $percentage, @years, @year_data, $year_data, $year_data_prev, $delta_percent) ;
  my ($dummy1, $dummy2, $dummy3, $dummy4) ;

  $year_max = 0 ;

  die "file not found '$file_csv_gdp_per_capita'" if ! -e $file_csv_gdp_per_capita ;

# https://perlmaven.com/how-to-read-a-csv-file-using-perl
  open FILE_CSV, '<', $file_csv_gdp_per_capita ;

  while ($line = <FILE_CSV>)
  {
     chomp $line ;

     # take care of commas inside names
     # to do: use Text::CSV_XS instead
     $line =~ s/"\,\s*$/"/g ; # remove comma at end of line
     $line =~ s/","/"~"/g ;   # replace field separators
     $line =~ s/,/;/g ;       # replace other commas
     $line =~ s/"~"/","/g ;   # restore field separators
     
     if ($line =~ /Last Updated Date/)
     {
        my ($text,$date) = split (',', $line) ;
        $date =~ s/"//g ;
        $json_out {$key_about} {$key_sources} {$key_world_bank} {$key_internet_users} {$key_last_updated} = $date ;
        next ;
     }
     
     if ($line =~ /Country Name/)
     {
       $line =~ s/\"//g ;
       ($dummy1, $dummy2, $dummy3, $dummy4, @years) = split (',', $line) ;
       next ;
     }

     if ($line =~ /GDP per capita/)
     {
       chomp $line ;
     # $line =~ s/\"//g ;
       ($name,$iso3,$description,$code,@year_data) = split ('\",\"', $line) ;
       $name        =~ s/\"//g ; 
       $name        =~ s/,//g ; 
       $iso3        =~ s/\"//g ; 
       $description =~ s/\"//g ; 
       $description =~ s/,//g ; 
       $code        =~ s/\"//g ;
       foreach my $year_data (@year_data)
       {
         $year_data =~ s/\"//g ;
         $year_data =~ s/,//g ;
         $year_data = 0 if $year_data eq '' ;
       }
     # print "1 '$name', 2 '$iso3', 3 '$description', 4 '$code', 5'" . join (':',@year_data) . "'\n" ;

     # next if $iso3 !~ /NLD/ ; # debug only

       $iso2 = $iso2_by_iso3 {$iso3} ;
     # print "name $name, iso2 $iso2, iso3 $iso3, description $description, code $code," . join (':', @year_data) . "\n" ;
     # print "years " . join (':', @years) . "\n" ;
       if ((! defined $iso2) || ($iso2 eq ''))
       {
         # $iso2 = "_$iso3" ; # debug
         # print "1 '$iso3' -> '$iso2' \n" ;
        
         $messages {"022 no custom iso2 code ('starting with 'X') found for World Bank NY.GDP.PCAP.KD id: $iso3 in 'geo_codes_countries.csv' => skip"} ++ ;
         next ;
       }
       
       $year_data_prev = '' ;
       foreach $year (@years)
       {
         $year_data = shift (@year_data) ;
         next if $year < $do_not_import_years_before ;

         if ((defined $year_data) && ($year_data ne '') && ($year_data != 0))
         {
           $year_data = sprintf ("%.2f", $year_data) ;
           $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_gdp_per_capita} = $year_data ;
           
           if ($year_data_prev ne '')
           {
             $delta_percent = sprintf ("%.2f", 100 * ($year_data - $year_data_prev) / $year_data_prev) ;
             $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_gdp_per_capita_inc_perc} = $delta_percent ;
           }
           $year_data_prev = $year_data ;
         }  
       }
       # $year = $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_year}  ;
       # if ((defined $year) && ($year =~ /^\d\d\d\d$/))
       # {
       #   $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_internet_users} =
       #   $json_out {$key_countries} {$iso2} {$key_years} {$year}       {$key_internet_users} ;
       #   $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_internet_users_inc_perc_points} =
       #   $json_out {$key_countries} {$iso2} {$key_years} {$year}       {$key_internet_users_inc_perc_points} ;
       # }
       
     }
  }
   close FILE_CSV ;
  
  
}

sub DetermineLatestYearWithFullData
{
  my ($iso2, $year_min, $year_last_data_population, $year_last_data_internet_users, $year_last_data_mobile_subscriptions, $year_last_data_gdp_per_capita, $year_last_complete) ;
  foreach $iso2 (sort {$json_out {$key_countries} {$a} {$key_codes} {$key_region} . $a cmp
                       $json_out {$key_countries} {$b} {$key_codes} {$key_region} . $b} keys %iso2_codes)
  {
    $year_min = 1950 ;
    
    if ($do_not_import_years_before > $year_min)
    { $year_min = $do_not_import_years_before ; }
    
    $year_last_complete                  = $year_min ;
    $year_last_data_population           = $year_min ;
    $year_last_data_internet_users       = $year_min ;
    $year_last_data_mobile_subscriptions = $year_min ;
    $year_last_data_gdp_per_capita       = $year_min ;
    
    for ($year = $year_min ; $year <= $year_now ; $year++)
    {
      if (defined $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_population})
      { $year_last_data_population = $year ; }
      if (defined $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_internet_users})
      { $year_last_data_internet_users = $year ; }
      if (defined $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_mobile_subscriptions}) 
      { $year_last_data_mobile_subscriptions = $year ; }
      if (defined $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_gdp_per_capita}) 
      { $year_last_data_gdp_per_capita = $year ; }
      if (($year_last_data_population == $year) &&       
          ($year_last_data_internet_users == $year) &&       
          ($year_last_data_mobile_subscriptions == $year) &&
          ($year_last_data_gdp_per_capita == $year))
      { $year_last_complete = $year ; }
    }

    if ($year_last_complete == $year_min) 
    {
      print "iso2 $iso2 no complete data for any year: " . $json_out {$key_countries} {$iso2} {$key_names} {'en'} . "\n" ;
      print "iso2 $iso2 population $year_last_data_population, internet users $year_last_data_internet_users, " .
                        "mobile subscriptions $year_last_data_mobile_subscriptions, gdp_per_capita $year_last_data_gdp_per_capita\n" ;
    }
    else
    {
      $json_out {$key_countries} {$iso2} {$key_years} {$key_latest} {$key_year} = $year_last_complete ;

      $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_population} =
      $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_population} ;
      $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_internet_users} =
      $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_internet_users} ;
      $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_mobile_subscriptions} =
      $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_mobile_subscriptions} ;
      $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_gdp_per_capita} =
      $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_gdp_per_capita} ;

      if ($add_derived_values)
      {
        $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_population_inc_perc} =
        $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_population_inc_perc} ;
        $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_internet_users_inc_perc_points} =
        $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_internet_users_inc_perc_points} ;
        $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_mobile_subscriptions_inc_perc_points} =
        $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_mobile_subscriptions_inc_perc_points} ;
        $json_out {$key_countries} {$iso2} {$key_years} {$key_latest}         {$key_gdp_per_capita_inc_perc} =
        $json_out {$key_countries} {$iso2} {$key_years} {$year_last_complete} {$key_gdp_per_capita_inc_perc} ;
      }
      # print "iso2 $iso2 year last complete $year_last_complete\n" ;
    }
  }
}

# World Bank countries by income
# http://chartsbin.com/view/2438
# https://datahelpdesk.worldbank.org/knowledgebase/articles/906519

# OECD https://en.wikipedia.org/wiki/OECD

sub ExportInternetUserPercentages
{
  my ($iso2,$iso3,$name,$region_code,$region_code2,$region_code_prev,$north_south_code,$year,$year_columns,$year_data,$perc,$perc_prev,$perc_delta,$perc_absolute,$internet_users,@year_data,%internet_users) ;
  open CSV_OUT, '>', $file_csv_out_internet_users ;

  $year_columns = '' ;
  for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future-proof (last year with data minus ? x 5)
  { $year_columns .= "\"$year\"," ; }
  $year_columns =~ s/,$// ;
  
  foreach $iso2 (keys %iso2_codes)
  {
    # find higest value (used as sort criterium, later years may be lower or missing, lower values are ignored later,
    # as Excel stacking bar chart can't handle negative values, adds those to the stack, rather than substracts)
    $internet_users = 0 ;
    for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future proof
    {
      my $internet_users2 = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_internet_users} ;
      $internet_users2 = 0 if ! defined $internet_users2 ;
      
      if ($internet_users2 > $internet_users)
      { $internet_users = $internet_users2 ; }
    }
    $internet_users {$iso2} = $internet_users ;
  }  
  
  $region_code_prev = '' ;
  foreach $region_code (sort keys %region_codes)
  {
    print CSV_OUT "iso-3166-1 alpha-2,iso-3166-1 alpha-3,region,sort order (2016 abs),north_south,,$year_columns\n" ; # leave name column empty, this makes excel treat first row as header row
  # foreach $iso2 (sort {$json_out {$key_countries} {$b} {$key_years} {2016} {$key_internet_users} <=> $json_out {$key_countries} {$a} {$key_years} {2016} {$key_internet_users}} keys %iso2_codes)
    foreach $iso2 (sort {$internet_users {$b} <=> $internet_users {$a}} keys %internet_users)
    {
      $region_code2 = $json_out {$key_countries} {$iso2} {$key_codes} {$key_region} ;
      next if $region_code ne $region_code2 ;
      
      $iso3             = $json_out {$key_countries} {$iso2} {$key_codes} {$key_iso3} ;
      $name             = $json_out {$key_countries} {$iso2} {$key_names} {'en'} ;
      $north_south_code = $json_out {$key_countries} {$iso2} {$key_codes} {$key_north_south} ;
      $name =~ s/"//g ; # fix typo

      # patch unicode chars which Excel can't print
      $name = "Curacao"               if $name =~ /^Cura.*ao/ ;
      $name = "Saint-Barthelemy"      if $name =~ /^Saint-Barth.*lemy/ ;
      $name = "Aland Islands"         if $name =~ /land Islands/ ;
      $name = "Sao Tome and Principe" if $name =~ /S.*o Tom.* and Pr.*ncipe/ ;
      $name = "Reunion"               if $name =~ /R.*union/ ;
    
      $year_data = '' ;
      $perc_prev = 0 ;
      $perc      = 0 ;
      for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future proof
      {
        $perc = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_internet_users} ;
        $perc = $perc_prev if ! defined $perc ;

        if (($perc < $perc_prev) && ($perc > 0))
        {
          if ($perc_prev > $perc * 1.1) # only report decrease of 10+%
          { $messages {"100 Internet users, country $name, year $year: decrease ($perc_prev -> $perc) ignored, replaced by 0, (Excel stacking bars would show decrease as increase)"} ++ ; }  
          $perc = $perc_prev ;
        }
      # print "1 $year:$perc\n" ;
        $perc_delta = (0+$perc) - (0+$perc_prev) ; # force numeric
      # $perc_delta -= (0+$perc_prev) ; # turn absolute numbers into increase over previous value (make negative zero, or Excel will  fail)
        $perc_delta = 0 if $perc_delta < 0 ;
        $year_data .= sprintf ("%.2f", $perc_delta) . ',' ; 
      # print "2 $year:$perc_delta -> '$year_data'\n" ;
        if ($perc > $perc_prev)
        { $perc_prev = $perc ; }
      }
      $year_data =~ s/,$// ;
    
      print CSV_OUT "$iso2,$iso3,$region_code,$north_south_code,$perc,$name,$year_data\n" ;
      $region_code_prev = $region_code ;
    }
    print CSV_OUT "\n" ;
  }
  close CSV_OUT ;
}

sub ExportMobileSubscriptionsPercentages
{
  my ($iso2,$iso3,$name,$region_code,$region_code2,$region_code_prev,$north_south_code,$year,$year_columns,$year_data,$perc,$perc_prev,$perc_delta,$perc_absolute,$mobile_subscriptions,@year_data,%mobile_subscriptions) ;
  open CSV_OUT, '>', $file_csv_out_mobile_subscriptions ;

  $year_columns = '' ;
  for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future-proof (last year with data minus ? x 5)
  { $year_columns .= "\"$year\"," ; }
  $year_columns =~ s/,$// ;
  
  foreach $iso2 (keys %iso2_codes)
  {
    $mobile_subscriptions = 0 ;
    for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future proof
    {
      my $mobile_subscriptions2 = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_mobile_subscriptions} ;
      $mobile_subscriptions2 = 0 if ! defined $mobile_subscriptions2 ;
      
      if ($mobile_subscriptions2 > $mobile_subscriptions)
      { $mobile_subscriptions = $mobile_subscriptions2 ; }
    }
    $mobile_subscriptions {$iso2} = $mobile_subscriptions ;
  }  
  
  $region_code_prev = '' ;
  foreach $region_code (sort keys %region_codes)
  {
    print CSV_OUT "iso-3166-1 alpha-2,iso-3166-1 alpha-3,region,sort order (2016 abs),north_south,,$year_columns\n" ; # leave name column empty, this makes excel treat first row as header row
  # foreach $iso2 (sort {$json_out {$key_countries} {$b} {$key_years} {2016} {$key_internet_users} <=> $json_out {$key_countries} {$a} {$key_years} {2016} {$key_internet_users}} keys %iso2_codes)
    foreach $iso2 (sort {$mobile_subscriptions {$b} <=> $mobile_subscriptions {$a}} keys %mobile_subscriptions)
    {
      $region_code2 = $json_out {$key_countries} {$iso2} {$key_codes} {$key_region} ;
      next if $region_code ne $region_code2 ;
      
      $iso3             = $json_out {$key_countries} {$iso2} {$key_codes} {$key_iso3} ;
      $name             = $json_out {$key_countries} {$iso2} {$key_names} {'en'} ;
      $north_south_code = $json_out {$key_countries} {$iso2} {$key_codes} {$key_north_south} ;
      $name =~ s/"//g ; # fix typo

      # patch unicode chars which Excel can't print
      $name = "Curacao"               if $name =~ /^Cura.*ao/ ;
      $name = "Saint-Barthelemy"      if $name =~ /^Saint-Barth.*lemy/ ;
      $name = "Aland Islands"         if $name =~ /land Islands/ ;
      $name = "Sao Tome and Principe" if $name =~ /S.*o Tom.* and Pr.*ncipe/ ;
      $name = "Reunion"               if $name =~ /R.*union/ ;
    
      $year_data = '' ;
      $perc_prev = 0 ;
      $perc      = 0 ;
      for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future proof
      {
        $perc = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_mobile_subscriptions} ;
        $perc = $perc_prev if ! defined $perc ;
        
        if (($perc < $perc_prev) && ($perc > 0))
        {
          if ($perc_prev > $perc * 1.2) # only report decrease of 10+%
          { $messages {"101 Mobile subscriptions, country $name, year $year: decrease ($perc_prev -> $perc) ignored, replaced by 0, (Excel stacking bars would show decrease as increase)"} ++ ; }  
          $perc = $perc_prev ;
        }
      # print "1 $year:$perc\n" ;
        $perc_delta = (0+$perc) - (0+$perc_prev) ; # force numeric
      # $perc_delta -= (0+$perc_prev) ; # turn absolute numbers into increase over previous value (make negative zero, or Excel will  fail)
        $perc_delta = 0 if $perc_delta < 0 ;
        $year_data .= sprintf ("%.2f", $perc_delta) . ',' ; 
      # print "2 $year:$perc_delta -> '$year_data'\n" ;
        if ($perc > $perc_prev)
        { $perc_prev = $perc ; }
      }
      $year_data =~ s/,$// ;
    
      print CSV_OUT "$iso2,$iso3,$region_code,$north_south_code,$perc,$name,$year_data\n" ;
      $region_code_prev = $region_code ;
    }
    print CSV_OUT "\n" ;
  }
  close CSV_OUT ;
}

sub ExportInternetPlusMobileSubscriptions
{
  my ($iso2,$iso3,$name,$region_code,$region_code2,$region_code_prev,$north_south_code,$year,$year_columns,$year_data,$perc,$perc_prev,$perc_delta,$perc_absolute,$internet_users,$mobile_subscriptions,@year_data,%mobile_subscriptions) ;

  open CSV_OUT, '>', $file_csv_out_internet_plus_mobile ;

  print CSV_OUT "iso-3166-1 alpha-2,iso-3166-1 alpha-3,name,region code,internet users per 100,Africa,Asia,Central America,Europe,North America,Oceania,South America\n" ; 

  $year_columns = '' ;
  for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future-proof (last year with data minus ? x 5)
  { $year_columns .= "\"$year\"," ; }
  $year_columns =~ s/,$// ;
  
  # sort by region code, and within that iso-3166-1 alpha-2
  foreach $iso2 (sort {$json_out {$key_countries} {$a} {$key_codes} {$key_region} . $a cmp
                       $json_out {$key_countries} {$b} {$key_codes} {$key_region} . $b} keys %iso2_codes)
  {
    $internet_users       = 0 ;
    $mobile_subscriptions = 0 ;
    
    $iso3        = $json_out {$key_countries} {$iso2} {$key_codes} {$key_iso3} ;
    $region_code = $json_out {$key_countries} {$iso2} {$key_codes} {$key_region} ;
    $name        = $json_out {$key_countries} {$iso2} {$key_names} {'en'} ;
    
    for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future proof
    {
      my $internet_users2 = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_internet_users} ;
      $internet_users2 = 0 if ! defined $internet_users2 ;
      
      if ($internet_users2 > $internet_users)
      { $internet_users = $internet_users2 ; }

      my $mobile_subscriptions2 = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_mobile_subscriptions} ;
      $mobile_subscriptions2 = 0 if ! defined $mobile_subscriptions2 ;
      
      if ($mobile_subscriptions2 > $mobile_subscriptions)
      { $mobile_subscriptions = $mobile_subscriptions2 ; }
    }
    
    next if $internet_users == 0 and $mobile_subscriptions == 0 ;
    
    # every region into its own column, for region-colored scatter plot
       if ($region_code eq 'AS') { $mobile_subscriptions = ",$mobile_subscriptions" ; }
    elsif ($region_code eq 'CA') { $mobile_subscriptions = ",,$mobile_subscriptions" ; }
    elsif ($region_code eq 'EU') { $mobile_subscriptions = ",,,$mobile_subscriptions" ; }
    elsif ($region_code eq 'NA') { $mobile_subscriptions = ",,,,$mobile_subscriptions" ; }
    elsif ($region_code eq 'OC') { $mobile_subscriptions = ",,,,,$mobile_subscriptions" ; }
    elsif ($region_code eq 'SA') { $mobile_subscriptions = ",,,,,,$mobile_subscriptions" ; }
    
    print CSV_OUT "$iso2,$iso3,$name,$region_code,$internet_users,$mobile_subscriptions\n" ;
  }  
  
  close CSV_OUT ;
}

sub ExportGDPplusMobileSubscriptions
{
  my ($iso2,$iso3,$name,$region_code,$region_code2,$region_code_prev,$north_south_code,$year,$year_columns,$year_data,$perc,$perc_prev,$perc_delta,$perc_absolute,$gdp_per_capita,$mobile_subscriptions,@year_data,%mobile_subscriptions) ;

  open CSV_OUT, '>', $file_csv_out_gdp_plus_mobile ;

  print CSV_OUT "iso-3166-1 alpha-2,iso-3166-1 alpha-3,name,region code,gdp per capita in usd,Africa,Asia,Central America,Europe,North America,Oceania,South America\n" ; 

  $year_columns = '' ;
  for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future-proof (last year with data minus ? x 5)
  { $year_columns .= "\"$year\"," ; }
  $year_columns =~ s/,$// ;
  
  # sort by region code, and within that iso-3166-1 alpha-2
  foreach $iso2 (sort {$json_out {$key_countries} {$a} {$key_codes} {$key_region} . $a cmp
                       $json_out {$key_countries} {$b} {$key_codes} {$key_region} . $b} keys %iso2_codes)
  {
    $gdp_per_capita       = 0 ;
    $mobile_subscriptions = 0 ;
    
    $iso3        = $json_out {$key_countries} {$iso2} {$key_codes} {$key_iso3} ;
    $region_code = $json_out {$key_countries} {$iso2} {$key_codes} {$key_region} ;
    $name        = $json_out {$key_countries} {$iso2} {$key_names} {'en'} ;
    
    for ($year = 1996 ; $year <= 2016 ; $year += 5 ) # make start year future proof
    {
      my $gdp_per_capita2 = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_gdp_per_capita} ;
      $gdp_per_capita2 = 0 if ! defined $gdp_per_capita2 ;
      
      if ($gdp_per_capita2 > $gdp_per_capita)
      { $gdp_per_capita = $gdp_per_capita2 ; }

      my $mobile_subscriptions2 = $json_out {$key_countries} {$iso2} {$key_years} {$year} {$key_mobile_subscriptions} ;
      $mobile_subscriptions2 = 0 if ! defined $mobile_subscriptions2 ;
      
      if ($mobile_subscriptions2 > $mobile_subscriptions)
      { $mobile_subscriptions = $mobile_subscriptions2 ; }
    }
    
    next if $gdp_per_capita == 0 and $mobile_subscriptions == 0 ;
    
    # every region into its own column, for region-colored scatter plot
       if ($region_code eq 'AS') { $mobile_subscriptions = ",$mobile_subscriptions" ; }
    elsif ($region_code eq 'CA') { $mobile_subscriptions = ",,$mobile_subscriptions" ; }
    elsif ($region_code eq 'EU') { $mobile_subscriptions = ",,,$mobile_subscriptions" ; }
    elsif ($region_code eq 'NA') { $mobile_subscriptions = ",,,,$mobile_subscriptions" ; }
    elsif ($region_code eq 'OC') { $mobile_subscriptions = ",,,,,$mobile_subscriptions" ; }
    elsif ($region_code eq 'SA') { $mobile_subscriptions = ",,,,,,$mobile_subscriptions" ; }
    
    print CSV_OUT "$iso2,$iso3,$name,$region_code,$gdp_per_capita,$mobile_subscriptions\n" ;
  }  
  
  close CSV_OUT ;
}
