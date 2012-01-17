 #!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;

sub WriteOutputIpFrequencies
{
  trace WriteOutputIpFrequencies ;

  my $path_out = shift ;
  print "\ncd $path_out\n\n" ;
  chdir ($path_out) ;

  $comment = "# Data from $time_to_start till $time_to_stop (yyyy-mm-ddThh:mm:ss) - all counts in thousands due to sample rate of log (1 = 1000)\n" ;

  open  CSV_MULTIPLE_ADDRESSES, '>', $file_ip_frequencies ;
  print                        "# html pages found: $html_pages_found\n" ;
  print CSV_MULTIPLE_ADDRESSES "# html pages found: $html_pages_found\n" ;
  print CSV_MULTIPLE_ADDRESSES "#\n" ;

  foreach $address (keys %ip_frequencies)
  {
    $ip_distribution {$ip_frequencies {$address}} ++ ;
  }

  $ip_distribution_ge_2     = 0 ;
  $ip_distribution_ge_3     = 0 ;
  $ip_distribution_ge_4     = 0 ;
  $ip_distribution_ge_5     = 0 ;
  $ip_distribution_ge_10    = 0 ;
  $ip_distribution_ge_20    = 0 ;
  $ip_distribution_ge_50    = 0 ;
  $ip_distribution_ge_100   = 0 ;
  $ip_distribution_ge_250   = 0 ;
  $ip_distribution_ge_1000  = 0 ;
  $ip_distribution_ge_2500  = 0 ;
  $ip_distribution_ge_10000 = 0 ;

  foreach $frequency (sort {$a <=> $b} keys %ip_distribution)
  {
    $metafreq = $ip_distribution {$frequency} ;
    if ($frequency >= 2)     { $ip_distribution_ge_2     += $metafreq ; }
    if ($frequency >= 3)     { $ip_distribution_ge_3     += $metafreq ; }
    if ($frequency >= 4)     { $ip_distribution_ge_4     += $metafreq ; }
    if ($frequency >= 5)     { $ip_distribution_ge_5     += $metafreq ; }
    if ($frequency >= 10)    { $ip_distribution_ge_10    += $metafreq ; }
    if ($frequency >= 20)    { $ip_distribution_ge_20    += $metafreq ; }
    if ($frequency >= 50)    { $ip_distribution_ge_50    += $metafreq ; }
    if ($frequency >= 100)   { $ip_distribution_ge_100   += $metafreq ; }
    if ($frequency >= 250)   { $ip_distribution_ge_250   += $metafreq ; }
    if ($frequency >= 1000)  { $ip_distribution_ge_1000  += $metafreq ; }
    if ($frequency >= 2500)  { $ip_distribution_ge_2500  += $metafreq ; }
    if ($frequency >= 10000) { $ip_distribution_ge_10000 += $metafreq ; }
    if ($frequency > 20) { next ; }
    print                        "# $metafreq addresses occur $frequency times\n" ;
    print CSV_MULTIPLE_ADDRESSES "# $metafreq addresses occur $frequency times\n" ;
  }

  print CSV_MULTIPLE_ADDRESSES "#\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_2 addresses occur 2+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_3 addresses occur 3+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_4 addresses occur 4+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_5 addresses occur 5+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_10 addresses occur 10+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_20 addresses occur 20+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_50 addresses occur 50+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_100 addresses occur 100+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_250 addresses occur 250+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_1000 addresses occur 1000+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_2500 addresses occur 2500+ times\n" ;
  print CSV_MULTIPLE_ADDRESSES "# $ip_distribution_ge_10000 addresses occur 10000+ times\n" ;

  foreach $address (sort {$ip_frequencies {$b} <=> $ip_frequencies {$a}} keys %ip_frequencies)
  {
    $frequency = $ip_frequencies {$address} ;
  # print "$freq,$address\n" ;
    if ($frequency > 1)
    { print CSV_MULTIPLE_ADDRESSES "$frequency,$address\n" ; }
  }

  close CSV_MULTIPLE_ADDRESSES ;

  if ($job_runs_on_production_server)
  {
    $cmd = "bzip2 -f $file_ip_frequencies" ;
    print "\ncmd = '$cmd'\n" ;
    `$cmd` ;
  }
}

