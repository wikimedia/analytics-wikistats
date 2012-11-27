#!/usr/bin/perl


#$referer = "74.125.47.132" ;
#  if (&IpAddress ($referer)) # never ?
#  { $referer   = &MatchIpRange ($referer) ; }
#  exit ;

## check totals
## reports scripts: totals e.g. for index.php do not add up correctly

# http://svn.wikimedia.org/viewvc/mediawiki/trunk/tools/counter/
# http://leuksman.com/log/2007/06/07/wikimedia-page-views/
# http://www.iplists.com/
# WHOIS http://ws.arin.net/whois/?queryinput=N%20.%20GOOGLE
# WHOIS http://tools.whois.net/index.php?fuseaction=whois.whoisbyipresults
# http://en.wikipedia.org/wiki/List_of_search_engines

# http://wikitech.wikimedia.org/view/Squid_log_format
# 1. Hostname
# 2. Sequence number
# 3. Current time in ISO 8601 format (oplus milliseconds), according ot the squid server's clock
# 4. Request time in ms
# 5. Client IP
# 6. Squid request status, HTTP status code
# 7. Reply size including HTTP headers
# 8. Request method (GET/POST etc)
# 9. URL
# 10. Squid hierarchy status, peer IP
# 11. MIME content type
# 12. Referer header
# 13. X-Forwarded-For header
# 14 User-Agent header

  use Time::Local ;

  $false = 0 ;
  $true  = 1 ;
  $timestart = time ;

  $pattern_url_pre  = "(?:^|[a-zA-Z0-9-]+\\.)*?" ;
  $pattern_url_post = "\\.(?:biz|com|info|name|net|org|pro|aero|asia|cat|coop|edu|gov|int|jobs|mil|mobi|museum|tel|travel|arpa|[a-zA-Z0-9-]{2}|(?:com?|ne)\\.[a-zA-Z0-9-]{2})\$" ;

  if (-d "/a/log") # runs on Linux
  {
    print "Job runs on server\n" ;
    ($sec,$min,$hour,$day,$month,$year) = localtime (time) ;
    $day_after_process  = sprintf ("%04d-%02d-%02d",$year+1900,$month+1,$day) ;
    ($sec,$min,$hour,$day,$month,$year) = localtime (time-60*60*24) ;
    $day_to_process = sprintf ("%04d-%02d-%02d",$year+1900,$month+1,$day) ;

    $file_in             = "/a/log/sampled-1000.log" ;
    $file_csv_methods    = "WikiCountsSampledVisitorsLogMethods.csv" ;
    $file_csv_skins      = "WikiCountsSampledVisitorsLogSkins.csv" ;
    $file_csv_scripts    = "WikiCountsSampledVisitorsLogScripts.csv" ;
    $file_csv_images     = "WikiCountsSampledVisitorsLogImages.csv" ;
    $file_csv_binaries   = "WikiCountsSampledVisitorsLogBinaries.csv" ;
    $file_csv_extensions = "WikiCountsSampledVisitorsLogExtensions.csv" ;
    $file_csv_requests   = "WikiCountsSampledVisitorsLogRequests.csv" ;
    $file_csv_origins    = "WikiCountsSampledVisitorsLogOrigins.csv" ;
    $file_csv_search     = "WikiCountsSampledVisitorsLogSearch.csv" ;
    $file_out            = "WikiCountsSampledVisitorsLog.txt" ;
    $file_err            = "WikiCountsSampledVisitorsErr.txt" ;
    $file_out_referers   = "WikiCountsSampledVisitorsLogReferersDoNotPublish!.txt" ;
  }
  else
  {
    print "Job runs local for tests\n" ;
    $day_to_process     = "2009-02-05" ;
    $day_after_process  = "2009-02-05T01" ;
  # $day_after_process  = "2009-02-06" ;

    $file_in             = "sampled-1000-oneday.txt" ;
  # $file_in             = "sampled-1000-oneday-small.txt" ;
    $file_csv_methods    = "WikiCountsSampledVisitorsLogMethodsLocal.csv" ;
    $file_csv_skins      = "WikiCountsSampledVisitorsLogSkinsLocal.csv" ;
    $file_csv_scripts    = "WikiCountsSampledVisitorsLogScriptsLocal.csv" ;
    $file_csv_images     = "WikiCountsSampledVisitorsLogImagesLocal.csv" ;
    $file_csv_binaries   = "WikiCountsSampledVisitorsLogBinariesLocal.csv" ;
    $file_csv_extensions = "WikiCountsSampledVisitorsLogExtensionsLocal.csv" ;
    $file_csv_requests   = "WikiCountsSampledVisitorsLogRequestsLocal.csv" ;
    $file_csv_origins    = "WikiCountsSampledVisitorsLogOriginsLocal.csv" ;
    $file_csv_search     = "WikiCountsSampledVisitorsLogSearchLocal.csv" ;
    $file_out            = "WikiCountsSampledVisitorsLogLocal.txt" ;
    $file_err            = "WikiCountsSampledVisitorsErrLocal.txt" ;
    $file_out_referers   = "WikiCountsSampledVisitorsLogReferersDoNotPublish!Local.txt" ;
  }

  print "Process data for $day_to_process\n" ;
  open OUT, '>', $file_out ;
  open ERR, '>', $file_err ;

  &ReadInput ;

  print "Lines counted for hash \$adds_referer_upload: $adds_referer_upload\n\n" ;
  print "Lines counted for hash \$adds_referer_other:  $adds_referer_other\n" ;
  if (($adds_referer_upload >= 100000000) ||
      ($adds_referer_other  >= 100000000))
  { print "Safety limit for hash size exceeded!. Abort.\n" ; exit ; }

  &WriteOutput ;
  &WriteDiagnostics ;

  close OUT ;
  close ERR ;

  print "\nReady in " . &minsec ((time - $timestart)). "\n" ;
  exit ;

