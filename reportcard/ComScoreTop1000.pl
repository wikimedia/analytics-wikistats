#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

  my $seqno = 0 ;
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
  foreach $month (@months_en)
  { $months_seqno {$month} = ++$seqno ; }

  $path_data = "W:/\@ Report Card/Data" ;
  $path_html = "W:/\@ Report Card/Staff" ;

  my $do_normalize = $true ;
  my $no_normalize = $false ;

  $file_csv_ref  = "Reference sites UV_(Oct 09 - Dec 10).csv" ;
  $file_csv_top  = "Top 1000 poperties, UV trend_(Oct 09 - Dec 10).csv" ;
  $file_html_ref = "ComScoreReferenceSites-2010-12.htm" ;
  $file_html_top = "ComScoreTop1000Properties-2010-12.htm" ;

# note normalization needs overhaul: * 30/actual days in month does not work for UV's

#  &ReadCsv ($file_csv_ref,$do_normalize) ;
#  &RankData ;
#  &WriteData ($file_html_ref, $do_normalize, 50, 25, "comScore: Reference sites ranked by unique visitor counts") ;

  &ReadCsv ($file_csv_ref,$no_normalize) ;
  &RankData ;
  &WriteData ($file_html_ref, $no_normalize, 50, 25, "comScore: Reference sites ranked by unique visitor counts") ;

#  &ReadCsv ($file_csv_top,$do_normalize) ;
#  &RankData ;
#  &WriteData ($file_html_top, $do_normalize, 250, 100, "comScore: Top 1000 properties ranked by unique visitor counts") ;

  &ReadCsv ($file_csv_top,$no_normalize) ;
  &RankData ;
  &WriteData ($file_html_top, $no_normalize, 250, 100, "comScore: Top 1000 properties ranked by unique visitor counts") ;

  chdir $path_html ;
  `$file_html_ref` ;
  `$file_html_top` ;

  exit ;

sub ReadCsv
{
  my ($file_csv, $normalize) = @_ ;

  if (! -e "$path_data/$file_csv")
  { print "File not found: $path_data/$file_csv\n" ; return ; }

  undef %types ;
  undef %ranks_now ;
  undef @counts ;
  open CSV, '<', "$path_data/$file_csv" ;
  $headers_found = $false ;
  while ($line = <CSV>)
  {
    chomp $line ;
    $line =~ s/"(\d+),(\d+),(\d+)"/$1$2$3/g ;
    $line =~ s/"(\d+),(\d+)"/$1$2/g ;
    $line =~ s/"([^"]*)"/$1/g ;
    $line =~ s/N\/A/0/g ;
#   if ($line =~ /Total Internet/)
#   {
#     ($d1,$d2,$d3,@internet) = split (',', $line) ;
#     next ;
#    }
#   elsif ($line =~ /^Items/)

    # find month headers
    if ($line =~ /\w\w\w-\d\d\d\d.*?\w\w\w\-\d\d\d\d/)
    {
      ($d1,$d2,$d3,$months) = split (',', $line,4) ;
      print "MONTHS $months\n" ;
      @months = split (',', $months) ;
      $headers_found = $true ;
      next ;
    }
    elsif (($line !~ /^\d/) && ($line !~ /Total Internet/))
    { next ; }
    elsif (! $headers_found)
    { next ; }

    ($rank_now, $type, $site, @counts_site) = split (',', $line) ;

    $shifts_done = 0 ;
    while (($counts_site [0] !~ /^\d+$/) && ($shifts_done++ < 5))
    { $site .= shift @counts_site ; }

    $site =~ s/^\s+// ;
    $site =~ s/\s+$// ;

    if ($site eq "") { next ; }

    $types     {$site} = $type ;
    $ranks_now {$site} = $rank_now ;

    for ($i=0 ; $i <= $#counts_site; $i++)
    {
      my $count = $counts_site [$i] ;

      if ($normalize)
      {
        my ($month,$year) = split "-", $months [$i] ;
        my $month2 = $months_seqno {$month} ;

        if ($month2 == 0)
        { print "Invalid month '$month' in line '$line'\n" ; next }

        my $days_in_month = days_in_month ($year, $month2) ;
        if ($days_in_month == 0)
        { $count_n = "n.a." ; }
        else
        { $count_n = sprintf ("%.0f", ($count * 30/$days_in_month)) ; }
        # print "$year $month -> $days_in_month days ; $count -> $count_n\n" ;
        $count = $count_n ;
      }

      $counts [$i] {$site} = sprintf ("%.0f", $count);
    }
  }
}