sub WriteOutputSquidSequenceGaps
{
  trace WriteOutputSquidSequenceGaps ;

  my $path_out = shift ;
  print "\ncd $path_out\n\n" ;
  chdir ($path_out) ;

  my ($tot_events_all_day, $tot_delta_all_day, %all_squids_events, %all_squids_delta, %squids, $tot_squids) ;

  $yyyy = substr ($time_to_start,0,4) ;
  $mm   = substr ($time_to_start,5,2) ;
  $dd   = substr ($time_to_start,8,2) ;
  $date = substr ($time_to_start,0,10) ;
  $date_excel = "\"=DATE($yyyy,$mm,$dd)\"" ;

  open  CSV_SEQNO_PER_SQUIDHOUR, '>', $file_seqno_per_squidhour ;
  print CSV_SEQNO_PER_SQUIDHOUR  "squid,hour,events,tot delta,avg delta\n" ;

  $squid_hour = 0 ;
  foreach $squid_hour (sort keys %squid_events)
  {
    $events    = $squid_events {$squid_hour} ;
    next if $events == 0 ;

    $delta     = $squid_delta  {$squid_hour} ;
    $avg_delta = sprintf ("%.0f", $delta / $events) ;

    print CSV_SEQNO_PER_SQUIDHOUR "$squid_hour,$events,$delta,$avg_delta\n" ;
    print                         "$squid_hour,$events,$delta,$avg_delta\n" ;

    $tot_events_all_day += $events ;
    $tot_delta_all_day  += $delta ;
    ($squid,$hour) = split (',', $squid_hour) ;
    $squids {$squid} ++ ;

    $all_squids_events {$hour} += $events ;
    $all_squids_delta  {$hour} += $delta ;
  }

  foreach $squid (keys %squids)
  { $tot_squids++ ; }


  if ($tot_events_all_day > 0)
  {
    $avg_delta_all_day = sprintf ("%.0f", $tot_delta_all_day / $tot_events_all_day) ;
    $tot_events_all_day_corrected = sprintf ("%.0f", ($avg_delta_all_day / 1000) * $tot_events_all_day) ;

    print CSV_SEQNO_PER_SQUIDHOUR "# Squids: $tot_squids Events: $tot_events_all_day Avg delta: $avg_delta_all_day\n\n" ;
    print                         "\nSquids: $tot_squids\nEvents: $tot_events_all_day\nAvg delta: $avg_delta_all_day\n\n" ;
  }
  else
  {
    print CSV_SEQNO_PER_SQUIDHOUR "# Squids: $tot_squids Events: 0\n\n" ;
    print                         "\nSquids: $tot_squids\nEvents: 0\n\n" ;
  }
  close CSV_SEQNO_PER_SQUIDHOUR ;

  # now same thing for all squids combined, hourly

  undef @csv ;

  open  CSV_SEQNO_ALL_SQUIDS_DAY, '>', $file_seqno_all_squids ;
  print CSV_SEQNO_ALL_SQUIDS_DAY  "date,time,events,avg delta seqno\n" ;

  open  CSV_SEQNO_ALL_SQUIDS_MONTH, '<', "../$file_seqno_all_squids" ;
  while ($line = <CSV_SEQNO_ALL_SQUIDS_MONTH>)
  {
    next if $line =~ /^$date/ ;
    next if $line =~ /^date/ ;
    push @csv, $line ;
  }
  close CSV_SEQNO_ALL_SQUIDS_MONTH ;

  open  CSV_SEQNO_ALL_SQUIDS_MONTH, '>', "../$file_seqno_all_squids" ;
  print CSV_SEQNO_ALL_SQUIDS_MONTH  "date,time,events (x 1000),avg delta seqno,date excel,events corrected (x 1000)\n" ;
  foreach $line (sort @csv)
  { print CSV_SEQNO_ALL_SQUIDS_MONTH $line ; }

  $hour = '' ;
  foreach $hour (sort keys %all_squids_events)
  {
    $avg_delta = 0 ;
    $events    = $all_squids_events {$hour} ;
    $delta     = $all_squids_delta  {$hour} ;
    if ($events > 0)
    { $avg_delta = sprintf ("%.0f", $delta / $events) ; }

    print CSV_SEQNO_ALL_SQUIDS_DAY   "$date,$hour,$events,$avg_delta\n" ;
    print CSV_SEQNO_ALL_SQUIDS_MONTH "$date,$hour,$events,$avg_delta\n" ;
    print                            "$date,$hour,$events,$avg_delta\n" ;
  }

  print CSV_SEQNO_ALL_SQUIDS_MONTH "$date,*,$tot_events_all_day,$avg_delta_all_day,$date_excel,$tot_events_all_day_corrected\n" ;
  print                            "$date,*,$tot_events_all_day,$avg_delta_all_day,$tot_events_all_day_corrected\n" ;

  close CSV_SEQNO_ALL_SQUIDS_DAY ;
  close CSV_SEQNO_ALL_SQUIDS_MONTH ;
}

