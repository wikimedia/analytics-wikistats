#!/usr/bin/perl
# Build json equivalent (one file) of WiViVi input (three csv files),
# or actually superset, augmented with e.g. country names from world_bank_demographics_for_wikimedia_yyyy_mm.json

  use warnings ;
  use strict ;
  use JSON;
  my $json_obj_out = new JSON;
  my $data_demographics ;

  our $true  = 1 ;
  our $false = 0 ;
  our $dev_mode = $false ;
  our $add_thousands_separator = $false ; # no longer add commas to bring this json file in line with demographics.json

  our %json_about ;
  my %json_all ;
  my %json_flags ;
  my %json_countries ;
  my %json_regions ;
  my %json_languages ;

  my %html_flags ;

  my %csv_countries ;
  my %name_country ;
  my %name_region ;
  my %code_region ;
  my %code_north_south ;
  my %codes_regions ;
  my %countries_per_region ;
  my %perc_global_population ;
  my %iso3_to_iso2 ;

# our $count_countries ;
# our $count_regions ;
# our $count_languages ;
# our $count_flags ;

  our $unique_countries ;
  our $unique_regions ;
  our $unique_languages ;
  our $unique_flags ;
  our $month_data_countries ;

  our $max_countries = 9999 ;
  our $max_languages = 9999 ;
  our $max_regions   = 9999 ;

  if ($dev_mode) # just collect few objects per nesting level, for better overview of results
  {
    $max_countries = 3 ;
    $max_languages = 3 ;
    $max_regions   = 5 ;
  }

# syntax test
# my @friends1 = qw[Shabbir Anjan Sajal Navin];
# my @friends2 = qw[Sanket Taneesha Sreekutty];
# $perl_data{Pradeep} = { locale => 'en_IN', friends => \@friends1 };
# $perl_data{Anjali}  = { locale => 'en_IN', friends => \@friends2 };

# to be fixed: hard coded paths
# my $folder = 'd:\\@Wikimedia\datamaps\datafiles' ; # test on Erik's Windows PC
  my $folder = '/home/ezachte/wikistats_data/squids/reports' ;

  my $file_json_in            = "/home/ezachte/wikistats/worldbank/world_bank_demographics_for_wikimedia.json" ;
  my $file_json_out           = "$folder/datamaps-data.json" ;
  my $file_country_stats      = "$folder/datamaps-country-stats.csv" ; # not for WiViVi viz. (yet), so not actually for datamaps, calling it this to keep files names uniform
  my $file_flags              = "$folder/datamaps-flags.csv" ;
  my $file_views_per_country  = "$folder/datamaps-views-per-country.csv" ;
  my $file_views_per_region   = "$folder/datamaps-views-per-region.csv" ;
  my $file_views_per_language = "$folder/datamaps-views-per-language.csv" ;

# my @regions = qw(AA BB CC) ;
# $json_all {'regions'} = \@regions ;
# print $json_obj_out->pretty->canonical->encode(\%json_all);

  &ComposeJsonMetaData ;
  &ReadJsonFile ($file_json_in) ;;
  &ReadDataPerFlag     ($file_flags) ;
  &ReadDataPerRegion   ($file_views_per_region) ;

  &PatchMissingData ; # add country codes which not yet in server csv file, also patch CIV to english spelling

  &ReadDataPerCountry  ($file_views_per_country) ;
  &ReadDataPerLanguage ($file_views_per_language) ;

  $json_about {'stats'} = {'languages'  => $unique_languages,
                           'countries'  => $unique_countries,
                           'regions'    => $unique_regions} ;
                         # 'flags'      => $unique_flags} ;

  &WriteCsvFileCountryStats ; # special csv file for WMF staff (not for WiViVi viz.)
  &WriteJsonFile ($file_json_out) ;
  print "Ready\n\n" ;
  exit ;