sub ReadInput
{
  open IN,  '<', $file_in ;

  read_line:
  while ($line = <IN>)
  {
    @fields = split (' ', $line) ;
    if ($#fields < 13) { $fields_too_few  ++ ; next ; }
    if ($#fields > 13) { $fields_too_many ++ ; next ; }
    $time = $fields [2] ;

    if ($time lt $day_to_process)
    { next ; }
    if ($time ge $day_after_process)
    { last ; }

    $date = substr ($time,0,10) ;
    if ($date lt $dateprev) { next ; } # occasionally one record for previous day arrives late
    if ($date ne $dateprev)
    {
      print &mmss (time - $timestart) . " $date\n" ;
      if ($dateprev ne "")
      {
        print "$dateprev: $lines_this_day\n" ;
        $lines_read {$dateprev} = $lines_this_day ;
      }
      $lines_this_day = 0 ;
      $dateprev = $date ;
    }
    $lines_this_day++ ;

    if (++ $times % 10000 == 0)
    { print "$time\n" ; }

    $lines++ ;

    if ($lines == 1)
    { $start = &GetTimeIso8601 ($time) ; }
    $last = $time ;

    &ProcessLine ($line) ;
  }
  close IN ;

  $lines_read {$dateprev} = $lines_this_day ;

  if ($lines == 0)
  { print "No data found for $day_to_process\n" ; exit ; }

  $stop = &GetTimeIso8601 ($last) ;
}

sub ProcessLine
{
  my $line = shift ;

  $client_ip  = $fields [4] ;
  $status     = $fields [5] ;
  $size       = $fields [6] ;
  $method     = $fields [7] ;
  $url        = lc ($fields [8]) ;
  $mime       = $fields [10] ;
  $referer    = lc ($fields [11]) ;
  $agent      = $fields [13] ;

  $client_ip_range = $client_ip ;
  $client_ip_range =~ s/\.\d+\.\d+$// ;
  $cnt_ip_ranges {$client_ip_range}++ ;

  if ($status =~ /^TCP/)
  {
    $statusses {"$method:$status"}++ ;
    $statusses {"$method:total"}++ ;
  }
  else
  { $statusses_non_tcp ++ ; }

  if ($mime =~ /html/)
  { $mimecat = "page" ; }
  elsif ($mime =~ /(?:gif|png|jpeg)/)
  { $mimecat = "image" ; }
  else
  { $mimecat = "other" ; }

  $url =~ s/^http\w?\:\/\/// ;
  $url =~ s/\%3A/:/gi ;
  $url =~ s/\%3B/;/gi ;
  $url =~ s/\&amp;/\&/gi ;

  if ($url =~ /org\/skins/)
  {
    ($url2 = $url) =~ s/^.*?\/skins/skins/ ;
    $skins {$url2} ++ ;
  }
# elsif ($url =~ /\/skins/)
# { print "SKIN? $url\n" ; }

  if ($url =~ /^upload\.wikimedia\.org\//) # count image size if applicable
  { &ProcessUploadPath ($url) ; }

  ($file,$ext) = &GetFileExt ($url) ;
  $exts {$ext}++ ;

  if (($ext eq "js") || ($ext eq "css"))
  { $scripts {"$ext,$file,"} ++ ; }

  if ($ext eq "php")
  {
    ($url,$parm) = &NormalizeParms ($url) ;
    if ($parm eq "?") { return ; } # error
    $file =~ s/,/&comma;/g ;
    $parm =~ s/,/&comma;/g ;
    $scripts {"php,$file,$parm"} ++ ;
    $ext .= "($file)" ; # add filename behind extension php
  }

  ($url2 = $url) =~ s/\.php\?.*$/\.php\?../g ;
  ($domain,$location) = split ('\/',$url2,2) ;
  $domain_original = $domain ;

  # for diagnostics
  if (($referer =~ /google/) || ($agent =~ /google/i))
  { $googles++ ; }

# if (($referer =~ /upload/) && ($referer !~ /css/))
#  { $referer_upload = $referer ; }
#  else
#  { $referer_upload = "" ; }

  $referer =~ s/^http\w?\:\/\/// ;
  $referer =~ s/\.php\?.*$/\.php\?../g ;
  ($referer,$dummy) = split ('\/',$referer,2) ;
  $referer_original = $referer ;

  $domain  = &Abbreviate ($domain) ;
  if (($domain =~ /\./) ||
      ($domain !~ /^[\*\@]?!(wb|wn|wo|wp|wq|ws|wv|wk|wx|xx|wm|mw|wmf)\:/))
  {
    $unrecognized_domains {$domain_original} ++ ;
    $domain = 'other' ;
  }

  $referer = &Abbreviate ($referer) ;
  $referer_external = ($referer !~ /^[\*\@]?!(wb|wn|wo|wp|wq|ws|wv|wk|wx|xx|wm|mw|wmf)\:/) ;

  if ($referer_external)
  {
    $tot_referers_external++ ;

    ($origin, $toplevel) = &DetectOrigin ($client_ip, $referer_original, $agent, $mime, $mimecat, $service, $ext) ;

    &CountOrigin ("external", $origin, $toplevel, $mimecat) ;

    if ($origin !~ /^\!/)
    { $origins_unsimplified {$referer_original} ++ ; }
    else
    {
      $origin_simplified {"$origin [$referer] <- $referer_original"} ++ ;
      $origins_external   {$origin} ++ ;
    }

#   $referer_original =~ s/^!// ;
#   if (++$adds_referer_external < 10000000)
#    { $referer_external {$referer_original} ++ ; }
#   $referer = "external" ;
  }
  else
  {
  # strangely some referers are images
  # if ($referer_upload ne "")
  # { print "$referer_upload\n" ; }


    $tot_referers_internal ++ ;
    $referers_internal {$referer} ++ ;
    $referer =~ s/!//g ; # ! was marker to signal pattern was recognized as wikimedia project
    &CountOrigin ("internal", $referer, "org" , $mimecat) ;
  }

  $domain  =~ s/!// ;
  $referer =~ s/!// ;
  $domain  =~ s/\:\d+$// ; # remove port number
  $referer =~ s/\:\d+$// ; # remove port number
  if ($domain =~ /!/)
  { print ERR "still ! in domain: '$domain' <- '$domain_original'\n" ; }

  $requests {"$domain|$referer|$ext|$mime|$parm"}++ ;

# =========================================================
if (0)
{
  if (($domain eq "!invalid!") && ($referer ne "external"))
  { $referer = 'internal' ; }

  if ($domain =~ /upload/)
  {
    $location =~ s/\/centralnotice\/([^\/*]*)\/([^\/*]*)\/.*$/centralnotice:$1:$2/ ;
    $location =~ s/(\/[^\/]*\/[^\/]*\/).*$/$1/ ;
    $location =~ s/\/wp\/([^\/*]*)\//wp:$1/ ;
    $location =~ s/^math.*$/math/ ;
    $location =~ s/skins\/([^\/*]*)\//skins:$1/ ;
    $location =~ s/.*$/other/ ;
    $location = '-' ;

    if (++$adds_referer_upload < 10000000)
    { $referer_upload {"$ext,$referer"}++ ; }
  }
  else
  {
    $location =~ s/w\/extensions\/([^\/]+)\/.*$/\/ext:$1/ ;
    $location =~ s/skins[^\/]*\/([^\/]+)\/.*$/\/skins:$1/ ;
    $location =~ s/w\/([^\.\/]*)\.php\?.*$/$1\/$2.php?../ ;
    $location =~ s/wiki\/.*$/$1\/wiki\/../ ;
    $location =~ s/favicon.ico/std:favicon/ ;
    $location =~ s/images\/wm-button.png/std:button/ ;
    $location =~ s/images\/wiki-[^\.]+.png/std:logo/ ;

    if (++$adds_referer_other < 10000000)
    { $referer_other {"$ext,$referer"}++ ; }
  }

  if (($url =~ /upload/) && ($ext =~ /^(?:gif|jpg|jpeg|png|svg)$/))
  { $images_xref {"$domain|$folder|$referer|$ext"} ++ ; }

  if (($domain ne $referer) && ($domain =~ /^[a-z]+\:/) && ($referer =~ /^[a-z]\:/) && ($domain !~ /upload/))
  { $interwiki {"$domain|$referer|$ext|$mime|$parm"} ++ ; }
}
}


sub ProcessUploadPath
{
  my $url = shift ;
  my ($file,$folder,$path,$size,$sizerange) ;
  ($path = $url) =~ s/^.*?\.org\/// ;
  ($file = $path) =~ s/^.*\/([^\/]*)$/$1/g ; # remove path

  $binaries {$file} ++ ;

  if ($file =~ /(?:gif|jpg|jpeg|png|svg)$/i)
  {
    ($folder = $path) =~ s/\/[^\/]*$/\// ; # remove file
    $folder =~ s/\/[^\/]{1,1}\/[^\/]{2,2}\/.*$// ; # remove /x/yy/ part and beyond
    $folder =~ s/\/[^\/]{1,1}\/[^\/]{2,2}\/.*$// ; # remove /x/yy/ part and beyond, can occur twice (in thumbs)
    $folder =~ s/\/thumb// ;
    $folder =~ s/^math\/.*$/math/ ;
    # print "$folder    <-    $upload\n" ;
    if ($file =~ /\d+px/)
    {
      ($size = $file) =~ s/^.*?(\d+)px.*$/$1/ ;
       $sizerange = sprintf ("%5d",(int ($size / 20)) * 20) . "-"  . sprintf ("%5d",(((int ($size / 20))+1) * 20)) ;
       $imagesizes {$sizerange} ++ ;
    }
    else
    { $imagesizes {"???"} ++ ; }
  }
}

sub GetFileExt
{
  my $url = shift ;
  my ($file, $ext) ;
  $url =~ s/\?.*$// ;
  ($file = $url) =~ s/^([^\/]*\/)+// ; # drop path before file

  if ($file =~ /^[^\.]*$/) # no extension
  { $ext = "none" ; }
  else
  {
    ($ext = $file) =~ s/^.*?\.([^\.]+)$/$1/ ;
    if ($ext =~ /[^a-zA-Z]/)
    { $ext = "invalid" ; }
  }
  $ext = lc ($ext) ;
  $ext =~ s/^(jpg|jpeg)$/jp[e]g/g ;
#  print "$ext\n" ;

  return ($file, $ext) ;

#  # implied php request returns html
##  if ($url =~ /\/wiki\//)
##  { $ext = "html <- /wiki/" ; }
##  elsif ($url =~ /\.org\/?$/)
##  { $ext = "html <- *.org" ; }
##  elsif ($url =~ /\.com\/?$/)
##  { $ext = "html <- *.com" ; }
##  elsif ($url =~ /\/wiki\?title=/)
##  { $ext = "html <- /wiki?title=.." ; }
#  if ($mime =~ /(?:xml|html)/)
#  { $ext = "none (mimetype:$mime)" ; }
#  else
#  {
#    $url =~ s/\?.*$// ;
##   $url =~ s/\&.*$// ;
#    ($file = $url) =~ s/^([^\/]*\/)+// ; # drop path before file

#    if ($file =~ /^[^\.]*$/) # no extension
#    { $ext = "none (mimetype:$mime)" ;
#     print "\n\n$mime\n$line\n" ;
#    $ext = "none" ; }
#    else
#    {
#      ($ext = $file) =~ s/^.*?\.([^\.]+)$/$1/ ;
#      if ($ext =~ /[^a-zA-Z]/)
#      { $ext = "invalid" ; }
#    }
#  }

#  $ext = lc ($ext) ;
#  $ext =~ s/^(jpg|jpeg)$/jp[e]g/g ;

#  return ($file, $ext) ;
}

sub NormalizeParms
{
  my $url = shift ;
  $invalid = $false ;
  ($url2,$parm) = split ('\?', $url) ;
  $parm =~ s/^\&+// ;
  $parm =~ s/\&+$// ;
  $parm =~ s/\&\&+/\&/ ;
  @parms = split ('\&', $parm) ;
  @parms = sort @parms ;
  foreach $parm (@parms)
  {
    if ($parm eq "") { next ; }
    if (($parm !~ /=/) && ($parm !~ /^[\w\_]+$/))
    { $error = "parm probably invalid: '$parm' in '$url' -> skip\n" ; $invalid = $true ; last }
    ($keyword,$data) = split ('\=', $parm) ;
    if ($keyword eq "")
    { $keyword = "[empty]" ; }
    if (($keyword ne "action") || ($data !~ /^[a-zA-Z\-\_]*$/))
    { $parm =~ s/=.+/=../ ; } # show generalized version of parameter, without specifics
  }

  if ($invalid)
  {
  # print $error ;
    print ERR $error ;
    return ("?","?") ;
  }

  $parm  = join ('&', @parms) ;
  $url = "$url2\?$parm" ;
  return ($url,$parm) ;
}

sub WriteOutput
{
  open CSV_METHODS,    '>', $file_csv_methods ;
  open CSV_SKINS,      '>', $file_csv_skins ;
  open CSV_SCRIPTS,    '>', $file_csv_scripts ;
  open CSV_IMAGES,     '>', $file_csv_images ;
  open CSV_BINARIES,   '>', $file_csv_binaries ;
  open CSV_EXTENSIONS, '>', $file_csv_extensions ;
  open CSV_REQUESTS,   '>', $file_csv_requests ;
  open CSV_ORIGINS,    '>', $file_csv_origins ;
  open CSV_SEARCH,     '>', $file_csv_search ;
  open OUT_REFERERS,   '>', $file_out_referers ;

  $comment = "# Data for $day_to_process (yyyy-mm-dd) - all counts in thousands due to sample rate of log (1 = 1000)\n" ;
  print CSV_METHODS    $comment ;
  print CSV_SKINS      $comment ;
  print CSV_SCRIPTS    $comment ;
  print CSV_IMAGES     $comment ;
  print CSV_BINARIES   $comment ;
  print CSV_EXTENSIONS $comment ;
  print CSV_REQUESTS   $comment ;
  print CSV_ORIGINS    $comment ;
  print CSV_SEARCH     $comment ;
  print OUT_REFERERS   $comment ;

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

  print CSV_METHODS "method,status,count\n" ;
  foreach $key (sort keys %statusses)
  {
    if ($key =~ /:total/)
    {
      $total = $statusses {$key} ;
      $method_all1 += $total ;
      ($method = $key) =~ s/:.*$// ;
    }
    else
    {
      $total = $statusses {$key} ;
      $method_all2 += $total ;

      print OUT sprintf ("%6d",$total) . " : " . $key . "\n" ;
      $key2 = $key ;
      $key2 =~ s/,/&comma;/g ;
      $key2 =~ s/\:/,/g ;
      print CSV_METHODS "$key2,$total\n" ;
    }
  }

  # CSV_SKINS
  print OUT "\nSKINS:\n\n" ;
  print CSV_SKINS "scripts,parameters,count\n" ;
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
  print CSV_SCRIPTS "scripts,parameters,count\n" ;
  foreach $key (sort keys %scripts)
  {
    print OUT sprintf ("%5d","''xxxx " .$scripts{$key}) . " : " . $key . "\n" ;
    print CSV_SCRIPTS "$key,${scripts{$key}}\n" ;
  }

  # CSV_IMAGES
  print OUT "\nIMAGE SIZES:\n\n" ;
  print CSV_IMAGES "size range,count\n" ;
  foreach $range (sort keys %imagesizes)
  {
    ($range2 = $range) =~ s/ //g ;
    $count = $imagesizes {$range} ;
    print OUT sprintf ("%5d",$count) . " : $range\n" ;
    print CSV_IMAGES "$range2,$count\n" ;
  }

  # CSV_BINARIES
  print OUT "\nBINARIES:\n\n" ;
  print CSV_IMAGES "file,count\n" ;
  $cnt_binaries = 0 ;
  foreach $key (sort {$binaries {$b} <=> $binaries {$a}} keys %binaries)
  {
    print OUT sprintf ("%5d",$binaries{$key}) . " : " . $key . "\n" ;
    print CSV_BINARIES "$key,${binaries{$key}}\n" ;
    if (++$cnt_binaries > 500) { last ; }
  }
  # print OUT "\nImages:\n\n" ;
  # print CSV_IMAGES "project,referer,ext,mime,parms,count\n" ;

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
  print CSV_EXTENSIONS "extension,count\n" ;
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
  print OUT "\nREQUESTS:\n\n" ;
  print CSV_REQUESTS $legend ;
  print CSV_REQUESTS "project,referer,ext,mime,parms,count\n" ;
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
  print CSV_ORIGINS  "toplevel,count\n" ;
  foreach $key (sort keys %origins)
  {
    print OUT sprintf ("%8d",$origins{$key}) . " : " . $key . "\n" ;
    print CSV_ORIGINS "$key,${origins{$key}}\n" ;
  }

  # CSV_SEARCH
  print OUT "\nSEARCHES:\n" ;
  print CSV_SEARCH "matches (ip range|referer|agent string),site,referer group,bot,agent match,mime group,top level domain,count\n" ;
  foreach $key (sort keys %search)
  {
    print OUT sprintf ("%8d",$search{$key}) . " : " . $key . "\n" ;
    print CSV_SEARCH "$key,${search{$key}}\n" ;
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
  foreach $key (sort { $google_lookalikes {$b} <=> $google_lookalikes {$a}} keys %google_lookalikes)
  { print OUT sprintf ("%5d",$google_lookalikes{$key}) . " : " . $key . "\n" ; }

  print OUT "\nYAHOO BOTS:\n\n" ;
  foreach $key (sort keys %yahoobots)
  { print OUT sprintf ("%5d",$yahoobots{$key}) . " : " . $key . "\n" ; }

  print OUT "\nIP ACTIVITY BY COUNT:\n\n" ;
  foreach $key (sort {$cnt_ip_ranges {$b} <=> $cnt_ip_ranges {$a}}keys %cnt_ip_ranges)
  {
    if ($cnt_ip_ranges {$key} >= 10)
    { print OUT sprintf ("%5d",$cnt_ip_ranges{$key}) . " : " . $key . "\n" ; }
  }

  print OUT "\nIP ACTIVITY BY ADDRESS:\n\n" ;
  foreach $key (sort keys %cnt_ip_ranges)
  {
    if ($cnt_ip_ranges {$key} >= 10)
    { print OUT sprintf ("%5d",$cnt_ip_ranges{$key}) . " : " . $key . "\n" ; }
  }

  close CSV_METHODS ;
  close CSV_SKINS ;
  close CSV_SCRIPTS ;
  close CSV_IMAGES ;
  close CSV_BINARIES ;
  close CSV_EXTENSIONS ;
  close CSV_REQUESTS ;
  close CSV_ORIGINS ;
  close CSV_SEARCH ;
  close OUT_REFERERS ;
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

# # double check that yahoo is much more than 10% of google (even when google uses ip addresses)
# print "\ngoogle string in referer or agent: $googles\n" ;
}

sub Abbreviate
{
  my $domain = shift ;

  $domain =~ s/www\.([^\.]+\.[^\.]+\.[^\.]+)/$1/ ;
  $domain =~ s/\.com/\.org/ ;
# $domain =~ s/\.net/\.org/ ;
  $domain =~ s/^([^\.]+\.org)/www.$1/ ;

  if ($domain !~ /\.org/)
  { $domain =~ s/www\.(wik[^\.\/]+)\.([^\.\/]+)/$2.$1.org/ ; }

  $legend  = "# wx = wikispecial (commons|mediawiki|meta|foundation|species)\n" ;
  $legend .= "# xx:upload = upload.wikimedia.org\n" ;
  $domain =~ s/commons\.wikimedia\.org/!wx:commons/ ;
  $domain =~ s/www\.mediawiki\.org/!wx:mediawiki/ ;
  $domain =~ s/meta\.wikipedia\.org/!wx:meta/ ;
  $domain =~ s/meta\.wikimedia\.org/!wx:meta/ ;
  $domain =~ s/foundation\.wikimedia\.org/!wx:foundation/ ;
  $domain =~ s/species\.wikimedia\.org/!wx:species/ ;
  $domain =~ s/upload\.wikimedia\.org/!xx:upload/ ;

  $legend .= "# wmf = wikimediafoundation\n" ;
  $legend .= "# wb  = wikibooks\n" ;
  $legend .= "# wn  = wikinews\n" ;
  $legend .= "# wo  = wikivoyage\n" ;
  $legend .= "# wp  = wikipedia\n" ;
  $legend .= "# wq  = wikiquote\n" ;
  $legend .= "# ws  = wikisource\n" ;
  $legend .= "# wv  = wikiversity\n" ;
  $legend .= "# wk  = wiktionary\n" ;
  $legend .= "# wm  = wikimedia\n" ;
  $legend .= "# mw  = mediawiki\n" ;
  $legend .= "# \@   = mobile\n" ;
  $legend .= "# \*   = wap\n" ;

  $domain =~ s/wikimediafoundation/!wmf/ ;
  $domain =~ s/wikibooks/!wb/ ;
  $domain =~ s/wikinews/!wn/ ;
  $domain =~ s/wikivoyage/!wo/ ;
  $domain =~ s/wikipedia/!wp/ ;
  $domain =~ s/wikiquote/!wq/ ;
  $domain =~ s/wikisource/!ws/ ;
  $domain =~ s/wikiversity/!wv/ ;
  $domain =~ s/wiktionary/!wk/ ;
  $domain =~ s/wikimedia/!wm/ ;
  $domain =~ s/mediawiki/!mw/ ;

  $domain =~ s/\.mobile\./.@/ ;
  $domain =~ s/\.wap\./.*/ ;

  if ($domain =~ /^error:/)
  { $domain_errors {$domain}++ ; }
  $domain =~ s/error:.*$/!error:1/ ;

  $domain =~ s/^([^\.\/]+)\.([^\.\/]+)\.org/$2:$1/ ;
  return ($domain) ;
}

sub DetectOrigin
{
# this simplification is rather loose approximation, not rigidly according to domain name standards, as that would require further study

# three reasons to count search engine 'xxx':
# 1 $referer contains 'xxx'
# 2 $client_ip is known to belong to 'xxx'
# 3 agent shows request (probably) came from 'xxx'

  my $client_ip   = shift ;
  my $referer     = shift ;
  my $agent       = shift ;
  my $mime        = shift ;
  my $mimecat     = shift ;
  my $service     = shift ;
  my $ext         = shift ;

  my $referer_original = $referer ;
  my $origin ;

  if ($referer ne '-')
  { $origin = $referer ; }
  else
  { $origin = $client_ip ; }

  my $origin_original = $origin ;

  if (&IpAddress ($client_ip)) # always ?
  { $client_ip = &MatchIpRange ($client_ip) ; }

  if (&IpAddress ($referer)) # never ?
  {
    $top_level_domain = "-" ;
    $referer   = &MatchIpRange ($referer) ;
  }
  else
  {
    $top_level_domain = &GetTopLevelDomain  ($referer) ;
    if ($top_level_domain eq "")
    {
      $secondary_domain = "invalid" ;
      $referer = "invalid" ;
      $origin  = "invalid origin" ;
    }
    else
    { $secondary_domain = &GetSecondaryDomain ($referer) ; }
    if ($secondary_domain eq "google")
    {
      $referer =~ s/$pattern_url_post// ;
      $referer =~ s/^${pattern_url_pre}maps\.google$/!google:maps/o ;
      $referer =~ s/^${pattern_url_pre}images\.google$/!google:image search/o ;
      $referer =~ s/^${pattern_url_pre}translate\.google$/!google:translate/o ;
      $referer =~ s/^${pattern_url_pre}mail\.google$/!google:mail/o ;
      $referer =~ s/^${pattern_url_pre}toolbar\.google$/!google:toolbar/o ;
      $referer =~ s/^${pattern_url_pre}gmodules$/!google:gmodules/o ;
      $referer =~ s/^${pattern_url_pre}google$/!google:web search/o ;
      $referer =~ s/^${pattern_url_pre}www\.google/!google:web search/o ;
      if ($referer !~ /!/)
      { print "google referer not recognized: '$referer_original'\n" ; }
    }
#   if ($secondary_domain !~ /(?:-|google|yahoo)/)
#   { print "$secondary_domain <= $referer\n" ; }
  }

  if ($client_ip =~ /!google:ip/i)
  { $googles_ip++ ; }
  if ($client_ip =~ /!yahoo:ip/i)
  { $yahoos_ip++ ; }

  ($service,$agent) = &MatchAgent ($agent, $client_ip, $mime, $ext) ;

  if (($top_level_domain eq "-") && ($client_ip =~ /!google:ip/i))
  { $top_level_domain = "ip:$service" ; }
# elsif ($top_level_domain eq "")
# { print "xxxxxx $client_ip\n" ; }

  if (($client_ip =~ /!.*google/i) || ($referer =~ /!.*google/i) || ($agent =~ /!.*google/i))
  {
    if ($referer =~ /!.*google/i)
    { $origin = "google (by referer)" } #  $referer_original ; }
    elsif ($client_ip =~ /!.*google/i)
    { $origin = "google (by ip)" ; }
    else
    { $origin = "google (by agent)" ; }

    if ($client_ip =~ /!.*google/i) { $google_x = "x" ; } else { $google_x = "-" ; }
    if ($referer   =~ /!.*google/i) { $google_y = "y" ; } else { $google_y = "-" ; }
    if ($agent     =~ /!.*google/i) { $google_z = "z" ; } else { $google_z = "-" ; }
    $googlematch = "$google_x $google_y $google_z" ;

    $referer2 = $referer ; if ($referer2 !~ /!/) { $referer2 = ".." ; } else { $referer2 =~ s/^!google:// ; }
    $agent2 = $agent ;     if ($agent2   !~ /!/) { $agent2 = ".." ; }   else { $agent2   =~ s/^!google:// ; }

    $top_level_domain =~ s/^.*\.// ; # co.uk -> uk
    if (($service eq "..") && ($referer =~ /!google:/) && ($referer !~ /!google:ip/))
    { ($service = $referer) =~ s/^.*?:(.*$)/ucfirst($1)/e ; }
    $service =~ s/^\.\.$/Other/ ;

    # only found in agent string -> except Google Earth and Google Desktop, ignore others (Toolbar , Crawler)
    $accept = "   " ;
    if (($googlematch eq "- - z") && ($service !~ /(?:Earth|Desktop)/))
    {
      $service = "Look alikes?" ;
      $google_lookalikes {$agent}++ ;
    }
#   if (($googlematch ne "- - z") || ($service =~ /(?:Earth|Desktop)/))
#   { $search {"'$googlematch',google,$referer2,$service,$agent2,$mimecat,$top_level_domain"} ++ ; }
#   else
#   { $accept = "not" ; }
    $search {"'$googlematch',google,$referer2,$service,$agent2,$mimecat,$top_level_domain"} ++ ;

    $googlebins2 {"$accept [$googlematch]  " . sprintf ("%-14s",$service) . $referer} ++ ;
    $googlebins {$googlematch}++ ;
  }

  # test: make yahoo's treatment of languages look like google's
  # $origin =~ s/^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+\.yahoo.com)/$2.$1/ ;


   $origin =~ s/^localhost(\:.*)?$/!localhost/o ;
   $origin =~ s/\:\d+$// ; # remove port number

#  $origin =~ s/${pattern_url_pre}mail\.live$/!microsoft live mail/o ;
#  $origin =~ s/${pattern_url_pre}msn.$/!microsoft MSN/o ;
#  $origin =~ s/${pattern_url_pre}msdn.$/!microsoft MSDN/o ;

#  $origin =~ s/${pattern_url_pre}dailynews\.yahoo$/!yahoo news/o ;
#  $origin =~ s/${pattern_url_pre}mail\.yahoo$/!yahoo mail/o ;
#  $origin =~ s/${pattern_url_pre}search.yahoo$/!yahoo search/o ;
## $origin =~ s/^[\w\.]+.yahoo..*$/!yahoo misc./o ;

#if ($origin =~ /!/o)
#{  print "$origin\n" ; }

#  if (($origin !~ /^ip:!/o) && ($origin !~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})/o))
#  {
#    $origin =~ s/${pattern_url_pre}([a-zA-Z0-9-]+)$/!$1/o ;
#    print "$origin\n" ;
#   }

  if ($origin =~ /wiki/)
  { $wikis {$origin} ++ ; }

  if ($origin eq "wikipedia")
  {
    # print "incomplete origin: $origin <= $referer_original\n$line\n\n" ;
    $origin = "!error:4" ;
  }

  return ($origin, $top_level_domain) ;
}

sub IpAddress
{
  my $address = shift ;
  return ($address =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?:\:\d+)?$/) ;
}


sub MatchAgent
{
  my $agent     = shift ;
  my $client_ip = shift ;
  my $mime      = shift ;
  my $ext       = shift ;

  ($client_ip_range = $client_ip) =~ s/\.\d+\.\d+$// ;

  $service = '..' ;
  if ($agent =~ /google/i)
  {
    if ($agent =~ /Googlebot/i)
    { $service = "Crawler" ;    $agent = "!GoogleBot" ; }
    elsif ($agent =~ /FeedFetcher-Google/i)
    { $service = "FeedFetcher" ; $agent = "!FeedFetcher-Google" ; }
    elsif ($agent =~ /Google.*?Wireless.*?Transcoder/i)
    { $service = "Wireless" ; $agent = "!GoogleWirelessTranscoder" ; }
    elsif ($agent =~ /Google.*?Desktop/i)
    { $service = "Desktop" ; $agent = "!GoogleDesktop" ; }
    elsif ($agent =~ /GoogleEarth/i)
    { $service = "Earth" ; $agent = "!GoogleEarth" ; }
    elsif ($agent =~ /GoogleToolbar/i)
    { $service = "Toolbar" ; $agent = "!GoogleToolbar" ; }
    elsif ($agent =~ /Google.*?Keyword.*?Tool/i)
    { $service = "KeywordTool" ; $agent = "!GoogleKeywordTool" ; }
    elsif ($agent =~ /GoogleT\d/i)
    { $service = "Toolbar" ; $agent =~ s/^.*?(GoogleT\d+).*$/"!".$1/e ; }
    elsif ($agent =~ /translate\.google\.com/i)
    { $service = "Translate" ; $agent = "!GoogleTranslate" ; }
    else
    { $service = "Other" ; $agent = "!GoogleOther" ; }

    @googlebots {"$agent,$client_ip_range,$service,$mime,$ext"} ++ ;
  }

#  if ($agent =~ /yahoo/i)
#  {
#    if ($agent =~ /ysearch\/slurp/)
#    { $service = "bot" ; $agent = "!YahooBot" ; }

#    @yahoobots {"$agent,$client_ip_range,$mime,$ext"} ++ ;
#  }

  return ($service, $agent) ;
}

sub MatchIpRange
{
  my $address = shift ;

  $address =~ s/\:.*$// ; # remove port number

  $address_original = $address ;
  $address =~ s/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/sprintf("%03d",$1).".".sprintf("%03d",$2).".".sprintf("%03d",$3).".".sprintf("%03d",$4)/e ;
# $address =~ s/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/sprintf("%03d",$1).".".sprintf("%03d",$2).".".sprintf("%03d",$3)/e ; # ??//
  $address_11 = substr ($address,0,11) ;

     if (($address_11 ge "064.233.160")     && ($address_11 le "064.233.191"))     { $address = "!google:IP064" ; }
  elsif (($address_11 ge "066.249.064")     && ($address_11 le "066.249.095"))     { $address = "!google:IP066" ; }
  elsif (($address_11 ge "066.102.000")     && ($address_11 le "066.102.015"))     { $address = "!google:IP066" ; }
  elsif (($address_11 ge "072.014.192")     && ($address_11 le "072.014.255"))     { $address = "!google:IP072" ; }
  elsif (($address_11 ge "074.125.000")     && ($address_11 le "074.125.255"))     { $address = "!google:IP074" ; }
  elsif (($address_11 ge "209.085.128")     && ($address_11 le "209.085.255"))     { $address = "!google:IP209" ; }
  elsif (($address_11 ge "216.239.032")     && ($address_11 le "216.239.063"))     { $address = "!google:IP216" ; }
  elsif (($address    ge "070.089.039.152") && ($address    le "070.089.039.159")) { $address = "!google:IP070" ; }
  elsif (($address    ge "070.090.219.072") && ($address    le "070.090.219.079")) { $address = "!google:IP070" ; }
  elsif (($address    ge "070.090.219.048") && ($address    le "070.090.219.055")) { $address = "!google:IP070" ; }

  elsif (($address_11 ge "067.195.000")     && ($address_11 le "067.195.255"))     { $address = "!yahoo:IP067" ;  }
  elsif (($address_11 ge "072.030.000")     && ($address_11 le "072.030.255"))     { $address = "!yahoo:IP072" ;  }
  elsif (($address_11 ge "074.006.000")     && ($address_11 le "074.006.255"))     { $address = "!yahoo:IP074" ;  }
  elsif (($address_11 ge "209.191.064")     && ($address_11 le "209.191.127"))     { $address = "!yahoo:IP209" ;  }

  $address =~ s/IP\d+/ip/ ; # no need for detailed ranges for now

#  @fields = split ('\.', $address) ;
#  foreach $field (@fields)
#  { $field =~ s/^0+(\d)/$1/ ; }
#  $address2 = join ('.', @fields) ;
#  if ($address2 ne $address_original)
#  { print "MatchIpRange: '$address2' <- $address_original\n" ; }

  return ($address) ;
}

# see http://en.wikipedia.org/wiki/Domain_name
sub GetTopLevelDomain
{
  my $domain = shift ;
  $domain =~ s/\:\d+$// ; # remove port tnumber

  if ($domain eq '-')
  { $top_level_domain = '-' ; }
  elsif ($domain =~ /!?localhost/)
  { $top_level_domain = 'localhost' ; }
  elsif ($domain !~ /.+\..+/)
  { $top_level_domain = '' ; }
  else
  {
    ($top_level_domain = $domain) =~ s/^.*?($pattern_url_post)/$1/o ;
    if ($domain eq $top_level_domain)
    { $top_level_domain = '-other-' ; }
  }
  return ($top_level_domain) ;
}

sub GetSecondaryDomain
{
  my $domain = shift ;
  $domain =~ s/\:\d+$// ; # remove port tnumber

  if ($domain !~ /\./)
  { return ($domain) ; }

  $domain =~ s/$pattern_url_post// ;
  $domain =~ s/^.*?\.([^\.]+)$/$1/ ;
  return ($domain) ;
}

sub CountOrigin
{
  my $source   = shift ;
  my $origin   = shift ;
  my $toplevel = shift ;
  my $mimecat  = shift ;

  if ($source eq "external")
  {
    $tot_origins_external_counted ++ ;
    $origin =~ s/\:.*$// ;
    if (&IpAddress ($origin))
    { $origin = "unmatched ip address" ; $toplevel = "" ; }
    elsif ($origin =~ /^!error/)
    { $origin = "invalid origin" ; $toplevel = "" ; }
    elsif ($origin =~ /^!localhost/)
    { $origin = "localhost" ; $toplevel = "" ; }
    else
    {
      if (($origin =~ /!/) && ($origin !~ /!error/))
      { print "CountOrigin: $origin\n" ; }
      $origin = &GetSecondaryDomain ($origin) ;
      # print "$origin\n" ;
    }
  }
  $origins {"$source,$origin,$toplevel,$mimecat"} ++ ;
}

sub GetTimeIso8601
{
  my $time = shift ;
  my $year = substr ($time,0,4) ;
  my $mon  = substr ($time,5,2) ;
  my $mday = substr ($time,8,2) ;
  my $hour = substr ($time,11,2) ;
  my $min  = substr ($time,14,2) ;
  my $sec  = substr ($time,17,2) ;
  print OUT "$year $mon $mday $hour $min $sec\n" ;
  $time = timegm($sec,$min,$hour,$mday,$mon-1,$year-1900);
  return ($time) ;
}

sub mmss
{
  my $time = shift ;
  return (sprintf ("%02d\:%02d", int ($time / 60), $time % 60)) ;
}

sub minsec
{
  my $time = shift ;
  return (int ($time / 60) . " min, " . ($time % 60) . " sec") ;
}


#ref code Brion for http://leuksman.com/log/2007/06/07/wikimedia-page-views/

#update hits set hit_source='other';
#update hits set hit_source='-' where hit_refer='-';
#update hits set hit_source='gadget' where hit_refer like 'x-gadget:%';
#update hits set hit_source='other-wiki' where hit_refer rlike 'http://([a-z0-9]+\\.)*(wikipedia|wikimedia|wiktionary|wikisource|wikibooks|wikiquote|mediawiki)\\.org';
#update hits set hit_source='self' where hit_refer like concat('http://',hit_lang,'.',hit_site,'.org%');
#update hits set hit_source='self-search' where hit_refer like concat('http://',hit_lang,'.',hit_site,'.org%') and hit_refer like '%:Search%search=%';
#update hits set hit_source='google' where hit_refer rlike 'http://([a-z0-9]+\\.)*google\\.';
#update hits set hit_source='yahoo' where hit_refer rlike 'http://([a-z0-9]+\\.)*yahoo\\.';
#update hits set hit_source='aol' where hit_refer rlike 'http://([a-z0-9]+\\.)*aol\\.';
#update hits set hit_source='ask' where hit_refer rlike 'http://([a-z0-9]+\\.)*ask\\.';
#update hits set hit_source='msn' where hit_refer rlike 'http://([a-z0-9]+\\.)*msn\\.';
#update hits set hit_source='live' where hit_refer rlike 'http://([a-z0-9]+\\.)*live\\.';
#update hits set hit_source='altavista' where hit_refer rlike 'http://([a-z0-9]+\\.)*altavista\\.';
#select hit_source,count(*) as hit_count from hits group by hit_source order by hit_count desc;

#mysql> select hit_source,count(*) as hit_count from hits group by hit_source order by hit_count desc;
#+-------------+-----------+
#| hit_source  | hit_count |
#+-------------+-----------+
#| self        |      6136 |
#| google      |      3278 |
#| -           |      2263 |
#| gadget      |      1043 |
#| other-wiki  |       433 |
#| self-search |       401 |
#| other       |       220 |
#| yahoo       |       218 |
#| msn         |        64 |
#| live        |        19 |
#| ask         |        19 |
#| aol         |        13 |
#| altavista   |         6 |
#+-------------+-----------+
#13 rows in set (0.11 sec)


#mysql> select hit_source,count(*) as hit_count from hits group by hit_source order by hit_count desc;
#+-------------+-----------+
#| hit_source  | hit_count |
#+-------------+-----------+
#| self        |     35092 |
#| google      |     14666 |
#| -           |     14479 |
#| gadget      |      7912 |
#| other-wiki  |      2210 |
#| self-search |      2202 |
#| yahoo       |      1633 |
#| other       |      1098 |
#| msn         |       216 |
#| aol         |       105 |
#| live        |        82 |
#| ask         |        47 |
#| altavista   |        28 |
#+-------------+-----------+
#13 rows in set (0.54 sec)

#select count(*) from hits;
#|    79770 |

#mysql> select unix_timestamp(max(hit_datetime)) - unix_timestamp(min(hit_datetime)) from hits;
#+-----------------------------------------------------------------------+
#| unix_timestamp(max(hit_datetime)) - unix_timestamp(min(hit_datetime)) |
#+-----------------------------------------------------------------------+
#|                                                                260387 |
#+-----------------------------------------------------------------------+
#1 row in set (0.34 sec)


#select hit_source,count(*) as hit_count,
#  count(*)*100/79770 as hit_percent,
#  format(((count(*)*1000)/260387)*86400,0) as hit_daily
# from hits group by hit_source order by hit_count desc;
#+-------------+-----------+-------------+------------+
#| hit_source  | hit_count | hit_percent | hit_daily  |
#+-------------+-----------+-------------+------------+
#| self        |     35092 |     43.9915 | 11,644,010 |
#| google      |     14666 |     18.3854 | 4,866,381  |
#| -           |     14479 |     18.1509 | 4,804,332  |
#| gadget      |      7912 |      9.9185 | 2,625,311  |
#| other-wiki  |      2210 |      2.7705 | 733,308    |
#| self-search |      2202 |      2.7604 | 730,654    |
#| yahoo       |      1633 |      2.0471 | 541,852    |
#| other       |      1098 |      1.3765 | 364,332    |
#| msn         |       216 |      0.2708 | 71,672     |
#| aol         |       105 |      0.1316 | 34,840     |
#| live        |        82 |      0.1028 | 27,209     |
#| ask         |        47 |      0.0589 | 15,595     |
#| altavista   |        28 |      0.0351 | 9,291      |
#+-------------+-----------+-------------+------------+
#13 rows in set (0.57 sec)

#select count(*) as hit_count,
#  count(*)*100/79770 as hit_percent,
#  format(((count(*)*1000)/260387)*86400,0) as hit_daily
# from hits;
#+-----------+-------------+------------+
#| hit_count | hit_percent | hit_daily  |
#+-----------+-------------+------------+
#|     79770 |    100.0000 | 26,468,787 |
#+-----------+-------------+------------+





#from the 1/100 log sample

#  144316 sampled-50megs
#1180469361 start
#1180469833 end
#472 delta
#30575


#from the 1/1000
#1180213592.254
#1180473980.319
#260,388.065000057
#721511 lines
#2770/sec

#another one:
#716355 lines
#1181133271.607
#1181159854.352
#26,582.745 seconds
#26,948.11991764 hits/sec




#mysql> select count(*) from hits;
#+----------+
#| count(*) |
#+----------+
#|    71873 |
#+----------+
#1 row in set (0.00 sec)

#mysql>  select unix_timestamp(max(hit_datetime)) - unix_timestamp(min(hit_datetime)) from hits;
#+-----------------------------------------------------------------------+
#| unix_timestamp(max(hit_datetime)) - unix_timestamp(min(hit_datetime)) |
#+-----------------------------------------------------------------------+
#|                                                                 26582 |
#+-----------------------------------------------------------------------+
#1 row in set (0.17 sec)



#+-------------+-----------+
#| hit_source  | hit_count |
#+-------------+-----------+
#| self        |     31512 |
#| google      |     17102 |
#| -           |     11873 |
#| gadget      |      3862 |
#| other-wiki  |      2174 |
#| self-search |      2140 |
#| yahoo       |      1507 |
#| other       |      1162 |
#| msn         |       208 |
#| live        |       189 |
#| aol         |        84 |
#| ask         |        39 |
#| altavista   |        21 |
#+-------------+-----------+
#13 rows in set (0.49 sec)


#select count(*) as hit_count,
#  count(*)*100/71873 as hit_percent,
#  format(((count(*)*1000)/26582)*86400,0) as hit_daily,
#  format(((count(*)*1000)/26582)*86400*30,0) as hit_monthly
#  from hits;

#select hit_source,count(*) as hit_count,
#  count(*)*100/71873 as hit_percent,
#  format(((count(*)*1000)/26582)*86400,0) as hit_daily,
#  format(((count(*)*1000)/26582)*86400*30,0) as hit_monthly
#  from hits group by hit_source order by hit_count desc;


#+-----------+-------------+-------------+---------------+
#| hit_count | hit_percent | hit_daily   | hit_monthly   |
#+-----------+-------------+-------------+---------------+
#|     71873 |    100.0000 | 233,610,232 | 7,008,306,975 |
#+-----------+-------------+-------------+---------------+

#+-------------+-----------+-------------+-------------+---------------+
#| hit_source  | hit_count | hit_percent | hit_daily   | hit_monthly   |
#+-------------+-----------+-------------+-------------+---------------+
#| self        |     31512 |     43.8440 | 102,424,076 | 3,072,722,293 |
#| google      |     17102 |     23.7947 | 55,586,969  | 1,667,609,059 |
#| -           |     11873 |     16.5194 | 38,591,047  | 1,157,731,397 |
#| gadget      |      3862 |      5.3734 | 12,552,735  | 376,582,048   |
#| other-wiki  |      2174 |      3.0248 | 7,066,195   | 211,985,855   |
#| self-search |      2140 |      2.9775 | 6,955,684   | 208,670,529   |
#| yahoo       |      1507 |      2.0968 | 4,898,232   | 146,946,957   |
#| other       |      1162 |      1.6167 | 3,776,872   | 113,306,147   |
#| msn         |       208 |      0.2894 | 676,067     | 20,281,995    |
#| live        |       189 |      0.2630 | 614,310     | 18,429,313    |
#| aol         |        84 |      0.1169 | 273,027     | 8,190,806     |
#| ask         |        39 |      0.0543 | 126,762     | 3,802,874     |
#| altavista   |        21 |      0.0292 | 68,257      | 2,047,701     |
#+-------------+-----------+-------------+-------------+---------------+



#select count(*) as hit_count
#  from hits
#  where hit_site='wikipedia';

#70979

#select
#  'total' as hit_source,
#  count(*) as hit_count,
#  count(*)*100/70979 as hit_percent,
#  format(((count(*)*1000)/26582)*86400,0) as hit_daily,
#  format(((count(*)*1000)/26582)*86400*30,0) as hit_monthly
#  from hits
#  where hit_site='wikipedia'
#union select
#  hit_source,
#  count(*) as hit_count,
#  count(*)*100/70979 as hit_percent,
#  format(((count(*)*1000)/26582)*86400,0) as hit_daily,
#  format(((count(*)*1000)/26582)*86400*30,0) as hit_monthly
#  from hits
#  where hit_site='wikipedia'
#  group by hit_source order by hit_count desc;

#+-------------+-----------+-------------+-------------+---------------+
#| hit_source  | hit_count | hit_percent | hit_daily   | hit_monthly   |
#+-------------+-----------+-------------+-------------+---------------+
#| total       |     70979 |    100.0000 | 230,704,447 | 6,921,133,399 |
#| self        |     31275 |     44.0623 | 101,653,751 | 3,049,612,520 |
#| google      |     17022 |     23.9817 | 55,326,943  | 1,659,808,291 |
#| -           |     11535 |     16.2513 | 37,492,438  | 1,124,773,155 |
#| gadget      |      3862 |      5.4410 | 12,552,735  | 376,582,048   |
#| self-search |      2117 |      2.9826 | 6,880,927   | 206,427,808   |
#| other-wiki  |      2003 |      2.8220 | 6,510,390   | 195,311,715   |
#| yahoo       |      1500 |      2.1133 | 4,875,480   | 146,264,389   |
#| other       |      1126 |      1.5864 | 3,659,860   | 109,795,802   |
#| msn         |       208 |      0.2930 | 676,067     | 20,281,995    |
#| live        |       187 |      0.2635 | 607,810     | 18,234,294    |
#| aol         |        84 |      0.1183 | 273,027     | 8,190,806     |
#| ask         |        39 |      0.0549 | 126,762     | 3,802,874     |
#| altavista   |        21 |      0.0296 | 68,257      | 2,047,701     |
#+-------------+-----------+-------------+-------------+---------------+

