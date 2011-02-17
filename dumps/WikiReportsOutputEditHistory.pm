#!/usr/bin/perl

# vary namespace to include per project
# add links to other projects (to proper file type)

$plots_max  = 999 ;
$plots_top  = 50 ;
$plots_many = 75 ;

$index_show = $true ;
$index_hide = $false ;

sub ReadEditHistory
{
  return if $language ne "en" ;

  &LogT ("\nReadEditHistory\n") ;
  my @nsid ;

  open EDITS_IN, '<', $file_edits_per_namespace or die ("file $file_edits_per_namespace not found") ; ;

  while ($line = <EDITS_IN>)
  {
    chomp $line ;
    ($lang,$date,$usertype,@nscnts) = split (',', $line) ;
    if ($date eq "00/00/0000")
    {
      @nsid = @nscnts ;
      # for ($n = 0 ; $n <= $#nsid ; $n++)
      # {
      #   if (&NameSpaceArticle ($lang, $nsid [$n]))
      #   { print "Y $lang ns " . $nsid[$n] . ": " . $nscnt [$n] . "\n" ; }
      # }
      next ;
    }

    if (! $mode_wx && ($lang =~ /commons/i)) { next ; }

    ($month,$day,$year) = split ('\/', $date) ;

    # next if $lang !~ /^(?:de|ja|en|fr|es|ru|it|pl|pt|nl)$/ ;
    # next if $year < 2003 ;
    # print "$day $month $year $lang $usertype $ns0\n" ;

    $ns0 = 0 ;
    for ($n = 0 ; $n <= $#nsid ; $n++)
    {
      if (&NameSpaceArticle ($lang, $nsid [$n]))
      { $ns0 += $nscnts [$n] ; }
    }

    $edits    {"$year/$month/$day"}{$usertype}{$lang} = $ns0 ;
    $editstot {"$year/$month/$day"}{$lang} += $ns0 ;
    $edits    {"$year/$month/$day"}{$usertype}{'zz'} += $ns0 ;
    $editstot {"$year/$month/$day"}{'zz'} += $ns0 ;

    $editstottype {$usertype}{$lang} += $ns0 ;
    $editstottype {$usertype}{'zz'} += $ns0 ;
    $editstottype {'T'}{$lang} += $ns0 ;
    $editstottype {'T'}{'zz'} += $ns0 ;

    if ($usertype eq 'A') # anon
    {
      $editstot_anon {"$year/$month/$day"}{'zz'}  += $ns0 ;
      $editstot_anon {"$year/$month/$day"}{$lang} += $ns0 ;
    }

    if ($editstot {"$year/$month/$day"}{$lang} > $editsmax {$lang})
    {
      $editsmax      {$lang} = $editstot {"$year/$month/$day"}{$lang} ;
      $editsmaxmonth {$lang} = &month_english_short ($month-1) . " $year" ;
    }

    if ($editstot {"$year/$month/$day"}{'zz'} > $editsmax {'zz'})
    {
      $editsmax      {'zz'} = $editstot {"$year/$month/$day"}{'zz'} ;
      $editsmaxmonth {'zz'} = &month_english_short ($month-1) . " $year" ;
    }

    if ($editstot_anon {"$year/$month/$day"}{$lang} > $editsmax_anon {$lang})
    {
      $editsmax_anon      {$lang} = $editstot_anon {"$year/$month/$day"}{$lang} ;
      $editsmaxmonth_anon {$lang} = &month_english_short ($month-1) . " $year" ;
    }

    if ($editstot_anon {"$year/$month/$day"}{'zz'} > $editsmax_anon {'zz'})
    {
      $editsmax_anon      {'zz'} = $editstot_anon {"$year/$month/$day"}{'zz'} ;
      $editsmaxmonth_anon {'zz'} = &month_english_short ($month-1) . " $year" ;
    }

    $months    {"$year/$month/$day"} = "$month/$day/$year" ; # Excel format
    $languages {$lang}++ ;
    $languages {'zz'}++ ;
  }
  close EDITS_IN ;
}

sub GenerateEditHistoryReports
{
  return if $language ne "en" ;

  &LogT ("\nGenerateEditHistoryReports\n") ;

  $mb_plots_generated_all = 0 ;
  $plots_all = 0 ;

#  if ($testmode)
#  {
#    &WriteEditsPerUserType ('fy') ;
#    &GeneratePlotEdits     ('fy');
#    &GeneratePlotReverts   ('fy') ;
#    &GeneratePlotAnons     ('fy') ;
#    &GenerateEditHistoryReport ($plots_all, 4, 'Table') ;
#    return ;
#  }

  &WriteEditsPerUserType ('zz') ;
  &GeneratePlotEdits ('zz') ;

  foreach $lang (sort {$reverts_read {$b} <=> $reverts_read {$a}} keys %reverts_read)
  {
    $calls_generate_edit_history_reports++ ;
    &Log ("\nGenerateEditHistoryReports $lang ($calls_generate_edit_history_reports)\n") ;

    &WriteEditsPerUserType ($lang) ;
    &GeneratePlotEdits     ($lang) ;
    &GeneratePlotReverts   ($lang) ;
    &GeneratePlotAnons     ($lang) ;

    $plots_all ++ ;
    $plot_size = -s "$path_out_plots\/PlotEdits" . uc($lang) . ".png" ;
    $mb_plots_generated_all  += $plot_size ;

    next if $plots_all >= $plots_top ;
    $mb_plots_generated_top  += $plot_size ;
  }

  if ($mb_plots_generated_all < 3000000)
  { $mb_plots_generated_all = &i2KbMb ($mb_plots_generated_all) ; }
  else
  { $mb_plots_generated_all = "<font color=#800000>" . &i2KbMb ($mb_plots_generated_all) . "!</font>" ; }

  if ($mb_plots_generated_top < 3000000)
  { $mb_plots_generated_top = &i2KbMb ($mb_plots_generated_top) ; }
  else
  { $mb_plots_generated_top = "<font color=#800000>" . &i2KbMb ($mb_plots_generated_top) . "!</font>" ; }

  &Log ("\n") ;

  if ($plots_all <= $plots_many)
  { $one_edit_history_report = $true ; }
  else
  { $one_edit_history_report = $false ; }

  if ($one_edit_history_report)
  { &GenerateEditHistoryReport ($plots_all, 1, 'All') ; }
  else
  {
    &GenerateEditHistoryReport ($plots_all, 2, 'All') ;
    &GenerateEditHistoryReport ($plots_top, 3, 'Top') ;
  }

  &GenerateEditHistoryReport ($plots_all, 4, 'Table') ;
}

sub NameSpaceArticle # best keep in sync with WikiCountsInput.pl (-> shared pm file ?)
{
  my ($language, $namespace) = @_ ;

  if ($language eq 'strategy')
  { return (($namespace == 0) || ($namespace == 106)) ; }
  elsif ($language eq 'commons')
  { return (($namespace == 0) || ($namespace == 6) || ($namespace == 14)) ; } # + file and category namespaces
  elsif ($mode_ws) # wikisource wikis
  { return (($namespace == 0) || ($namespace == 102) || ($namespace == 104) || ($namespace == 106)) ; } # + author, page, index (`100 = portal)
  else
  { return ($namespace == 0) ; }
}

sub GenerateEditHistoryReport
{
  &LogT ("Generate Edit History Report\n") ; # mode 4: really a html table that links to png's rather than containing them

  my ($plots_show, $mode, $type) = @_ ;

  $file_html = $path_out . "PlotsPngEditHistory$type.htm" ;

  if (! $mode_wp) { $up = "../.." ; } else { $up = ".." ; }
  if ($mode_wb) { $links_other_projects  =    "<font color=#808080>Wikibooks</font>" }      else { $links_other_projects  =    "<a href='$up/wikibooks/EN/PlotsPngEditHistoryTable.htm'>Wikibooks</a>" ; }
  if ($mode_wk) { $links_other_projects .= " / <font color=#808080>Wiktionary</font>" }     else { $links_other_projects .= " / <a href='$up/wiktionary/EN/PlotsPngEditHistoryTable.htm'>Wiktionary</a>" ; }
  if ($mode_wn) { $links_other_projects .= " / <font color=#808080>Wikinews</font>" }       else { $links_other_projects .= " / <a href='$up/wikinews/EN/PlotsPngEditHistoryTable.htm'>Wikinews</a>" ; }
  if ($mode_wp) { $links_other_projects .= " / <font color=#808080>Wikipedia</font>" }      else { $links_other_projects .= " / <a href='$up/EN/PlotsPngEditHistoryTable.htm'>Wikipedia</a>" ; }
  if ($mode_wq) { $links_other_projects .= " / <font color=#808080>Wikiquote</font>" }      else { $links_other_projects .= " / <a href='$up/wikiquote/EN/PlotsPngEditHistoryTable.htm'>Wikiquote</a>" ; }
  if ($mode_ws) { $links_other_projects .= " / <font color=#808080>Wikisource</font>" }     else { $links_other_projects .= " / <a href='$up/wikisource/EN/PlotsPngEditHistoryTable.htm'>Wikisource</a>" ; }
  if ($mode_wv) { $links_other_projects .= " / <font color=#808080>Wikiversity</font>" }    else { $links_other_projects .= " / <a href='$up/wikiversity/EN/PlotsPngEditHistoryTable.htm'>Wikiversity</a>" ; }
  if ($mode_wx) { $links_other_projects .= " / <font color=#808080>Other projects</font>" } else { $links_other_projects .= " / <a href='$up/wikispecial/EN/PlotsPngEditHistoryTable.htm'>Other projects</a>" ; }

  if ($mode < 4)
  { $out_page_title    = "$out_publication Edit History" ; }
  else
  { $out_page_title    = "$out_publication Edit and Revert Counts" ; }

  my $out_html_title    = $out_page_title ;
  my $out_explanation   = $links_other_projects ;
  my $out_msg           = "" ;
  my $out_crossref      = "" ;
  my $plotcnt ;
  my (@index_languages1, @index_languages2, @index_languages3) ;
  my $out_button_switch = "home" ;

  $participation {"intro"} = '' ;

  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
    $out_page_subtitle = &GetDate ($dumpdate2) ;
  }

# $out_crossref = &GenerateCrossReference ("") ;

  $out_html = "" ;
  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      "", "", $out_button_switch, $out_crossref, $out_msg) ;

  if ($mode == 1)
  {
    $out_html .= "<p><h3>Edit history charts for $plots_show $out_publications</h3>See also\n" ;
    $out_html .= "<a href='PlotsPngEditHistoryTable.htm'>Edit and revert counts for $plots_show $out_publications</a><p>\n" ;
  }
  elsif ($mode == 2)
  {
    $out_html .= "<p><h3>Edit history charts for all $plots_show $out_publications</h3>See also\n" ;
    $out_html .= "<a href='PlotsPngEditHistoryTop.htm'>Edit history for top $plots_top $out_publications</a> ($mb_plots_generated_top) / \n" ;
    $out_html .= "<a href='PlotsPngEditHistoryTable.htm'>Edit and revert counts for all $out_publications</a><p>\n" ;
  }
  elsif ($mode == 3)
  {
    $out_html .= "<p><h3>Edit history charts for top $plots_show $out_publications</h3>See also\n" ;
    $out_html .= "<a href='PlotsPngEditHistoryAll.htm'>Edit history for all $plots_all $out_publications</a> ($mb_plots_generated_all) / \n" ;
    $out_html .= "<a href='PlotsPngEditHistoryTable.htm'>Edit and revert counts for all $out_publications</a><p>\n" ;
  }
  else # ($mode == 4)
  {
    if ($one_edit_history_report)
    {
      $out_html .= "<p><h3>Edit and revert counts for $plots_show $out_publications, since start of project</h3>See also\n" ;
      $out_html .= "<a href='PlotsPngEditHistoryAll.htm'>Edit history charts for $plots_all $out_publications</a> ($mb_plots_generated_all)<p>\n" ;
    }
    else
     {
      $out_html .= "<p><h3>Edit and revert counts for all $plots_show $out_publications, since start of project</h3>See also\n" ;
      $out_html .= "<a href='PlotsPngEditHistoryTop.htm'>Edit history charts for top $plots_top $plots_some $out_publications</a> ($mb_plots_generated_top)\n" ;
      $out_html .= "/ <a href='PlotsPngEditHistoryAll.htm'>... for all $plots_all $out_publications</a> ($mb_plots_generated_all)<p>\n" ;
    }
  }

  if ($mode_ws)
  { $out_namespaces = "<tr><td><b>Only article edits are reported here, not edits on talk/project/media pages, etc</b><br>(namespace 0, 102, 104, 106)</td></tr>" ; }
  elsif ($mode_wx)
  { $out_namespaces = "<tr><td><b>Only article edits are reported here, not edits on talk/project/media pages, etc</b><br>(namespace 0, Strategy wiki also 106, Commons also 6 and 14)</td></tr>" ; }
  else
  { $out_namespaces = "<tr><td><b>Only article edits (namespace 0) are reported here, not edits on talk/project/media pages, etc</b></td></tr>" ; }

  if ($mode <= 3)
  {
    $out_html .= "<table border=1 width=640>\nINDEX" ;

    $plots_done = 0 ;
    undef %index_languages1 ;
    undef %index_languages2 ;
    # find largest x languages by total registered edits
    foreach $lang (keys_sorted_by_value_num_desc %{$editstottype{'R'}})
    {
      last if $plots_done++ >= $plots_show ;
      $index_languages1 {$out_languages {$lang}} = "<a href='\#$lang'>${out_languages {$lang}}</a>" ;
      $index_languages2 {$lang} = "<a href='\#$lang'>$lang</a>" ;
    }
    # build index on language names alphabetically
    foreach $key (sort keys %index_languages1)
    { push @index_languages1, $index_languages1 {$key} ; }
    # build index on language names alphabetically
    foreach $key (sort keys %index_languages2)
    { push @index_languages2, $index_languages2 {$key} ; }

    $plots_done = 0 ;
    foreach $lang (keys_sorted_by_value_num_desc %{$editstottype{'R'}})
    {
      last if $plots_done++ >= $plots_show ;
      my $edits = &i2KM4 ($editstottype {'R'}{$lang} + $editstottype {'A'}{$lang} + $editstottype {'B'}{$lang}) ;
      push @index_languages3, "<a href='\#$lang'>${out_languages{$lang}}</a> ($edits)" ;
    }

    $out_html =~ s/,\s*$// ;
    $out_html .= "</table><p>\n" ;

    $out_html .= $out_namespaces ;

    $plots_done = 0 ;
    foreach $lang (keys_sorted_by_value_num_desc %{$editstottype{'R'}})
    {
      last if $plots_done++ >= $plots_show ;
      my $lang_uc = uc $lang ;
      $png_file = "PlotEdits" . uc($lang) . ".png" ;
      $link_edits_reverts = '' ;
      if ($lang ne 'zz')
      { $link_edits_reverts = "<br><a href='EditsReverts$lang_uc\.htm'>More edit and revert trends on ${out_languages{$lang}} $out_publication</a>" ; }
      $out_html .= "<tr><td><a id='$lang' name='$lang'>&nbsp;</a><p><img src='$png_file' class='border'>$link_edits_reverts</td></tr>\n" ;
    }
  }
  else
  {
    $out_html .= $out_namespaces ;

    $out_html .= $out_script_sorter ;
    $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Tables and charts' class=tablesorter>\n<thead>\n" ;

    $out_html .= &tr (&tdc2b (&ww(&b($out_publication))) .
                      &tdc7b (&ww(&b('Edits since start of project'))) .
                      &tdimg2 ("<img src='EditPlot.png'>") .
                      &tdc7b (&ww(&b('Reverts since start of project (MD5)'))) .
                      &tdimg2 ("<img src='RevertPlot.png'>")) ;
    $out_html .= &tr (&tdlr2b (&ww(&b('Code'))) .
                      &tdlr2b (&ww(&b('Language'))) .
                      &tdlr2b (&ww(&b('Total'))) .
                      #&tdcb  (&ww(&b('Total'))) .
                      &tdc2b (&ww(&b('Registered'))) .
                      &tdc2b (&ww(&b('Anonymous'))) .
                      &tdc2b (&ww(&b('Bot'))) .
                      &tdlr2b (&ww(&b('Total'))) .
                      #&tdcb  (&ww(&b('Total'))) .
                      &tdc2b (&ww(&b('Registered'))) .
                      &tdc2b (&ww(&b('Anonymous'))) .
                      &tdc2b (&ww(&b('Bot')))) ;
    $out_html .= &tr (&tdcb  ('Abs') .
                      &tdcb  ('Rel') .
                      &tdcb  ('Abs') .
                      &tdcb  ('Rel') .
                      &tdcb  ('Abs') .
                      &tdcb  ('Rel') .
                      &tdcb  ("&nbsp;") .
                      &tdcb  ('Abs') .
                      &tdcb  ('Rel') .
                      &tdcb  ('Abs') .
                      &tdcb  ('Rel') .
                      &tdcb  ('Abs') .
                      &tdcb  ('Rel') .
                      &tdlr2b ("&nbsp;")) ;
    $out_html .= &tr (&the . &the . &the . &the . &the . &the . &the . &the . &the . &the . &the . &the . &the . &the . &the . &the . &the) ;

    $out_html .= "</thead>\n</tbody>\n" ;
    foreach $lang (keys_sorted_by_value_num_desc %{$editstottype{'R'}})
    {
      $editstotT = $editstottype {'T'}{$lang} ;
      $editstotR = $editstottype {'R'}{$lang} ;
      $editstotA = $editstottype {'A'}{$lang} ;
      $editstotB = $editstottype {'B'}{$lang} ;

      next if $editstotT == 0 ;

      $perceditsR  = '' ;
      $perceditsA  = '' ;
      $perceditsB  = '' ;

      $perceditsR  = sprintf ("%.0f%", 100 * $editstotR / $editstotT) if $editstotR > 0 ;
      $perceditsA  = sprintf ("%.0f%", 100 * $editstotA / $editstotT) if $editstotA > 0  ;
      $perceditsB  = sprintf ("%.0f%", 100 * $editstotB / $editstotT) if $editstotB > 0  ;

      $lang2 = $lang ;
      $lang2 =~ s/^zz$/&Sigma;/ ;

      my $sampling_rate = $sampling_rate_reverts {$lang} ;
      if ($sampling_rate == 0)
      { $sampling_rate = 1 ; }

      my $out_script_plot   = $out_script_plot_reverts ;
      my $out_language_name = $out_languages {$lang} ;
      my $maxmonth          = $editsmaxmonth {$lang} ;
      my $code              = uc ($lang) ;

      $file_csv_input       =~ s/\\/\//g ;
      $path_png_raw         =~ s/\\/\//g ;
      $path_png_trends      =~ s/\\/\//g ;
      $path_svg             =~ s/\\/\//g ;
      $out_language_name    =~ s/&nbsp;/ /g ;

      my $revertstotR = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'R'}{$lang} * $sampling_rate ;
      my $revertstotA = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'A'}{$lang} * $sampling_rate ;
      my $revertstotB = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'B'}{$lang} * $sampling_rate ;
      my $revertstotT = $revertstotR + $revertstotA + $revertstotB ;

      return if $editstotT == 0 ;

      my $percrevertsR = '' ;
      my $percrevertsA = '' ;
      my $percrevertsB = '' ;
      my $percrevertsT = '' ;

      $percrevertsR = sprintf ("%.1f%", 100 * $revertstotR / $editstotR) if $editstotR > 0 and $revertstotR > 0 ;
      $percrevertsA = sprintf ("%.1f%", 100 * $revertstotA / $editstotA) if $editstotA > 0 and $revertstotA > 0 ;
      $percrevertsB = sprintf ("%.1f%", 100 * $revertstotB / $editstotB) if $editstotB > 0 and $revertstotB > 0 ;
      $percrevertsT = sprintf ("%.1f%", 100 * $revertstotT / $editstotT) if $editstotT > 0 and $revertstotT > 0 ;

      $out_html .= &tr (&tdlb ($lang2) .
                        &tdlb ($out_languages{$lang}) .
                        &tdrb (&i2KM4 ($editstotT)) .
                        &tdrb (&i2KM4 ($editstotR)) .
                        &tdrb (        $perceditsR) .
                        &tdrb (&i2KM4 ($editstotA)) .
                        &tdrb (        $perceditsA) .
                        &tdrb (&i2KM4 ($editstotB)) .
                        &tdrb (        $perceditsB) .
                        &tdcb ("<a href='" . "PlotEdits" . uc($lang) . ".png'>Chart</a>") .
                        &tdrb (($lang ne 'zz') ? &i2KM4 ($revertstotT) : "") .
                        &tdrb (($lang ne 'zz') ? &i2KM4 ($revertstotR) : "") .
                        &tdrb (($lang ne 'zz') ?         $percrevertsR : "") .
                        &tdrb (($lang ne 'zz') ? &i2KM4 ($revertstotA) : "") .
                        &tdrb (($lang ne 'zz') ?         $percrevertsA : "") .
                        &tdrb (($lang ne 'zz') ? &i2KM4 ($revertstotB) : "") .
                        &tdrb (($lang ne 'zz') ?         $percrevertsB : "") .
                        &tdcb (($lang ne 'zz') ? "<a href='" . "EditsReverts" . uc($lang) . ".htm'>Trends</a>" : "")) ;
    }
    $out_html .= "</tbody>\n</table>\n" ;

    $out_html .= "<small><p>Revert percentage is ratio reverts:edits per class of editors (registered or anonymous users or bots).<br>" .
                 "Only reverts detected by md5 matching are considered here, not (partial) manual reverts only detectable by edit comment.<br>" .
                 "Reverts is less than reverted edits! Sometimes several edits are undone with one revert (see trends report per language).<br>" .
                 "When several revisions were reverted in one action, the oldest reverted revision determines editor class (and coloring):<br>" .
                 "is this a reverted user edit (reg/anon) or a reverted bot edit?</small><p>" ;

  }

  &GenerateColophon ($false, $false, $true) ;