sub RankData
{
  for ($i=0 ; $i <= $#months; $i++)
  {
    %data = %{$counts [$i]} ;
    $rank = 0 ;
    for $site (sort {$data {$b} <=> $data {$a}} keys %data)
    {
      $rank++ ;
      $ranks {$site}{$i} = $rank ;
    }
  }
}

sub WriteData
{
  my ($file_html, $normalize, $threshold_filter, $threshold_bold, $title) = @_ ;

#  my $file_alt = $file_html ;
#  if (! $normalize)
#  { $file_html =~ s/\.htm/-o.htm/ ; }
#  else
#  { $file_alt =~ s/\.htm/-o.htm/ ; }
#  $file_alt =~ s/-\d\d\d\d-\d\d// ;

  $header = "<!DOCTYPE FILE_HTML PUBLIC '-//W3C//DTD FILE_HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>\n" .
            "<html lang='en'>\n" .
            "<head>\n" .
            "<title>$title</title>\n" .
            "<meta http-equiv='Content-type' content='text/html; charset=iso-8859-1'>\n" .
            "<meta name='robots' content='index,follow'>\n" .
            "<script language='javascript' type='text/javascript' src='WikipediaStatistics13.js'></script>\n" .
            "<style type='text/css'>\n" .
            "<!--\n" .
            "body {font-family:arial,sans-serif; font-size:12px }\n" .
            "h2   {margin:0px 0px 3px 0px; font-size:18px}\n" .
            "td   {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top}\n" .
            "th   {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top ; font-width:bold}\n" .
            "th.l {text-align:left;   vertical-align:middle ; border: inset 1px #FFFFFF}\n" .
            "th.c {text-align:center; vertical-align:middle ; border: inset 1px #FFFFFF}\n" .
            "th.r {text-align:right;  vertical-align:middle ; border: inset 1px #FFFFFF}\n" .
            "td.h {text-align:left;   vertical-align:middle ; }\n" .
            "td.c {text-align:center; vertical-align:middle ; border: inset 1px #FFFFFF}\n" .
            "td.r {text-align:right;  vertical-align:middle ; border: inset 1px #FFFFFF}\n" .
            "td.l {text-align:left;   vertical-align:middle ; border: inset 1px #FFFFFF}\n" .
            "a:link { color:blue;text-decoration:none;}\n" .
            "a:visited {color:#0000FF;text-decoration:none;}\n" .
            "a:active  {color:#0000FF;text-decoration:none;}\n" .
            "a:hover   {color:#FF00FF;text-decoration:underline}\n" .
            ".d1 { font-size:9px;float:left;width:1%}\n" .
            ".d2 { font-size:12px;font-weight:bold;float:right;width:100%}\n" .
            "-->\n" .
            "</style>\n" .
            "<body bgcolor='\#FFFFDD'>\n<table width=100%>\n<tr><td class=h>\n" .
            "<h2>$title <small><small>(counts x 1000)</small></small> &nbsp;&nbsp;&nbsp;<font color=#FF0000>!! WMF staff use only !!</font></h2>\n</td>\n<td>" .
            "<input type='button' value=' Wikimedia Statistics ' onclick='window.location=\"http://stats.wikimedia.org\"'><br>LINK" .
            "</td></tr>\n</table><hr>\nPRE\n" ;

  # to be localized some day like any reports
  $out_license      = "All data and images on this page are in the public domain." ;
  $out_generated    = "Generated on " ;
  $out_author       = "Author" ;
  $out_mail         = "Mail" ;
  $out_myname = "Erik Zachte" ;
  $out_mymail = "ezachte@### (no spam: ### = wikimedia.org)" ;
  $out_mysite = "http://infodisiac.com/" ;

  $colophon = "<p><small>\n" .
               $out_generated . date_time_english (time) . "\n<br>" .
               $out_author . ":" . $out_myname .
               " (<a href='" . $out_mysite . "'>" . $out_site . "</a>)\n<br>" .
               "$out_mail: $out_mymail<br>\n" .
               "$out_license" .
               "</small>\n" ;

  $delta_rank_year  = "&Delta Year = Rank ${months [$#months-12]} &rArr; ${months [$#months]}" ;
  $delta_rank_month = "&Delta Month = Rank ${months [$#months-1]} &rArr; ${months [$#months]}" ;
  $delta_perc_year  = "% Year = Growth ${months [$#months-12]} &rArr; ${months [$#months]}" ;
  $delta_perc_month = "% Month = Growth ${months [$#months-1]} &rArr; ${months [$#months]}" ;

  $abbreviations = "P = property, M = media title, C = channel, S = subchannel, G = group" ;

  $color_legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                  &TdBgColor ('-50%') .
                  &TdBgColor ('-40%') .
                  &TdBgColor ('-30%') .
                  &TdBgColor ('-20%') .
                  &TdBgColor ('-10%') .
                  &TdBgColor ('0%') .
                  &TdBgColor ('10%') .
                  &TdBgColor ('20%') .
                  &TdBgColor ('30%') .
                  &TdBgColor ('40%') .
                  &TdBgColor ('50%') .
                  "</tr></table></td><td valign=bottom><table border='0'><tr><td>Percentage increase or decrease compared to previous month</td></tr></table></td><tr></table>" ;

  $color = &BgColor ('9%') ;

  $cell_legend  = "<table border=0><tr><td valign=middle>\n" ;
  $cell_legend .= "<table border=1><tr>\n" ;
  $cell_legend .= "<script language='javascript'>\n" ;
  $cell_legend .= "tdc('$color','7&nbsp;&nbsp;&nbsp;+8,&nbsp;+9%','123,456');\n" ;
  $cell_legend .= "</script>\n" ;
  $cell_legend .= "</tr></table></td><td valign=middle>" ;
  $cell_legend .= "= over 123 million unique views, ranks 7th, which is 8 higher than previous month, with 9% more unique views than previous month\n" ;
  $cell_legend .= "</td></tr></table>\n" ;

  $quickdirty = "<b>* Links to external sites are Q&D guesswork based on property name. Some links may not work or misdirect. Try Google.</b><p>" ;
  $relpop     = "Rel. pop. = Relative popularity" ;

  $header =~ s/PRE/<b>Legend<\/b><br>$color_legend<br>$cell_legend<br>$delta_rank_year<br>$delta_rank_month<br>$delta_perc_year<br>$delta_perc_month<br>$abbreviations<br>$relpop<p>$quickdirty<br>/ ;
  $header =~ s/LINK// ;
  $html = $header ;

#  if ($normalize)
#  { $html .= "<b><font color=#008000>View counts on this page have been normalized to months of 30 days only, for fair comparison.</font></b><br>" .
#             "There is also a version with <a href='$file_alt'>original (=not normalized) data.</a><br>&nbsp;" ; }
#  else
#  { $html .= "<b><font color=#800000>View counts on this page have <font color=#FF0000>not</font> been normalized to months of 30 days only.</font></b><br>" .
#             "There is also a version with <a href='$file_alt'>normalized data</a>, for fairer comparison of monthly trends.<br>&nbsp;" ; }

  $html .= "<p>For fastest risers in ranks in a year see <a href=#fast>second table</a> at bottom of page<br>&nbsp;" ;
  $html .= "<table border=1>\n" ;
  $html .= "<tr><td colspan=99 align=left class=l><h2><font color=#C00000>Complete list</font></h2></td></tr>" ;
  $html .= "<tr><th class=l colspan=2>Property</th><th class=c colspan=3>Rank</th><th class=c colspan=2>Growth</th><th class=c>Rel. pop.</th><th class=c colspan=99>Monthly data: Unique Visitors (count x 1000) <small><small>+ Rank + Rang change + Growth percentage</small></small></th></tr>" ;
  $html .= "<tr><th class=l>Site (*)</th><th class=c>Type</th><th class=c>Rank</th><th class=c>&Delta Year</th><th class=c>&Delta Month</th><th class=c>% Year</th><th class=c>% Month</th><th>WM=100</small></th>" ;
  for ($i = $#months; $i >= 0 ; $i--)
  { $html .= "<th class=c>${months[$i]}</th>" ; }
  $html .= "</tr>" ;

  $html_fast_risers = "" ;
  $rank_latest = -1 ;
  foreach $site (sort {$ranks_now {$a} <=> $ranks_now {$b}} keys %ranks_now)
  {
    $html_line = "<tr>" ;
    $rank_latest++ ;

    $site2 = $site ;

    $site2 =~ s/!// ; # Yahoo!
    $site2 =~ s/^The // ; # The mozilla organization
    $site2 =~ s/ sites// ; # Answers.com sites
    $site2 =~ s/Encyclopaedia Britannica/Britannica/i ; # Encyclopaedia britannica

    $site2 =~ s/\*//g ;
    $site3 = $site ;
    $site3 =~ s/\(.*$// ;
    $site2 =~ s/ .*$// ;
    $site3 =~ s/\*//g ;
    $site3 = ucfirst (lc ($site3)) ;

    $site3 =~ s/Encyclopaedia Britannica/Britannica/i ; # Encyclopaedia britannica

    if ($site2 =~ /(?:Total internet|Wikimedia)/i)
    { $site2 = " $site3" ; }
    elsif ($site2 =~ /\.\w\w\w(?: |$)/)
    { $site2 = " <a href='http://www.$site2'>$site3</a>" ; }
    elsif ($site =~ /(?:Google|Microsoft|Yahoo|Facebook|Aol|Ebay|Amazon|Ask network|CBS|Warner|Apple|Fox interactive|Glam|Baidu|wiki|Britannica)/i)
    { $site2 = " <a href='http://www.$site2.com'>$site3</a>" ; }
    elsif ($site =~ /(?:Mozilla|Wordpress)/)
    { $site2 = " <a href='http://www.$site2.org'>$site3</a>" ; }
    else
    { $site2 = "$site3 <small><a href='http://www.$site2.com'>.com</a>/<a href='http://www.$site2.org'>.org</a></small>" ; }

    $type  = $types {$site} ;
    $type =~ s/[^\w]//g ;

    $tag = "td" ;
    if ($site =~ /wikimedia/i)
    { $tag = "th" ; }

    $rank_now        = $ranks {$site}{$#months} -1 ; # -1 because of internet = 'rank 1'
    $rank_year_ago   = $ranks {$site}{$#months-12} -1 ;
    $rank_month_ago  = $ranks {$site}{$#months-1} -1 ;
    $count_now       = $counts [$#months]{$site} ;
    $count_year_ago  = $counts [$#months-12]{$site} ;
    $count_month_ago = $counts [$#months-1]{$site} ;

    $fast_riser = $false ;
    if (($count_now > 0) && ($count_year_ago > 0))
    {
      $rank_delta_year = $rank_year_ago - $rank_now ;
      if ($rank_delta_year >= $threshold_filter)
      { $fast_riser = $true ; }
      if ($rank_delta_year >= $threshold_bold)
      { $rank_delta_year = "<font color=black><b>+$rank_delta_year</b></font>" ; }
      elsif ($rank_delta_year >= 0)
      { $rank_delta_year = "+$rank_delta_year" ; }

      $perc_delta_year = (sprintf ("%.0f", 100*($count_now/$count_year_ago)) - 100) . '%' ;
      if ($perc_delta_year >= $threshold_bold)
      { $perc_delta_year = "<font color=black><b>+$perc_delta_year</b></font>" ; }
      elsif ($perc_delta_year >= 0)
      { $perc_delta_year = "+$perc_delta_year" ; }
    } # 300 => 290 = +10
    else
    {
      $rank_delta_year = "-" ;
      $perc_delta_year = "-" ;
    }

    if (($count_now > 0) && ($count_month_ago > 0))
    {
      $rank_delta_month = $rank_month_ago - $rank_now ;
      if ($rank_delta_month >= 0)
      { $rank_delta_month = "+$rank_delta_month" ; }

      $perc_delta_month = (sprintf ("%.0f", 100*($count_now/$count_month_ago)) - 100) . '%' ;
      if ($perc_delta_month >= 0)
      { $perc_delta_month = "+$perc_delta_month" ; }
    } # 300 => 290 = +10
    else
    {
      $rank_delta_month = "-" ;
      $perc_delta_month = "-" ;
    }

    $relative_size = ".." ;
    if ($counts [$#months]{"Wikimedia Foundation Sites"} > 0)
    { $relative_size = sprintf ("%.1f", 100 * $counts [$#months]{$site} / $counts [$#months]{"Wikimedia Foundation Sites"}) ; }

    $html_line .= "<$tag class=l>$site2</$tag>" ;

    if ($rank_latest == 0) # internet
    {
      $html_line .= "<$tag class=c>n.a.</$tag>" ;
      $html_line .= "<$tag class=c>n.a.</$tag>" ;
      $html_line .= "<$tag class=c>n.a.</$tag>" ;
      $html_line .= "<$tag class=c>n.a.</$tag>" ;
    }
    else
    {
      $html_line .= "<$tag class=c>$type</$tag>" ;
      $html_line .= "<$tag class=c>$rank_latest</$tag>" ;
      $html_line .= "<$tag class=c valign=middle>$rank_delta_year</$tag>" ;
      $html_line .= "<$tag class=c valign=middle>$rank_delta_month</$tag>" ;
    }
    $html_line .= "<$tag class=c valign=middle>$perc_delta_year</$tag>" ;
    $html_line .= "<$tag class=c valign=middle>$perc_delta_month</$tag>" ;
    $html_line .= "<$tag class=c valign=middle>$relative_size</$tag>" ;

    $html_line .= "<script language='javascript'>\n" ;
    for ($i = $#months; $i >= 0 ; $i--)
    {
      $rank = $ranks {$site}{$i} - 1 ;
      $count = $counts [$i] {$site} ;

      if (($i > 0) && ($counts [$i]{$site} > 0) && ($counts [$i-1]{$site} > 0))
      {
        $rank_now = $ranks {$site}{$i} ;
        $rank_month_ago = $ranks {$site}{$i-1} ;
        $rank_delta_month = $rank_month_ago - $rank_now ; # 300 => 290 = +10
        if ($rank_delta_month >= 0)
        { $rank_delta_month = "+$rank_delta_month" ; }
        else
        { $rank_delta_month = "n.a." ; }

        $perc_delta_month = (sprintf ("%.0f", 100*($counts [$i]{$site}/$counts [$i-1]{$site})) - 100) . '%' ;
        if ($perc_delta_month >= 0)
        { $perc_delta_month = "+$perc_delta_month" ; }
      }
      else
      {
        $rank_delta_month = 'n.a.' ;
        $perc_delta_month = 'n.a.' ;
      }

      if ($count > 0)
      {
        $count = &FormatCount ($count) ;

      # copied from WikiReportOutputTables , function BgColor, type 'I'
      $val  = $perc_delta_month ;
      $val =~ s/\%// ;
      $color = &BgColor ($val) ;
      # end copy

        if ($rank > 0)
        { $html_line .= "tdc('$color','$rank&nbsp;&nbsp;&nbsp;$rank_delta_month,&nbsp;$perc_delta_month','$count');\n" ; }
        else
        { $html_line .= "tdc('$color','n.a.','$count');\n" ; }
      }
      else
      {
      # $html_line .= "<td class=r>-<sup>&nbsp;</sup></td>" ;
        $html_line .= "tdc('#FFFFFF','n.a.','-');\n" ;
      }
    }
    $html_line .= "</script>\n" ;
    $html_line .= "</tr>\n" ;

    $html .= $html_line ;
    if ($fast_riser)
    { $html_fast_risers .= $html_line ; }
  }
# $html .= "<tr><td colspan=99 align=left>&nbsp;</td></tr>" ;
  $html .= "</tr><tr><td colspan=99>&nbsp;</td></tr>" ;
  $html .= "<tr><td colspan=99 align=left class=l><a id='fast' name='fast'></a><h2><font color=#C00000>Fastest risers</font>&nbsp;&nbsp;<small>$threshold_filter+ rise in ranks in a year</small></h2></td></tr>" ;
  $html .= "<tr><th class=l colspan=2>Property</th><th class=c colspan=3>Rank</th><th class=c colspan=2>Growth</th><th class=c>Rel. pop.</th><th class=c colspan=99>Monthly data: Unique Visitors (count x 1000) <small><small>+ Rank + Rang change + Growth percentage</small></small></th></tr>" ;
  $html .= "<tr><th class=l>Site</th><th class=c>Type</th><th class=c>Rank</th><th class=c>&Delta Year</th><th class=c>&Delta Month</th><th class=c>% Year</th><th class=c>% Month</th><th>WM=100</small></th>" ;
  for ($i = $#months; $i >= 0 ; $i--)
  { $html .= "<th class=c>${months[$i]}</th>" ; }
  $html .= $html_fast_risers ;
  $html .= "</table>\n" ;


  $html .= $colophon ;
  open HTML, '>', "$path_html/$file_html" ;
  print HTML $html ;
  close HTML ;
  $file_html =~ s/-\d\d\d\d-\d\d// ;
  open HTML, '>', "$path_html/$file_html" ;
  print HTML $html ;
  close HTML ;
}

sub ConvertDate
{
  my $date = shift ;
  my $time = substr ($date,0,5) ;
  my $hour = substr ($time,0,2) ;
  $date =~ s/^[^\s]* // ;
  ($day,$month,$year) = split (' ',$date) ;

     if ($month =~ /^january$/i)    { $month = 1 ; }
  elsif ($month =~ /^february$/i)   { $month = 2 ; }
  elsif ($month =~ /^march$/i)      { $month = 3 ; }
  elsif ($month =~ /^april$/i)      { $month = 4 ; }
  elsif ($month =~ /^may$/i)        { $month = 5 ; }
  elsif ($month =~ /^june$/i)       { $month = 6 ; }
  elsif ($month =~ /^july$/i)       { $month = 7 ; }
  elsif ($month =~ /^august$/i)     { $month = 8 ; }
  elsif ($month =~ /^september$/i)  { $month = 9 ; }
  elsif ($month =~ /^october$/i)    { $month = 10 ; }
  elsif ($month =~ /^november$/i)   { $month = 11 ; }
  elsif ($month =~ /^december$/i)   { $month = 12 ; }
  else { print "Invalid month '$month' encountered\n" ; exit ; }

  $date = sprintf ("%04d/%02d/%02d",$year,$month,$day) ;
  $date2 = sprintf ("=date(%04d,%02d,%02d)",$year,$month,$day) ; # excel

  if ("$date $time" gt $date_time_max)
  { $date_time_max = "$date $time" ; }
  return ($date,$date2,$time,$hour) ;
}

sub FormatCount
{
  my $count = shift ;
  if ($count eq "")
  { return ("&nbsp;") ; }
  if ($count < 1)
  { return ("1") ; }
  $count =~ s/^(\d{1,3})(\d\d\d)$/$1,$2/ ;
  $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
  $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)(\d\d\d)$/$1,$2,$3,$4/ ;
  return ($count) ;
}

sub TdBgColor
{
  my $val  = shift ;
  my $color = &BgColor ($val) ;
  return ("<td width=25 bgcolor=$color>$val</td>") ;
}

sub BgColor
{
  my $val = shift ;
  my $valmax = 50 ;
  my $color ;
  if ($val > $valmax) { $val = $valmax ; }
  if ($val < (0 - $valmax)) { $val = 0 - $valmax ; }

  if ($val == 0)
  { $color = "#FFFFFF " ; }
  elsif ($val > 0)
  {
    $col1 = 255 ;
    $col2 = int (255 - ($val/$valmax) * 200) ;
    $color = "\#" . sprintf ("%02X%02X%02X", $col2, $col1, $col2) ;
  }
  else
  {
    $col1 = 255 ;
    $col2 = int (255 + ($val/$valmax) * 200) ;
    $color = "\#" . sprintf ("%02X%02X%02X", $col1, $col2, $col2) ;
  }
  return ($color) ;
}