sub ReadJsonFile
{
  my $file_json_demographics = shift ;

  print "Read from '$file_json_demographics'\n" ;

  my $json_text_demographics = do
  {
    open (my $json_fh, "<:encoding(UTF-8)", $file_json_demographics) or die ("Can't open \$file_json_demographics\ $!\n") ;
    local $/;
    <$json_fh>
  };
  
# $json_text_demographics =~s/[^\x00-\x7f]//g ; # drop 'wide' characters

  my $json_obj_in = JSON->new ;
  $data_demographics = $json_obj_in->decode ($json_text_demographics) ;

  foreach my $iso2 (sort keys %{$data_demographics -> {'countries'}})
  {
    my $iso3 = $data_demographics -> {'countries'} {$iso2} {'codes'} {'iso_3166_1_alpha_3'} ;
    next if ! defined ($iso3) or $iso3 !~ /^[A-Z]{3,3}$/ ; # skip invalid entries
    $iso3_to_iso2 {$iso3} = $iso2 ;
    print "iso2 $iso2 -> $iso3\n"; # $element -> {'country'}{'id'}  ;
  # foreach my $lang_code (sort keys %{$data_demographics -> {'countries'} {$iso2} {'names'}})
  # { print "$iso2 $lang_code: ". $data_demographics -> {'countries'} {$iso2} {'names'} {$lang_code} . "\n" ; }
  }
}

sub WriteJsonFile
{
 my $file_json_out = shift ;

 $json_all {'about'}     = \%json_about ;
 $json_all {'countries'} = \%json_countries ;
 $json_all {'regions'}   = \%json_regions ;
 $json_all {'languages'} = \%json_languages ;

# print $json_obj_out->pretty->canonical->encode(\%json_all);

  open  JSON_OUT, '>', $file_json_out ;
  binmode JSON_OUT, ':utf8' ;
  print JSON_OUT $json_obj_out->pretty->canonical->encode(\%json_all);
  close JSON_OUT ;

  my $json_file_size = -s $file_json_out ;
  print "\nFile $file_json_out: size $json_file_size bytes\n" ;
}


sub WriteCsvFileCountryStats # special csv file for WMF staff, not (yet) for WiViVi viz.
{
  open  CSV_COUNTRIES, '>', $file_country_stats ;
  print CSV_COUNTRIES "# Pageview data supplied by Wikimedia Foundation Analytics Team\n" ;
  print CSV_COUNTRIES "# Demographics and flags taken from English Wikipedia - page https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population or from article about a country (infobox) - e.g. https://en.wikipedia.org/wiki/Kenya\n" ;
  print CSV_COUNTRIES "# Number of speakers taken from English Wikipedia - page https://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users\n" ;
  print CSV_COUNTRIES "country code, country name, region code, region name, north_south, views per capita per month, views per internet user, percentage of global views, requests per country per month, population, percentage of world population, percentage connected to internet, flag icon\n" ;
  foreach my $iso2 (sort keys %csv_countries)
  {
    my $line = $csv_countries {$iso2} ;
    $line =~ s/,$// ; # remove last comma
    print CSV_COUNTRIES "$line\n" ;
  }
  close CSV_COUNTRIES ;
}