# $out_html .= "<p><Small>Charts rendered with <a href='http://www.r-project.org/'>R</a></small>" ;
  $out_html .= $out_script_sorter_invoke_edits ;
  $out_html .= "</body>\n</html>\n" ;

#  if ($mode <= 3)
#  {
#    $index = &HtmlIndex ($index_show, join ', ', @index_languages) ;
#    $out_html =~ s/INDEX1/$index/ ;
#    $index = &HtmlIndex ($index_hide, join ', ', @index_languages2) ;
#    $out_html =~ s/INDEX2/$index/ ;
#  }

  if ($mode <= 3)
  {
    $index_languages1 = join ', ', @index_languages1 ;
    $index_languages2 = join ', ', @index_languages2 ;
    $index_languages3 = join ', ', @index_languages3 ;
    $index_html = &HtmlIndex2 ;
    $index_html .= "<tr><td class=l><b>Projects indexed by <span id='caption'><font color=#006600>language</font> / <font color=#A0A0A0>language code</font> / <font color=#A0A0A0>edit count</font></span></b></td><td class=r colspan=99><a href=\"#\" id='toggle' onclick=\"toggle_visibility_index();\">Toggle index</a></td></tr>\n" ;
    $index_html .= "<tr><td class=lwrap colspan=99>\n" .
                   "<span id='index1' style=\"display:block\">\n$index_languages1\n</span>\n" .
                   "<span id='index2' style=\"display:none\">\n$index_languages2\n</span>\n" .
                   "<span id='index3' style=\"display:none\">\n$index_languages3\n</span>" .
                   "</td></tr>\n" ;
    $out_html =~ s/INDEX/$index_html/ ;
  }

  &Log ("Write $file_html\n") ;

  open  EDIT_HISTORY_HTML, ">", $file_html ;
  print EDIT_HISTORY_HTML $out_html ;
  close EDIT_HISTORY_HTML ;

  return ;
}

