#!/usr/bin/perl

  use LWP::Simple;                # From CPAN
  use JSON qw( decode_json );     # From CPAN
  use Data::Dumper;               # Perl core module
  use URI::Escape ;
  use Getopt::Std ;

  my @options ;
  getopt ("iol", \%options) ;

  die ("Specify input url as: -i url")         if (! defined ($options {"i"})) ;
  die ("Specify output folder as: -o path'")   if (! defined ($options {"o"})) ;
  die ("Specify folder for logs as: -l path'") if (! defined ($options {"l"})) ;

  $url_in   = $options {"i"} ;
  $path_out = $options {"o"} ;
  $path_log = $options {"l"} ;

  die "Output folder '$path_out' does not exist" if (! -d $path_out) ;
  die "Folder for logs '$path_log' does not exist" if (! -d $path_log) ;

  print "Input  url:      $url_in\n" ;
  print "Output folder:   $path_out\n" ;
  print "Folder for logs: $path_log\n" ;
  print "\n" ;

# my $url  = "http://tools.wmflabs.org/wikiloves/db.json";
  my $txt_log                     = "$path_log/wiki_loves_parse_json_log.txt";
  my $txt_warnings                = "$path_out/wiki_loves_parse_json_warnings.txt";

  my $csv_contest_countries       = "$path_out/wiki_loves_countries.csv";
  my $csv_contest_countries_users = "$path_out/wiki_loves_users.csv";
  my $csv_contest_countries_dates = "$path_out/wiki_loves_dates.csv";

  open    TXT_LOG, '>', $txt_log ;
  binmode TXT_LOG, ':utf8'  ;

  open    CSV_CONTEST_COUNTRIES, '>', $csv_contest_countries || die ("Could not open '$csv_contest_countries'") ;
  binmode CSV_CONTEST_COUNTRIES, ':utf8' ;
  print   CSV_CONTEST_COUNTRIES "year,contest,country,category,uploaders,..registered,uploads,..in_articles,start_time,end_time,start_date_excel,end_date_excel\n" ;

  open    CSV_CONTEST_COUNTRIES_USERS, '>', $csv_contest_countries_users || die ("Could not open '$csv_contest_countries_users'") ;
  binmode CSV_CONTEST_COUNTRIES_USERS, ':utf8'  ;
  print   CSV_CONTEST_COUNTRIES_USERS "year,contest,country,user,uploads,in_articles,reg_time,reg_date_excel\n" ;

  open    CSV_CONTEST_COUNTRIES_DATES, '>', $csv_contest_countries_dates || die ("Could not open '$csv_contest_countries_dates'") ;
  binmode CSV_CONTEST_COUNTRIES_DATES, ':utf8'  ;
  print   CSV_CONTEST_COUNTRIES_DATES "year,contest,country,uploads,date,date_excel\n" ;

  open    TXT_WARNINGS, '>', $txt_warnings || die ("Could not open '$txt_warnings'") ;
  binmode TXT_WARNINGS, ':utf8'  ;

  print "get $url\n" ;
  my $json = get( $url );
  print "done\n" ;
  die "Could not get $url!" unless defined $json;

  my ($name_contest, $name_country) ;

  print "decode json\n" ;
  my %decoded_json = %{decode_json($json)};
  print "done\n" ;
# print TXT_LOG Dumper $decoded_json ;