sub ComposeJsonMetaData
{
  if ($add_thousands_separator)
  { $json_about {'thousands_separator'} = ',' ; }

  $json_about {'layout'} = {'version'  => '0.1',
                            'comments' => '0.1 = initial release'} ;

 $json_about {'comments on json key'} = {'1' => { 'key' => 'countries/country_code (X)/language_code (Y)/perc',
                                                  'key_comments' => 'perc = percentage of monthly views from country X to language Y'},
                                         '2' => { 'key' => 'languages/language_code/rank_most_spoken',
                                                  'key_comments' => 'rank = rank by numbers of people who speak this language as primary or secondary language, source: English Wikipedia'},
                                         '3' => { 'key' => 'regions/region_code/~countries',
                                                  'key_comments' => 'note this key starts with tilde, to sort it last, for easier manual inspection of json file'}} ;

  $json_about {'codes'} = {'countries' => {'scheme' => 'ISO 3166-1 alpha-2',
                                           'about'  => 'https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2', 
                                           'note'   => 'script [datamaps] (used in visualization WiViVi) expects alpha-3 codes for countries -> added as extra field'},
                           'languages' => {'scheme' => 'ISO 639',
                                           'about'  => 'https://meta.wikimedia.org/wiki/Language_codes'},
                           'regions' =>   {'scheme' => 'no ISO scheme, custom scheme somewhat analogous to UN Geoscheme (except for Carribean in Central America, may be changed)',
                                           'about'  => 'https://en.wikipedia.org/wiki/United_Nations_geoscheme, also GN/GS for Global North/South, see https://en.wikipedia.org/wiki/North%E2%80%93South_divide'},
                           'format_years'  => 'yyyy',
                           'format_months' => 'yyyy-mm',
                           'format_dates'  => 'yyyy-mm-dd'} ;

  $json_about {'created by'} = {'author'                  => 'Erik Zachte, Data Analyst',
                                'organization_name'       => 'Wikimedia Foundation',
                                'organization_url'        => 'https://wikimediafoundation.org/',
                                'organization_department' => 'Research'} ;

  my $source1 = {'file'     => 'stat1005:/mnt/hdfs/wmf/data/archive/projectview/geo/hourly/',
                 'items'    => 'pageviews per country per hour per wiki per requester type (user/spider) per platform (mobile web/mobile app/desktop)',
                 'curation' => {'curator' => 'Wikimedia Foundation (Analytics Team)',
                                'method' => 'automated'}} ;

  my $source2 = {'url'      => 'https://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users',
                 'items'    => 'country name, internet users as share of population (percentage)',
                 'curation' => { 'curator' => 'Wikipedia editors',
                                 'method' => 'manual',
                                 'comment' =>  'see Wikipedia page (section See Also) for calculation method and reliability'}} ;

  my $source3 = {'url'      => 'https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population',
                 'items'    => 'country name, population, country icon file name',
                 'curation' => {'curator' => 'Wikipedia editors',
                                'method' => 'manual',
                                'source' => 'mostly from official estimation pages or official population clock pages',
                                'comment' =>  'for most countries quite up to date (date is specified on Wikipedia page)'}} ;

  my $script1 = {'name'    => 'datamaps_views.sh',
                              'language' => 'bash',
                              'github_url' => 'https://github.com/wikimedia/analytics-wikistats/blob/master/traffic/bash/datamaps_views.sh',
                              'role' => 'collect and aggregate monthly pageview data'} ;
  my $script2 = {'name'    => 'TrafficAnalysisGeo.pl',
                              'language' => 'perl',
                              'github_url' => 'https://github.com/wikimedia/analytics-wikistats/blob/master/traffic/perl/TrafficAnalysisGeo.pl',
                              'role' => 'filter and aggregate data from source 1 into monthly pageview data'} ;
  my $script3 = {'name'    => 'datamaps_convert_data.pl',
                              'language' => 'perl',
                              'role' => 'convert csv output files from TrafficAnalysisGeo.pl to one json file'} ;

  $json_about {'created from'} = {'source 1'  => $source1,
                                  'source 2'  => $source2,
                                  'source 3'  => $source3} ;

  $json_about {'created with'} = {'script1' => $script1,
                                  'script2' => $script2,
                                  'script3' => $script3} ;

  $json_about {'application'}  = {'name'  => 'WiViVi',
                                  'topic' => 'visualisation: Wikipedia Views Visualized',
                                  'url'   => 'https://stats.wikimedia.org/wikimedia/animations/wivivi/wivivi.html',
                                  'note'  => 'this json file is compatible with csv files used in WiViVi, but not used there (yet)' } ;

  $json_about {'copyright'}    = {'license' => 'CC0 = No Rights reserved',
                                  'about'   => 'https://creativecommons.org/share-your-work/public-domain/cc0/'} ;

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
  $json_about {'file_generated'} = sprintf ("%4d-%02d-%02d %02d:%02d",$year+1900,$mon+1,$mday,$hour,$min) ;
}