sub GeneratePlotEdits
{
  my $lang = shift ;

  return if $lang =~ /^zzz?$/ ;

# return if ! $reverts_read {$lang} ;
#  if ($testmode)
#  {
#    my $file_reverts = $path_in . "/RevertedEdits" . uc ($lang) . ".csv" ;
#    return if ! -e $file_reverts ;
#  }

  &LogT ("GeneratePlotEdits $lang\n") ;

  my $file_csv_input    = $file_edits_per_usertype ;
  my $path_png_raw      = "$path_out_plots\/PlotEdits" . uc($lang) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotEditsTrends" . uc($lang) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotEdits" . uc($lang) . ".svg" ;
  my $out_script_plot   = $out_script_plot_edits ;
  my $out_language_name = $out_languages {$lang} ;
  my $editsmax          = $editsmax {$lang} ;
  my $maxmonth          = $editsmaxmonth {$lang} ;
  my $code              = uc ($lang) ;

  $file_csv_input       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  # calc plot parameters

  my $editstotR  = $editstottype {'R'}{$lang} ;
  my $editstotA  = $editstottype {'A'}{$lang} ;
  my $editstotB  = $editstottype {'B'}{$lang} ;
  my $editstotG  = $editstotR + $editstotA + $editstotB ;

  my $reverts_reg_users = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'R'}{$lang} ;
  my $reverts_anon_users = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'A'}{$lang} ;
  my $reverts_bots = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'B'}{$lang} ;
  my $revertstotX = $reverts_reg_users + $reverts_anon_users + $reverts_bots ;

  return if $editstotG == 0 ;

  my $percR = sprintf ("%.0f", 100 * $editstotR / $editstotG) ;
  my $percA = sprintf ("%.0f", 100 * $editstotA / $editstotG) ;
  my $percB = sprintf ("%.0f", 100 * $editstotB / $editstotG) ;
  my $percX = sprintf ("%.0f", 100 * $revertstotX / ($editstotG - $revertstotX)) if $editstotG - $revertstotX > 0  ;

  $editsmax =~ s/(\d)(\d\d\d)$/$1,$2/ ;
  $editsmax =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  $editsmax =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  $editsmax =~ s/(\d)(\d\d\d),/$1,$2,/ ;


  # edit plot parameters

  $editstotR   = &i2KM5 ($editstotR) ;
  $editstotA   = &i2KM5 ($editstotA) ;
  $editstotB   = &i2KM5 ($editstotB) ;
  $editstotG   = &i2KM5 ($editstotG) ;
  $revertstotX = &i2KM5 ($revertstotX) ;

  if ($lang eq 'zz')
  { $out_script_plot =~ s/TITLE/Edits on all $out_publications/g ; }
  elsif ($mode_wx)
  { $out_script_plot =~ s/TITLE/Edits on $out_language_name wiki/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Edits on $out_publication CODE: LANGUAGE/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  }

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_input/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;
  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_MONTH/$maxmonth/g ;
  $out_script_plot =~ s/EDITS/$editsmax/g ;

  $out_script_plot =~ s/TOT_G/total $editstotG/g ;
  $out_script_plot =~ s/TOT_R/total $editstotR/g ;
  $out_script_plot =~ s/TOT_A/total $editstotA/g ;
  $out_script_plot =~ s/TOT_B/total $editstotB/g ;
  $out_script_plot =~ s/TOT_X/total $revertstotX/g ;

  $out_script_plot =~ s/PERC_G/(100%)/g ;
  $out_script_plot =~ s/PERC_R/($percR%)/g ;
  $out_script_plot =~ s/PERC_A/($percA%)/g ;
  $out_script_plot =~ s/PERC_B/($percB%)/g ;
  $out_script_plot =~ s/PERC_X/($percX%)/g ;

  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;

  my $file_script = $path_in . "R-PlotEdits.txt" ;
  open R_SCRIPT, '>', $file_script or die ("file $file_script not found") ; ;
  print R_SCRIPT $out_script_plot ;
  close R_SCRIPT ;

  $cmd = "R CMD BATCH \"$file_script\"" ;

  if ($generate_edit_plots++ == 0)
  { print "$cmd\n" ; }

  @result = `$cmd` ;