sub WriteOutputSquidLogs
{
  trace WriteOutputSquidLogs ;

  my $path_out = shift ;
  print "\ncd $path_out\n\n" ;
  chdir ($path_out) ;

  $comment = "# Data from $time_to_start till $time_to_stop (yyyy-mm-ddThh:mm:ss) - all counts in thousands due to sample rate of log (1 = 1000)\n" ;

  open CSV_METHODS,         '>', $file_csv_methods ;
  open CSV_SKINS,           '>', $file_csv_skins ;
  open CSV_SCRIPTS,         '>', $file_csv_scripts ;
  open CSV_IMAGES,          '>', $file_csv_images ;
  open CSV_BANNERS,         '>', $file_csv_banners ;
  open CSV_BINARIES,        '>', $file_csv_binaries ;
  open CSV_EXTENSIONS,      '>', $file_csv_extensions ;
  open CSV_REQUESTS,        '>', $file_csv_requests ;
  open CSV_REQUESTS_WAP,    '>', $file_csv_requests_wap ;
  open CSV_REQUESTS_M,      '>', $file_csv_requests_m ;
  open CSV_ORIGINS,         '>', $file_csv_origins ;
  open CSV_SEARCH,          '>', $file_csv_search ;
  open CSV_BOTS,            '>', $file_csv_bots ;
  open CSV_GOOGLEBOTS,      '>', $file_csv_googlebots ;
  open CSV_OPSYS,           '>', $file_csv_opsys ;
  open CSV_CLIENTS,         '>', $file_csv_clients ;
  open CSV_LANGUAGES,       '>', $file_csv_languages ;
  open CSV_COUNTRIES_VIEWS, '>', $file_csv_countries_views ;
  open CSV_COUNTRIES_SAVES, '>', $file_csv_countries_saves ;
  open CSV_COUNTRIESTIMED,  '>', $file_csv_countries_timed ;
  open OUT_REFERERS,        '>', $file_out_referers ;
  open CSV_CLIENTS_BY_WIKI, '>', $file_csv_clients_by_wiki ;
  open CSV_AGENTS,          '>', $file_csv_agents ;

  print CSV_METHODS         $comment ;
  print CSV_SKINS           $comment ;
  print CSV_SCRIPTS         $comment ;
  print CSV_IMAGES          $comment ;
  print CSV_BANNERS         $comment ;
  print CSV_BINARIES        $comment ;
  print CSV_EXTENSIONS      $comment ;
  print CSV_REQUESTS        $comment ;
  print CSV_REQUESTS_WAP    $comment ;
  print CSV_REQUESTS_M      $comment ;
  print CSV_ORIGINS         $comment ;
  print CSV_SEARCH          $comment ;
  print CSV_BOTS            $comment ;
  print CSV_GOOGLEBOTS      $comment ;
  print CSV_OPSYS           $comment . "# mobile: $tags_mobile ($tags_mobile_upd)\n" .
                                      "# pos 1: - = non mobile, M = mobile ('-'+'M'=100%), G = aggregated Group\n" ;
  print CSV_CLIENTS         $comment ;
  print CSV_LANGUAGES       $comment ;
  print CSV_COUNTRIES_VIEWS $comment ;
  print CSV_COUNTRIES_SAVES $comment ;
  print CSV_COUNTRIESTIMED  $comment ;
  print OUT_REFERERS        $comment ;
  print CSV_CLIENTS_BY_WIKI $comment ;
  print CSV_AGENTS          $comment ;

  # CSV_METHODS
  print OUT "\nMETHODS:\n\n" ;
  print     "\nMethods:\n\n" ;
  $method_all = 0 ;
  foreach $key (sort keys %statusses)
  {
    if ($key =~ /:total/)
    {
      $total = $statusses {$key} ;
      $method_all += $total ;
      ($method = $key) =~ s/:.*$// ;
      print OUT sprintf ("%-8s", "$method:") . sprintf ("%6d",$total) . "\n" ;
      print     sprintf ("%-8s", "$method:") . sprintf ("%6d",$total) . "\n" ;
    }
  }
  print OUT "TOTAL:  " . sprintf ("%6d",$method_all) . "\n" ;
  print     "TOTAL:  " . sprintf ("%6d",$method_all) . "\n" ;

  print CSV_METHODS ":method,status,count\n" ;
  foreach $key (sort keys %statusses)
  {
    if ($key =~ /:total/)
    {
      $total = $statusses {$key} ;
      ($method = $key) =~ s/:.*$// ;
    }
    else
    {
      $total = $statusses {$key} ;

      print OUT sprintf ("%6d",$total) . " : " . $key . "\n" ;
      $key2 = $key ;
      $key2 =~ s/,/&comma;/g ;
      $key2 =~ s/\:/,/g ;
      print CSV_METHODS "$key2,$total\n" ;
    }
  }

  # CSV_SKINS
  print OUT "\nSKINS:\n\n" ;
  print CSV_SKINS ":scripts,parameters,count\n" ;
  $total_skins = 0 ;
  foreach $key (sort keys %skins)
  {
    $total = $skins{$key} ;
    $total_skins += $total ;
    print OUT sprintf ("%5d",$total) . " : " . $key . "\n" ;
    print CSV_SKINS "$key,$total\n" ;
  }
  print OUT sprintf ("%5d",$total_skins) . " : total\n" ;

  # CSV_SCRIPTS
  print OUT "\nSCRIPTS:\n\n" ;
  print CSV_SCRIPTS ":scripts,parameters,count\n" ;
  foreach $key (sort keys %scripts)
  {
    print OUT sprintf ("%5d",$scripts{$key}) . " : " . $key . "\n" ;
    print CSV_SCRIPTS "$key,${scripts{$key}}\n" ;
  }

  print OUT "\nSCRIPTS NO FURTHER PROCESSED:\n\n" ;
  foreach $key (sort keys %scripts_no_further_processing)
  {
    print OUT sprintf ("%5d",$scripts_no_further_processing{$key}) . " : " . $key . "\n" ;
  }

  # CSV_IMAGES
  print OUT "\nIMAGE SIZES:\n\n" ;
  print CSV_IMAGES ":size range,count\n" ;
  foreach $range (sort keys %imagesizes)
  {
    ($range2 = $range) =~ s/ //g ;
    $count = $imagesizes {$range} ;
    print OUT sprintf ("%5d",$count) . " : $range\n" ;
    print CSV_IMAGES "$range2,$count\n" ;
  }

  # CSV_BANNERS
  print OUT "\nBANNERS:\n\n" ;
  print CSV_BANNERS ":country,url\n" ;
  foreach $key (sort {$banners {$b} <=> $banners {$a}} keys %banners)
  {
    print OUT sprintf ("%5d",$banners{$key}) . " : " . $key . "\n" ;
    print CSV_BANNERS "$key,${banners{$key}}\n" ;
  }

  # CSV_BINARIES
  print OUT "\nBINARIES:\n\n" ;
  print CSV_BINARIES ":file,count\n" ;
  $cnt_binaries = 0 ;
  foreach $key (sort {$binaries {$b} <=> $binaries {$a}} keys %binaries)
  {
    if (++$cnt_binaries <= 500)
    { print OUT sprintf ("%5d",$binaries{$key}) . " : " . $key . "\n" ; }

    print CSV_BINARIES "$key,${binaries{$key}}\n" ;
  }
  # print OUT "\nImages:\n\n" ;
  # print CSV_IMAGES ":project,referer,ext,mime,parms,count\n" ;

  foreach $key (sort keys %images_xref)
  {
    print OUT sprintf ("%5d",$images_xref{$key}) . " : " . $key . "\n" ;
  #  $key2 = $key ;
  #  $key2 =~ s/,/&comma;/g ;
  #  $key2 =~ s/\|/,/g ;
  #  push @csv, "$key2,${requests{$key}}" ;
  }
  #@csv =sort @csv ;
  #foreach $line (@csv)
 #{ print CSV_REQUESTS "$line\n" ; }

  # CSV_EXTENSIONS
  print OUT "\nEXTENSIONS:\n\n" ;
  print     "\nExtensions:\n\n" ;
  print CSV_EXTENSIONS ":extension,count\n" ;
  $total = 0 ;
  foreach $key (sort {$exts {$b} <=> $exts {$a}} keys %exts)
  {
    $count = $exts {$key} ;
    $total += $count ;
    print OUT sprintf ("%6d",$count) . " : $key\n" ;
    print     sprintf ("%6d",$count) . " : $key\n" ;
    print CSV_EXTENSIONS "$key,$count\n" ;
  }
  print OUT sprintf ("%6d",$total) . " : total\n" ;
  print     sprintf ("%6d",$total) . " : total\n" ;

  # CSV_REQUESTS
  undef @csv ;
  print OUT "\nREQUESTS:\n\n" ;
  print CSV_REQUESTS $legend ;
  print CSV_REQUESTS ":project,referer,ext,mime,parms,count\n" ;
  foreach $key (sort keys %requests)
  {
    print OUT sprintf ("%5d",$requests{$key}) . " : " . $key . "\n" ;
    $key2 = $key ;
    $key2 =~ s/,/&comma;/g ;
    $key2 =~ s/\|/,/g ;
    push @csv, "$key2,${requests{$key}}" ;
  }
  @csv = sort @csv ;
  foreach $line (@csv)
  { print CSV_REQUESTS "$line\n" ; }

  # CSV_REQUESTS_WAP
  undef @csv ;
  print OUT "\nREQUESTS_WAP:\n\n" ;
  print CSV_REQUESTS_WAP $legend ;
  print CSV_REQUESTS_WAP ":project,ext,mime,parms,country,count\n" ;
  foreach $key (sort keys %requests_wap)
  {
    print OUT sprintf ("%5d",$requests_wap{$key}) . " : " . $key . "\n" ;
    $key2 = $key ;
    $key2 =~ s/,/&comma;/g ;
    $key2 =~ s/\|/,/g ;
    push @csv, "$key2,${requests_wap{$key}}" ;
  }
  @csv = sort @csv ;
  foreach $line (@csv)
  { print CSV_REQUESTS_WAP "$line\n" ; }

  # CSV_REQUESTS_M
  undef @csv ;
  print OUT "\nREQUESTS_M:\n\n" ;
  print CSV_REQUESTS_M $legend ;
  print CSV_REQUESTS_M ":project,ext,mime,parms,country,count\n" ;
  foreach $key (sort keys %requests_m)
  {
    print OUT sprintf ("%5d",$requests_m{$key}) . " : " . $key . "\n" ;
    $key2 = $key ;
    $key2 =~ s/,/&comma;/g ;
    $key2 =~ s/\|/,/g ;
    push @csv, "$key2,${requests_m{$key}}" ;
  }
  @csv = sort @csv ;
  foreach $line (@csv)
  { print CSV_REQUESTS_M "$line\n" ; }

  # CSV_BOTS
  foreach $key (sort {$bots {$b} <=> $bots {$a}} keys %bots)
  { print CSV_BOTS $bots{$key} . ",$key\n" ; }

  # CSV_GOOGLEBOTS
  print CSV_GOOGLEBOTS "# Hits for googlebot from Google ip address\n" ;
  print CSV_GOOGLEBOTS ":date,:ip range,:hits\n" ;
  foreach $key (sort {$a cmp $b} keys %google_bot_hits)
  {
    my $year = substr ($key,0,4) ;
    my $mon  = substr ($key,5,2) ;
    my $mday = substr ($key,8,2) ;
    my $hour = substr ($key,11,2) ;
    my $date = "$year/$mon/$mday $hour:00:00" ;
    my $iprange = $key ;
    $iprange =~ s/^[^,]*,// ;

    print CSV_GOOGLEBOTS "$date,$iprange,${google_bot_hits{$key}}\n" ;
  }

  #print OUT "\nUrls:\n" ;
  #foreach $key (sort keys %urls)
  #{ print OUT sprintf ("%5d",$urls{$key}) . " : " . $key . "\n" ; }

  # OUT_INTERWIKI
  print OUT "\nINTERWIKI:\n\n" ;
  foreach $key (sort keys %interwiki)
  { print OUT sprintf ("%5d",$interwiki{$key}) . " : " . $key . "\n" ; }

  print OUT "\nREFERER UPLOAD:\n\n" ;
  foreach $key (sort keys %referer_upload)
  { print OUT sprintf ("%5d",$referer_upload{$key}) . " : " . $key . "\n" ; }

  # OUT_REFERERS
  print OUT_REFERERS $legend ;
  print OUT_REFERERS  "referer,count\n" ;

  print OUT_REFERERS  "# internal\n" ;
  foreach $key (sort keys %referers_internal)
  { print OUT_REFERERS sprintf ("%5d",$referers_internal{$key}) . " : " . $key . "\n" ; }

  print OUT_REFERERS  "# external\n" ;
  foreach $key (sort {$origins_external {$b} <=> $origins_external {$a} } keys %origins_external)
  { print OUT_REFERERS sprintf ("%5d",$origins_external{$key}) . " : " . $key . "\n" ; }

  print OUT_REFERERS  "# unsimplified\n" ;
  foreach $key (sort keys %origins_unsimplified)
  { print OUT_REFERERS sprintf ("%5d",$origins_unsimplified{$key}) . " : " . $key . "\n" ; }

  print OUT_REFERERS  "# simplified\n" ;
  foreach $key (sort keys %origin_simplified)
  { print OUT_REFERERS sprintf ("%5d",$origin_simplified{$key}) . " : " . $key . "\n" ; }

  print               "\nLook alikes:\n\n" ;
  print OUT_REFERERS  "# look alikes\n" ;
  foreach $key (sort {$wikis {$b} <=> $wikis {$a}} keys %wikis)
  {
    print OUT_REFERERS sprintf ("%5d",$wikis{$key}) . " : " . $key . "\n" ;
    print              sprintf ("%5d",$wikis{$key}) . " : " . $key . "\n" ;
  }

  # CSV_ORIGINS
  print OUT "\nORIGINS:\n\n" ;
  print CSV_ORIGINS  ":toplevel,count\n" ;
  foreach $key (sort keys %origins)
  {
    print OUT sprintf ("%8d",$origins{$key}) . " : " . $key . "\n" ;
    print CSV_ORIGINS "$key,${origins{$key}}\n" ;
  }

  # CSV_SEARCH
  print OUT "\nSEARCHES:\n" ;
  print CSV_SEARCH ":matches (ip range|referer|agent string),site,referer group,bot,agent match,mime group,top level domain,count\n" ;
  foreach $key (sort keys %search)
  {
    print OUT sprintf ("%8d",$search{$key}) . " : " . $key . "\n" ;
    print CSV_SEARCH "$key,${search{$key}}\n" ;
  }

  # CSV_LANGUAGES
  print OUT "\nLANGUAGES:\n\n" ;
  print CSV_LANGUAGES  ":browser,:language,:count\n" ;
  foreach $key (sort keys %languages)
  {
    print OUT sprintf ("%8d",$languages{$key}) . " : " . $key . "\n" ;
    print CSV_LANGUAGES "$key,${languages{$key}}\n" ;
  }

  #print OUT "\nSources:\n\n" ;
  #foreach $key (sort keys %srcs)
  #{ print OUT sprintf ("%5d",$srcs{$key}) . " : " . $key . "\n" ; }

  print OUT "\nGOOGLE BOTS:\n\n" ;
  foreach $key (sort keys %googlebots)
  { print OUT sprintf ("%5d",$googlebots{$key}) . " : " . $key . "\n" ; }

  print OUT "\nGOOGLE BINS:\n\n" ;
  print     "\nGoogle bins:\n\n" ;
  foreach $key (sort {$googlebins {$b} <=> $googlebins {$a}} keys %googlebins)
  {
    print OUT sprintf ("%5d",$googlebins{$key}) . " : " . $key . "\n" ;
    print     sprintf ("%5d",$googlebins{$key}) . " : " . $key . "\n" ;
  }

  print OUT "\nGOOGLE BINS 2:\n\n" ;
  print     "\nGoogle bins 2:\n\n" ;
  foreach $key (sort {$googlebins2 {$b} <=> $googlebins2 {$a}} keys %googlebins2)
  {
    print OUT sprintf ("%5d",$googlebins2{$key}) . " : " . $key . "\n" ;
    print     sprintf ("%5d",$googlebins2{$key}) . " : " . $key . "\n" ;
  }

  print OUT "\nDOMAIN ERRORS:\n\n" ;
  foreach $key (sort { $domain_errors {$b} <=> $domain_errors {$a}} keys %domain_errors)
  { print OUT sprintf ("%5d",$domain_errors{$key}) . " : " . $key . "\n" ; }

  print OUT "\nUNRECOGNIZED GOOGLE AGENTS:\n\n" ;
  foreach $key (sort { $googleagents {$b} <=> $googleagents {$a}} keys %googleagents)
  { print OUT sprintf ("%5d",$googleagents{$key}) . " : " . $key . "\n" ; }

  print OUT "\nGOOGLE LOOK ALIKES:\n\n" ;
  foreach $key (sort { $google_imposters {$b} <=> $google_imposters {$a}} keys %google_imposters)
  { print OUT sprintf ("%5d",$google_imposters{$key}) . " : " . $key . "\n" ; }

  print OUT "\nYAHOO BOTS:\n\n" ;
  foreach $key (sort keys %yahoobots)
  { print OUT sprintf ("%5d",$yahoobots{$key}) . " : " . $key . "\n" ; }

  if ($count_hits_per_ip_range)
  {
    print OUT "\nIP ACTIVITY BY COUNT:\n\n" ;
    foreach $key (sort {$cnt_ip_ranges {$b} <=> $cnt_ip_ranges {$a}}keys %cnt_ip_ranges)
    {
      if ($cnt_ip_ranges {$key} >= 10)
      { print OUT sprintf ("%5d",$cnt_ip_ranges{$key}) . " : " . $key . "\n" ; }
    }
  }

  print OUT "\nIP ACTIVITY BY ADDRESS:\n\n" ;
  foreach $key (sort keys %cnt_ip_ranges)
  {
    if ($cnt_ip_ranges {$key} >= 10)
    { print OUT sprintf ("%5d",$cnt_ip_ranges{$key}) . " : " . $key . "\n" ; }
  }

  print OUT2 "\nOPERATING SYSTEMS:\n\n" ;
  print CSV_OPSYS ":rectype,opsys,count\n" ;
  $total_operating_systems = 0 ;

  foreach $key (keys %operating_systems)
  { $total_operating_systems += $operating_systems{$key} ; }

  print OUT2 "\nTOTAL_OPERATING_SYSTEMS: $total_operating_systems\n\n" ;
  foreach $key (sort keys %operating_systems)
  {
    my $count = $operating_systems {$key} ;
    my $count2 = sprintf ("%5d",$count) ;
    my $perc1 = sprintf ("%6.2f",(100*$count/$total_operating_systems)) . "%" ;
    my $perc2 = sprintf ("%.2f",(100*$count/$total_operating_systems)) . "%" ;

    if ($count >= 1)
    { print OUT2 "$count2 = $perc1: $key \n" ; }

    print CSV_OPSYS "$key,$count,$perc2\n" ;
  }
  print OUT2 "\nOPERATING SYSTEMS GROUPED:\n\n" ;
  $total_operating_systems_printed = 0 ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "BlackBerry") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "DoCoMo") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "FreeBSD") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "iPad") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "iPhone") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "Linux") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "Mac") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "OpenBSD") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "SunOS") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "SymbianOS") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "Windows") ;
  print OUT2 sprintf ("%6d",$total_operating_systems_printed) . "=" . sprintf ("%5.2f",(100*$total_operating_systems_printed/$total_operating_systems)) . "% : Total\n\n" ;

  @LinuxVersions = split (',', 'Android,Xubuntu,Kubuntu,Ubuntu,Gentoo,PCLinuxOS,CentOS,Oracle,Mandriva,Red Hat,Mandriva,openSUSE,SUSE,Fedora,Epiphany,Mint,Mips,Arch,Debian,Slackware,Motor,Other') ;

  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "Mac Intel") ;
  &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "Mac PowerPC") ;

  foreach $LinuxVersion (@LinuxVersions)
  { &WriteOutputLineToCsvSharePerOs  ($total_operating_systems, "Linux $LinuxVersion") ; }


  print OUT2 "\nCLIENTS:\n\n" ;
  print CSV_CLIENTS ":mobile,engine,client,mime-cat\n" ;
  $total_clients = 0 ;
  foreach $key (keys %clients)
  {
    ($mobile,$version,$mimecat) = split (',', $key) ;
    print OUT2 "\%CLIENTS: '$mobile','$version','$mimecat': " . $clients{$key} . "\n" ;
    $total_clients {$mimecat} += $clients{$key} ;
    $version =~ s/ .*$// ;
    $version =~ s/\/.*$// ;
    $version =~ s/,/&comma;/g ;
    $group = "$mobile,$version,$mimecat" ;
    $grouped_clients {$group} += $clients{$key} ;
  }
  foreach $key (sort keys %clients)
  {
    ($mobile,$version,$mimecat) = split (',', $key) ;
    my $count = $clients {$key} ;
    my $count2 = sprintf ("%5d",$count) ;
    my $perc1 = sprintf ("%6.2f",(100*$count/$total_clients {$mimecat})) . "%" ;
    my $perc2 = sprintf ("%.2f" ,(100*$count/$total_clients {$mimecat})) . "%" ;

    if ($clients {$key} >= 3)
    { print OUT2 "$count2 = $perc1: $key\n" ; }

    print CSV_CLIENTS "$key,$count,$perc2\n" ;
  }
  foreach $key (sort keys %engines)
  {
    my $count = $engines {$key} ;
    print CSV_CLIENTS "E,$key,$count\n" ;
  }
  foreach $key (sort keys %grouped_clients)
  {
    ($group,$version,$mimecat) = split (',', $key) ;
    my $count = $grouped_clients {$key} ;
    my $perc2 = sprintf ("%.2f",(100*$count/$total_clients {$mimecat})) . "%" ;
    print CSV_CLIENTS "G,$key,$count,$perc2\n" ;
  }

  print OUT2 "\nCLIENTS BY WIKI:\n\n" ;
  print CSV_CLIENTS_BY_WIKI ":mobile,client,mime-cat\n" ;
  $total_clients = 0 ;
  foreach $key (keys %clients_by_wiki)
  { $total_clients += $clients_by_wiki{$key} ; }

  foreach $key (sort keys %clients_by_wiki)
  {
    my $count = $clients_by_wiki {$key} ;
    my $count2 = sprintf ("%5d",$count) ;
    my $perc1 = sprintf ("%6.2f",(100*$count/$total_clients)) . "%" ;
    my $perc2 = sprintf ("%.2f",(100*$count/$total_clients)) . "%" ;
    if ($clients_by_wiki {$key} >= 3)
    { print OUT2 "$count2 = $perc1: $key\n" ; }
    ($mobile,$version,$domain,$mimecat) = split (',', $key) ;
    $domain = ExpandAbbreviation ($domain) ;
    $domain =~ s/:/,/ ;
    $domain =~ s/\&nbsp;/--/ ;
    print CSV_CLIENTS_BY_WIKI "$mobile,$version,$domain,$mimecat,$count,$perc2\n" ;
  }

  foreach $key (sort keys %grouped_clients_by_wiki)
  {
    my $count = $grouped_clients_by_wiki {$key} ;
    my $perc2 = sprintf ("%.2f",(100*$count/$total_clients)) . "%" ;
    print CSV_CLIENTS_BY_WIKI "G,$key,$count,$perc2\n" ;
  }

  print OUT2 "\nGOOGLEBOT NOT FROM GOOGLE\n\n" ;
  foreach $key (sort keys %ip_bot_no_google)
  {
    if ($ip_bot_no_google {$key} >= 3)
    { print OUT2 sprintf ("%5d",$ip_bot_no_google{$key}) . " : " . $key . "\n" ; }
  }

  print OUT2 "\nMOBILE OTHER\n\n" ;
  foreach $key (sort keys %mobile_other)
  { print OUT2 sprintf ("%5d",$mobile_other{$key}) . " : " . $key . "\n" ; }

  foreach $key (sort keys %countries_views)
  {
    my $count = $countries_views {$key} ;
    print CSV_COUNTRIES_VIEWS "$key,$count\n" ;
  }

  foreach $key (sort keys %countries_saves)
  {
    my $count = $countries_saves {$key} ;
    print CSV_COUNTRIES_SAVES "$key,$count\n" ;
    print "$key,$count\n" ;
  }

  foreach $key (sort keys %countries_timed)
  {
    my $count = $countries_timed {$key} ;
    print CSV_COUNTRIESTIMED "$key,$count\n" ;
  }

 foreach $key (keys_sorted_by_value_num_desc %agents_raw)
 {
   my $count = $agents_raw {$key} ;
   $key =~ s/,/;/g ;
   next if $count < 5 ;
   print CSV_AGENTS "$key,$count\n" ;
 }

  close CSV_METHODS ;
  close CSV_SKINS ;
  close CSV_SCRIPTS ;
  close CSV_IMAGES ;
  close CSV_BANNERS ;
  close CSV_BINARIES ;
  close CSV_EXTENSIONS ;
  close CSV_REQUESTS ;
  close CSV_ORIGINS ;
  close CSV_SEARCH ;
  close CSV_BOTS ;
  close CSV_GOOGLEBOTS ;
  close CSV_OPSYS ;
  close CSV_LANGUAGES ;
  close CSV_COUNTRIES_VIEWS ;
  close CSV_COUNTRIES_SAVES ;
  close CSV_COUNTRIESTIMED ;
  close CSV_CLIENTS ;
  close CSV_CLIENTS_BY_WIKI ;
  close OUT_REFERERS ;
  close CSV_AGENTS ;
}