sub ReadDataPerFlag
{
  my $csv_in = shift ;
  my ($line, $country, $html, $url) ;

  print "sub ReadDataPerFlag, read from $csv_in\n\n" ;
  die "Could not find '$csv_in'" if ! -e $csv_in ; 
  
  open CSV_FLAGS, '<', $csv_in || die "Could not open input file '$csv_in'" ;

  $line = <CSV_FLAGS> ; # skip header
  print "line: $line\n"; 
  while ($line = <CSV_FLAGS>)
  {
    next if $line =~ /^\s*$/ ; # skip empty lines
    $unique_flags ++ ;
    chomp $line ;
    ($country, $html) = split (',', $line) ;
    $url = $html ;
    $url =~ s/<img src='/http:/ ;
    $url =~ s/svg\/.*$/svg/ ;
    $url =~ s/thumb\/// ;
    $json_flags {$country} = { 'url' => $url,
                               'html_wivivi' => $html } ;
    $html_flags {$country} = $html ;
    print "$country -> $html\n" ;
  }
  close CSV_FLAGS ;
  print "sub ReadDataPerFlag ready\n\n" ;
}

sub ReadDataPerCountry
{
  my $csv_in = shift ;
  my ($count_languages,@languages,
      $line,
      $views_per_capita,$percentage_of_global_views,$views_this_country2,$population2,$connected2,
      $dummy,$shares_per_language, $share) ;


  open CSV_VIEWS_PER_COUNTRY, '<', $csv_in || die "Could not open input file '$csv_in'" ;

  $line = <CSV_VIEWS_PER_COUNTRY> ; # from header line only use month for which data are meant ('month=yyyy-mm' not actually a real column header)
  chomp $line ;
  die ("not found for which month these data are, specify as 'month=yyyy-mm'\n") if $line !~ /month=/ ;
  $line =~ s/^.*?month\=// ;
  $month_data_countries = substr ($line,0,7) ;
  $json_about {'data_for_month'} = $month_data_countries ;

  print "month_data_countries=$month_data_countries\n" ;
  
  while ($line = <CSV_VIEWS_PER_COUNTRY>)
  {
    next if $line =~ /^\s*$/ ; # skip empty lines

    chomp $line ;
    $line =~ s/<[^>]*>//g ; # remove html from data, like text colors (?)

    my ($iso3,$views_per_capita_per_month,$percentage_of_global_views,$requests_per_country_per_month,$population,$percentage_connected_to_internet,$dummy,$shares_per_language,$month_data_countries) = split (',', $line) ;
    
    my $iso2 = $iso3_to_iso2 {$iso3} ;

    print "iso3 $iso3 -> $iso2\n"; 
    next if length ($iso2) != 2 ;

    next if $iso3 eq '--' ;
    next if $iso3 eq '^' ;
  # next if $iso3 ne 'AFG' ; # test only
    last if ++ $unique_countries > $max_countries ;

    print "\nReadDataPerCountry '$line'\n" ;

    $requests_per_country_per_month = &ExpandFigure ($requests_per_country_per_month) ;
    $population                     = &ExpandFigure ($population) ;
    $percentage_of_global_views =~ s/\%// ;

    my $image = $html_flags {$iso3} ;
    $image =~ s/^.*?'(.*?)'.*$/$1/ ;
    $image = "https:$image" ;

    my $views_per_internet_user = '--' ;
    (my $percentage_connected_to_internet2 = $percentage_connected_to_internet) =~ s/\%// ;
    my $population_connected = $population * $percentage_connected_to_internet2 / 100 ;
    if ($population_connected > 0)
    { $views_per_internet_user = sprintf ("%.2f",$requests_per_country_per_month / $population_connected) ; }
  # print  $name_country     {$iso2 . " / " . $population_connected . " / " . $requests_per_internet_user . "\n" ;

    $codes_regions {$code_region {$iso2}} .= "$iso2," ;
    $codes_regions {'W'} .= "$iso2," ; # world


    $csv_countries {$iso2} = &Csv ($iso3) .
                             &Csv ($name_country     {$iso2}) .
                             &Csv ($code_region      {$iso2}) .
                             &Csv ($name_region      {$iso2}) .
                             &Csv ($code_north_south {$iso2}) .
                             &Csv ($views_per_capita_per_month) .
                             &Csv ($views_per_internet_user).
                             &Csv ($percentage_of_global_views  . '%') .
                             &Csv ($requests_per_country_per_month) .
                             &Csv ($population) .
                             &Csv ($perc_global_population {$iso2}) .
                             &Csv ($percentage_connected_to_internet) ; 
                             # &Csv ("=IMAGE(\"$image\")") ;

    $json_countries {$iso2} = { 'views_per_capita_per_month'       => $views_per_capita_per_month,
                                'percentage_of_global_views'       => $percentage_of_global_views,
                                'views_per_month'                  => &Commas ($requests_per_country_per_month),
                                'population'                       => &Commas ($population),
                                'percentage_connected_to_internet' => $percentage_connected_to_internet} ;


    foreach my $lang_code (sort keys %{$data_demographics -> {'countries'} {$iso2} {'names'}})
    {
    # print "$iso2 $lang_code: ". $data_demographics -> {'countries'} {$iso2} {'names'} {$lang_code} . "\n" ;
      my $name = $data_demographics -> {'countries'} {$iso2} {'names'} {$lang_code} ;
      if ($name !~ /^\s*$/) # non-empty string ?  
      { $json_countries {$iso2} {'names'} {$lang_code} = $name ; }
    }

    my $code_north_south = $code_north_south {$iso2} ;
    my $code_region      = $code_region      {$iso2} ;

    $json_countries {$iso2} {'codes'} {'iso_3166_1_alpha_3'} = $iso3             if $iso3 ne '' ;
    $json_countries {$iso2} {'codes'} {'north_south'}        = $code_north_south if $code_north_south ne '' ; 
    $json_countries {$iso2} {'codes'} {'region'}             = $code_region      if $code_region ne '';

 
    my $count_languages = 0 ;

    my @share_per_language = split ('\|', $shares_per_language) ;
    foreach $share (@share_per_language)
    {

      last if ++ $count_languages > $max_languages ;

      my ($lang_code,$lang_name,$percentage_of_views_to_this_language) = split (':', $share) ;
      $percentage_of_views_to_this_language =~ s/\%// ;
      $percentage_connected_to_internet     =~ s/\%// ;

      $lang_code = 'other' if $lang_code eq '^' ;
      $json_countries {$iso2} { 'percentages_views_per_language' } { $lang_code } =
                                                                                     $percentage_of_views_to_this_language ;
    }
  }
}