#  exit ;
#  exit if $plotsgenerated++ > 10 ;
}

sub GeneratePlotReverts
{
  my $lang = shift ;

  return if $lang =~ /^zzz?$/ ;

  return if ! $reverts_read {$lang} ;

#  if ($testmode)
#  {
#    my $file_reverts = $path_in . "/RevertedEdits" . uc ($lang) . ".csv" ;
#    return if ! -e $file_reverts ;
#  }

  &LogT ("GeneratePlotReverts $lang\n") ;

  my $sampling_rate = $sampling_rate_reverts {$lang} ;
  if ($sampling_rate == 0)
  { $sampling_rate = 1 ; }

  my $file_csv_input    = $file_edits_per_usertype ;
  my $path_png_raw      = "$path_out_plots\/PlotReverts" . uc($lang) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotRevertsTrends" . uc($lang) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotReverts" . uc($lang) . ".svg" ;
  my $out_script_plot   = $out_script_plot_reverts ;
  my $out_language_name = $out_languages {$lang} ;
# my $editsmax          = $editsmax {$lang} ;
  my $maxmonth          = $editsmaxmonth {$lang} ;
  my $code              = uc ($lang) ;

  $file_csv_input       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  # calc plot parameters

  my $editstotR  = $editstottype {'R'}{$lang} ;
  my $editstotA  = $editstottype {'A'}{$lang} ;
  my $editstotB  = $editstottype {'B'}{$lang} ;
  my $editstotG  = $editstotR + $editstotA + $editstotB ;

  my $revertstotR = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'R'}{$lang} * $sampling_rate ;
  my $revertstotA = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'A'}{$lang} * $sampling_rate ;
  my $revertstotB = 0+$reverts_in_article_namespaces_per_revertedusertype_tot {'B'}{$lang} * $sampling_rate ;
  my $revertstotG = $revertstotR + $revertstotA + $revertstotB ;

  return if $editstotG == 0 ;

  my $percR = 100 ;
  my $percA = 100 ;
  my $percB = 100 ;
  my $percG = 100 ;