sub WriteOutputEditsSavesFile
{
  trace WriteOutputEditsSavesFile ;

  my $path_out = shift ;
  print "\ncd $path_out\n\n" ;
  chdir ($path_out) ;

  $comment = "# Data from $time_to_start till $time_to_stop (yyyy-mm-ddThh:mm:ss) - all counts in thousands due to sample rate of log (1 = 1000)\n" ;

# $comment = "# Data from $time_to_start till $time_to_stop (yyyy-mm-ddThh:mm:ss) - all counts in thousands due to sample rate of log (1 = 1000)\n" ;

  # only keep edits/submits for ip addresses which occur only once in this hash (stands for avg. 2000 hits)
  foreach $key (keys %client_ip_record_cnt)
  { $client_ip_record_cnt_total {$client_ip_record_cnt {$key}}++ ; }

  print "\n\nEdit submit lines:\n" ;
  foreach $key (sort {$b <=> $a} keys %client_ip_record_cnt_total)
  {
    print sprintf ("%5d", $client_ip_record_cnt_total {$key}) . " ip address(es) occur $key times\n" ;
    $lines_edit_submit_total +=  $key * $client_ip_record_cnt_total {$key} ;
  }
  print "Total edit submit lines: $lines_edit_submit_total\n\n" ;

  foreach $key (keys %index_php_raw)
  {
    ($client_ip,$key2) = split (',', $key, 2) ;
    if ($client_ip_record_cnt {$client_ip} < 2)
    {
      $index_php {$key2}    += $index_php_raw {$key} ;
      $edit_submit_filtered += $index_php_raw {$key} ;
    }
  }
  undef %index_php_raw ;

  open CSV_INDEXPHP, '>', "$path_out/$file_csv_indexphp" ;

  print CSV_INDEXPHP $comment ;
  foreach $key (sort {$index_php {$b} <=> $index_php {$a}} keys %index_php)
  {
    print CSV_INDEXPHP "$key,${index_php {$key}}\n" ;
    $lines_edit_submit_filtered ++ ;
  }
  print "Filtered edits+submits: $edit_submit_filtered in $lines_edit_submit_filtered lines\n\n" ;

  close CSV_INDEXPHP ;
}