sub ReadDataPerRegion
{
  my $csv_in = shift ;

  my ($count_languages,@countries,
      $line,
      %data_per_country) ;

  open CSV_VIEWS_PER_REGION, '<', $csv_in || die "Could not open input file '$csv_in'" ;

  $line = <CSV_VIEWS_PER_REGION> ; # skip headers
  while ($line = <CSV_VIEWS_PER_REGION>)
  {
    next if $line =~ /^\s*$/ ; # skip empty lines

    print "$line\n" ;

    last if ++ $unique_regions > $max_regions ;
    chomp $line ;
  # my ($iso3,$views_per_capita_per_month,$percentage_of_global_views,$requests_per_country_per_month,$population,$percentage_connected_to_internet,$dummy,$shares_per_language) = split (',', $line) ;
    # ignore lat,long and two colors
    my ($region_name, $region_code_wivivi, $d1, $d2, $d3, $d4,
        $population_region, $percentage_population_region_out_of_world_total,
        $connected_to_internet_in_region, $percentage_connected_to_internet_in_region,
        $pageviews_region_per_month, $pageviews_region_per_month_per_user,
        $percentage_of_total,$countries,$data_per_country,@data_per_country) = split (',', $line) ;
    my @countries = split ('\|', $countries) ;

    $population_region                = &ExpandFigure ($population_region) ;
    $connected_to_internet_in_region  = &ExpandFigure ($connected_to_internet_in_region) ;
    $pageviews_region_per_month       = &ExpandFigure ($pageviews_region_per_month) ;

    $percentage_population_region_out_of_world_total =~ s/\%// ;
    $percentage_connected_to_internet_in_region      =~ s/\%// ;
    $percentage_of_total                             =~ s/\%// ;

    my $count_countries = 0 ;
#    my @share_per_language = split ('\|', $shares_per_language) ;
    foreach my $country (@countries)
    {
      last if ++ $count_countries > $max_countries ;

      my ($rank_by_region_pageviews,$iso3,$country_name,$north_south_code,
          $population_country,$percentage_population_country_out_of_world_total,
          $percentage_connected_to_internet_in_country,
          $pageviews_country_per_month,$percentage_pageviews_out_of_global_total) = split ('\:', $country) ;

      next if $iso3 =~ /^\s*$/ ; # empty string

      my $iso2 = $iso3_to_iso2 {$iso3} ;

      next if length ($iso2) != 2 ;

      # supply missing country names (to be added to csv file on server)

      $name_country           {$iso2} = $country_name ;
      $name_region            {$iso2} = $region_name ;
      $code_region            {$iso2} = $region_code_wivivi ;
      $code_north_south       {$iso2} = $north_south_code ;
      $perc_global_population {$iso2} = $percentage_population_country_out_of_world_total ;

      $population_country               = &ExpandFigure ($population_country) ;
     # $connected_to_internet_in_country = &ExpandFigure ($connected_to_internet_in_country) ;
      $pageviews_country_per_month      = &ExpandFigure ($pageviews_country_per_month) ;

      $percentage_population_country_out_of_world_total  =~ s/\%// ;
      $percentage_connected_to_internet_in_country       =~ s/\%// ;
      $percentage_pageviews_out_of_global_total          =~ s/\%// ;

      my $connected_to_internet_in_country = '--' ;
      if ($population_country =~ /^\d+$/)
      { $connected_to_internet_in_country = sprintf ("%.0f", $percentage_connected_to_internet_in_country / 100 * $population_country) ; }

#    # print "$iso3: $lang_code, $lang_name, $percentage_of_views_to_this_language\n" ;
    #   undef %data_metric ;
    #   $data_per_metric {'absolute'} = { $iso3}

       $data_per_country {$iso2} = {'rank_by_region_pageviews' => $rank_by_region_pageviews,
                                    'country_name'             =>  $country_name,
                                    'north_south'              => $north_south_code,

                                    #'population_country' =>  $population_country,
                                    #'percentage_population_country_out_of_world_total' => $percentage_population_country_out_of_world_total,
                                     'population' =>  {'count'   => &Commas ($population_country),
                                                       '%global' => $percentage_population_country_out_of_world_total},

                                    #'percentage_connected_to_internet_in_country', $connected_to_internet_in_country,
                                    #'percentage_connected_to_internet_in_country', $percentage_connected_to_internet_in_country,
                                     'people_connected' => {'count'    => &Commas ($connected_to_internet_in_country),
                                                            '%country' => $percentage_connected_to_internet_in_country},

                                    #'pageviews_country_per_month' => $pageviews_country_per_month,
                                    #'percentage_pageviews_out_of_global_total' => $percentage_pageviews_out_of_global_total} ;
                                     'pageviews' =>   {'count'   => &Commas ($pageviews_country_per_month),
                                                       '%global' => $percentage_pageviews_out_of_global_total} } ;
#       print "$region_code_wivivi $iso2\n" ;

       $countries_per_region {$region_code_wivivi} {$iso2} ++ ;
     # $countries_per_region {$north_south_code}   {$iso2} ++ ;
     # $countries_per_region {'W'}                 {$iso2} ++ ;
    }

     my @keys_json_regions = keys %{$countries_per_region {$region_code_wivivi}} ;
     my $count_countries_in_region = $#keys_json_regions + 1 ;
     
  #  my @countries_codes = sort {$a cmp $b} @{$countries_per_region {$region_code_wivivi}} ;
     my @countries_codes = sort {$a cmp $b} keys %{$countries_per_region {$region_code_wivivi}} ;
     $json_regions {$region_code_wivivi} = {'country_count' => $count_countries_in_region, 
                                            'name'  => $region_name,

                                           #'population_region'                                 => $population_region,
                                           #'percentage_population_region_out_of_world_total'   => $percentage_population_region_out_of_world_total,
                                            'population' =>  {'count'   => &Commas ($population_region),
                                                              '%global' => $percentage_population_region_out_of_world_total},

                                           #'connected_to_internet_in_region'                   => $connected_to_internet_in_region,
                                           #'percentage_connected_to_internet_in_region'        => $percentage_connected_to_internet_in_region,
                                            'people_connected' => {'count'   => &Commas ($connected_to_internet_in_region),
                                                                   '%region' => $percentage_connected_to_internet_in_region},

                                           #'pageviews_region_per_month'                        => $pageviews_region_per_month,
                                           #'pageviews_region_per_month_per_user'               => $pageviews_region_per_month_per_user,
                                            'pageviews' =>   {'count'   => &Commas ($pageviews_region_per_month),
                                                              'per user' => $pageviews_region_per_month_per_user},

                                           #'~countries' => \@{$countries_per_region {$region_code_wivivi}}} ; # not 'countries', to sort this down in alpha keys list
                                            '~country_codes' => \@countries_codes} ; # not 'countries', to sort this down in alpha keys list
                                           #'country' => \%data_per_country }
  }
}