# $percR = sprintf ("%.1f", 100 * $revertstotR / ($editstotR - $revertstotR)) if $revertstotR < $editstotR ;
# $percA = sprintf ("%.1f", 100 * $revertstotA / ($editstotA - $revertstotA)) if $revertstotA < $editstotA ;
# $percB = sprintf ("%.1f", 100 * $revertstotB / ($editstotB - $revertstotB)) if $revertstotB < $editstotB ;
# $percG = sprintf ("%.1f", 100 * $revertstotG / ($editstotG - $revertstotG)) if $revertstotG < $editstotG ;

  $percR = sprintf ("%.1f", 100 * $revertstotR / $editstotR) if $editstotR > 0 ;
  $percA = sprintf ("%.1f", 100 * $revertstotA / $editstotA) if $editstotA > 0 ;
  $percB = sprintf ("%.1f", 100 * $revertstotB / $editstotB) if $editstotB > 0 ;
  $percG = sprintf ("%.1f", 100 * $revertstotG / $editstotG) if $editstotG > 0 ;

  # edit plot parameters

  $revertstotR = &i2KM5 ($revertstotR) ;
  $revertstotA = &i2KM5 ($revertstotA) ;
  $revertstotB = &i2KM5 ($revertstotB) ;
  $revertstotG = &i2KM5 ($revertstotG) ;

  if ($mode_wx)
  { $out_script_plot =~ s/TITLE/Revert ratio on $out_language_name wiki/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Revert ratio on $out_publication CODE: LANGUAGE/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  }

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_input/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;
  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_MONTH/$maxmonth/g ;
  $out_script_plot =~ s/EDITS/$editsmax/g ;

  $out_script_plot =~ s/TOT_G/$revertstotG reverts/g ;
  $out_script_plot =~ s/TOT_R/$revertstotR reverts/g ;
  $out_script_plot =~ s/TOT_A/$revertstotA reverts/g ;
  $out_script_plot =~ s/TOT_B/$revertstotB reverts/g ;

  $out_script_plot =~ s/PERC_G/($percG%)/g ;
  $out_script_plot =~ s/PERC_R/($percR%)/g ;
  $out_script_plot =~ s/PERC_A/($percA%)/g ;
  $out_script_plot =~ s/PERC_B/($percB%)/g ;

  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;

  $reverts_ylim = ceil ($reverts_perc_max/5) * 5 ;
  $out_script_plot =~ s/YLIM/c(0,$reverts_ylim)/g ;

  my $file_script = $path_in . "R-PlotReverts.txt" ;
  open R_SCRIPT, '>', $file_script or die ("file $file_script not found") ; ;
  print R_SCRIPT $out_script_plot ;
  close R_SCRIPT ;

  $cmd = "R CMD BATCH \"$file_script\"" ;

  if ($generate_edit_plots++ == 0)
  { print "$cmd" ; }

  @result = `$cmd` ;
}