# while (my ($key, $value) = each %decoded_json)
# { print TXT_LOG "$key = $value\n"; }

  foreach $name_contest (sort keys %decoded_json)
  {
    &Log ("1 $name_contest\n") ;

    ($year_contest = $name_contest) =~ s/[^\d]//g ;
    ($name_contest_alpha = $name_contest) =~ s/\d//g ;

    %data_contest= %{$decoded_json{$name_contest}} ;
    foreach $name_country (sort keys %data_contest)
    {
      &Log ("2   $name_country = " . $data_contest {$name_country} . "\n") ;

    # %data_country = %{$decoded_json{$name_contest}{$name_country}} ;
      %data_country = %{$data_contest {$name_country}} ;
      foreach $key_country (sort keys %data_country)
      {
        &Log ("3     $key_country = " . $data_country {$key_country} . "\n") ;

        if ($key_country !~ /^(?:count|category|data|end|start|users|usercount|userreg|usage)$/)
        { &Warn ("3 unexpected key '$key_country' in contest '$name_contest', country '$name_country' -> abort\n") ; }
      }

      $cc_category   = &GetData ($data_country {'category'}) ;
      $cc_usercount  = &GetData ($data_country {'usercount'}) ;
      $cc_userreg    = &GetData ($data_country {'userreg'}) ;
      $cc_count      = &GetData ($data_country {'count'}) ;
      $cc_usage      = &GetData ($data_country {'usage'}) ;
      $cc_start_time = &GetData ($data_country {'start'}) ;
      $cc_end_time   = &GetData ($data_country {'end'}) ;

      $cc_start_date_excel  = '' ;
      $cc_end_date_excel    = '' ;

      if ($cc_start_time =~ /^\d{14}$/)
      { $cc_start_date_excel = "\"=DATE(" . substr ($cc_start_time,0,4) . ',' . substr ($cc_start_time,4,2) . ',' . substr ($cc_start_time,6,2) . ")\"" ; }
      else
      {
        &Warn ("Invalid or missing time field (start = '$cc_start_time') for contest '$name_contest', country '$name_country'\n") ;
        $cc_start_date_excel = '' ;
      }

      if ($cc_end_time =~ /^\d{14}$/)
      { $cc_end_date_excel    = "\"=DATE(" . substr ($cc_end_time,0,4)   . ',' . substr ($cc_end_time,4,2)   . ',' . substr ($cc_end_time,6,2)   . ")\"" ; }
      else
      {
        &Warn ("Invalid or missing time field (end = '$cc_end_time') for contest '$name_contest', country '$name_country'\n") ;
        $cc_end_date_excel = '' ;
      }

      print CSV_CONTEST_COUNTRIES "$year_contest,$name_contest_alpha,$name_country,$cc_category,$cc_usercount,$cc_userreg,$cc_count,$cc_usage,$cc_start_time,$cc_end_time,$cc_start_date_excel,$cc_end_date_excel\n" ;

      %dates = %{$data_country {'data'}} ;
      foreach $key_date (sort keys %dates)
      {
        $key_date_excel = "\"=DATE(" . substr ($key_date,0,4) . ',' . substr ($key_date,4,2) . ',' . substr ($key_date,6,2) . ")\"" ;
        print CSV_CONTEST_COUNTRIES_DATES "$year_contest,$name_contest_alpha,$name_country," . $dates {$key_date} . ",$key_date,$key_date_excel\n" ;
      }


      %names_users = %{$data_country {'users'}} ;
      foreach $name_user (sort keys %names_users)
      {
        $name_user_encoded  = $name_user ;
        $name_user_encoded  =~ s/ /_/g ;
        $name_user_encoded2 = $name_user_encoded ;
      # $name_user_encoded = uri_escape ($name_user_encoded) ;
        $name_user_encoded = uri_escape_utf8 ($name_user_encoded) ;
      # if ($name_user_encoded ne $name_user_encoded2)
      # { print "name '$name_user' -> '$name_user_encoded'\n" ; }

        &Log ("4       $name_user = " . $names_users {$name_user} . "\n") ;

        %data_user = %{$names_users {$name_user}} ;
        foreach $key_user (sort keys %data_user)
        {
          if ($key_user !~ /^(?:usage|count|reg)$/)
          { &Warn ("4 unexpected key '$key_user' in contest '$name_contest', country '$name_country', user '$name_user' -> abort\n") ; }
        }

        $user_count    = $decoded_json{$name_contest}{$name_country}{'users'}{$name_user} {'count'} ;
        $user_usage    = $decoded_json{$name_contest}{$name_country}{'users'}{$name_user} {'usage'} ;
        $user_reg_time = $decoded_json{$name_contest}{$name_country}{'users'}{$name_user} {'reg'} ;

        if ($user_reg_time =~ /^\d{14}$/)
        { $user_reg_date_excel = "\"=DATE(" . substr ($user_reg_time,0,4) . ',' . substr ($user_reg_time,4,2) . ',' . substr ($user_reg_time,6,2) . ")\"" ; }
        else
        {
          &Warn ("Invalid or missing time field (reg = '$user_reg_time') for contest '$name_contest', country '$name_country', user '$name_user'\n") ;
          $user_reg_time       = '' ;
          $user_reg_date_excel = '' ;
        }
        &Log ("5           $year_contest,$name_contest_alpha,$name_country,$name_user,$user_count,$user_usage,$user_reg_time\n") ;

        print CSV_CONTEST_COUNTRIES_USERS "$year_contest,$name_contest_alpha,$name_country,$name_user_encoded,$user_count,$user_usage,$user_reg_time,$user_reg_date_excel\n" ;
      }
    }
  }
  close TXT_LOG ;
  close CSV_CONTEST_COUNTRIES ;
  close CSV_CONTEST_COUNTRIES_USERS ;
  close CSV_CONTEST_COUNTRIES_DATES ;

  print "\nReady\n\n" ;
  exit ;


sub Log
{
  my $msg = shift ;

  if ($msg !~ /^[45]/) # too detailed
  { print $msg ; }

  print TXT_LOG $msg ;
}

sub Warn
{
  my $msg = shift ;
  &Log ($msg) ;
  $warnings {$msg} ++ ;

  print TXT_WARNINGS $msg ;

# if ($msg !~ /^Invalid/)
# { exit ; } # only during testing
}

sub GetData
{
  my $data = shift ;
  if ($data eq '')
  { return ('-') ; }
  if ($data =~ /[\;\,\=\'\"]/)
  { return ("\"$data\"") ; }

  return ($data) ;
}