sub ReadDataPerLanguage
{
  my $csv_in = shift ;
  open CSV_VIEWS_PER_LANGUAGE, '<', $csv_in || die "Could not open input file '$csv_in'" ;

  my ($line,$lang_rank_name,$lang_rank,$lang_name,$lang_code,
      $speakers,$percentage_speakers_out_of_world_population,
      $language_pageviews_per_month,
      $breakdown_by_country,@countries_data,$country_data,$country_rank,$iso3,
      $dummy_country_name,$dummy_north_south,$dummy_continent,$country_pageviews_per_month,$percentage_country_pageviews) ;

  $line = <CSV_VIEWS_PER_LANGUAGE> ; # skip header
  while (my $line = <CSV_VIEWS_PER_LANGUAGE>)
  {
    next if $line =~ /^\s*$/ ; # skip empty lines
    last if ++ $unique_languages > $max_languages ;
    $line =~ s/<[^>]*>//g ; # remove html from data, like text colors (?)

    chomp $line ;
    ($lang_rank_name,$lang_code,$speakers,$percentage_speakers_out_of_world_population,$language_pageviews_per_month,$breakdown_by_country) = split (',', $line) ;

  # $lang_code = lc ($lang_code) ;
    ($lang_rank,$lang_name) = split (' ',$lang_rank_name) ;
    $lang_rank =~ s/\#// ;
    $lang_rank =~ s/:// ;

    @countries_data = split ('\|', $breakdown_by_country) ;

    $speakers                                     = &ExpandFigure ($speakers) ;
    $language_pageviews_per_month                 = &ExpandFigure ($language_pageviews_per_month) ;

    $percentage_speakers_out_of_world_population  =~ s/%.*$// ;


    my $count_countries = 0 ;
    foreach my $country_data (@countries_data)
    {
      last if ++$count_countries > $max_countries ;
      ($country_rank,$iso3,$dummy_country_name,$dummy_north_south,$dummy_continent,$country_pageviews_per_month,$percentage_country_pageviews) = split (':', $country_data) ;

print "XXX $country_data\n";
      $country_pageviews_per_month   = &ExpandFigure ($country_pageviews_per_month) ;
      $percentage_country_pageviews  =~ s/%.*$// ;
    }

    $json_languages {$lang_code} = {'name'     => $lang_name,
                                    'speakers_ranked' => $lang_rank,
                                    'speakers' => $percentage_speakers_out_of_world_population,
                                    'views'    => &Commas ($language_pageviews_per_month)} ;

  }
}