sub GeneratePlotAnons
{
  my $lang = shift ;

  return if $lang =~ /^zzz?$/ ;
  return if ! $reverts_read {$lang} ;

#  if ($testmode)
#  {
#    my $file_reverts = $path_in . "/RevertedEdits" . uc ($lang) . ".csv" ;
#    return if ! -e $file_reverts ;
#  }

  &LogT ("GeneratePlotAnons $lang\n") ;

  my $sampling_rate = $sampling_rate_reverts {$lang} ;
  if ($sampling_rate == 0)
  { $sampling_rate = 1 ; }

  my $file_csv_input    = $file_edits_per_usertype ;
  my $path_png_raw      = "$path_out_plots\/PlotAnons" . uc($lang) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotAnonsTrends" . uc($lang) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotAnons" . uc($lang) . ".svg" ;
  my $out_script_plot   = $out_script_plot_anons ;
  my $out_language_name = $out_languages {$lang} ;
  my $editsmax          = $editsmax_anon {$lang} ;
  my $maxmonth          = $editsmaxmonth_anon {$lang} ;
  my $code              = uc ($lang) ;

  $file_csv_input       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  # legend("topleft",c("All anonymous edits ", "TOT_AT PERC_AT " , " ", "Minus reverts on anon edits ", "TOT_AM PERC_AM", " ","Reverts by reg user ","TOT_RR PERC_RR ", " ", "Reverts by anon user ", "TOT_RA PERC_RA ",  " ", "Reverts by bot ", "TOT_RB PERC_RB ","", "(article edits only)"), lty=1, lwd=2,col=c("red","#E0E0E0", "#E0E0E0", "black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "darkred", "#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

  # calc plot parameters

  my $revertstotRR = 0+$reverts_anon_per_revertingusertype_tot {'R'}{$lang} * $sampling_rate ;
  my $revertstotRA = 0+$reverts_anon_per_revertingusertype_tot {'A'}{$lang} * $sampling_rate ;
  my $revertstotRB = 0+$reverts_anon_per_revertingusertype_tot {'B'}{$lang} * $sampling_rate ;
  my $revertstotT = $revertstotRR + $revertstotRA + $revertstotRB ;

  my $editstotA   = $editstottype {'A'}{$lang} ; # all anonymous edits
  my $editstotAM  = $editstotA - $revertstotT ; # all anonymous edits minus all reverted anon edits

  return if $editstotA == 0 ;

  $percAM = sprintf ("%.1f", 100 * $editstotAM   / $editstotA) ;
  $percRR = sprintf ("%.1f", 100 * $revertstotRR / $editstotA) ;
  $percRA = sprintf ("%.1f", 100 * $revertstotRA / $editstotA) ;
  $percRB = sprintf ("%.1f", 100 * $revertstotRB / $editstotA) ;

  $editstotA    = &i2KM5 ($editstotA) ;
  $editstotAM   = &i2KM5 ($editstotAM) ;
  $revertstotRR = &i2KM5 ($revertstotRR) ;
  $revertstotRA = &i2KM5 ($revertstotRA) ;
  $revertstotRB = &i2KM5 ($revertstotRB) ;

  $reverts_ylim = 100 ; # ceil ($reverts_perc_max/5) * 5 ;

  # edit plot parameters
  if ($mode_wx)
  { $out_script_plot =~ s/TITLE/Anon. edits on $out_language_name wiki/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Anon. edits on $out_publication CODE: LANGUAGE/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  }

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_input/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;
  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_MONTH/$maxmonth/g ;
  $out_script_plot =~ s/EDITS/$editsmax/g ;

  $out_script_plot =~ s/TOT_AT/$editstotA  edits/g ;     # anonymous edits total
  $out_script_plot =~ s/TOT_AM/$editstotAM edits/g ;     # anonymous edits total minus reverts
  $out_script_plot =~ s/TOT_RR/$revertstotRR reverts/g ; # reverts by reg user
  $out_script_plot =~ s/TOT_RA/$revertstotRA reverts/g ; # reverts by anon user
  $out_script_plot =~ s/TOT_RB/$revertstotRB reverts/g ; # reverts by bot

  $out_script_plot =~ s/PERC_AT/(100%)/g ;
  $out_script_plot =~ s/PERC_AM/($percAM%)/g ;  # perc anonymous edits minus reverts
  $out_script_plot =~ s/PERC_RR/($percRR%)/g ;  # perc reverts by reg user
  $out_script_plot =~ s/PERC_RA/($percRA%)/g ;  # perc reverts by anon users
  $out_script_plot =~ s/PERC_RB/($percRB%)/g ;  # perc reverts by bot

  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;

  $out_script_plot =~ s/YLIM/c(0,$reverts_ylim)/g ;

  my $file_script = $path_in . "R-PlotAnons.txt" ;
  open  R_SCRIPT, '>', $file_script or die ("file $file_script not found") ; ;
  print R_SCRIPT $out_script_plot ;
  close R_SCRIPT ;

  $cmd = "R CMD BATCH \"$file_script\"" ;

  if ($generate_edit_plots++ == 0)
  { print "$cmd" ; }

  @result = `$cmd` ;
}

