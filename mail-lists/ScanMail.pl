#!/usr/bin/perl

# The script scans for user names in the mailman archives not for mail addresses.
# uses name z from 'From:x at y (z)' ,

  use MIME::Base64;

  $| = 1; # flush screen output

  $false    = 0 ;
  $true     = 1 ;
  $root_in  = '@lists' ;

  if (-e '/[.. path ..]')
  {
    $file_log = '/[.. path ..]/cgi-bin/LogScanMailArchives.txt' ;
    $root_out = '/[.. path ..]/Wikipedia/ScanMail' ;
    $root_in  = '/[.. path ..]/cgi-bin/@lists' ;
    $do_iconv = $true ;
  }
  else
  {
    $file_log = 'LogScanMailArchives.txt' ;
    $root_out = '@html' ;
    $do_iconv = $false ;
  }

  $version  = '0.2' ;
  $datetime = &GetDateTimeEnglishShort (time) ;

  if (!-e $root_in)  { die "Folder $root_in no found\n" ; }
  if (!-e $root_out) { die "Folder $root_out no found\n" ; }

  $timestarted = time ;
  ($sec,$min,$hourstarted,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timestarted);

  &Init ;
  &OpenLog ;
  &ScanFolder ($root_in) ;

  &Log ("\nWrite List Stats\n") ;
  @folders = sort @folders ;
  foreach $folder (@folders)
  { &WriteListStats ($folder) ; }

  @keys = keys %edits_name_tot ;
  undef (@names) ;
  foreach $name (@keys)
  {
    $total = $edits_name_tot {$name} ;
    if ($total < 200) { next ; }
    push @names, $name ;
  }

  @names = sort { $edits_name_tot {$b} <=> $edits_name_tot {$a} } @names ;
  &WriteNameStats ('Board') ;
  foreach $name (@names)
  { &WriteNameStats ($name) ; }

  &WriteTopNameStats ;

  &WriteAliasList ;

  &Log ("\nExecution took " . (time - $timestarted) . " seconds\n") ;
  &Log ("\nReady") ;
  &WriteListIndex ;
  exit ;

sub Init
{
%aliases = (

'Angela_' => 'Angela',
'Angela Beesley' => 'Angela',
'Anthony DiPierro' => 'Anthony',
'Beesley' => 'Angela',
'ArnoLagrange' => 'Arno Lagrange',
'Brion VIBBER' => 'Brion Vibber',
'Brion L. VIBBER' => 'Brion Vibber',
'brion@pobox.com' => 'Brion Vibber',
'brion at pobox.com' => 'Brion Vibber',
'brion@zwinger.wikimedia.org' => 'Brion Vibber',
'brion@wikimedia.org' => 'Brion Vibber',
'brion at svn.leuksman.com' => 'Brion Vibber (SVN)',
'brion vibber' => 'Brion Vibber',
'BRIOSCHI Elfrida' => 'Frieda Brioschi',
'BRIOSCHI Elfrida Consultant' => 'Frieda Brioschi',
'vibber@users.sourceforge.net' => 'Brion Vibber',
'cbrown1023' => 'Casey Brown',
'cbrown1023@comcast.net' => 'Casey Brown',
'cbrown1023 at comcast.net' => 'Casey Brown',
'cbrown1023@gmail.com' => 'Casey Brown',
'cbrown1023.ml@gmail.com' => 'Casey Brown',
'charles matthews' => 'Charles Matthews',
'charles Matthews' => 'Charles Matthews',
'charles.r.matthews@ntlworld.com' => 'Charles Matthews',
'charles.r.matthews at ntlworld.com' => 'Charles Matthews',
'delirium@hackish.org' => 'Delirium',
'Effe iets anders' => 'effe iets anders',
'Elly Waterman' => 'Ellywa',
'epzachte@chello.nl' => 'Erik Zachte',
'erik_moeller@gmx.de' => 'Erik Moeller',
'Erik van den Muijzenberg' => 'Muijz',
'Finne Boonen' => 'Henna',
'fred thuiller' => 'Fred Thuiller',
'Huib Laurens' => 'Huib!',
'Abigor' => 'Huib!',
#'Huib@forgotten-beauty.com' => 'Huib!',
#'abigor@forgotten-beauty.com' => 'Huib!',
#'sterkebak@gmail.com' => 'Huib!',
'Federico' => 'jroger',
'Federico Cantoni' => 'jroger',
'GEMMA' => 'Gemma',
'Gerard Meijssen' => 'GerardM',
'Gerard.Meijssen' => 'GerardM',
'giskart op gmx.net' => 'Walter Vermeir',
'Giskart' => 'Walter Vermeir',
'Gurch' => 'Matthew Britton',
'Hein Van Meeteren' => 'Hein van Meeteren',
'Jeff V. Merkey' => 'Jeffrey V. Merkey',
'Jimmy &#40;Jimbo&#41; Wales' => 'Jimmy Wales',
'Jimbo' => 'Jimmy Wales',
'jroger a interfree.it' => 'jroger',
'jwales@wiki.com' => 'Jimmy Wales',
'Florence Devouard' => 'Anthere',
'florencedevouard' => 'Anthere',
'Kate Turner' => 'Kate',
'KIZU' => 'Aphaia',
'magnus,manske' => 'Magnus Manske',
'Matthew Brown' => 'Matt Brown',
'MeryGyorfalvi'  => 'undisclosed1',
'Nemo' => 'Federico Leva &#40;Nemo&#41;',
'Nemo_bis' => 'Federico Leva &#40;Nemo&#41;',
'Oscar op wikipedia.be' => 'oscar',
'Rob W.W. Hooft' => 'Rob Hooft',
'robchurch at svn.leuksman.com' => 'Rob Church (SVN)',
'Samuel Klein' => 'SJ',
'SJ Klein' => 'SJ',
'Sj' => 'SJ',
'- Essjay -' => 'Essjay',
'tstarling at svn.leuksman.com' => 'Tim Starling (SVN)',
'tstarling at users.sourceforge.net' => 'Tim Starling',
'Tomos at Wikipedia' => 'wiki tomos'
) ;

%monthes = (
'January'   => 1,
'February'  => 2,
'March'     => 3,
'April'     => 4,
'May'       => 5,
'June'      => 6,
'July'      => 7,
'August'    => 8,
'September' => 9,
'October'   => 10,
'November'  => 11,
'December'  => 12
) ;

$out_html = <<__HTML__ ;

<html>
<head>
<title>Mail Stats: LIST</title>
<style type=\"text/css\">
<!--
td   {font-size:10px ; text-align:center }
th   {font-size:10px ; text-align:center }
td.l {font-size:10px ; text-align:left }
th.l {font-size:10px ; text-align:left }
td.r {font-size:10px ; text-align:right }
th.r {font-size:10px ; text-align:right }
thin {border:none;margin:0px}
-->
</style>
</head>
<body bgcolor='#FFFFDD'>
<table width=100%><tr><td class=l>
<h2>Wikimedia Mail Stats: <a href='URL'>LIST</a></h2>
</td><td class=r>
<small>
<a href='index.html'>All lists</a><br>
<a href='_PowerPosters.html'>Powerposters</a><br>
<a href='_Aliases.html'>Aliases</a></small><p>
</small>
</td></tr></table>
HTML
<p>
<small>
Please don't confuse number of posts of a person with relevance of that person's contributions.
Less may be more in some cases.
<p>Generated on DATETIME
<br>Script version:VERSION
<br>Author:Erik Zachte (<a href='http://infodisiac.com/'>Web site</a>)
<br>Mail:erikzachte@###.com (&lt;nospam&gt; ### = infodisiac &lt;/nospam&gt;)
</small>
</body>
</html>

__HTML__
}