sub PatchMissingData
{
  $name_country {'AI'} = 'Anguilla' ;
  $name_country {'CI'} = 'Ivory Coast' ;
  $name_country {'CU'} = 'Curacao' ;
  $name_country {'SS'} = 'South Sudan' ;
  $name_country {'ST'} = 'Sao Tome and Principe' ;
  $name_country {'SX'} = 'Sint Maarten' ;
  $name_country {'TC'} = 'Turks and Caicos Islands' ;
  $name_country {'VG'} = 'British Virgin Islands' ;
  $name_country {'XX'} = 'Unknown' ;

  $code_region {'AI'} = 'CA' ;
  $code_region {'CI'} = 'AF' ;
  $code_region {'CU'} = 'CA' ;
  $code_region {'SS'} = 'AF' ;
  $code_region {'ST'} = 'AF' ;
  $code_region {'SX'} = 'NA' ;
  $code_region {'TC'} = 'CA' ;
  $code_region {'VG'} = 'CA' ;
  $code_region {'XX'} = '--' ;

  $name_region {'AI'} = 'Central America' ;
  $name_region {'CI'} = 'Africa' ;
  $name_region {'CU'} = 'Central America' ;
  $name_region {'SS'} = 'Africa' ;
  $name_region {'ST'} = 'Africa' ;
  $name_region {'SX'} = 'Central America' ;
  $name_region {'TC'} = 'Central America' ;
  $name_region {'VG'} = 'Central America' ;
  $name_region {'XX'} = 'Unknown' ;

  $code_north_south {'AI'} = 'S' ;
  $code_north_south {'CI'} = 'S' ;
  $code_north_south {'CU'} = 'S' ;
  $code_north_south {'SS'} = 'S' ;
  $code_north_south {'ST'} = 'S' ;
  $code_north_south {'SX'} = 'S' ;
  $code_north_south {'TC'} = 'S' ;
  $code_north_south {'VG'} = 'N' ;
  $code_north_south {'XX'} = '-' ;

}

sub ExpandFigure
{
  my $figure = shift ;

  return ('--') if ! defined $figure || $figure eq '' ;

  my ($count,$multiplier) = split ('\^', $figure) ;
  my $result = $figure ;

  if ((defined $multiplier) && ($multiplier ne ''))
  {
    if ($multiplier eq 'K') { $result = $count * 1000 ; }
    if ($multiplier eq 'M') { $result = $count * 1000000 ; }
    if ($multiplier eq 'B') { $result = $count * 1000000000 ; }
  }

# print "ExpandFigure - $figure = count $count / multiplier $multiplier -> result $result\n" ;
  return $result ;
}

sub Commas
{
  my $count = shift ; 

  if ($add_thousands_separator)
  {
    return '--' if ! defined ($count) || $count eq '' ;

    $count =~ s/(\d+)(\d\d\d)(\d\d\d)(\d\d\d)$/$1,$2,$3,$4/ ;
    $count =~ s/(\d+)(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
    $count =~ s/(\d+)(\d\d\d)$/$1,$2/ ;
  }

  return $count ;
}

sub Csv
{
  my $data = shift ;
  return "," if ! defined $data || $data eq '' || $data =~ /\^/ ;
  return "$data," ;

}