sub WriteEditsPerUserType
{
  my $lang = shift  ;

  if ($testmode)
  {
    my $file_reverts = $path_in . "/RevertedEdits" . uc ($lang) . ".csv" ;
    return if ! -e $file_reverts ;
  }

  &LogT ("\nWriteEditsPerUserType: $lang\n") ;

  my $sampling_rate = 0 + $sampling_rate_reverts {$lang} ;
  if ($sampling_rate == 0)
  { $sampling_rate = 1 ; }
  &Log ("Sampling rate $lang $sampling_rate\n") ;

  $highest_monthly_total_edits = $editsmax {$lang} ;
  $highest_monthly_anon_edits  = $editsmax_anon {$lang} ;

  return if $highest_monthly_anon_edits == 0 ;

  open EDITS_OUT, '>', $file_edits_per_usertype or die ("file $file_edits_per_usertype not found") ; ;

  # all metrics are scaled such that full height of plot area is always used
  print EDITS_OUT "language,month," .
                  # following metrics are relative to max total edits (max = for busiest month)
                  "PE_edits_reg_users, PE_edits_anon_users, PE_edits_bots, PE_edits_total, PE_reverts_total," .
                  # not used in any plot
                  "reverts_reg,reverts_anon,reverts_bot,registered_abs,anonymous_abs,bot_abs,total_abs,reverts_tot_abs,reverts_reg_abs,reverts_anon_abs,reverts_bot_abs," .
                  # following metrics are relative to max revert rate (can be for total edits, reg users, anon users or bots)
                  "PR_reverts_total, PR_reverts_reg_users, PR_reverts_anon_users, PR_reverts_bots," .
                  # following metrics are relative to max edits by anonymous users (max = for busiest month)
                  "PA_edits_anon_users, PA_edits_anon_users_kept, PA_reverts_by_reg_users, PA_reverts_by_anon_users, PA_reverts_by_bots\n" ;

  $edits_found = $false ;
  my $months = 0 ;
  $reverts_perc_max = 0 ; # determine max value in any ..._rel column for ylimit in GenerateEditPlotReverts


# PE = Plot Edits
# PR = Plot Revert Ratio
# PA = Plot Anons

  for $month (sort keys %months)
  {
    $month2 = substr ($month,0,4) . substr ($month,5,2) ;
    last if $month2 ge $month_reverts_hi {$lang} ;

    if ($editstot {$month}{$lang} >  0)
    { $edits_found = $true ; }

    next if ! $edits_found ;
    next if $lang eq 'strategy' and $month lt '2009' ; # ignore a few imported articles dating back up to to 2001

    $month2 = $months {$month} ;
    my ($mm,$dd,$yy) = split ('\/', $month2) ;
    my  $yyyymm = sprintf ("%04d%02d",$yy,$mm) ;
    if ($months++ == 0)
    {
      if ($mm > 2)
      {
        print EDITS_OUT "$lang," . sprintf ("%02d/%02d/%04d", 1,     31, $yy) . ",0,0,0,0\n" ;
        print EDITS_OUT "$lang," . sprintf ("%02d/%02d/%04d", $mm-1, 28, $yy) . ",0,0,0,0\n" ;
      }
      elsif ($mm == 2)
      {
        print EDITS_OUT "$lang," . sprintf ("%02d/%02d/%04d", 1,     31, $yy) . ",0,0,0,0\n" ;
      }
    }

    $edits_reg_users  = 0+$edits {$month}{'R'}{$lang} ;
    $edits_anon_users = 0+$edits {$month}{'A'}{$lang} ;
    $edits_bots       = 0+$edits {$month}{'B'}{$lang} ;
    $edits_total      = $edits_reg_users + $edits_anon_users + $edits_bots ;

    $PA_reverts_by_reg_users  = sprintf ("%.1f", 100 * $revertstats_wp {'ArticleRevertedEditFromAnonUserRevertByRegUser'  . $yyyymm}{$lang} / $highest_monthly_anon_edits) ;
    $PA_reverts_by_anon_users = sprintf ("%.1f", 100 * $revertstats_wp {'ArticleRevertedEditFromAnonUserRevertByAnonUser' . $yyyymm}{$lang} / $highest_monthly_anon_edits) ;
    $PA_reverts_by_bots       = sprintf ("%.1f", 100 * $revertstats_wp {'ArticleRevertedEditFromAnonUserRevertByBot'      . $yyyymm}{$lang} / $highest_monthly_anon_edits) ;

    $reverts_reg_users  = 0+$reverts_in_article_namespaces_per_revertedusertype {'R'}{$month}{$lang} * $sampling_rate ;
    $reverts_anon_users = 0+$reverts_in_article_namespaces_per_revertedusertype {'A'}{$month}{$lang} * $sampling_rate ; ;
    $reverts_bots       = 0+$reverts_in_article_namespaces_per_revertedusertype {'B'}{$month}{$lang} * $sampling_rate ; ;
    $reverts_total      = $reverts_reg_users + $reverts_anon_users + $reverts_bots ;

    $PE_edits_reg_users  = sprintf ("%.1f", 100 * $edits_reg_users  / $highest_monthly_total_edits) ;
    $PE_edits_anon_users = sprintf ("%.1f", 100 * $edits_anon_users / $highest_monthly_total_edits) ;
    $PE_edits_bots       = sprintf ("%.1f", 100 * $edits_bots       / $highest_monthly_total_edits) ;
    $PE_edits_total      = sprintf ("%.1f", 100 * $edits_total      / $highest_monthly_total_edits) ;

    $reverts_r2       = sprintf ("%.1f", 100 * $reverts_reg_users  / $highest_monthly_total_edits) ;
    $reverts_a2       = sprintf ("%.1f", 100 * $reverts_anon_users / $highest_monthly_total_edits) ;
    $reverts_b2       = sprintf ("%.1f", 100 * $reverts_bots       / $highest_monthly_total_edits) ;
    $PE_reverts_total = sprintf ("%.1f", 100 * $reverts_total      / $highest_monthly_total_edits) ;

    $PA_edits_anon_users      = sprintf ("%.1f", 100 * $edits_anon_users                         / $highest_monthly_anon_edits) ;
    $PA_edits_anon_users_kept = sprintf ("%.1f", 100 * ($edits_anon_users - $reverts_anon_users) / $highest_monthly_anon_edits) ;

    $PR_reverts_reg_users  = 0 ;
    $PR_reverts_anon_users = 0 ;
    $PR_reverts_bots       = 0 ;
    $PR_reverts_total      = 0 ;

#   ratio reverts : non reverted edits (does not yet account for multiple edits reverted in one go)
#   $PR_reverts_reg_users  = sprintf ("%.1f", 100 * $reverts_reg_users  / ($edits_reg_users  - $reverts_reg_users))  if $edits_reg_users  - $reverts_reg_users > 0 ;
#   $PR_reverts_anon_users = sprintf ("%.1f", 100 * $reverts_anon_users / ($edits_anon_users - $reverts_anon_users)) if $edits_anon_users - $reverts_anon_users > 0 ;
#   $PR_reverts_bots       = sprintf ("%.1f", 100 * $reverts_bots       / ($edits_bots       - $reverts_bots))       if $edits_bots       - $reverts_bots > 0 ;
#   $PR_reverts_total      = sprintf ("%.1f", 100 * $reverts_total      / ($edits_total      - $reverts_total))      if $edits_total      - $reverts_total > 0 ;

#   getting back to percentage reverts as share of totals edits, (reverts relative to total non reverted edits is difficult to explain and maybe not more useful after all)
    $PR_reverts_reg_users  = sprintf ("%.1f", 100 * $reverts_reg_users  / $edits_reg_users)  if $edits_reg_users  > 0 ;
    $PR_reverts_anon_users = sprintf ("%.1f", 100 * $reverts_anon_users / $edits_anon_users) if $edits_anon_users > 0 ;
    $PR_reverts_bots       = sprintf ("%.1f", 100 * $reverts_bots       / $edits_bots)       if $edits_bots       > 0 ;
    $PR_reverts_total      = sprintf ("%.1f", 100 * $reverts_total      / $edits_total)      if $edits_total      > 0 ;

    if ($lang eq "nl")
    { print "$month2, $PR_reverts_anon_users\% $edits_anon_users - $reverts_anon_users = " . ($edits_anon_users - $reverts_anon_users) . "\n" ; }

    if ($PR_reverts_reg_users  > $reverts_perc_max) { $reverts_perc_max = $PR_reverts_reg_users ; }
    if ($PR_reverts_anon_users > $reverts_perc_max) { $reverts_perc_max = $PR_reverts_anon_users ; }
    if ($PR_reverts_total      > $reverts_perc_max) { $reverts_perc_max = $PR_reverts_total ; }

    # if ($PR_reverts_bots > $reverts_perc_max)
    # {
    #  if ($PR_reverts_bots > $reverts_perc_max + 5)
    #  { $reverts_perc_max = $PR_reverts_max + 5 }
    #  else
    #  { $reverts_perc_max = $PR_reverts_bots ; }
    #}

    if (($edits_total > 0) && ($PE_reverts_total)) # do not show months for which no revert data are available yet
    {
      $line = "$lang,$month2," .
              "$PE_edits_reg_users,  $PE_edits_anon_users, $PE_edits_bots, $PE_edits_total, $PE_reverts_total," .
              "$reverts_r2,$reverts_a2,$reverts_b2, $edits_reg_users, $edits_anon_users, $edits_bots, $edits_total, $reverts_total,$reverts_reg_users,$reverts_anon_users,$reverts_bots," .
              "$PR_reverts_total,    $PR_reverts_reg_users, $PR_reverts_anon_users, $PR_reverts_bots," .
              "$PA_edits_anon_users, $PA_edits_anon_users_kept, $PA_reverts_by_reg_users, $PA_reverts_by_anon_users, $PA_reverts_by_bots\n" ;
      print EDITS_OUT $line ;
    }
  }
  close EDITS_OUT ;
}

sub HtmlIndex
{
  my ($show, $index) = @_ ;

  if ($show)
  { $display = 'block' ; $action = 'Hide' ; $id = 'index1' ; $toggle = 'toggle1' ; $caption = 'Projects indexed by total numbers of edits' }
  else
  { $display = 'none'  ; $action = 'Show' ; $id = 'index2' ; $toggle = 'toggle2' ; $caption = 'Projects indexed alphabetically by language code'}

  my $html = <<__HTML_INDEX__ ;

<script type="text/javascript">
<!--
function toggle_visibility_$id()
{
  var index  = document.getElementById('$id');
  var toggle = document.getElementById('$toggle');
  if (index.style.display == 'block')
  {
    index.style.display = 'none';
    toggle.innerHTML = 'Show index';
  }
  else
  {
    index.style.display = 'block';
    toggle.innerHTML = 'Hide index';
  }
}
//-->
</script>

<tr><td class=l><b>$caption</b></td><td class=r colspan=99><a href="#" id='$toggle' onclick="toggle_visibility_$id();">$action index</a></td></tr>
<tr><td class=lwrap colspan=99><span id='$id' style="display:$display">\n$index\n</span></td></tr>
__HTML_INDEX__
  return ($html) ;
}