sub ScanFolder
{
   my $folder = shift ;
   my ($file, $filecnt) ;

   if (!-e $folder)
   {
     &Log ("Folder $folder no found\n") ;
     return ;
   }

   chdir ($folder) || die "Cannot chdir to $folder\n";
   local (*DIR);
   opendir (DIR, ".");
   while ($file = readdir (DIR))
   {
      if ($file eq "." || $file eq "..")
      { next ; }

      if ($file =~ /mediawiki\-cvs/i) # temp for SJ
      { next ; }

      if (-d $file)
      {
        $foldercnt++ ;
        $folder = $file ;
        &Log ("\nFolder $folder\n\n") ;
        if ($folder ne $root_in)
        { push @folders, $folder ; }
        &ScanFolder ("$folder");
      }
      else
      {
        if ($file !~ /\.txt$/)
        { next ; }

        $filecnt++ ;

        @stats = stat ($file) ;
        if ($#stats < 0) { next ; }

        $size = $stats [7] ;
        $time = $stats [9] ;

        ($year, $month) = $file =~ /^(\d+)\-(\w+)/ ;
        $month2 = $monthes {$month} ;
        $period = $year*12+$month2 ;
        if ($period == 0)
        {
          print "Skip $folder/$file\n" ;
          next ;
        }
        $periody {$period} = $year ;
        $periodm {$period} = $month ;

        # &Log ("$file\n") ;
        &ScanFile ($folder, $file, $period) ;
      }
   }
   if ($filecnt > 0)
   { &Log ("$filecnt files\n") ; }

   closedir(DIR);
   chdir("..");
}

sub ScanFile
{
  my $folder = shift ;
  my $file   = shift ;
  my $period = shift ;

  open "FILE_ARCHIVE", "<", $file  || abort ("File '$file' could not be opened.") ;
  $continue = $true ;
  while (($line = <FILE_ARCHIVE>) && $continue)
  {
          $line =~ s/\x09+\x20+/ /g ;
          $line =~ s/\x09+/ /g ;

    if ($line =~ /^From\:.*\((.*)\)/i)
    {
      ($name) = $line =~ /^From\:.*?\((.*)\)\s*$/ ;
      $name =~ s/\s*\(gmail\)\s*//i ;
      $name =~ s/\s*\.+\s*$//i ;
      $name =~ s/\s*\@ nupedia.com\s*//i ;
      $name =~ s/\s*\@ gmail.com\s*//i ;

#if (($name !~ /8859/) && ($name !~ /1250/)){ next ; }
#if ($name !~ /^gemma/i) { next ; }


      $name =~ s/\(/&#40;/g ;
      $name =~ s/\)/&#41;/g ;

      if ($folder eq "WikiPL-l")
      {
                $name =~ s/(.)/&WinCode1250 ($1)/ge ;
      }

      $name2 = &Encode ($name, $period) ;
      if ($name2 =~ /^\s*$/) # e.g. from bogus@does.not.exist.com
      {
        &Log ("Folder $folder File $file Name '$name' -> ''\n") ;
        next ;
      }
      $name = $name2 ;

      my $board = $false ;

      if (($name eq 'Jimmy Wales')           && ($period > 2004*12+5))
      { $board = $true ; }

      elsif (($name eq 'Kat Walsh')          && ($period > 2006*12+11))
      { $board = $true ; }

      elsif (($name eq 'Jan-Bart de Vreede') && ($period > 2006*12+11))
      { $board = $true ; }

      elsif (($name eq 'Michael Snow')       && ($period > 2008*12+6))
      { $board = $true ; }

      elsif (($name eq 'Domas Mituzas')      && ($period > 2008*12+1))
      { $board = $true ; }

      elsif (($name eq 'Stu West')           && ($period > 2008*12+3))
      { $board = $true ; }

      elsif (($name eq 'Ting Chen')          && ($period > 2008*12+6))
      { $board = $true ; }

      elsif  (($name eq 'Angela')            && ($period > 2004*12+5) && ($period < 2006*12+10))
      { $board = $true ; }

      elsif (($name eq 'Anthere')            && ($period > 2004*12+5) && ($period < 2008*12+8))
      { $board = $true ; }

      elsif (($name eq 'Erik Moeller')       && ($period > 2006*12+9) && ($period < 2008*12+1))
      { $board = $true ; }

      elsif (($name eq 'Michael Davis')      && ($period > 2004*12+5) && ($period < 2007*12+12))
      { $board = $true ; }

      elsif (($name eq 'oscar van dillen')   && ($period > 2006*12+11) && ($period < 2007*12+7))
      { $board = $true ; }

      elsif (($name eq 'Frieda Brioschi')    && ($period > 2007*12+6) && ($period < 2008*12+10))
      { $board = $true ; }

      elsif  (($name eq 'Tim Shell')         && ($period > 2004*12+5) && ($period < 2006*12+12))
      { $board = $true ; }

      if ($board == $true)
      {
        $edits_name_list       {"$folder|Board"} ++ ;
        $edits_name_list_month {"$folder|$period|Board"} ++ ;
        $edits_name_tot_month  {"$period|Board"} ++ ;
        $edits_name_tot        {"Board"} ++ ;
      }

      $edits_name_list       {"$folder|$name"} ++ ;
      $edits_name_list_month {"$folder|$period|$name"} ++ ;
      $edits_tot_list_month  {"$folder|$period"} ++ ;
      $edits_name_tot        {"$name"} ++ ;
      $edits_name_tot_month  {"$period|$name"} ++ ;
      $edits_tot             {"$period"} ++ ;
      $edits_tot_list        {"$folder"} ++ ;
      $edits_tot_all ++ ;
    }
  }
  close "FILE_ARCHIVE" ;
  return ($continue) ;
}

sub WriteListStats
{
  my $folder = shift ;
  my ($period, @periods, $name, @names, %names) ;
  $output = '' ;

  @keys = keys %edits_tot_list_month ;
  foreach $key (@keys)
  {
    if ($key !~ /^$folder\|/) { next ; }

    ($period) = $key =~ /^.*?\|(.*)$/ ;
    push @periods, $period ;
  }
  @periods = sort {$b cmp $a} @periods ;

  @keys = keys %edits_name_list ;
  foreach $key (@keys)
  {
    if ($key !~ /^$folder\|/) { next ; }

    ($name) = $key =~ /^.*?\|(.*)$/ ;
    @names {$name} ++ ;
  }
  @names = keys %names ;

  $output  = "<small>Clickable names are for <a href='_PowerPosters.html'>powerposters</a>: editors with at least 200 posts on all lists combined.</small><table border='1'>\n" ;

  $output .= "<tr><th class=l>period</th><th>&nbsp;</th>" ;
  foreach $period (@periods)
  {
    $year  = $periody {$period} ;
    $year  =~ s/20/\'/ ;
    $month = substr ($periodm {$period},0,3) ;
    $output .= "<td align=center>$year<br>$month</td>" ;
  }
  $output .= "</tr>\n" ;

  $max_list = 0 ;
  foreach $period (@periods)
  {
    $total = $edits_tot_list_month {"$folder|$period"} ;
    if ($total > $max_list) { $max_list = $total ; }
  }

  $total = $edits_tot_list {$folder} ;
  $output .= "<tr><th class=l valign=bottom>Total</th><th valign=bottom>$total</th>" ;
  foreach $period (@periods)
  {
    $total = $edits_tot_list_month {"$folder|$period"} ;

    if ($max_list > 0)
    { $em = int (0.5 + (100 * $total / $max_list)) ; }
    else
    { $em = "" ; }

    if ($em == "")
    { $output .= "<td>&nbsp;</td>" ; }
    else
    { $output .= "<td valign=bottom><img src='redbar.gif' height=$em width=20><br>$total</td>" ; }
  }
  $output .= "</tr><p>" ;

  $columns = $#periods + 3 ;
  $output .= "<tr class=thin><td colspan=$columns height=1 class=thin><img src='grey.gif' height=2 width=100%></td></tr>" ;

  if ($edits_name_list {"$folder|Board"} > 5)
  {
    $output .= "<tr><td class=l valign=bottom>Board (relative)</td><td>&nbsp;</td>" ;
    foreach $period (@periods)
    {
      $total_period = $edits_tot_list_month {"$folder|$period"} ;
      $total_Board  = $edits_name_list_month {"$folder|$period|Board"} ;
      if ($total_period > 0)
      { $em = int (0.5 + (100 * $total_Board / $total_period)) ; }
      else
      { $em = "" ; }
      if ($em == "")
      { $output .= "<td>&nbsp;</td>" ; }
      else
      { $output .= "<td valign=bottom><img src='bluebar.gif' height=$em width=20><br>$em%</td>" ; }
    }
    $output .=  "</tr><p>" ;

    $em = $edits_name_list {"$folder|Board"} ;
    $output .=   "<tr><td class=l valign=bottom><a href='Board.html'>Board</a> (absolute)</td><th valign=bottom>$em</th>" ;
    foreach $period (@periods)
    {
      $total  = $edits_name_list_month {"$folder|$period|Board"} ;
      if ($max_list > 0)
      { $em = int (0.5 + (100 * $total / $max_list)) ; }
      else
      { $em = "" ; }

      if ($em == "")
      { $output .= "<td>&nbsp;</td>" ; }
      else
      { $output .= "<td valign=bottom><img src='greenbar.gif' height=$em width=20><br>$total</td>" ; }
    }
    $output .= "</tr><p>" ;
  }

  @names = sort { $edits_name_list {"$folder|$b"} <=> $edits_name_list {"$folder|$a"} } @names ;
  foreach $name (@names)
  {
    $name2 = &UnicodeToHtml ($name) ;
    if ($name eq 'Board') { next ; }
    $count = $edits_name_list {"$folder|$name"} ;

    if (($#names > 100) && ($count <= 4)) { last ; }

    $total = $edits_name_tot {$name} ;
    if (($total > 200) && ($name !~ /\(SVN\)/) && ($name !~ /\.pl$/i)) # ignore .pl for safety
    {
      $url = &EncodeURL ("$name\.html") ;
      $output .= "<tr><td class=l><a href='$url'>$name2</a></td><th>$count</th>" ;
    }
    else
    { $output .= "<tr><td class=l>$name2</td><th>$count</th>" ; }
    foreach $period (@periods)
    {
      $em = $edits_name_list_month {"$folder|$period|$name"} ;
      if ($em == "")
      { $output .= "<td>-</td>" ; }
      else
      { $output .= "<td>$em</td>" ; }
    }
    $output .= "</tr>" ;
  }

  $output .= "</table>\n" ;

  &WritePage ($folder, $true) ;
}

sub WriteNameStats
{
  my $name = shift ;
  my ($period, @periods, $folder, @folders) ;
  $output = '' ;

  @keys = keys %edits_tot_list_month ;
  foreach $key (@keys)
  {
    ($period) = $key =~ /^.*?\|(.*)$/ ;
    @periods {$period} ++ ;
  }
  @periods = sort {$b cmp $a} keys %periods ;

  while (($#periods > 0) &&
          ($edits_name_tot_month {@periods [$#periods]."|$name"} == 0))
  { pop @periods ; }         ;

  $output  = "<table border='1'>\n" ;

  $output .= "<tr><th class=l valign=top>period</th><th>&nbsp;</th>" ;
  foreach $period (@periods)
  {
    $year  = $periody {$period} ;
    $year  =~ s/20/\'/ ;
    $month = substr ($periodm {$period},0,3) ;
    $output .= "<td align=center>$year<br>$month</td>" ;
  }
  $output .= "</tr>\n" ;

  $total = $edits_name_tot {$name} ;
  $output .= "<tr><th class=l valign=bottom>Total</th><th valign=bottom>$total</th>" ;
  $max = 0 ;
  foreach $period (@periods)
  {
    $count = $edits_name_tot_month {"$period|$name"} ;
    # print "Period $period Name $name Count $count\n" ;
    if ($count > $max)
    { $max = $count ; }
  }
  foreach $period (@periods)
  {
    $count = $edits_name_tot_month {"$period|$name"} ;
    if (($count == 0) || ($max == 0))
    { $output .= "<td>-</td>" ; }
    else
    {
      $height = int (0.5 + 100 * $count / $max) ;
      $output .= "<td align=center valign=bottom><img src=greenbar.gif height=$height width=20><br>$count</td>" ;
    }
  }
  $output .= "</tr><p>" ;

  $columns = $#periods + 3 ;
  $output .= "<tr class=thin><td colspan=$columns height=1 class=thin><img src='grey.gif' height=2 width=100%></td></tr>" ;

  @folders = keys %edits_tot_list  ;
  @folders = sort { $edits_name_list {"$b|$name"} <=>  $edits_name_list {"$a|$name"} } @folders ;

  foreach $folder (@folders)
  {
    if ($edits_name_list {"$folder|$name"} < 3) { next ; }

    $count = $edits_name_list {"$folder|$name"} ;
    if (($#folders > 50) && ($count <= 4)) { last ; }

    $total = $edits_name_list {"$folder|$name"} ;
    $folder2 = &FormatListName ($folder) ;
    $output .= "<tr><td class=l><a href='$folder\.html'>$folder2</a></td><th>$total</th>" ;
    foreach $period (@periods)
    {
      $em = $edits_name_list_month {"$folder|$period|$name"} ;
      if ($em == "")
      { $output .= "<td>-</td>" ; }
      else
      { $output .= "<td>$em</td>" ; }
    }
    $output .= "</tr>" ;
  }

  $output .= "</table>\n" ;

  $output .= "<p><a href='_Aliases.html'>List of aliases</a></small>\n" ;
  &WritePage ($name, $false) ;
}

sub WriteTopNameStats
{
  my ($period, @periods, $folder, @folders) ;
  $output = '' ;

  @keys = keys %edits_tot_list_month ;
  foreach $key (@keys)
  {
    ($period) = $key =~ /^.*?\|(.*)$/ ;
    @periods {$period} ++ ;
  }
  @periods = sort {$b cmp $a} keys %periods ;

  while (($#periods > 0) &&
          ($edits_name_tot_month {@periods [$#periods]."|$name"} == 0))
  { pop @periods ; }         ;

  @keys = keys %edits_name_tot ;
  @keys = sort { @edits_name_tot {$b} <=> @edits_name_tot {$a} } @keys ;

  $output  = "This list contains all community members that posted at least 200 times on all lists combined.<p>See below for <a href='#colours'>explanation of colours</a>.<p>" ;

  $output .= "<table border='1'>\n" ;

  $output .= "<tr><th><font color=#800000>cat F</font></th><th><font color=#008000>cat P</font></th><th><font color=#000080>cat T</font></th><th class=l valign=top>Name</th><th>&nbsp;FPT&nbsp;</th><th>Total</th><th colspan=14 class=l>Mostly posted at..." .
             "<font color=#800000>foundation</font>, <font color=#008000>project</font> or <font color=#000080>technical</font> oriented lists.</th></tr>\n\n" ;
  foreach $name (@names)
  {
    $name2 = &UnicodeToHtml ($name) ;
    if ($name eq 'Board') { next ; }

    $count = $edits_name_tot {$name} ;

    if ($count < 200) { last ; }

    undef @keys2 ;
    @keys = keys %edits_name_list ;
    foreach $key (@keys)
    {
      $key2 = $key ;
      $key2 =~ s/^.*\|// ;
      if ($key2 eq $name)
      { push @keys2, $key ; }
    }
    @keys = sort { @edits_name_list {$b} <=> @edits_name_list {$a} } @keys2 ;

    undef (%totposts) ;
    undef (@totposts) ;
    $maxcolor = 0 ;
    foreach $key (@keys)
    {
      $posts  = @edits_name_list {$key} ;
      $folder = $key ;
      $folder =~ s/\|.*$// ;

      $color = &GetFolderColor ($folder) ;
      @totposts {$color} += $posts ;
      if (@totposts {$color} > $maxcolor)
      { $maxcolor = @totposts {$color} ; }
    }

    if ($maxcolor != 0)
    {
      # print "0 " . (0+@totposts{"#800000"}) . " " . (0+@totposts{"#008000"}) . " " . (0+@totposts{"#000080"}) . "\n" ;

      $red    = &Colorize (@totposts {"#800000"}, $maxcolor) ;
      $green  = &Colorize (@totposts {"#008000"}, $maxcolor) ;
      $blue   = &Colorize (@totposts {"#000080"}, $maxcolor) ;
      $red2   = sprintf ("%02X", $red) ;
      $green2 = sprintf ("%02X", $green) ;
      $blue2  = sprintf ("%02X", $blue) ;
      $red3   = "\#${red2}0000" ;
      $green3 = "\#00${green2}00" ;
      $blue3  = "\#0000${blue2}" ;
      $mix   = "\#${red2}${green2}${blue2}" ;
    }

    $images = "<td bgcolor=$red3>&nbsp;</td>" .
              "<td bgcolor=$green3>&nbsp;</td>" .
              "<td bgcolor=$blue3>&nbsp;</td>" ;
    $mix    = "<td bgcolor=$mix>&nbsp;</td>" ;
    $total = $edits_name_tot {$name} ;
    $url = &EncodeURL ("$name\.html") ;
    $url =~ s/\//%25%2E/g ;
    $url =~ s/\%/\%25/g ;

#   if ($url ne "$name\.html")
#   { &Log ("$name\.html -> $url\n") ; }
    $output .= "<tr>$images<td class=l><a href='$url'>$name2</a></td>$mix<th>$count</th>" ;

    for ($ndx = 0 ; $ndx <= 6 ; $ndx++)
    {
      $key = @keys [$ndx] ;
      $posts = @edits_name_list {$key} ;
      $folder = $key ;
      $folder =~ s/\|.*$// ;

      $color = '#800000' ;
      if ($folder =~ /(?:tech|cvs|mediawiki|server|bots|commons|translator)/i)
      { $color = '#000080' ; }
      elsif (($folder =~ /(?:^wiki|wiktio|textbook)/i) && ($folder !~ /^wikimedia/i))
      { $color = '#008000' ; }

      if ($posts == 0)
      { $output .= "<td colspan=2>&nbsp;</td>" ; }
      else
#     { $output .= "<td class=l><table border=0><tr><td align=left>$folder:</td><td align=right>$posts</td></tr></table></td>" ; }
      { $output .= "<td class=l><font color=$color>$folder</font></td><td class=r>$posts</td>" ; }
    }

    $output .= "</tr>\n\n" ;
  }

  $output .= "</table>\n\n" ;

  $output .= "<small><a id='colours' name='colours'><p>" .
             "Mailing lists have been divided into three groups:" .
             "<ul><li><font color='800000'>F: Mainly foundation or chapter oriented</font>" .
             "<li><font color='008000'>P: Mainly project oriented</font>" .
             "<li><font color='000080'>T: Mainly technically oriented</font>" .
             "</ul><p>" .
             "Of course separation between lists is not absolute, e.g. sometimes technical matters are discussed on project lists.<p>" .
             "For each person three colours before his/her name indicate how many of the posts were in that category.<br>" .
             "The category where a person posted most often is shown with maximal colour value. Other colour strengths are relative to that value.<p>" .
             "The 'FPT' column shows a simple addition of the three category colour values.<br>" .
             "It can be used to match likewise inclined people in the list (of course don't take this too seriously).</small>" ;
  $output .= "<p><a href='_Aliases.html'>List of aliases</a></small>\n" ;
  &WritePage ("_PowerPosters", $false) ;
}

sub GetFolderColor
{
        my $folder = shift ;
  my $color= '#800000' ;
  if ($folder =~ /(?:tech|cvs|mediawiki|server|bots|commons|translator)/i)
  { $color = '#000080' ; }
  elsif (($folder =~ /(?:^wiki|wiktio|textbook)/i) && ($folder !~ /^wikimedia/i))
  { $color = '#008000' ; }
  return ($color) ;
}

sub Colorize
{
  my $total = shift ;
  my $maxtotal = shift ;
  my $color ;
  my $ratio = $total / $maxtotal ;

     if ($ratio < 0.16) { $color = 0 ; }
  elsif ($ratio < 0.33) { $color = 128 ; }
  elsif ($ratio < 0.49) { $color = 192 ; }
  elsif ($ratio < 0.66) { $color = 224 ; }
  elsif ($ratio < 0.82) { $color = 240 ; }
  else                  { $color = 255 ; }
  return ($color) ;
}

sub WriteListIndex
{
  my ($period, @periods, @periods) ;
  $output = '' ;

  @keys = keys %edits_tot_list_month ;
  foreach $key (@keys)
  {
    ($period) = $key =~ /^.*?\|(.*)$/ ;
    @periods {$period} ++  ;
  }

  @periods = keys %periods ;
  @periods = sort { $b <=> $a } @periods ;
  @folders = sort { $edits_tot_list {$b} <=> $edits_tot_list {$a} } @folders ;

  $max_month = 0 ;
  foreach $period (@periods)
  {
    $total = $edits_tot {$period} ;
    if ($total > $max_month)
    { $max_month = $total ; }
  }

  $output = "See below for <a href='#colours'>explanation of colours</a>." ;

  $output .= "<table border='1'>" ;

  $output .= "<tr><th class=l colspan=2>List</th><th class=l>Posts</th>" ;
  foreach $period (@periods)
  {
    $year  = $periody {$period} ;
    $year  =~ s/20/\'/ ;
    $month = substr ($periodm {$period},0,3) ;
    $output .= "<td align=center>$year<br>$month</td>" ;
  }
  $output .= "</tr>\n" ;

  $output .= "<tr><th>&nbsp;</th><th class=l valign=bottom>Total</th><th valign=bottom class=r>$edits_tot_all</th>" ;
  foreach $period (@periods)
  {
    $total = $edits_tot {"$period"} ;

    if ($max_month > 0)
    { $em = int (0.5 + (100 * $total / $max_month)) ; }
    else
    { $em = "" ; }

    if ($em == "")
    { $output .= "<td>&nbsp;</td>" ; }
    else
    { $output .= "<td valign=bottom><img src='yellowbar.gif' height=$em width=20><br>$total</td>" ; }
  }
  $output .= "</tr><p>" ;

  foreach $folder (@folders)
  {
    $edits   = $edits_tot_list {$folder} ;
    $folder2 = &FormatListName ($folder) ;
    $color   = &GetFolderColor ($folder) ;
    if ($edits eq "")
    { $edits = "&nbsp;" ; }
    $output .= "<tr><td class=l style=\"background-color:$color\">&nbsp;</td><td class=l><a href='$folder\.html'>$folder2</a></td><th>$edits</th>" ;

    foreach $period (@periods)
    {
      $em = $edits_tot_list_month {"$folder|$period"} ;
      if ($em == "")
      { $output .= "<td>&nbsp;</td>" ; }
      else
      { $output .= "<td valign=bottom>$em</td>" ; }
    }
    $output .= "</tr>\n" ;
  }

  $output .= "</table>" ;

  $output .= "<small><a id='colours' name='colours'><p>" .
             "Mailing lists have been divided into three groups:" .
             "<ul><li><font color='800000'>F: Mainly foundation or chapter oriented</font>" .
             "<li><font color='008000'>P: Mainly project oriented</font>" .
             "<li><font color='000080'>T: Mainly technically oriented</font>" .
             "</ul><p>" .
             "Of course separation between lists is not absolute, e.g. sometimes technical matters are discussed on project lists.<p>" .
             "On page <a href='_PowerPosters.html'>Powerposters</a> for each person three colours before his/her name indicate how many of the posts were in that category.<br>" .
             "It can be used to match likewise inclined people in the list (of course don't take this too seriously).<br>" .
             "<b>April 2009: The colouring scheme is somewhat outdated. You can help by sending corrections to the mail address below.</b></small>" ;

  &WritePage ("index", $false) ;
  &WritePage ("Index", $false) ;
  &WritePage ("\_Index", $false) ;
}

sub WriteAliasList
{
  $output = "<b>The following names are treated as aliases:</b><p>" ;
  @keys = sort keys %aliases ;

  $output .= "<table border='1'>" ;

  foreach $alias (@keys)
  {
    $name  = @aliases {$alias} ;

    if ($name eq 'Ellywa')      { next ; } # hide real names for privacy reasons
    if ($name eq 'GerardM')     { next ; }
    if ($name eq 'Henna')       { next ; }
    if ($name eq 'Casey Brown') { next ; }
    if ($name eq 'jroger')      { next ; }
    if ($name =~ /cbrown1023/)  { next ; }
    if ($name =~ /undisclosed/) { next ; }

    $alias =~ s/@/ at /g ;
    $name  =~ s/@/ at /g ;
    $alias =~ s/\./ dot /g ;
    $name  =~ s/\./ dot /g ;
    $output .= "<td><td class=l>$alias</td><td class=l>$name</td></tr>" ;
  }

  $output .= "</table>" ;
  $output .= "<p><small>Several real names are omitted here for privacy reasons.</small>" ;
  $output .= "<p><small>Feel free to send updates to the mail address shown below.</small>" ;

  &WritePage ("_Aliases", $false) ;
}

sub WritePage
{
  my $file = shift ;
  $file =~ s/\//%25%2E/g ;
  my $linksite = shift ;

  my $html = $out_html ;
  if (($file =~ /_?Index/i) || ($file =~ /PowerPosters/i))
  {
    $html =~ s/<a href='URL'>LIST<\/a>/LIST/ ;
    $html =~ s/GO_UP/http\:\/\/infodisiac.com\//g ;
    $html =~ s/UP/Home/g ;
  }
  elsif ($file =~ /_Aliases/)
  {
    $html =~ s/<a href='URL'>LIST<\/a>/LIST/ ;
    $html =~ s/GO_UP/index.html/g ;
    $html =~ s/UP/Index/g ;
  }
  else
  {
    $html =~ s/GO_UP/index.html/g ;
    $html =~ s/UP/Index/g ;
  }

  if (! $linksite)
  { $html =~ s/<a href='URL'>LIST<\/a>/LIST/ ; }

  $filelc = lc ($file) ;
  $file2 = $file ;
  $file2 =~ s/^\_// ;
  $file2 = &FormatListName (&UnicodeToHtml ($file2)) ;

  $html =~ s/URL/http\:\/\/mail.wikipedia.org\/pipermail\/$filelc\// ;
  $html =~ s/LIST/$file2/g ;
  $html =~ s/HTML/$output/ ;
  $html =~ s/VERSION/$version/ ;
  $html =~ s/DATETIME/$datetime/ ;

  if ($file !~ /\.pl$/i)
  {
    $file = &EncodeURL ($file) ;
    open "FILE_HTML", ">", "$root_out/$file.html"  || abort ("File '$file' could not be opened.") ;
    print FILE_HTML $html ;
    close "FILE_HTML" ;
  }
}

sub Encode
{
  my $name   = shift ;
  my $period = shift ;

  $alias = $aliases {$name} ;
  if ($alias ne '')
  { $name = $alias ; }

  if ($name =~ /nemo/i)
  { &Log ("Name $name\n") ; }

  $name =~ s/at svn.leuksman.com/ (SVN)/ ;
  $name =~ s/at svn.wikimedia.org/ (SVN)/ ;
  $name =~ s/^.*?Bjarmason/\xC3\x86var_Arnfj\xC3\xB6r\xC3\xB0_Bjarmason/ ;

  $name =~ s/\¡\÷/\@/g ; # occurs in Japanese mail addreses
  $name2 = $name ;
  $name =~ s/=\?(.*?)\?([BQ])\?(.*?)\?=/&EncodeConv($1,$2,$3)/ieg ;

  if (($name =~ /=\?/) || ($name =~ /\?=/))
  { print "$name2 ==>\n$name\n\n" ; }

  if ($false) # ($name =~ /^\=\?.*\?\=/)
  {
    if ($name =~ /^=\?ISO\-8859\-1\?[Qq].*?\?=/i)
    {
      $name =~ s/^=\?.*\?[qQ]\?(.*?)\?=(.*)$/$1$2/i ;
      $name =~ s/\=([0-9A-Fa-f]{2})/'&#'.hex($1).';'/ge ;
    }
    elsif ($name =~ /^=\?ISO\-8859\-2\?[Qq].*?\?=.*$/i)
    {
      $name =~ s/^=\?.*\?[qQ]\?(.*?)\?=(.*)$/$1$2/i ;
      $name =~ s/\=([0-9A-Fa-f]{2})/'&#'.ISO8859_2($1).';'/ge ;
    }
    elsif ($name =~ /^=\?WINDOWS\-1250\?[Qq].*?\?=/i)
    {
      $name =~ s/^=\?.*\?[qQ]\?(.*?)\?=(.*)$/$1$2/i ;
      $name =~ s/\=([0-9A-Fa-f]{2})/'&#'.WinCode1250($1).';'/ge ;
    }
    elsif ($name =~ /^=\?.*?\?B\?.*?\?=/)
    {
      $name =~ s/^=\?(.*?)\?B\?(.*?)\?=$/&Iconv($1,$2)/ie ;
      $name = &UnicodeToHtml ($name) ;
    }
    else
    {
      $name =~ s/^=\?(.*?\?[BQ])\?(.*?)\?=$/$1\:$2/i ;
      $name =~ s/^(\w+)/uc($1)/e ;
      $name =~ s/^WINDOWS/WIN/ ;
    }
  }

  $name =~ s/\@/ at / ;
  $name =~ s/_/ /g ;
  return ($name) ;
}

sub EncodeConv
{
  my $code = shift ;
  my $mode = shift ;
  my $text = shift ;
  my $text_org = $text ;
  my $conv = @iconv {$text} ;

  if (defined ($conv))
  { return ($conv) ; }

  # rfc2045 rfc2047
  if ($mode =~ /^[bB]$/)
  { $conv = decode_base64 ($text); }
  if ($mode =~ /^[qQ]$/)
  {
    $conv = $text ;
    $conv =~ s/\=([0-9A-Fa-f]{2})/chr(hex($1))/ge ;
  }

  if (! $do_iconv)
  { return ($conv) ; }

  open "FILE_IN", ">", "iconv.in" ;
  print FILE_IN $conv ;
  close "FILE_IN" ;

  $cmd = "iconv --verbose -c -f '$code' -t 'UTF-8' -o 'iconv.out' 'iconv.in'" ;

  $result = `$cmd` ;

  open "FILE_OUT", "<", "iconv.out" ;
  $conv = <FILE_OUT> ;
  close "FILE_OUT" ;

  @iconv {$text} = $conv ;

# print " $text => $conv => " . &UnicodeToHtml ($conv) . "\n\n" ;

  return ($conv) ;
}

sub EncodeURL
{
  my $url = shift ;
  $url =~ s/\s/_/g ;
  # For some reason everything gets run through this weird internal
  # encoding that's similar to URL-encoding. Armor against this as well,
  # or else adjacent encoded bytes will be corrupted.
  $url =~ s/([^0-9a-zA-Z\%\:\/\.\ \_\-\@])/"%".sprintf ("%02X",ord($1))/ge ;
  return ($url) ;
}

sub GetDateTimeEnglishShort
{
  my @weekdays_en = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
  my @months_en   = qw (January February March April May June July
                        August September October November December);
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  return (substr ($weekdays_en[$wday],0,3) . ", " .
          substr ($months_en[$mon],0,3) . " " .
          $mday . ", " .
          (1900 + $year) .
          " " . sprintf ("%2d:%02d", $hour, $min)) ;
}

sub OpenLog
{
  $fileage  = -M $file_log ;
  if ($fileage > 5)
  {
    open "FILE_LOG", "<", $file_log || abort ("Log file '$file_log' could not be opened.") ;
    @log = <FILE_LOG> ;
    close "FILE_LOG" ;
    $lines = 0 ;
    open "FILE_LOG", ">", $file_log || abort ("Log file '$file_log' could not be opened.") ;
    foreach $line (@log)
    {
      if (++$lines >= $#log - 5000)
      { print FILE_LOG $line ; }
    }
    close "FILE_LOG" ;
  }
  open "FILE_LOG", ">>", $file_log || abort ("Log file '$file_log' could not be opened.") ;
  close FILE_LOG ; # first update timestamp only
  open "FILE_LOG", ">>", $file_log || abort ("Log file '$file_log' could not be opened.") ;
  &Log ("\n\n===== Scan Mailing List Stats / " . &GetDateTimeEnglishShort (time) . " =====\n\n") ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}

#sub WinCode1250
#{
#  my $value = shift ;
#  $value = hex ($value) ;

#     if ($value == 165) { $value = 260 ; }
#  elsif ($value == 198) { $value = 262 ; }
#  elsif ($value == 202) { $value = 280 ; }
#  elsif ($value == 163) { $value = 321 ; }
#  elsif ($value == 209) { $value = 323 ; }
#  elsif ($value == 211) { $value = 211 ; }
#  elsif ($value == 140) { $value = 346 ; }
#  elsif ($value == 143) { $value = 377 ; }
#  elsif ($value == 175) { $value = 379 ; }
#  elsif ($value == 185) { $value = 261 ; }
#  elsif ($value == 230) { $value = 263 ; }
#  elsif ($value == 234) { $value = 281 ; }
#  elsif ($value == 179) { $value = 322 ; }
#  elsif ($value == 241) { $value = 324 ; }
#  elsif ($value == 243) { $value = 243 ; }
#  elsif ($value == 156) { $value = 347 ; }
#  elsif ($value == 159) { $value = 378 ; }
#  elsif ($value == 191) { $value = 380 ; }

#  return ($value) ;
#}

sub WinCode1250
{
  my $value = shift ;
  my $value0 = $value ;
  $value = ord ($value) ;

     if ($value == 165) { $value = "&#260;" ; }
  elsif ($value == 198) { $value = "&#262;" ; }
  elsif ($value == 202) { $value = "&#280;" ; }
  elsif ($value == 163) { $value = "&#321;" ; }
  elsif ($value == 209) { $value = "&#323;" ; }
  elsif ($value == 211) { $value = "&#211;" ; }
  elsif ($value == 140) { $value = "&#346;" ; }
  elsif ($value == 143) { $value = "&#377;" ; }
  elsif ($value == 175) { $value = "&#379;" ; }
  elsif ($value == 185) { $value = "&#261;" ; }
  elsif ($value == 230) { $value = "&#263;" ; }
  elsif ($value == 234) { $value = "&#281;" ; }
  elsif ($value == 179) { $value = "&#322;" ; }
  elsif ($value == 241) { $value = "&#324;" ; }
  elsif ($value == 243) { $value = "&#243;" ; }
  elsif ($value == 156) { $value = "&#347;" ; }
  elsif ($value == 159) { $value = "&#378;" ; }
  elsif ($value == 191) { $value = "&#380;" ; }
  else                  { $value = $value0  ; }
  return ($value) ;
}

#sub ISO8859_2
#{
#  my $value = shift ;
#  $value = hex ($value) ;

#     if ($value == 161) { $value = 260 ; }
#  elsif ($value == 198) { $value = 262 ; }
#  elsif ($value == 202) { $value = 280 ; }
#  elsif ($value == 163) { $value = 321 ; }
#  elsif ($value == 209) { $value = 323 ; }
#  elsif ($value == 211) { $value = 211 ; }
#  elsif ($value == 166) { $value = 346 ; }
#  elsif ($value == 172) { $value = 377 ; }
#  elsif ($value == 175) { $value = 379 ; }
#  elsif ($value == 177) { $value = 261 ; }
#  elsif ($value == 230) { $value = 263 ; }
#  elsif ($value == 234) { $value = 281 ; }
#  elsif ($value == 179) { $value = 322 ; }
#  elsif ($value == 241) { $value = 324 ; }
#  elsif ($value == 243) { $value = 243 ; }
#  elsif ($value == 182) { $value = 347 ; }
#  elsif ($value == 188) { $value = 376 ; }
#  elsif ($value == 191) { $value = 380 ; }

#  return ($value) ;
#}

  sub UnicodeToHtml {
  my $text  = shift ;
  my ($c, $len, $byte, $ord, $unicode, $bytes, $html) ;

  $len = length ($text) ;
  for ($c = 0 ; $c < $len ; $c++)
  {
    $byte = substr ($text,$c,1) ;
    $ord = ord ($byte) ;
    if ($ord < 128)      # plain ascii character
    { $html .= $byte ; } # (will not occur in this script)
    else
    {
      # single byte left >= 0x80 ? should never occur but does a few times
      # treat as pre-unicode high ascii character
      if ($c == $len - 1)
      {
        $html = "\&\#". $ord . ";" ;
        push @errors, $title .":invalid unicode char ".$text. "\n" ;
      }
      else
      {
        if    ($ord < 224) { $bytes = 2 ; }
        elsif ($ord < 240) { $bytes = 3 ; }
        elsif ($ord < 248) { $bytes = 4 ; }
        elsif ($ord < 252) { $bytes = 5 ; }
        else               { $bytes = 6 ; }

        $unicode = substr ($text,$c,$bytes) ;
        $html .= &UnicodeToHtmlTag ($unicode) ;
        $c += $bytes - 1 ;
      }
    }
  }
  return ($html) ;
}

sub FormatListName
{
  my $name = shift ;
  $name =~ s/^Wiki([a-z]{2,3})\-l$/"Wiki".uc($1)."-l"/ie ;
  $name =~ s/^Wikimedia([a-z]{2,3})\-l$/"Wikimedia".uc($1)."-l"/ie ;
  return ($name) ;
}

# translates one unicode character into plain ascii or html tag
sub UnicodeToHtmlTag {
  my $unicode = shift ;
  my $char = substr ($unicode,0,1) ;
  my $ord = ord ($char) ;
  my ($c, $value, $html) ;

  if ($ord < 128)         # plain ascii character
  { return ($unicode) ; } # (will not occur in this script)
  else
  {
    if    ($ord >= 252) { $value = $ord - 252 ; }
    elsif ($ord >= 248) { $value = $ord - 248 ; }
    elsif ($ord >= 240) { $value = $ord - 240 ; }
    elsif ($ord >= 224) { $value = $ord - 224 ; }
    else                { $value = $ord - 192 ; }

    for ($c = 1 ; $c < length ($unicode) ; $c++)
    { $value = $value * 64 + ord (substr ($unicode, $c,1)) - 128 ; }
    $html = "\&\#" . $value . ";" ;


    if ($value < 0)
    { &Log ("\nUnicodeToHtmlTag unicode '$unicode' -> html '$html'") ; }

    return ($html) ;
  }
}

