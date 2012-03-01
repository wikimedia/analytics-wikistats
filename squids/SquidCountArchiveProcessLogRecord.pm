# to do: study http://www.zytrax.com/tech/web/mobile_ids.html

sub ProcessLine
{
  my $line = shift ;

  $time = $fields [2] ;
  $date = substr ($time,0,10) ;

  $client_ip  = $fields [4] ;
  $mime       = $fields [10] ;
  $url        = lc ($fields [8]) ;

  if ($mime eq '-')
  {
    # no mime type on log records from varnish, assume 'page request' on most, until that stream had been fixed
    if (($url =~ /\.m\..*?\/wiki\//) || ($url =~ /\.m\..*?\/w\/index.php/))
    { $mime = "text/html" ; }
  }

  $count_event = 1 ;
  # from Oct 16, 2011 00:00 hrs till Nov 29, 2011 20:00 hrs one of the two servers which process requests to the mobile site did not send log lines
  # since the two servers are load-balanced, selected stats (e.g. breakdown browser, OS) can be repaired by counting requests to mobile site twice in this period
  # note: do not count twice for metrics where specific ip addresses are considered, this would inflate number of assumed bots (based on ip address freq.)
  if ((($time ge '2011-10-16T00') && ($time lt '2011-11-29T20')) and
       ($url =~ /\.m\./))
  { $count_event = 2 ; }

  if ($scan_ip_frequencies) # phase 1
  {
    return if $line =~ /Banner(?:Cont|List|Load|beheer)/io ;

    if ($mime eq "text/html")
    {
      $ip_frequencies {$client_ip} ++ ; # do not use $count_event here!
      $html_pages_found += $count_event ;
    }

    return ;
  }


  # remember for each squid per hour lowest and highest sequence number and number of events
  # later calc per hour average distance between events = (highest - lowest sequence number) / events - 1
  # distance between consecutive events that lay in different hour bin are ignored, negligible
  $squid = $fields [0] ;
  $seqno = $fields [1] ;
  $hour = substr ($time, 11, 2) ;

  # init for new found or restarted squid
  # note seqno can be negative! probably unsigned int printed as signed int, 3rd clause deals with this
  if (($squid_seqno {$squid} == 0) || ($seqno < $squid_seqno {$squid}) || (($seqno > 0) && ($squid_seqno {$squid} < 0)))
  { $squid_seqno {$squid} = $seqno ; }
  else
  {
    $squid_events {"$squid,$hour"} ++ ;
    $delta = $seqno - $squid_seqno {$squid};
    $squid_delta  {"$squid,$hour"} += $delta ;
    $squid_seqno  {$squid} = $seqno ;
  }

  # now parse all other fields

  $status     = $fields [5] ;
  $size       = $fields [6] ;
  $method     = $fields [7] ;

  $referer    = lc ($fields [11]) ;
  $agent      = $fields [13] ;

# print "\ntime '$time', client_ip '$client_ip', mime '$mime', squid '$squid', seqno '$seqno', \nstatus '$status', size '$size', method '$method', referer '$referer',\nurl '$url', agent '$agent'\n" ;

  if ($url =~ /\.m\.wikipedia.org/)
  {
    $url_wikipedia_mobile += $count_event ;
    $status_url_wikipedia_mobile {$status} += $count_event ;
    $status_mime_url_wikipedia_mobile {"$status,$mime"} += $count_event ;
    if ($status eq "TCP_MISS/302")
    {
      $redirected_to_mobile += $count_event ;
      return ;
    }
  }

  $url =~ s/^http\w?\:\/\///o ;
  $url =~ s/\%3A/:/gio ;
  $url =~ s/\%3B/;/gio ;
  $url =~ s/\&amp;/\&/gio ;

  ($agent2 = $agent) =~ s/\%20/ /g ; # mainly to make line content more readable on debugging
  $agent2 =~ s/\%2F/\//g ; # mainly to make line content more readable on debugging
  $agents_raw {$agent2} += $count_event ;

  ($file,$ext) = &GetFileExt ($url) ;
  $exts {$ext} += $count_event ;

  if (($ext eq "js") || ($ext eq "css"))
  { $scripts {"$ext,$file,"} += $count_event ; }

  $title = "" ;
  $parm  = "" ;
  if ($ext eq "php")
  {
    if ($url =~ /title=/o)
    {
      $title = $url ;
      $title =~ s/^.*?title=//o ;
      $title =~ s/\&.*$//o ;
    }
    ($url,$parm) = &NormalizeParms ($url) ;
    if ($parm eq "?") { return ; } # error
    $file =~ s/,/&comma;/go ;
    $parm =~ s/,/&comma;/go ;
    $scripts {"php,$file,$parm"} += $count_event ;
    $ext .= "($file)" ; # add filename behind extension php
  }

  if ($mime eq "text/html")
  {
    $mimecat = "page" ;
    $tot_mime_html += $count_event ;
  }
  elsif ($mime =~ /(?:gif|png|jpeg)/o)
  { $mimecat = "image" ; }
  else
  { $mimecat = "other" ; }

  if ($job_runs_on_production_server)
  {
    $country = $fields [14] ;
    if (($country eq "") || ($country =~ /null/))
    { $country = "--" ; }
  }
  else
  {
    $country = $fields [14] ;
    if ($country eq "")
    {
      if (++ $fake_country_code % 3 == 0)
      { $country = "XX" ; }
      else
      { $country = "YY" ; }
    }
  }

  if ($line =~ /(?:BannerCont|BannerList|BannerLoad|Bannerbeheer)/io)
  {
    $banners {"$country,$url"} += $count_event ;
    $banner_requests_ignored += $count_event ;
    return ;
  }

  $countries {$country} += $count_event ; ;

  $agent2 = $agent ;
  $agent2 =~ s/\%20/ /g ;

  # remove all mentions of .NET CLR
  # http://en.wikipedia.org/wiki/Common_Language_Runtime
  $agent2 =~ s/\.NET CLR [0-9.]+\s*;?\s*//go ;
  $agent2 =~ s/\(\s*\)//go ;

  # e.g. BlackBerry8310/4.2.2 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/102 -> BlackBerry8310/4.2.2
  if ($agent2 =~ BlackBerry)
  { $agent2 =~ s/^.*?BlackBerry\d+\/([^\s]*).*$/BlackBerry\/$1/io ; } # keep

  $agent2 =~ s/Android (\d)/Android\/$1/o ;
  $agent2 =~ s/Safari(\d)/Safari\/$1/o ;
  $agent2 =~ s/Browser\/NetFront/NetFront/o ;
  $agent2 =~ s/Browser\/VF-NetFront/NetFront/o ;
  $agent2 =~ s/jig browser (\d)/JigBrowser\/$1/o ;
  $agent2 =~ s/jig browser9 (\d)/JigBrowser\/$1/o ;
  $agent2 =~ s/jig browser web; (\d)/JigBrowser9\/$1/o ;

  # Remove explanation for KHTML
  $agent2 =~ s/\(KHTML, like Gecko\)/KHTML/o ;
  $agent2 =~ s/(KHTML[^\s]*) \(like Gecko\)/$1/o ;

  # Remove name of Ubuntu release (or name -> number)
  $agent2 =~ s/(Ubuntu\/[0-9\.]+)\s*\(\w+\)/$1/gio ;
  $agent2 =~ s/\(Ubuntu-(\w)\w+\)/("Ubuntu\/".(ord (lc($1))-ord('a')+1))/gieo ;
  $agent2 =~ s/Ubuntu\/([a-zA-Z])\w+/("Ubuntu\/".(ord (lc($1))-ord('a')+1))/gieo ;

  $agent2 =~ s/;\s*U\s*;/;/o ;

  if ($agent2 =~ /GoogleBot/io)
  {
    $client_ip2 = &MatchIpRange ($client_ip) ;
    if ($client_ip2 =~ /!google/o)
    {
      $agent2 .= " |Google ip address" ;
      $client_ip_range = $client_ip ;
      $client_ip_range =~ s/\.\d+$//o ;
      $google_bot_hits {substr ($time,0,13).','.$client_ip_range} ++ ;
    }
    elsif ($agent2 !~ /compatible GoogleBot/io)
    {
      $agent2 .= " |no Google ip address" ;
      $ip_bot_no_google {$client_ip}++ ;
    }
  }

  $bot = $false ;

  # url in agent string should only occur for bots (agent string is free format, no rules, just conventions)
  # exception: Embedded Web Browser from: http://bsalsa.com/,
  # see also http://www.bsalsa.com/forum/showthread.php?t=724
  if (($agent2 =~ /http:\/\//o) && ($agent2 !~ /bsalsa.com/o))
  {
    if ($agent2 !~ /MSIE \d+\/\d+/o) # most likely false positives
    {
      $bot = $true ;
      @bots {"$mime,$agent2"} += $count_event ;
    }
  }
  elsif (($agent2 =~ /bot/io) || (($agent2 =~ /crawl(?:er)?/io) && ($agent2 !~ /MSIEcrawler/io)) || ($agent2 =~ /spider/io) || ($agent2 =~ /parser/io))
  {
    $bot = $true ;
    @bots {"$mime,$agent2"} += $count_event ;
  }

  # GECKO
  $gecko = "" ;
  if ($agent2 =~ /Gecko\/\d{4,}/io)
  { ($gecko = $agent2) =~ s/^.*?Gecko\/(\d{4}).*$/Gecko\/$1/io ; }

  # APPLEWEBKIT
  $applewebkit = "" ;
  if ($agent2 =~ /AppleWebKit/io)
  {
    ($applewebkit = $agent2) =~ s/^.*?AppleWebKit\/(\d+\.\d+).*$/AppleWebKit\/$1/io ;
    $applewebkit =~ s/^.*?AppleWebKit\/(\d+).*$/AppleWebKit\/$1/io ;
    $applewebkit =~ s/\/(\d\d)$/\/0$1/o ;

    if ($agent2 =~ /Mozilla.{1,8}\(/io)
    {
      $agent3 = $agent2 ;
      $agent3 =~ s/^[^\(]*\(//o ;
      $agent3 =~ s/;.*$//o ;
      $agent3 =~ s/\).*$//o ;
      $agent3 =~ s/^\s+//o ;
      $agent3 =~ s/\s+$//o ;
      $agent3 = substr ($agent3,0,20) ;

      $platform = '' ;
      if ($agent2 =~ /Chrome/io)
      { ($platform = $agent2) =~ s/^.*?(Chrome\/?\s*\d+\.?\d*).*$/$1/io ; }
      elsif ($agent2 =~ /Android/io)
      { ($platform = $agent2) =~ s/^.*?(Android\/?\s*\d+\.?\d*).*$/$1/io ; }
      elsif ($agent2 =~ /(?:iPad|iPod|iPhone)/io)
      {
        ($platform = $agent2) =~ s/^.*?(OS\s*\d\_?\d?).*$/$1/io ;
        $platform =~ s/_/./go ;
      }
      elsif ($agent2 =~ /Kindle/io)
      { ($platform = $agent2) =~ s/^.*?(Kindle\/?\s*\d+\.?\d*).*$/$1/io ; }
      elsif ($agent2 =~ /Safari/io)
      { ($platform = $agent2) =~ s/^.*?(Safari\/\d+).*$/$1/io ; }

      if (($agent2 =~ /Symbian/i) && ($agent3 !~ /Symbian/io))
      { ($platform = $agent2) =~ s/^.*?(Symbian[\w\d\.\/]+).*$/$1/io ; }

      if ($platform ne '')
      {
        $platform =~ s/^\s+//o ;
        $platform =~ s/\s+$//o ;
        $platform = " $platform" ;
      }

      $applewebkit .= " ($agent3$platform)" ;
    }

    if (($agent2 =~ /Nokia/io) && ($applewebkit !~ /Nokia/io))
    { $applewebkit .= " (Nokia)" ; }

    #    if ($agent2 =~ /\(iPad/i)      { $applewebkit .= " (iPad)" ; }
    # elsif ($agent2 =~ /\(iPod/i)      { $applewebkit .= " (iPod)" ; }
    # elsif ($agent2 =~ /\(iPhone/i)    { $applewebkit .= " (iPhone)" ; }
    # elsif ($agent2 =~ /\(Windows/i)   { $applewebkit .= " (Win)" ; }
    # elsif ($agent2 =~ /\(Macintosh/i) { $applewebkit .= " (Mac)" ; }
    # else                              { $applewebkit .= " (--)" ; }
  }

  # MOBILE
  $mobile = '-' ;
  if ($agent2 =~ /(?:$tags_wiki_mobile)/io)
  { $mobile = 'W' ; }
  elsif ($agent2 =~ /(?:$tags_mobile)/io)
  { $mobile = 'M' ; }

  $os = ".." ;

  if ($agent2 =~ /CFNetwork/io)     { $os = "iPhone" ; }
  elsif ($agent2 =~ /BlackBerry/io)     {($os = $agent2) =~ s/^.*?BlackBerry[^\/]*\/(\d+\.\d+).*$/BlackBerry\/$1/io ; } # BlackBerry/8320/4.2 -> BlackBerry/4.2
  elsif ($agent2 =~ /DoCoMo/io)         { $os = "DoCoMo" ; }
  elsif ($agent2 =~ /iPad/io)           { $version = "iPad" ;   ($os = $agent2) =~ s/^.*?(iPad OS \d+\_\d+).*$/$1/io ; }
  elsif ($agent2 =~ /iPod/io)           { $version = "iPod" ;   ($os = $agent2) =~ s/^.*?(iPhone OS \d+\_\d+).*$/$1/io ; }
  elsif ($agent2 =~ /iPhone/io)         { $version = "iPhone" ; ($os = $agent2) =~ s/^.*?(iPhone OS \d+\_\d+).*$/$1/io ; }
  elsif ($agent2 =~ /webOS.* Pre/io)    { $version = "Pre" ;    ($os = $agent2) =~ s/^.*?(webOs\/\d+\.?\d*).*$/$1/io ; } # Palm Pre
  elsif ($agent2 =~ /Intel Mac/io)      { $os = "Mac Intel" ; }
  elsif ($agent2 =~ /PPC Mac/io)        { $os = "Mac PowerPC" ; }
  elsif ($agent2 =~ /Mac_PowerPC/io)    { $os = "Mac PowerPC" ; }
  elsif ($agent2 =~ /Macintosh.*PPC/io) { $os = "Mac PowerPC" ; }
  elsif ($agent2 =~ /Mac OS/io)         { $os = "Mac" ; }
  elsif ($agent2 =~ /MacBook/io)        { $os = "Mac" ; }
  elsif ($agent2 =~ /iMac/io)           { $os = "iMac" ; }
  elsif ($agent2 =~ /Power.*Macintosh/io) { $os = "Mac PowerPC" ; }
  elsif ($agent2 =~ /FreeBSD/io)        { $os = "FreeBSD" ; }
  elsif ($agent2 =~ /OpenBSD/io)        { $os = "OpenBSD" ; }
  elsif ($agent2 =~ /SunOS/io)          { $os = "SunOS" ; }
  elsif ($agent2 =~ /PlayStation/io)    { $os = "PlayStation" ; }
  elsif ($agent2 =~ /SymbianOS/io)      { ($os = $agent2) =~ s/^.*?SymbianOS[^\/]*\/(\d+\.\d+).*$/SymbianOS\/$1/io ; }
  elsif ($agent2 =~ /Symbian.*OS/io)    { $os = "SymbianOS/0.0" ; }
# elsif ($agent2 =~ /Linux i686/io)     { $os = "Linux i686" ; }
# elsif ($agent2 =~ /Linux x86_64/io)   { $os = "Linux x86_64" ; }
# elsif ($agent2 =~ /Linux armv\d+/io)  { $os = "Linux armv" ; }
# elsif ($agent2 =~ /Linux ppc\d+/io)   { $os = "Linux ppc" ; }
# elsif ($agent2 =~ /Linux mips/io)     { $os = "Linux mips" ; }
  elsif ($agent2 =~ /Linux/io)          { $os = "Linux" ; }
  elsif ($agent2 =~ /Win95/io)          { $os = "Windows 95" ; }
  elsif ($agent2 =~ /Win(?:dows)[+\s-]?98/io) { $os = "Windows 98" ; }
  elsif ($agent2 =~ /Win(?:dows)?[+\s-]?9x/io) { $os = "Windows 9x" ; }
  elsif ($agent2 =~ /WinNT4.0/io)       { $os = "Windows NT 4.0" ; }
  elsif ($agent2 =~ /Windows XP/io)     { $os = "Windows XP" ; } # Windows XP 2600.xpsp.14648-27197 -> Windows XP
  elsif ($agent2 =~ /Windows CE/io)     { $os = "Windows CE" ; }
  elsif ($agent2 =~ /Windows; PPC/io)   { $os = "Windows CE" ; }
  elsif ($agent2 =~ /NT \d+\.\d+.*Windows/io) { ($os = $agent2) =~ s/^.*?NT (\d+\.\d+).*$/Windows NT $1/io ; }
  elsif ($agent2 =~ /Windows NT \d+\.\d+/io) { ($os = $agent2) =~ s/^.*?Windows NT (\d+\.\d+).*$/Windows NT $1/io ; }
  elsif ($agent2 =~ /Windows NT/io)     { $os = "Windows NT" ; }
  elsif ($agent2 =~ /Windows VISTA/io)  { $os = "Windows VISTA" ; }
  elsif ($agent2 =~ /Windows 7/io)      { $os = "Windows 7" ; }
# elsif ($agent2 =~ /Windows/io)        { ($os = $agent2) =~ s/^.*?(Windows.{10,10}[^;\(\)\[\]]*).*$/$1/io ; }
  elsif ($agent2 =~ /Windows/io)        { $os = "Windows" ; }
  elsif ($agent2 =~ /Win32/io)          { $os = "Windows 32" ; }
  elsif ($agent2 =~ /Wii/io)            { $os = "Wii" ; }
  elsif ($agent2 =~ /SonyEricsson/io)   { $os = "SonyEricsson" ; }
  elsif ($agent2 =~ /Samsung/io)        { $os = "Samsung" ; }
  elsif ($agent2 =~ /Nokia/io)          { $os = "Nokia" ; }
  elsif ($agent2 =~ /Palm Pre/io)       { $os = "Palm Pre" ; }
  elsif ($agent2 =~ /Vodafone/io)       { $os = "Vodafone" ; }
  elsif ($agent2 =~ /Danger/io)         { $os = "Danger" ; }
  elsif ($agent2 =~ /J2ME\/MIDP/io)     { $os = "Java/ME" ; }
  elsif ($agent2 =~ /Kindle/io)         { $os = "Kindle" ; }
  elsif ($agent2 =~ /Dalvik/io)         { $os = "Android" ; }

  if (($os eq '..') && ($mobile eq 'M' || $mobile eq 'W'))
  {
    $os = "Mobile other" ;
    $mobile_other {$agent2} += $count_event ; 
  }

  if ($version =~ /(?:iPod|iPhone|iPad)/io)
  {
    if ($os !~ /Iphone OS \d/io)
    { $os = "iPhone OS 1_X" ; }
    if ($agent2 !~ /(?:Opera|Safari)/io)
    { $agent2 .= " Safari/0.0" ; }
  }
  elsif ($version =~ /(?:Ipad)/io)
  {
    if ($os !~ /Ipad OS \d/io)
    { $os = "iPad OS 1_X" ; }
    if ($agent2 !~ /(?:Opera|Safari)/io)
    { $agent2 .= " Safari/0.0" ; }
  }

  if (($os =~ /Mac/o) && ($agent2 =~ /OS X/o))
  {
    ($osx = $agent2) =~ s/^.*?(OS X[^;\(\)\[\]]*).*$/$1/o ;
    $osx =~ s/(\d+\_\d+).*$/$1/o ;
    $osx =~ s/_/\./o ;
    $os = "$os $osx" ;
  }

  if ($os =~ /Linux/o)
  {
    ($cpu = $agent2) =~ s/^.*?(armv\d+|i\d+|x[0-9_]+).*$/$1/o ;
    if ($cpu eq $agent2)
    { $cpu = '' ; }

    ($osx = $agent2) =~ s/^.*?((?:Android|Xubuntu|Kubuntu|Ubuntu|Gentoo|PCLinuxOS|CentOS|Oracle|Mandriva|Red Hat|Mandriva|openSUSE|SUSE|Fedora|Epiphany|Mint|Mips|Arch|Debian|Slackware|Motor\w+)[^\s;\[\]\(\)]*).*$/ucfirst($1)/ieo ;
    if ($osx ne $agent2)
    {
      $osx =~ s/(\d+\_\d+).*$/$1/o ;
      $osx =~ s/^([^-]*)-/$1\//o ; # Debian-1.0 -> Debian/1.0
      $osx =~ s/_/\./o ;
      $osx =~ s/(\d+\.\d+).*$/$1/o ;
      $osx =~ s/^(Motor)(\w+).*$/ucfirst(lc($1)).uc($2)/ieo ;
    }
    else
    { $osx = "Other" ; }

    $os = "$os $cpu $osx" ;
    $os =~ s/\s\s+/ /g ;

    # testing:
    # if ($osx eq $agent2)
    # { print "Linux ?? -> $agent2\n" ; }
    # elsif ($osx !~ /(?:Android|Ubuntu)/i)
    # { print "Linux !! $cpu $osx -> $agent2\n" ; }
  }

  $os =~ s/(Windows NT \d+\.\d+).*$/$1/o ;

  if ($bot)
  { $agent2 = "BOT $agent2" ; }

  elsif ($agent2 eq "-")
  {;}

  # KINDLE
  elsif ($agent2 =~ /Kindle/io)
  { ($version = $agent2) =~ s/^.*?(Kindle \d+\.\d+).*$/$1/io ; }

  # IEMOBILE
  elsif ($agent2 =~ /IEMobile/io)
  { ($version = $agent2) =~ s/^.*?(IEMobile \d+\.\d+).*$/$1/io ; }

  # PALM PRE
  elsif ($agent2 =~ /webOS\/\d+\.\d+.*Pre\/\d/io)
  { ($version = $agent2) =~ s/^.*?(Pre\/\d+\.?\d*).*$/Palm_$1/o ; }

  # OPERA
  # new format
  elsif ($agent2 =~ /^Opera\/\d/io)
  {
    if ($agent2 =~ /Version\//o)
    { ($version = $agent2) =~ s/^.*?Version\/(\d+\.\d+).*$/Opera\/$1/o ; }
    else
    { ($version = $agent2) =~ s/^.*?(Opera\/\d+\.\d+).*$/$1/o ; }

    $agent2 =~ s/Windows NT \d\.\d/Windows/o ;
    $agent2 =~ s/X11; Linux [^;]+/Linux/o ;
    $agent2 =~ s/(Opera Mini\/\d+\.\d+)[^;\) ]+/$1/o ;
    $agent2 =~ s/J2ME\/MIDP/Java mobile (J2ME)/o ; # J2ME\/MIDP

    $agent2 = &ExtractLanguage ($agent2, 'Opera') ;

    if ($agent2 =~ /Opera Mini/o)
    {
      if ($agent2 =~ /Opera Mini\/\d+\.\d+/o)
      { ($mini = $agent2) =~ s/^.*?Opera (Mini\/\d+\.\d+).*$/$1/o ; }
      else
      { $mini = "Mini/?.?" ; }
      $version = "$version ($mini)" ;
    }
    elsif ($agent2 =~ /Opera Mobi/o)
    {
      if ($agent2 =~ /Opera Mobi\/\d+\.\d+/o)
      { ($mobi = $agent2) =~ s/^.*?Opera (Mobi\/\d+\.\d+).*$/$1/o ; }
      else
      { $mobi = "Mobi/?.?" ; }
      $version = "$version ($mobi)" ;
    }

    $version =~ s/^\s*(.*?)\s*$/$1/o ;
  }

  # old format
  elsif ($agent2 =~ /^Mozilla.*\(compatible.*Opera \d/io)
  {
    $agent2 =~ s/Opera (\d+\.\d+)/Opera\/$1/o ;
    $agent2 =~ s/Windows NT \d\.\d/Windows/o ;
    $agent2 =~ s/X11; Linux [^;\)]+/Linux/o ;
    ($version = $agent2) =~ s/^.*?(Opera\/\d+\.\d+).*$/$1/o ;
    $version =~ s/^\s*(.*?)\s*$/$1/o ; # remove leading/trailing spaces
  }

  # CHROME MOBILE
  elsif ($agent2 =~ /CrMo\/\d+/io)
  { ($version = $agent2) =~ s/^.*?(CrMo\/\d+\.\d+).*$/$1/o ; 
    $version =~ s/CrMo/ChromeMobile/o ;
  }

  # DALVIK (applications on Android)
  elsif ($agent2 =~ /Dalvik\/\d+/io)
  { ($version = $agent2) =~ s/^.*?(Dalvik\/\d+\.?\d*).*$/$1/o ; }

  # ANDROID
  elsif ($agent2 =~ /Android\/\d+/io)
  { ($version = $agent2) =~ s/^.*?(Android\/\d+\.?\d*).*$/$1/o ; }

  # EXPLORER
  elsif ($agent2 =~ /Mozilla\/\d+\.\d+ \(compatible;.*MSIE/io)
  { ($version = $agent2) =~ s/^.*?(MSIE \d+\.\d+).*$/$1/o ; }

  # CHROME
  elsif ($agent2 =~ /Chrome\/\d/io) # Chrome sometimes mimicked Safari to work around Hotmail bug
  {
    $agent2 =~ s/Windows NT \d\.\d/Windows/o ;
    $agent2 =~ s/(Chrome\/\d+\.\d+)[^;\) ]+/$1/o ;

    $agent2 = &ExtractLanguage ($agent2, 'Chrome') ;

    ($version = $agent2) =~ s/^.*?(Chrome\/\d+\.\d+).*$/$1/o ;
  }

  # SAFARI
  elsif ($agent2 =~ /Safari\/[^\s]+$/io)
  {
    $agent2 = &ExtractLanguage ($agent2, 'Safari') ;
    $agent2 =~ s/(Safari\/\d+\.\d+)[^;\) ]+/$1/o ;
    if ($agent2 =~ /Safari\/\d+\.\d+/o)
    { ($version = $agent2) =~ s/^.*?(Safari\/\d+\.\d+).*$/$1/o ; }
    elsif ($agent2 =~ /Safari\/\d+/o)
    { ($version = $agent2) =~ s/^.*?(Safari\/\d+).*$/$1/o ; }
  }

  # FIREFOX
  elsif ($agent2 =~ /Firefox\/[^\s]+/io)
  {
    $agent2 = &ExtractLanguage ($agent2, 'Firefox') ;
    $agent2 =~ s/X11; Linux [^;]+/Linux/o ;
    $agent2 =~ s/(Firefox\/\d+\.\d+)[^;\) ]+/$1/o ;

    if ($agent2 =~ /Firefox\/\d+\.\d+/o)
    { ($version = $agent2) =~ s/^.*?(Firefox\/\d+\.\d+).*$/$1/o ; }
    elsif ($agent2 =~ /Firefox\/\d+/o)
    { ($version = $agent2) =~ s/^.*?(Firefox\/\d+).*$/$1/o ; }
  }

  # BLACKBERRY
  elsif ($agent2 =~ /BlackBerry\d+/io)
  {
    $agent2 =~ s/(\/\d+\.\d+).*$/$1/o ;
    $agent2 =~ s/BlackBerry/BlackBerry\//o ;
    $version = $agent2 ;
  }

  # KONQUEROR
  elsif ($agent2 =~ /Konqueror\/\d/io) # Chrome sometimes mimicked Safari to work around Hotmail bug
  {
    $agent2 =~ s/(Konqueror\/\d+\.\d+)[^;\) ]+/$1/o ;

    ($version = $agent2) =~ s/^.*?(Konqueror\/\d+\.\d+).*$/$1/o ;
  }

  # WGET
  elsif ($agent2 =~ /Wget\/\d/io)
  {
    $agent2 =~ s/(Wget\/\d+\.\d+)[^;\) ]+/$1/io ;

    ($version = $agent2) =~ s/^.*?Wget\/(\d+\.\d+).*$/$1/io ;
  }

  elsif ($os =~ /Iphone OS \d/io)
  { $os = "iPhone OS 1_X" ; }
  elsif ($os =~ /Ipad OS \d/io)
  { $os = "iPad OS 1_X" ; }

  else
  {
    $browserfound = $false ;

    @browsers = qw (GranParadiso IceWeasel JigBrowser K-Meleon NetFront Netscape SeaMonkey Shiretoko Sleipnir Songbird) ;
    foreach $browser (@browsers)
    {
      if ($agent2 =~ /$browser/i)
      {
        ($version = $agent2) =~ s/.*?($browser\/\d+\.\d+).*$/$1/i ;
        $browserfound = $true ;
        last ;
      }
    }
    if (! $browserfound)
    {
      ($version = $agent2) =~ s/(^[a-zA-Z0-9-_]+\/\d+\.\d+).*$/$1/io ;
      $version =~ s/[;\[\]\(\)].*$//o ;
      $version =~ s/(\d+\.\d+).*$/$1/o ;
    }

    $agent2  = "*[$version] [$os] --- $agent2" ;
  }

  if ((! $bot) && ($agent ne "-"))
  {
    $engine  =~ s/,/&comma;/go ;
    if ($gecko ne "")
    { $engines {$gecko} += $count_event ; }
    elsif ($applewebkit ne "")
    {
      $applewebkit =~ s/AppleWebKit\//AppleWebKit /o ;
      $engines {$applewebkit} += $count_event ; ;
    }

    $version =~ s/,/&comma;/go ;
    if ($os =~ /playstation/io)
    { $version = "NetFront (PlayStation)" ; }

    $clients {"$mobile,$version,$mimecat"} += $count_event ; ;

    $operating_systems =~ s/,/&comma;/go ;
    $operating_systems {"$mobile,$os"} += $count_event ; ;
  }

  if ($count_hits_per_ip_range)
  {
    $client_ip_range = $client_ip ;
    $client_ip_range =~ s/\.\d+$//o ;
    $cnt_ip_ranges {$client_ip_range}++ ;
  }

  if ($status =~ /^TCP/)
  {
    $statusses {"$method:$status"} += $count_event ;
    $statusses {"$method:total"}   += $count_event ;
  }
  else
  { $statusses_non_tcp += $count_event ; }

  if ($url =~ /org\/skins/o)
  {
    ($url2 = $url) =~ s/^.*?\/skins/skins/o ;
    $skins {$url2} += $count_event ; ;
  }

  if ($url =~ /^upload\.wikimedia\.org\//o) # count image size if applicable
  { &ProcessUploadPath ($url) ; }

  ($url2 = $url) =~ s/\.php\?.*$/\.php\?../go ;
  ($domain,$location) = split ('\/',$url2,2) ;
  $domain_original = $domain ;

  # for diagnostics
  if (($referer =~ /google/o) || ($agent =~ /google/io))
  { $googles += $count_event ; }

  $referer =~ s/^http\w?\:\/\///o ;
  $referer =~ s/\.php\?.*$/\.php\?../go ;
  $referer =~ s/\/.*$//o ;
  $referer_original = $referer ;

  # $domain_mobile = $false ;
  # if ($domain =~ /m\.wikipedia/o)
  # {
  #   print "Domain 1 $domain\n" ;
  #   $domain_mobile = $true ;
  # }

  $domain  = &Abbreviate ($domain) ;
  if (($domain =~ /\./o) ||
      ($domain !~ /^[\*\@\%]?!(wb|wn|wp|wq|ws|wv|wk|wx|xx|wm|mw|wmf)\:/o))
  {
    $unrecognized_domains {$domain_original} += $count_event ;
    $domain = 'other' ;
  }

  # if ($domain_mobile)
  # { print "Domain 2 $domain\n" ; }

  # $referer_mobile = $false ;
  # if ($referer =~ /m\.wikipedia/o)
  # {
  #   print "Referer 1 $referer\n" ;
  #   $referer_mobile = $true ;
  # }

  $referer = &Abbreviate ($referer) ;
  $referer_external = ($referer !~ /^[\*\@]?!(wb|wn|wp|wq|ws|wv|wk|wx|xx|wm|mw|wmf)\:/o) ;

  if ($referer_external)
  {
    $tot_referers_external += $count_event ; ;

    ($origin, $toplevel) = &DetectOrigin ($client_ip, $referer_original, $agent, $mime, $mimecat, $service, $ext) ;

    &CountOrigin ("external", $origin, $toplevel, $mimecat) ;

    if ($origin !~ /^\!/o)
    { $origins_unsimplified {$referer_original} += $count_event ; }
    else
    {
      $origin_simplified {"$origin [$referer] <- $referer_original"} += $count_event ; ;
      $origins_external   {$origin} += $count_event ;
    }
  }
  else
  {
    $tot_referers_internal += $count_event ;
    $referers_internal {$referer} += $count_event ;
    $referer =~ s/!//go ; # ! was marker to signal pattern was recognized as wikimedia project
    &CountOrigin ("internal", $referer, "org" , $mimecat) ;
  }

  $domain  =~ s/!//o ;
  $referer =~ s/!//o ;
  $domain  =~ s/\:\d+$//o ; # remove port number
  $referer =~ s/\:\d+$//o ; # remove port number
  if ($domain =~ /!/o)
  { print ERR "still ! in domain: '$domain' <- '$domain_original'\n" ; }

  $requests {"$domain|$referer|$ext|$mime|$parm"} += $count_event ; ;
  $clients_by_wiki {"$mobile,$version,$domain"}   += $count_event ; ;

  # different output use either 'bot=N' or 'M'(anual) / 'bot=Y' or 'B'(ot)
  if ($bot)
  {
    $ind_bot  = 'bot=Y' ;
    $ind_bot2 = 'B' ;
  }
  else
  {
    $ind_bot  = 'bot=N' ;
    $ind_bot2 = 'M' ;
  }

  if (($domain =~ /^\@/) || ($domain =~ /^\*/))
  {
    # print "Requests wap $domain | $ext | $mime | $parm | $country | $ind_bot\n" ;
    $requests_wap {"$domain|$ext|$mime|$parm|$country|$ind_bot"} += $count_event ; ;
  }

  if ($domain =~ /^\%/)
  {
    # print "Requests m $domain | $ext | $mime | $parm | $country | $ind_bot\n" ;
    $requests_m {"$domain|$ext|$mime|$parm|$country|$ind_bot"} += $count_event ; ;
  }
                              # $title !~ /:/ -> only namespace 0 (minus few titles with colon in name)
  if (($url =~ /index.php\?/o) && ($title !~ /:/o) && ($mime eq "text/html") && (($url =~ /action=edit/o) || ($url =~ /action=submit/o)))
  {

    if (($referer ne "-") && ($referer !~ /^..:/o))
    { $referer = "ext" ; }

    $key = "$client_ip|$ind_bot|$domain|$referer|$status|$mime|$parm" ;
    $key =~ s/,/&comma;/go ;
    $key =~ s/\|/,/go ;

    $index_php_raw {$key} += $count_event ; ;
    $client_ip_record_cnt {$client_ip}++ ;
  }

  if ($mimecat eq "page")
  {
    $tot_mime_html2 += $count_event ;

    if (($ind_bot =~ /N/) and ($ip_frequencies {$client_ip} > 2))
    { $ind_bot = 'bot=Y' ; }

    $countries_views {"$ind_bot,$domain,$country"} += $count_event ; ;
                                  # $title !~ /:/ -> only namespace 0 (minus few titles with colon in name)
    if (($url =~ /index.php\?/o) && ($title !~ /:/) && ($mime eq "text/html") && ($url =~ /action=submit/o) && ($status =~ /302/o))
    { $countries_saves {"$ind_bot,$domain,$country"} += $count_event ; }

    $time_hh = substr ($time,11,2) ;
    $time_mm = substr ($time,14,2) ;
    $time_tt = $time_hh * 60 + $time_mm ;
    $time_tt2 = $time_tt - $time_tt % 15 ;
    $countries_timed {"$ind_bot,$domain,$country,$time_tt2"} += $count_event ;

    if (! $test)
    {
      $time2    = substr ($time,0,19) ; # omit msec
      $line = "$time2,$client_ip,$domain,$ind_bot2,$mobile,$os,$version,$mimecat\n" ;
      $gz_csv_views_viz->gzwrite($line) || die "Zlib error writing to $file_csv_views_viz: $gz_csv_views_viz->gzerror\n" ;
    }
  }

  $records {"$mobile,$mimecat"} += $count_event ;
  $records {"*,$mimecat"}       += $count_event ;
  $records {"$mobile,*"}        += $count_event ;
  $records {"*,*"}              += $count_event ;
}

sub ExtractLanguage
{
  my $agent = shift ;
  my $application = shift ;
  my $language ;

  $regexp_lang = "[a-z]{2}(?:-[a-zA-Z]{2,3})?(?:-[a-zA-Z]{2,3})?" ;
  ($language = $agent) =~ s/^.*?; ($regexp_lang)[\);].*$/$1/o ;
  if ($language eq $agent)
  { $languages_unrecognized {$agent} += $count_event ; }
  else
  {
    $languages {"$application,$language"} += $count_event ;
    $agent =~ s/ $language//o ;
  }
  return ($agent) ;
}

sub GetFileExt
{
  my $url = shift ;
  my ($file, $ext) ;
  $url =~ s/\?.*$//o ;
  ($file = $url) =~ s/^([^\/]*\/)+//o ; # drop path before file

  if ($file =~ /^[^\.]*$/o) # no extension
  { $ext = "none" ; }
  else
  {
    ($ext = $file) =~ s/^.*?\.([^\.]+)$/$1/o ;
    if ($ext =~ /[^a-zA-Z]/o)
    { $ext = "invalid" ; }
  }
  $ext = lc ($ext) ;
  $ext =~ s/^(jpg|jpeg)$/jp[e]g/go ;

  return ($file, $ext) ;

  # obsolete alternate code ?
  # implied php request returns html
  #     if ($url =~ /\/wiki\//o)       { $ext = "html <- /wiki/" ; }
  #  elsif ($url =~ /\.org\/?$/o)      { $ext = "html <- *.org" ; }
  #  elsif ($url =~ /\.com\/?$/o)      { $ext = "html <- *.com" ; }
  #  elsif ($url =~ /\/wiki\?title=/o) { $ext = "html <- /wiki?title=.." ; }
  #
  #  if ($mime =~ /(?:xml|html)/o)
  #  { $ext = "none (mimetype:$mime)" ; }
  #  else
  #  {
  #    $url =~ s/\?.*$//o ;
  #    ($file = $url) =~ s/^([^\/]*\/)+//o ; # drop path before file
  #
  #    if ($file =~ /^[^\.]*$/o) # no extension
  #    { $ext = "none (mimetype:$mime)" ;
  #     print "\n\n$mime\n$line\n" ;
  #    $ext = "none" ; }
  #    else
  #    {
  #      ($ext = $file) =~ s/^.*?\.([^\.]+)$/$1/o ;
  #      if ($ext =~ /[^a-zA-Z]/o)
  #      { $ext = "invalid" ; }
  #    }
  #  }
  #
  #  $ext = lc ($ext) ;
  #  $ext =~ s/^(jpg|jpeg)$/jp[e]g/go ;
  #
  #  return ($file, $ext) ;
}

sub NormalizeParms
{
  my $url = shift ;

  $invalid = $false ;
  my ($url2,$parm) = split ('\?', $url) ;
  $parm =~ s/^\&+//o ;
  $parm =~ s/\&+$//o ;
  $parm =~ s/\&\&+/\&/o ;
  $parm =~ s/\&quot;/'/go ; # invalid in url ?, accept for now
  @parms = split ('\&', $parm) ;
  @parms = sort @parms ;

  foreach $parm (@parms)
  {
    next if $parm eq '' ;
    next if $parm eq '*' ;

    if (($parm !~ /=/) && ($parm !~ /^[\w\d\-\_]+$/o))
    { $error = "parm probably invalid: '$parm' in '$url' -> skip\n" ; $invalid = $true ; last }

    ($keyword,$data) = split ('\=', $parm) ;
    if ($keyword eq "")
    { $keyword = "[empty]" ; }
    if ($keyword ne "redlink")
    {
      if (($keyword !~ /^(?:action|ctype|gen|usemsgcache)$/) || ($data !~ /^[a-zA-Z\-\_\/]*$/o))
      { $parm =~ s/=.+/=../o ; } # show generalized version of parameter, without specifics
    }
  }

  if ($invalid)
  {
    print $error ;
    print ERR $error ;
    return ("?","?") ;
  }

  $parm  = join ('&', @parms) ;
  $url = "$url2\?$parm" ;
  return ($url,$parm) ;
}

sub Abbreviate
{
  my $domain = shift ;

  $domain =~ s/www\.([^\.]+\.[^\.]+\.[^\.]+)/$1/o ;
  $domain =~ s/\.com/\.org/o ;
  $domain =~ s/^([^\.]+\.org)/www.$1/o ;

  if ($domain !~ /\.org/o)
  { $domain =~ s/www\.(wik[^\.\/]+)\.([^\.\/]+)/$2.$1.org/o ; }

  $legend  = "# wx = wikispecial (commons|mediawiki|meta|foundation|species)\n" ;
  $legend .= "# xx:upload = upload.wikimedia.org\n" ;
  $domain =~ s/commons\.wikimedia\.org/!wx:commons/o ;
  $domain =~ s/www\.mediawiki\.org/!wx:mediawiki/o ;
  $domain =~ s/meta\.wikipedia\.org/!wx:meta/o ;
  $domain =~ s/meta\.wikimedia\.org/!wx:meta/o ;
  $domain =~ s/foundation\.wikimedia\.org/!wx:foundation/o ;
  $domain =~ s/species\.wikimedia\.org/!wx:species/o ;
  $domain =~ s/upload\.wikimedia\.org/!xx:upload/o ;

  $legend .= "# wmf = wikimediafoundation\n" ;
  $legend .= "# wb  = wikibooks\n" ;
  $legend .= "# wn  = wikinews\n" ;
  $legend .= "# wp  = wikipedia\n" ;
  $legend .= "# wq  = wikiquote\n" ;
  $legend .= "# ws  = wikisource\n" ;
  $legend .= "# wv  = wikiversity\n" ;
  $legend .= "# wk  = wiktionary\n" ;
  $legend .= "# wm  = wikimedia\n" ;
  $legend .= "# mw  = mediawiki\n" ;
  $legend .= "# \@   = .mobile.\n" ;
  $legend .= "# \*   = .wap.\n" ;
  $legend .= "# \%   = .m.\n" ;

  $domain =~ s/wikimediafoundation/!wmf/o ;
  $domain =~ s/wikibooks/!wb/o ;
  $domain =~ s/wikinews/!wn/o ;
  $domain =~ s/wikipedia/!wp/o ;
  $domain =~ s/wikiquote/!wq/o ;
  $domain =~ s/wikisource/!ws/o ;
  $domain =~ s/wikiversity/!wv/o ;
  $domain =~ s/wiktionary/!wk/o ;
  $domain =~ s/wikimedia/!wm/o ;
  $domain =~ s/mediawiki/!mw/o ;

  $domain =~ s/\.mobile\./.@/o ;
  $domain =~ s/\.wap\./.*/o ;
  $domain =~ s/\.m\./.%/o ;

  if ($domain =~ /^error:/o)
  { $domain_errors {$domain} += $count_event ; }
  $domain =~ s/error:.*$/!error:1/o ;

  $domain =~ s/^([^\.\/]+)\.([^\.\/]+)\.org/$2:$1/o ;

  $domain =~ s/\s//g ;

  return ($domain) ;
}

sub DetectOrigin
{
# this simplification is a rather loose approximation, not rigidly according to domain name standards, as that would require further study

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

  $client_ip =~ s/\:\d+$//o ;
  $referer   =~ s/\:\d+$//o ;

  my $referer_original = $referer ;
  my $origin ;

  if ($referer ne '-')
  { $origin = $referer ; }
  else
  { $origin = $client_ip ; }

  my $origin_original = $origin ;

  if (is_valid_ip_address ($client_ip)) # always ?
  { $client_ip = &MatchIpRange ($client_ip) ; }

  if (is_valid_ip_address ($referer)) # never ?
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
      $referer =~ s/$pattern_url_post//o ;
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

    # test code
    # if ($secondary_domain !~ /(?:-|google|yahoo)/o)
    # { print "$secondary_domain <= $referer\n" ; }
  }

  ($service,$agent) = &MatchAgent ($agent, $client_ip, $mime, $ext) ;

  if (($top_level_domain eq "-") && ($client_ip =~ /!google:ip/io))
  { $top_level_domain = "ip:$service" ; }

  if (($client_ip =~ /!.*google/io) || ($referer =~ /!.*google/io) || ($agent =~ /!.*google/io))
  {
    if ($referer =~ /!.*google/io)
    { $origin = "google (by referer)" } #  $referer_original ; }
    elsif ($client_ip =~ /!.*google/io)
    { $origin = "google (by ip)" ; }
    else
    { $origin = "google (by agent)" ; }

    if ($client_ip =~ /!.*google/io) { $google_x = "x" ; } else { $google_x = "-" ; }
    if ($referer   =~ /!.*google/io) { $google_y = "y" ; } else { $google_y = "-" ; }
    if ($agent     =~ /!.*google/io) { $google_z = "z" ; } else { $google_z = "-" ; }

    $googlematch = "$google_x $google_y $google_z" ;

    $referer2 = $referer ; if ($referer2 !~ /^!.*google:/io) { $referer2 = ".." ; } else { $referer2 =~ s/^!google://o ; }
    $agent2 = $agent ;     if ($agent2   !~ /^!.*google:/io) { $agent2 = ".." ; }   else { $agent2   =~ s/^!google://o ; }

    $top_level_domain =~ s/^.*\.//o ; # co.uk -> uk

    if (($service eq "..") && ($referer =~ /!google:/o) && ($referer !~ /!google:ip/o))
    { ($service = $referer) =~ s/^.*?:(.*$)/ucfirst($1)/eo ; }

    if (($service eq "GoogleBot") && ($client_ip !~ /!.*google/io))
    { $service = "GoogleBot?" ; }

    $service =~ s/^\.\.$/Other/o ;

    # only found in agent string -> except Google Earth and Google Desktop, ignore others (Toolbar , GoogleBot)
    $accept = "   " ;
    if (($googlematch eq "- - z") && ($service =~ /GoogleBot/io))
    {
      $service = "GoogleBot?" ;
      $google_imposters {$agent} += $count_event ;
    }

    # obsolete? to be considered ?
    # if (($googlematch ne "- - z") || ($service =~ /(?:Earth|Desktop)/o))
    # { $search {"'$googlematch',google,$referer2,$service,$agent2,$mimecat,$top_level_domain"} += $count_event ; }
    # else
    # { $accept = "not" ; }

    $search {"'$googlematch',google,$referer2,$service,$agent2,$mimecat,$top_level_domain"} += $count_event ;

    $googlebins2 {"$accept [$googlematch]  " . sprintf ("%-14s",$service) . $referer} ++ ;
    $googlebins {$googlematch}++ ;
  }

  # test only: make yahoo's treatment of languages look like google's
  # $origin =~ s/^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+\.yahoo.com)/$2.$1/o ;


   $origin =~ s/^localhost(\:.*)?$/!localhost/o ;
   $origin =~ s/\:\d+$//o ; # remove port number

  # $origin =~ s/${pattern_url_pre}mail\.live$/!microsoft live mail/o ;
  # $origin =~ s/${pattern_url_pre}msn.$/!microsoft MSN/o ;
  # $origin =~ s/${pattern_url_pre}msdn.$/!microsoft MSDN/o ;

  # $origin =~ s/${pattern_url_pre}dailynews\.yahoo$/!yahoo news/o ;
  # $origin =~ s/${pattern_url_pre}mail\.yahoo$/!yahoo mail/o ;
  # $origin =~ s/${pattern_url_pre}search.yahoo$/!yahoo search/o ;

  # if (($origin !~ /^ip:!/o) && ($origin !~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})/o))
  # {
  #   $origin =~ s/${pattern_url_pre}([a-zA-Z0-9-]+)$/!$1/o ;
  #   print "$origin\n" ;
  #  }

  if ($origin =~ /wiki/o)
  { $wikis {$origin} += $count_event ; }

  if ($origin eq "wikipedia")
  {
    # print "incomplete origin: $origin <= $referer_original\n$line\n\n" ;
    $origin = "!error:4" ;
  }

  return ($origin, $top_level_domain) ;
}

sub MatchAgent
{
  my $agent     = shift ;
  my $client_ip = shift ;
  my $mime      = shift ;
  my $ext       = shift ;

  ($client_ip_range = $client_ip) =~ s/\.\d+\.\d+$//o ;

  $service = '..' ;
  if ($agent =~ /google/io)
  {
       if ($agent =~ /Googlebot/io)                      { $service = "GoogleBot" ;   $agent = "!GoogleBot" ; }
    elsif ($agent =~ /FeedFetcher-Google/io)             { $service = "FeedFetcher" ; $agent = "!FeedFetcher-Google" ; }
    elsif ($agent =~ /Google.*?Wireless.*?Transcoder/io) { $service = "Wireless" ;    $agent = "!GoogleWirelessTranscoder" ; }
    elsif ($agent =~ /Google.*?Desktop/io)               { $service = "Desktop" ;     $agent = "!GoogleDesktop" ; }
    elsif ($agent =~ /GoogleEarth/io)                    { $service = "Earth" ;       $agent = "!GoogleEarth" ; }
    elsif ($agent =~ /GoogleToolbar/io)                  { $service = "Toolbar" ;     $agent = "!GoogleToolbar" ; }
    elsif ($agent =~ /Google.*?Keyword.*?Tool/io)        { $service = "KeywordTool" ; $agent = "!GoogleKeywordTool" ; }
    elsif ($agent =~ /GoogleT\d/io)                      { $service = "Toolbar" ;     $agent =~ s/^.*?(GoogleT\d+).*$/"!".$1/e ; }
    elsif ($agent =~ /translate\.google\.com/io)         { $service = "Translate" ;   $agent = "!GoogleTranslate" ; }
    else                                                { $service = "Other" ;       $agent = "!GoogleOther" ; }

    $googlebots {"$agent,$client_ip_range,$service,$mime,$ext"} ++ ;
  }

#  if ($agent =~ /yahoo/io)
#  {
#    if ($agent =~ /ysearch\/slurp/o)
#    { $service = "bot" ; $agent = "!YahooBot" ; }

#    @yahoobots {"$agent,$client_ip_range,$mime,$ext"} ++ ;
#  }

  return ($service, $agent) ;
}

sub MatchIpRange
{
  my $address = shift ;

  $address =~ s/\:.*$//o ; # remove port number

  # test code
  # $address_original = $address ;

  $address =~ s/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/sprintf("%03d",$1).".".sprintf("%03d",$2).".".sprintf("%03d",$3).".".sprintf("%03d",$4)/eo ;
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

  $address =~ s/IP\d+/ip/o ; # no need for detailed ranges for now

  # test code
  # @fields = split ('\.', $address) ;
  # foreach $field (@fields)
  # { $field =~ s/^0+(\d)/$1/o ; }
  # $address2 = join ('.', @fields) ;
  # if ($address2 ne $address_original)
  # { print "MatchIpRange: '$address2' <- $address_original\n" ; }

  return ($address) ;
}

# see http://en.wikipedia.org/wiki/Domain_name
sub GetTopLevelDomain
{
  my $domain = shift ;
  $domain =~ s/\:\d+$//o ; # remove port number

  if ($domain eq '-')
  { $top_level_domain = '-' ; }
  elsif ($domain =~ /!?localhost/o)
  { $top_level_domain = 'localhost' ; }
  elsif ($domain !~ /.+\..+/o)
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
  $domain =~ s/\:\d+$//o ; # remove port number

  if ($domain !~ /\./)
  { return ($domain) ; }

  $domain =~ s/$pattern_url_post//o ;
  $domain =~ s/^.*?\.([^\.]+)$/$1/o ;
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
    $tot_origins_external_counted += $count_event ;
    $origin =~ s/\:.*$//o ;
    if (is_valid_ip_address ($origin))
    { $origin = "unmatched ip address" ; $toplevel = "" ; }
    elsif ($origin =~ /^!error/o)
    { $origin = "invalid origin" ; $toplevel = "" ; }
    elsif ($origin =~ /^!localhost/o)
    { $origin = "localhost" ; $toplevel = "" ; }
    else
    {
      if (($origin =~ /!/o) && ($origin !~ /!error/o))
      { print "CountOrigin: $origin\n" ; }
      $origin = &GetSecondaryDomain ($origin) ;
      # print "$origin\n" ;
    }
  }
  $origins {"$source,$origin,$toplevel,$mimecat"} += $count_event ;
}

sub ProcessUploadPath
{
  my $url = shift ;
  my ($file,$folder,$path,$size,$sizerange) ;
  ($path = $url) =~ s/^.*?\.org\///o ;
  ($file = $path) =~ s/^.*\/([^\/]*)$/$1/go ; # remove path

  $binaries {$path} += $count_event ; # Jan 2012 store path, not file only

  if ($file =~ /(?:gif|jpg|jpeg|png|svg)$/io)
  {
    ($folder = $path) =~ s/\/[^\/]*$/\//o ; # remove file
    $folder =~ s/\/[^\/]{1,1}\/[^\/]{2,2}\/.*$//o ; # remove /x/yy/ part and beyond
    $folder =~ s/\/[^\/]{1,1}\/[^\/]{2,2}\/.*$//o ; # remove /x/yy/ part and beyond, can occur twice (in thumbs)
    $folder =~ s/\/thumb//o ;
    $folder =~ s/^math\/.*$/math/o ;
    # print "$folder    <-    $upload\n" ;
    if ($file =~ /\d+px/o)
    {
      ($size = $file) =~ s/^.*?(\d+)px.*$/$1/o ;
       $sizerange = sprintf ("%5d",(int ($size / 20)) * 20) . "-"  . sprintf ("%5d",(((int ($size / 20))+1) * 20 - 1)) ;
       $imagesizes {$sizerange} += $count_event ;
    }
    else
    { $imagesizes {"???"} += $count_event ; }
  }
}

1;