sub HtmlIndex2
{
  my $html = <<__HTML_INDEX_2__ ;
<script type="text/javascript">
<!--
function toggle_visibility_index()
{
  var index1  = document.getElementById('index1');
  var index2  = document.getElementById('index2');
  var index3  = document.getElementById('index3');
  var caption = document.getElementById('caption');
  if (index1.style.display == 'block')
  {
    index1.style.display = 'none';
    index2.style.display = 'block';
    index3.style.display = 'none';
    caption.innerHTML = '<font color=#A0A0A0>language</font> / <font color=#006600>language code</font> / <font color=#A0A0A0>edit count</font>' ;
  }
  else
  {
    if (index2.style.display == 'block')
    {
      index1.style.display = 'none';
      index2.style.display = 'none';
      index3.style.display = 'block';
      caption.innerHTML = '<font color=#A0A0A0>language</font> / <font color=#A0A0A0>language code</font> / <font color=#006600>edit count</font>' ;
    }
    else
    {
      index1.style.display = 'block';
      index2.style.display = 'none';
      index3.style.display = 'none';
      caption.innerHTML = '<font color=#006600>language</font> / <font color=#A0A0A0>language code</font> / <font color=#A0A0A0>edit count</font>' ;
    }
  }
}
//-->
</script>
__HTML_INDEX_2__
  return ($html) ;
}

sub GenerateYearlyGrowthStats
{
  return if ! $wikimedia ;
  &LogT ("\nGenerateYearlyGrowthStats") ;

  &ReadFileCsv ($file_csv_growth) ;
  @csv = grep ($_ !~ /^$mode/, @csv) ;

  my ($m0, $project, %editors, %articles, %sizecount) ;

     if ($mode_wb) { $m0 = ord (&yyyymm2b (2003, 7)) ; $project = 'Wikibooks' ; }
  elsif ($mode_wk) { $m0 = ord (&yyyymm2b (2003, 1)) ; $project = 'Wiktionaries' ;  }
  elsif ($mode_wn) { $m0 = ord (&yyyymm2b (2004,11)) ; $project = 'Wikinews' ;  }
  elsif ($mode_wp) { $m0 = ord (&yyyymm2b (2001, 1)) ; $project = 'Wikipedias' ; }
  elsif ($mode_wq) { $m0 = ord (&yyyymm2b (2003, 7)) ; $project = 'Wikiquote' ;  }
  elsif ($mode_ws) { $m0 = ord (&yyyymm2b (2003,11)) ; $project = 'Wikisources' ; }
  elsif ($mode_wv) { $m0 = ord (&yyyymm2b (2005, 1)) ; $project = 'Wikiversity' ;  }
  elsif ($mode_wx) { $m0 = ord (&yyyymm2b (2007, 1)) ; $project = 'Wikispecial' ;  }
  else { return ; }

  # findest oldest month where combined editors for all languages ifs first to exceed some power of ten
  for (my $m = $dumpmonth_ord ; $m >= $m0 ; $m--)
  {
    for (my $magnitude = 10 ; $magnitude <= 1000000000 ; $magnitude *= 10)
    {
      if ($MonthlyStats {'zz'.$m.$c[0]} >= $magnitude)
      { $editors {$magnitude} = $m ; }
      if ($MonthlyStats {'zz'.$m.$c[4]} >= $magnitude)
      { $articles {$magnitude} = $m ; }
    }
  }

  my $lines ;
  my $linecnt ;
  # numbers are for end of month, so add 1 to each date to get start of next month, use this for EasyTimeline
  my $ddmmyyyy_prev = &mmddyyyy2ddmmyyyy (&mmddyyyyInc (&m2mmddyyyy ($dumpmonth_ord))) ;
  foreach my $magnitude (sort {$editors {$b} <=> $editors {$a}} keys %editors)
  {
    my $ddmmyyyy = &mmddyyyy2ddmmyyyy (&mmddyyyyInc (&m2mmddyyyy ($editors{$magnitude}))) ;
    $line = "  bar:$project from:$ddmmyyyy till:$ddmmyyyy_prev \$U$magnitude" ;
    if ($magnitude == 10)
    { substr ($line,0,1) = '#' ; }
    push @lines, $line ;
    $ddmmyyyy_prev = $ddmmyyyy ;
  }
  foreach $line (reverse @lines)
  {
    $linecnt = sprintf ("%02d", ++ $linecnt) ;
    push @csv, "$mode,$linecnt,$line" ;
  }
  $linecnt = sprintf ("%02d", ++ $linecnt) ;
  push @csv, "$mode,$linecnt" ;

  @lines = () ;
  # numbers are for end of month, so add 1 day to each date to get start of next month, use this for EasyTimeline
  my $ddmmyyyy_prev = &mmddyyyy2ddmmyyyy (&mmddyyyyInc (&m2mmddyyyy ($dumpmonth_ord))) ;
  foreach my $magnitude (sort {$articles {$b} <=> $articles {$a}} keys %articles)
  {
    my $ddmmyyyy = &mmddyyyy2ddmmyyyy (&mmddyyyyInc (&m2mmddyyyy ($articles{$magnitude}))) ;
    $line = "  bar:$project from:$ddmmyyyy till:$ddmmyyyy_prev \$A$magnitude" ;
    if ($magnitude == 10)
    { substr ($line,0,1) = '#' ; }
    push @lines, $line ;
    $ddmmyyyy_prev = $ddmmyyyy ;
  }
  foreach $line (reverse @lines)
  {
    $linecnt = sprintf ("%02d", ++ $linecnt) ;
    push @csv, "$mode,$linecnt,$line" ;
  }
  $linecnt = sprintf ("%02d", ++ $linecnt) ;
  push @csv, "$mode,$linecnt" ;

  @lines = () ;
  for (my $m = $dumpmonth_ord ; $m >= $m0 ; $m--)
  {
    next if $m % 12 > 0 ;
    undef %sizecount ;
    my $ddmmyyyy = &mmddyyyy2ddmmyyyy (&mmddyyyyInc (&m2mmddyyyy ($m))) ;
    foreach my $wp (@languages)
    {
      for (my $magnitude = 10 ; $magnitude <= 1000000000 ; $magnitude *= 10)
      {
        if ($MonthlyStats {$wp.$m.$c[4]} >= $magnitude)
        { $sizecount {"$ddmmyyyy,$magnitude"} ++ ; }
      }
    }
    foreach my $key (sort {$sizecount {$b} <=> $sizecount {$a}} keys %sizecount)
    {
      ($date,$magnitude) = split (',', $key) ;
      # print "[$date, $magnitude] : ${sizecount {$key}}\n" ;
      if ($magnitude > 10)
      {
        $line = "   bar:$project at:$date text:${sizecount {$key}}  \$L$magnitude  \$S00a1" ;
        push @lines, $line ;
      }
    }
    push @lines, '' ;
  }
  foreach $line (reverse @lines)
  {
    $linecnt = sprintf ("%02d", ++ $linecnt) ;
    push @csv, "$mode,$linecnt,$line" ;
  }
  $linecnt = sprintf ("%02d", ++ $linecnt) ;
  push @csv, "$mode,$linecnt" ;

  open CSV, '>', $file_csv_growth ;
  foreach $line (sort @csv)
  { print CSV "$line\n" ; }
  close CSV ;

  open TXT, '>', $file_txt_growth ;
  foreach $line (sort @csv)
  {
    my ($mode,$index,$line) = split (',', $line,3) ;
    print TXT "$line\n" ;
  }
  close TXT ;
}

1;