sub WriteOutputCountriesSaves
{
  my $path_out = shift ;

  $comment = "# Data from $time_to_start till $time_to_stop (yyyy-mm-ddThh:mm:ss) - all counts in thousands due to sample rate of log (1 = 1000)\n" ;

  open CSV_COUNTRIES_SAVES, '>', "$path_out/$file_csv_countries_saves" ;
  print CSV_COUNTRIES_SAVES $comment ;

  foreach $key (sort keys %countries_saves)
  {
    my $count = $countries_saves {$key} ;
    print CSV_COUNTRIES_SAVES "$key,$count\n" ;
  }
  close CSV_COUNTRIES_SAVES ;
}

sub WriteDiagnostics
{
  if ($statusses_non_tcp > 0)
  { print ERR "Statusses non 'TCP..' : $statusses_non_tcp\n" ; }

  if ($fields_too_many > 0)
  { print ERR "Too many fields on $fields_too_many records. (space in article name?)\n" ; }

  if ($fields_too_few > 0)
  { print ERR "Too few fields on $fields_too_few records.\n" ; }

  print     "\nLines read per date:\n" ;
  print OUT "\nLines read per date:\n" ;
  foreach $key (sort keys %lines_read)
  {
    print OUT "$key: " . sprintf ("%8d",$lines_read{$key}) . "\n" ;
    print     "$key: " . sprintf ("%8d",$lines_read{$key}) . "\n" ;
  }
  print OUT "\n" ;
  print     "\n" ;

  print "Referers internal $tot_referers_internal\n" ;
  print "Referers external $tot_referers_external\n" ;
  print "Origins counted   $tot_origins_external_counted\n" ;

  print ERR "\nUnrecognized domains:\n\n" ;
  foreach $key (sort keys %unrecognized_domains)
  { print ERR sprintf ("%5d",$unrecognized_domains{$key}) . " : " . $key . "\n" ; }

  print "\n$tot_mime_html html requests found.\n" ;
  print "country info stored for $tot_mime_html2 html requests.\n" ;
# # double check that yahoo is much more than 10% of google (even when google uses ip addresses)
# print "\ngoogle string in referer or agent: $googles\n" ;
}

sub WriteOutputLineToCsvSharePerOs
{
  my $total_all = shift ;
  my $criteria  = shift ;
  (my $criteria2 = $criteria) =~ s/ /.*/g ;
  my @criteria = split (' ', $criteria2) ;

  my $total_operating_systems = 0 ;
  my $trace_count = 0 ;

  print "WriteOutputLineToCsvSharePerOs $criteria\n" ;
  foreach $key (keys %operating_systems)
  {
    my $match = $true ;
    foreach $criterion (@criteria)
    {
      if ($key !~ /$criterion/)
      {
        if (($trace_count++ < 20) && ($criteria =~ /Linux/))
        { print "key $key criterion $criterion FALSE\n" ; }
        $match = $false ;
        last ;
      }
      else
      {
        if (($trace_count++ < 20) && ($criteria =~ /Linux/))
        { print "key $key criterion $criterion TRUE\n" ; }
      }
    }
    if ($match)
    { $total_operating_systems += $operating_systems {$key} ; }
  }
  $perc_operating_systems1 = ".." ;
  $perc_operating_systems2 = ".." ;
  if ($total_all > 0)
  {
    $perc_operating_systems1 = sprintf ("%5.2f",(100*$total_operating_systems/$total_all)) ;
    $perc_operating_systems2 = sprintf ("%.2f",(100*$total_operating_systems/$total_all)) ;
  }
  print OUT2 sprintf ("%6d",$total_operating_systems) . "= $perc_operating_systems1\% : $criteria\n" ;
  print CSV_OPSYS "G,$criteria,$total_operating_systems,$perc_operating_systems2\%\n" ; ;
  $total_operating_systems_printed += $total_operating_systems ;
}

sub MoveAndCompressFiles
{
  trace MoveAndCompressFiles ;

  my ($path_out, $path_out_month, $date_collect_files) = @_ ;

  print "\ncd $path_out_month\n" ;
  chdir ($path_out_month) ;

# $cmd = "mv $path_out/private/SquidDataEditsSavesDoNotPublish.txt $path_out/private/SquidDataEditsSavesDoNotPublish$date_collect_files.txt" ;
# print "\ncmd = '$cmd'\n" ;
#`$cmd` ;

  $cmd = "bzip2 -f $path_out/$file_edits_saves" ;
  print "\ncmd = '$cmd'\n" ;
 `$cmd` ;

  $cmd = "bzip2 -f $path_out/$file_csv_agents" ;
  print "\ncmd = '$cmd'\n" ;
  `$cmd` ;

  # $cmd = "tar -cf $date_collect_files\-csv.tar $date_collect_files/*.csv" ;
  # print "\ncmd = '$cmd'\n" ;
  # `$cmd` ;

  # $cmd = "bzip2 -f $date_collect_files\-csv.tar" ;
  # print "\ncmd = '$cmd'\n" ;
  # `$cmd` ;
}

1 ;
