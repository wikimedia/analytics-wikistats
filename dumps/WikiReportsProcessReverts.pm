#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (2) ;

# plot 2 hele legenda in orde maken
# plot 3 percentage van all edits
# cross check getallen in plots en percentage in table 2:
# tel teotalen in legeneda plot 3 op
# ook reverts voor $lang='zz' opslaan

# $path_in  = "W:/# Out Bayes/csv_wp" ;
# $path_out = "W:/# Out Test/htdocs/EN" ;
# push @languages, "nl" ;
# &ProcessReverts ;
# print "\n\nReady\n\n" ;
# exit ;

sub ReadRevertHistoryGenerateReports
{
  return if $language ne "en" ;
  &LogT ("\nReadRevertHistoryGenerateReports\n\n") ;

  foreach $wp (@languages)
  {
    # next if $wp ne "fy" ;

    undef %reverts_per_article ;
    undef %reverts_in_non_article_namespaces ;

    undef %reverts_per_article_per_usertype ;
    undef %reverts_per_reverting_user ;
    undef %reverts_per_reverted_user_per_month ;
    undef %reverts_per_reverted_user ;

    undef %reverts_per_month ;
    undef %reverts_per_month_per_usertype ;

    undef %reverts_per_year_all ;
    undef %reverts_per_year_md5 ;
    undef %revertstats ;

    undef %reverting_revisions ;
    $reverting_revisions_tot = 0 ;

    undef %bots ;
    undef %bots3 ;

    # read list of bots as defined in sql user table, collected by WikiCounts
    &ReadFileCsv ($file_csv_bots, $wp) ;
    my ($lang,$botlist) = split (',', $csv [0]) ;
    my @bots2 = split ('\|', $botlist) ;
    foreach my $bot (@bots2)
    { $bots {$bot} = $true ; }

    # find bots that are at least defined on 10 projects, may be not registered as bots here (happens lot on smallest wikis), still assume they are bots here as well
    &ReadFileCsv ($file_csv_bots) ;
    foreach $line (@csv)
    {
      my ($wp,$bots) = split (',', $line, 2) ;
      my @bots2 = split ('\|', $bots) ;
      foreach $bot (@bots2)
      { $bots3 {$bot} ++ ; }
    }
    foreach my $bot (keys %bots3)
    {
      if ($bots3 {$bot} >= 10)
      { $bots {$bot} = $true ; }
    }

    my $file_reverts = $path_in . "/RevertedEdits" . uc ($wp) . ".csv" ;
    # my $file_out = $path_in . "/RevertedEdits2" . uc ($wp) . ".csv" ;
    if (!-e $file_reverts)
    {
      $file_reverts = $path_in . "/RevertedEdits" . uc ($wp) . ".csv.bz2" ;
      next if ! -e $file_reverts  ;
    }

    &Log ("\nProcess reverts for $wp\n") ;

    $reverts_read = 0 ;

    if ($file_reverts =~ /csv$/)
    { open REVERTS, '<', $file_reverts ; }
    else
    { open REVERTS, "-|", "bzip2 -dc \"$file_reverts\"" || abort ("Input file '" . $file_reverts . "' could not be opened.") ; }

    binmode REVERTS ;

    while ($line = <REVERTS>)
    {
      if ($line =~ /^#/)
      {
        if ($line =~ /sampling rate/i)
        { ($sampling_rate_reverts {$wp} = $line) =~ s/[^\d]//g ; }
        next ;
      }

    #  if (($wp ne "af") && $testmode && (++ $skip_most_reverts_in_test_mode % 50 > 0))
    #  { next ; }

      chomp $line ;
    # print REVERTED_EDITS substr($time,0,6) . ",$revertflags,'$comment'\n" ; }
    # print REVERTED_EDITS substr($prev_time,0,6) . ",$revertflags,$revert_after_secs_fmt,-$index_md5_33,$prev_revertflags,$prev_namespace,$prev_title,$prev_time,$prev_usertype,$prev_user,$prev_comment" ;
      my ($yyyymm,$revertflags,$namespace,$user,$usertype,$title,$comment,$version_older,$revert_after_secs,$prev_time,$prev_revertflags,$prev_usertype,$prev_user) = split (',', $line) ;

      # enormous amounts of false positives, many 'Wikipedia:...' pages are status pages that return to empty page often
      # for example in wp:en dump Jan 2010 there were 132820 'reverts' for Wikipedia:Administrator intervention against vandalism
      next if $namespace == 4 or $namespace == 5 ;

      $reverts_read {$wp} ++ ;
      if ($month_reverts_hi {$wp} lt $yyyymm)
      { $month_reverts_hi {$wp} = $yyyymm ; }

      $year = substr ($yyyymm,0,4) ;
      $reverts_per_year_all {$year}++ ;

      # fix usertype
      if (($comment =~ /^bot/i) || ($comment =~ /^robot/i)) # only when comment starts with (ro)bot take this as clue for bot
      { $usertype2 = 'B' ; } # bot
      elsif (&IpAddress ($user))
      { $usertype2 = 'A' ; } # anonymous
      else
      {
        if (&IsBot ($user) == 0)
        { $usertype2 = 'R' ; } # registered ;
        else
        { $usertype2 = 'B' ; } # bot
      }
      if ($usertype ne $usertype2)
      {
        # print "$usertype $usertype2 $user $time $article\n" ;
        $usertype = $usertype2 ;
        $usertype_corrected++ ;
        substr ($revertflags,5,1) = $usertype ;
      }

      # count reverting actions for breakdown tables

      if (&NameSpaceArticle ($wp,$namespace))
      { $revertstat = 'Article' ;     $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      else
      { $revertstat = 'Other' ;       $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }

      if (($revertflags =~ /^..M/) || ($revertflags =~ /^.C./))
      { $revertstat .= 'Reverted' ;   $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      else
      { $revertstat .= 'Edit' ;       $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }

      if ($revertflags =~ /^......R/)
      { $revertstat .= 'EditFromRegUser' ;  $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      elsif ($revertflags =~ /^......A/)
      { $revertstat .= 'EditFromAnonUser' ; $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      elsif ($revertflags =~ /^......B/)
      { $revertstat .= 'EditFromBot' ;      $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      else
      { $revertstat .= 'EditFromUnknown' ;  $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }

      if ($revertflags =~ /^.....R/)
      { $revertstat .= 'RevertByRegUser' ;  $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      elsif ($revertflags =~ /^.....A/)
      { $revertstat .= 'RevertByAnonUser' ; $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      else
      { $revertstat .= 'RevertByBot' ;      $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }

      if ($revertflags =~ /^.......S/)
      { $revertstat .= 'IsSelf' ;     $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }
      else
      { $revertstat .= 'NonSelf' ;    $revertstats {$revertstat} ++ ; $revertstats {$revertstat . $year} ++ ; $revertstats_wp {$revertstat . $yyyymm} {$wp} ++ ; }

      # if ($revertstat =~ /ArticleRevertByBotToUnknown/)
      # { print "$line\n" ; }
      # print "$revertflags: $revertstat\n" ;

      # print "YYYYMM $yyyymm SECS $revert_after_secs REVERT $revertflags PREV_REVERT $prev_revertflags  NS $namespace TITLE  $title TIME $prev_time USERTYPE $prev_usertype USER $prev_user COMMENT $comment\n" ;
      next if ($revertflags !~ /^..M/) ; # && ($revertflags !~ /^.C./) ; # continue with md5 matched reverts only

      $yyyy  = substr ($yyyymm,0,4) ;
      $mm    = substr ($yyyymm,4,2) ;
      $dd    = days_in_month ($yyyy,$mm) ;

      $reverting_revisions {-$version_older-1} ++ ;
      $reverting_revisions_tot ++ ;

      if (&NameSpaceArticle ($wp,$namespace))
      {
        $reverts_per_article {$title}++ if $title ne '' ;
        $reverts_per_reverted_user {$prev_user}++  if $prev_user ne '' ;
      # $reverts_per_reverted_user_per_month {$yyyymm} {$prev_user}++  if $prev_user ne '' ; # memory hog
        $reverts_per_reverting_user {$user}++  if $user ne '' ;
        $reverts_per_month    {$yyyymm}++ ;
        $reverts_per_year_md5 {$yyyy}++ ;

        $reverts_per_article_per_usertype {$prev_usertype} {$title}++ ;
        $reverts_per_month_per_usertype   {$prev_usertype} {$yyyymm}++ ;

        # global hashes
        $reverts_in_article_namespaces_per_revertedusertype        {$prev_usertype} {"$yyyy/$mm/$dd"}{$wp} ++ ;
        if ($prev_usertype eq 'A')
        { $reverts_anon_per_revertingusertype_tot {$usertype} {$wp} ++ ; }

        $reverts_in_article_namespaces_per_revertedusertype_tot {$prev_usertype} {$wp} ++ ;
        $reverts_in_article_namespaces     {"$yyyy/$mm/$dd"}{$wp} ++ ; # for WikiReportsOutputEditHistory.WriteEditsPerUserType
      }
      else
      {
        $reverts_in_non_article_namespaces {"$namespace:$title"}++ if $title ne '' ;

        # global hash
        # $reverts_non_article {"$yyyy/$mm/$dd"}{$wp} ++ ;
      }

      # last if ($cnt++) > 1000000 ;
      if ($reverts_read {$wp} % 100000 == 0)
      { print "Reverts read " . ($reverts_read {$wp} / 1000) . " k\n" ; }
    }
    close REVERTS ;

    &ProcessRevertStats ($wp) ;
    &WriteReportReverts ($wp) ;
  }

  print "User type corrected: $usertype_corrected\n" ;
}

sub ProcessRevertStats
{
  my $wp = shift ;
  &Log ("ProcessRevertsStats $wp\n") ;

  undef @top_reverting_users ;
  undef @top_reverted_users ;
  undef @top_reverted_articles ;
  undef @top_reverted_non_articles ;

  my $reverted_titles_printed_reverting_users ;
  my $reverted_titles_printed_reverted_users ;
  my $reverted_titles_printed_articles ;
  my $reverted_titles_printed_non_articles ;
  my $perc ;

  if ($reverting_revisions_tot > 0)
  {
    &Log ("Reverted revisions per action:\n") ;
    $out_breakdown_reverting_revisions = "Reverts broken down by number of reverted edits: " ;
    $reverted_revisions_gt_5 = 0 ;
    $edits = 'edit' ;
    foreach $key (sort {$a <=> $b} keys %reverting_revisions)
    {
      if ($key <= 5)
      {
        my $reverts = $reverting_revisions {$key} ;
        $perc = sprintf ("%.0f", 100 * $reverts / $reverting_revisions_tot) ;
        $out_breakdown_reverting_revisions .= "<b>$key $edits</b>:$perc\%, " ;
        $edits = 'edits' ;
      }
      else
      { $reverted_revisions_gt_5 += $reverting_revisions {$key} }
    }
    $perc = sprintf ("%.0f", 100 * $reverted_revisions_gt_5 / $reverting_revisions_tot) ;
  # $out_breakdown_reverting_revisions .= ">10: " . &i2KM4 ($reverted_revisions_gt_5) . " ($perc\%)\n" ;
    $out_breakdown_reverting_revisions .= "<b>>5 edits</b>:$perc\%\n" ;
  }

  $reverts_per_article = keys %reverts_per_article ;
  $reverts_in_non_article_namespaces = keys %reverts_in_non_article_namespaces ;
  &Log ("\nArticles with reverts $wp: $reverts_per_article\n") ;
  &Log ("Non articles with reverts $wp: $reverts_in_non_article_namespaces\n") ;

  if ($wp eq 'en') # sort fails on too large hash, pre-shrink hash
  {
    $users_in_hash_reverts_per_reverting_user = 0 ;
    $users_in_hash_reverts_per_reverted_user = 0 ;
    while(($user, $count) = each(%reverts_per_reverting_user))
    {
      $users_in_hash_reverts_per_reverting_user ++ ;
      if ($count > 100)
      { $reverts_per_reverting_user2 {$user} = $count ; }
    }
    %reverts_per_reverting_user = %reverts_per_reverting_user2 ;
    undef %reverts_per_reverting_user2 ;

    while(($user, $count) = each(%reverts_per_reverted_user))
    {
      $users_in_hash_reverts_per_reverted_user ++ ;
      if ($count > 100)
      { $reverts_per_reverted_user2 {$user} = $count ; }
    }
    %reverts_per_reverted_user = %reverts_per_reverted_user2 ;
    undef %reverts_per_reverted_user2 ;

    &Log ("\nusers_in_hash_reverts_per_reverting_user $users_in_hash_reverts_per_reverting_user\n") ;
    &Log ("users_in_hash_reverts_per_reverted_user $users_in_hash_reverts_per_reverted_user\n\n") ;
  }

  # print "\n\n" ;
  &Log ("Find users with most reverting edits\n") ;
# foreach $user (keys_sorted_by_value_num_desc %reverts_per_reverting_user)
  foreach $user (sort {$reverts_per_reverting_user {$b} <=> $reverts_per_reverting_user {$a}} keys %reverts_per_reverting_user)
  {
    # print sprintf ("%5d", $reverts_per_reverting_user {$user}) . "= $user\n" ;
    push @top_reverting_users, "${reverts_per_reverting_user {$user}},$user" ;
    last if $reverted_titles_printed_reverting_users ++ >= 50 ;
  }
  undef %reverts_per_reverting_user ;

  &Log ("Find users with most reverted edits\n") ;
# foreach $user (keys_sorted_by_value_num_desc %reverts_per_reverted_user)
  foreach $user (sort {$reverts_per_reverted_user {$b} <=> $reverts_per_reverted_user {$a}} keys %reverts_per_reverted_user)
  {
    # print sprintf ("%5d", $reverts_per_reverted_user {$user}) . "= $user\n" ;
    push @top_reverted_users, "${reverts_per_reverted_user {$user}},$user" ;
    last if $reverted_titles_printed_reverted_users ++ >= 50 ;
  }
  undef %reverts_per_reverted_user ;

  # print "\n\n" ;
  &Log ("Find articles with most reverts\n") ;
  foreach $article (keys_sorted_by_value_num_desc %reverts_per_article)
  {
    # print sprintf ("%5d", $reverts_per_article {$article}) . "= $article\n" ;
    push @top_reverted_articles, "${reverts_per_article {$article}},$article" ;
    last if $reverted_titles_printed_articles ++ >= 50 ;
  }

  # print "\n\n" ;
  &Log ("Find non articles with most reverts\n") ;
  foreach $title (keys_sorted_by_value_num_desc %reverts_in_non_article_namespaces)
  {
    # print sprintf ("%5d", $reverts_in_non_article_namespaces {$title}) . "= $title\n" ;
    push @top_reverted_non_articles, "${reverts_in_non_article_namespaces {$title}},$title" ;
    last if $reverted_titles_printed_non_articles ++ >= 50 ;
  }

  foreach $revertflags (keys_sorted_alpha_asc %revertstats)
  {
    #if ($revertflags =~ /^NC/
    #print "$revertflags ${revertstats {$revertflags}}\n" ;
  }
}

sub WriteReportReverts
{
  my $wp = shift ;
  &LogT ("WriteReportReverts $wp\n") ;

  &ReadFileCsv ($file_csv_namespaces) ;
  foreach $line (@csv)
  {
    my ($wp,$ns,$name) = split (',', $line, 3) ;
    $name =~ s/^'// ;
    $name =~ s/'$// ;
    $namespaces {$ns} = $name ;
  }

  my $out_zoom = "" ;
  my $out_options = "" ;
  my $out_explanation = "" ;
  my $out_button_prev = "" ;
  my $out_button_next = "" ;
  my $out_page_subtitle = "" ;
  my $out_crossref = "" ;
  my $out_description = "" ;
  my $lang ;
  my $out_html_start   = "" ;
  my $out_html_verbose = "" ;
  my $out_html_concise = "" ;
  my $out_button_switch = "home" ;
  my $out_msg = "" ;

  my (@index_languages1, @index_languages2, @index_languages3) ;

  my $out_html_title = $out_statistics . " \- " . "Edit and Revert Trends" ;
  my $out_page_title = $out_statistics . " \- " . "Edit and Revert Trends: " ."<a href='" . $out_urls {$wp} . "'>" . $out_languages {$wp} . "</a>" ;
  my $show_anons = ($editstottype {'A'}{$wp} > 100) ; # only on larger wikis # ($wp =~ /(?:en|de|ja|fr|pl|es|pt|ru|zh|nl|af)/i) ;

  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
    $out_page_title .= "<b>" . &GetDate ($dumpdate2) . "<\/b>" ;
  }
#  $out_crossref = &GenerateCrossReference ($language) ;

#  &ReadLog ($language) ;

  &GenerateHtmlStart ($out_html_title,  $out_zoom,          $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

  $out_html .= "<a href='PlotsPngEditHistoryTop.htm'>Edit history charts for top $plots_top $out_publications</a>\n" ;
  $out_html .= "/ <a href='PlotsPngEditHistoryAll.htm'>... for all $plots_all $out_publications</a> / " .
               "<a href='PlotsPngEditHistoryTable.htm'>Edit and revert counts for all $out_publications</a><p>" ;

  $out_html .= "<table border=1 width=640>\nINDEX\n</table>\n<p>" .
               "<h3>Monthly trend in number of edits</h3>" .
               "Also shown is monthly trend for total reverts, for scale comparison<p>" .
               "Chart shows absolute numbers (y axis scale shows number of edits relative (%) to busiest month)<p>" .
               "<img src='PlotEdits" . uc ($wp) . ".png' border='1' alt='Plot Edits'>&nbsp;&nbsp;&nbsp;<img src='PlotEditsTrends" . uc ($wp) . ".png' border='1' alt='Plot Edits'><br>" .

               "<hr width=640 align=left><p>" .
               "<h3>Monthly trend in revert activity, relative to edit volume</h3>" .
               "Per x edits, were anonymous edits reverted more often than edits by bots or by registered users?<p>" .
               "Chart shows ratio reverts:edits per class of editors (registered or anonymous users or bots).<br>" .
               "Note: often peaks in revert ratio in early years are not so significant as in later years: <br>" .
               "low absolute edit counts easily led to high fluctuations in revert ratio.<p>" .
               "<img src='PlotReverts" . uc ($wp) . ".png' border='1' alt='Plot Reverts'>&nbsp;&nbsp;&nbsp;<img src='PlotRevertsTrends" . uc ($wp) . ".png' border='1' alt='Plot Reverts'><p>" .
               "<small>Revert ratio is <i>ratio reverts:edits per class of editors (registered or anonymous users or bots)</i>.<br>" .
               "Only reverts detected by md5 matching are considered here, not (partial) manual reverts only detectable by edit comment.<p>" .
               "Reverts is less than reverted edits! Sometimes several edits are undone with one revert.<br>" .
               "$out_breakdown_reverting_revisions<p>" .
               "When several revisions were reverted in one action, the oldest reverted revision determines editor class (and coloring):<br>" .
               "is this a reverted user edit (reg/anon) or a reverted bot edit?</small><p>" .

               ($show_anons ?
               "<hr width=640 align=left><p>" .
               "<h3>Monthly trend in revert activity towards anonymous edits</h3>" .
               "Are anonymous edits reverted often, and if so, by what type of reverter?<p>" .
               "Chart shows absolute numbers (y axis scale shows number of edits relative (%) to busiest month)<br>" .
               "Note: for many (not all) larger projects the not reverted edits show less seasonal fluctuation than the reverted edits<p>" .

               "<img src='PlotAnons" . uc ($wp) . ".png' border='1' alt='Plot Anons'>&nbsp;&nbsp;&nbsp;<img src='PlotAnonsTrends" . uc ($wp) . ".png' border='1' alt='Plot Anons'><p>" .
               "<small>'All anonymous edits' is same red line from first chart, scaled up vertically<br>" .
               "Put succinctly: red - black = blue + brown + green<br>" .
               "Only reverts detected by md5 matching are considered here, not (partial) manual reverts only detectable by edit comment.<p>" .
               "Percentages are an approximation, as two simplifying assumptions have been made: <br>" .
               "1) Anonymous edits are reverted only once (in other words edit wars on anon edits are not taken into account).<br>" .
               "2) On each revert only one anonymous edit was undone. A frequency count of <i>multiple revision reverts</i> shows this is a simplification:<br>" .
               "$out_breakdown_reverting_revisions</small><p>"
               : "") ;


  if ($wp =~ /^zzz?/)
  { ; }
  elsif ($sampling_rate_reverts {$wp} > 1)
  { $out_html .= "<font color=#800000><b>Revert rate (%) plot based on extrapolation, after sampling 1:${sampling_rate_reverts {$wp}} articles.</b></font>" ; }
  else # = no sampling
  {

    foreach $key (sort keys %revertstats)
    { &Log2 ("$key: ${revertstats{$key}}\n") ; }

    $out_html .= "<hr width=640 align=left><p>" ;
    $out_html .= "<h3>Distribution of reverts</h3>\n" ;
    $out_html .= "Breakdown per namespace, type of reverted editor (registered or anonymous user or bot), type of reverter (same), was it a self revert or not, per time period.<br>" .
                 "Note: a high percentage in any segment can relate to a high absolute number of edits for that segment, or a high revert ratio, or both (please consult charts above for context)<br>." .
                 "Projects pages are excluded due to enormous amount of false positives: some status pages are cleared often as normal process<p>" ;

    $revertstotal                     = $revertstats {'Article'} + $revertstats {'Other'} ;
    $revertstotal_article_md5         = $revertstats {'Article'} - $revertstats {'ArticleRevertedEditFromUnknown'} ;
                                                               # - $revertstats {'ArticleRevertedEditFromRegUserRevertByRegUserIsSelf'}
                                                               # - $revertstats {'ArticleRevertedEditFromAnonUserRevertByAnonUserIsSelf'}
                                                               # - $revertstats {'ArticleRevertedEditFromBotRevertByBotIsSelf'} ;

    $out_html .= "<table border=0 cellspacing=0 style='' summary='Distribution of Reverts'>\n" ;
    $out_html .= "<tr><td>" ;

    $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Distribution of Reverts2'>\n" ;
    $out_html .= &tr (&thlb99 ('&nbsp;Distribution of reverts, each subdivision adds up to 100%')) ;
    $out_html .= &tr (&thcb2 ('Namespace(s)'). &thcb2 ('Reverted editor'). &thcb2 ('Revert by'). &thcb2 ('Self revert')) ;
    $out_html .= &tr (&RS (15,'Articles','Article')   . &RS2 (4,'Reg user',  'Article', 'ArticleRevertedEditFromRegUser') . &RS2 (2,'Reg user',  'ArticleRevertedEditFromRegUser',  'ArticleRevertedEditFromRegUserRevertByRegUser') .   &RS2 (1,'Self',   'ArticleRevertedEditFromRegUserRevertByRegUser', 'ArticleRevertedEditFromRegUserRevertByRegUserIsSelf')) ;
    $out_html .= &tr (                                                                                                                                                                                                                   &RS2 (1,'Others', 'ArticleRevertedEditFromRegUserRevertByRegUser', 'ArticleRevertedEditFromRegUserRevertByRegUserNonSelf')) ;
    $out_html .= &tr (                                                                                                      &RS2 (1,'Anon user', 'ArticleRevertedEditFromRegUser',  'ArticleRevertedEditFromRegUserRevertByAnonUser')) ;
    $out_html .= &tr (                                                                                                      &RS2 (1,'Bot',       'ArticleRevertedEditFromRegUser',  'ArticleRevertedEditFromRegUserRevertByBot')) ;
    $out_html .= &tr (                                  &RS2 (4,'Anon user', 'Article','ArticleRevertedEditFromAnonUser').  &RS2 (1,'Reg user',  'ArticleRevertedEditFromAnonUser', 'ArticleRevertedEditFromAnonUserRevertByRegUser')) ;
    $out_html .= &tr (                                                                                                      &RS2 (2,'Anon user', 'ArticleRevertedEditFromAnonUser', 'ArticleRevertedEditFromAnonUserRevertByAnonUser') . &RS2 (1,'Self',   'ArticleRevertedEditFromAnonUserRevertByAnonUser', 'ArticleRevertedEditFromAnonUserRevertByAnonUserIsSelf')) ;
    $out_html .= &tr (                                                                                                                                                                                                                   &RS2 (1,'Others', 'ArticleRevertedEditFromAnonUserRevertByAnonUser', 'ArticleRevertedEditFromAnonUserRevertByAnonUserNonSelf')) ;
    $out_html .= &tr (                                                                                                      &RS2 (1,'Bot',       'ArticleRevertedEditFromAnonUser', 'ArticleRevertedEditFromAnonUserRevertByBot')) ;
    $out_html .= &tr (                                  &RS2 (4,'Bot',       'Article', 'ArticleRevertedEditFromBot') .     &RS2 (1,'Reg user',  'ArticleRevertedEditFromBot',      'ArticleRevertedEditFromBotRevertByRegUser')) ;
    $out_html .= &tr (                                                                                                      &RS2 (1,'Anon user', 'ArticleRevertedEditFromBot',      'ArticleRevertedEditFromBotRevertByAnonUser')) ;
    $out_html .= &tr (                                                                                                      &RS2 (2,'Bot',       'ArticleRevertedEditFromBot',      'ArticleRevertedEditFromBotRevertByBot')       .     &RS2 (1,'Self',   'ArticleRevertedEditFromBotRevertByBot', 'ArticleRevertedEditFromBotRevertByBotIsSelf')) ;
    $out_html .= &tr (                                                                                                                                                                                                                   &RS2 (1,'Others', 'ArticleRevertedEditFromBotRevertByBot', 'ArticleRevertedEditFromBotRevertByBotNonSelf')) ;
    $out_html .= &tr (                                  &RS2 (3,'Unknown',   'Article', 'ArticleRevertedEditFromUnknown') . &RS2 (1,'Reg User',  'ArticleRevertedEditFromUnknown',  'ArticleRevertedEditFromUnknownRevertByRegUser')) ;
    $out_html .= &tr (                                                                                                      &RS2 (1,'Anon User', 'ArticleRevertedEditFromUnknown',  'ArticleRevertedEditFromUnknownRevertByAnonUser')) ;
    $out_html .= &tr (                                                                                                      &RS2 (1,'Bot',       'ArticleRevertedEditFromUnknown',  'ArticleRevertedEditFromUnknownRevertByBot')) ;
    $out_html .= &tr (&RS (4,'Other<br>Non-<br>Project<br>Pages','Other') .         &RS2 (1,'Reg user',  'Other', 'OtherRevertedEditFromRegUser')) ;
    $out_html .= &tr (                                  &RS2 (1,'Anon user', 'Other', 'OtherRevertedEditFromAnonUser')) ;
    $out_html .= &tr (                                  &RS2 (1,'Bot',       'Other', 'OtherRevertedEditFromBot')) ;
    $out_html .= &tr (                                  &RS2 (1,'Unknown',   'Other', 'OtherRevertedEditFromUnknown')) ;
    $out_html .= &tr ( &tdc99b ("Unknown = comments mentions (partial) revert, but no md5 match")) ;
    $out_html .= &tr ( &tdc99b ("Reg = registered, Anon = anonymous")) ;
    $out_html .= "</table>\n" ;

    $out_html .= "</td><td>&nbsp;&nbsp;</td><td>" ;

    $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Distribution of Reverts2'>\n" ;
    $out_html .= &tr (&thlb99 ('&nbsp;Distribution of reverts, each percentage is share of total reverts')) ;
    $out_html .= &tr (&thcb2 ('Namespace(s)'). &thcb2 ('Reverted editor'). &thcb2 ('Revert by'). &thcb2 ('Self revert')) ;
    $out_html .= &tr (&RS (15,'Articles','Article')   . &RS  (4,'Reg user',            'ArticleRevertedEditFromRegUser') .  &RS  (2,'Reg user',                                     'ArticleRevertedEditFromRegUserRevertByRegUser') .   &RS  (1,'Self',                                                    'ArticleRevertedEditFromRegUserRevertByRegUserIsSelf')) ;
    $out_html .= &tr (                                                                                                                                                                                                                   &RS  (1,'Others',                                                  'ArticleRevertedEditFromRegUserRevertByRegUserNonSelf')) ;
    $out_html .= &tr (                                                                                                      &RS  (1,'Anon user',                                    'ArticleRevertedEditFromRegUserRevertByAnonUser')) ;
    $out_html .= &tr (                                                                                                      &RS  (1,'Bot',                                          'ArticleRevertedEditFromRegUserRevertByBot')) ;
    $out_html .= &tr (                                  &RS  (4,'Anon user',           'ArticleRevertedEditFromAnonUser').  &RS  (1,'Reg user',                                     'ArticleRevertedEditFromAnonUserRevertByRegUser')) ;
    $out_html .= &tr (                                                                                                      &RS  (2,'Anon user',                                    'ArticleRevertedEditFromAnonUserRevertByAnonUser') . &RS  (1,'Self',                                                      'ArticleRevertedEditFromAnonUserRevertByAnonUserIsSelf')) ;
    $out_html .= &tr (                                                                                                                                                                                                                   &RS  (1,'Others',                                                    'ArticleRevertedEditFromAnonUserRevertByAnonUserNonSelf')) ;
    $out_html .= &tr (                                                                                                      &RS  (1,'Bot',                                          'ArticleRevertedEditFromAnonUserRevertByBot')) ;
    $out_html .= &tr (                                  &RS  (4,'Bot',                 'ArticleRevertedEditFromBot') .      &RS  (1,'Reg user',                                     'ArticleRevertedEditFromBotRevertByRegUser')) ;
    $out_html .= &tr (                                                                                                      &RS  (1,'Anon user',                                    'ArticleRevertedEditFromBotRevertByAnonUser')) ;
    $out_html .= &tr (                                                                                                      &RS  (2,'Bot',                                          'ArticleRevertedEditFromBotRevertByBot')       .     &RS  (1,'Self',                                            'ArticleRevertedEditFromBotRevertByBotIsSelf')) ;
    $out_html .= &tr (                                                                                                                                                                                                                   &RS  (1,'Others',                                          'ArticleRevertedEditFromBotRevertByBotNonSelf')) ;
    $out_html .= &tr (                                  &RS  (3,'Unknown',             'ArticleRevertedEditFromUnknown') .  &RS  (1,'Reg User',                                     'ArticleRevertedEditFromUnknownRevertByRegUser')) ;
    $out_html .= &tr (                                                                                                      &RS  (1,'Anon User',                                    'ArticleRevertedEditFromUnknownRevertByAnonUser')) ;
    $out_html .= &tr (                                                                                                      &RS  (1,'Bot',                                          'ArticleRevertedEditFromUnknownRevertByBot')) ;
    $out_html .= &tr (&RS (4,'Other<br>Non-<br>Project<br>Pages','Other') .         &RS  (1,'Reg user',           'OtherRevertedEditFromRegUser')) ;
    $out_html .= &tr (                                  &RS  (1,'Anon user',          'OtherRevertedEditFromAnonUser')) ;
    $out_html .= &tr (                                  &RS  (1,'Bot',                'OtherRevertedEditFromBot')) ;
    $out_html .= &tr (                                  &RS  (1,'Unknown',            'OtherRevertedEditFromUnknown')) ;
    $out_html .= &tr ( &tdc99b ("Unknown = comments mentions (partial) revert, but no md5 match")) ;
    $out_html .= &tr ( &tdc99b ("Reg = registered, Anon = anonymous")) ;
    $out_html .= "</table>\n" ;

    $out_html .= "</td><td>&nbsp;&nbsp;</td><td>" ;

    $out_html .= "<table border=1 cellspacing=0 style='' summary='Distribution of Reverts per Year'>\n" ;
    $out_html .= &tr (&thlb99 ('&nbsp;Distribution of reverts, per year and type')) ;
    $line_html = '' ;
    for $yyyy (keys_sorted_alpha_desc %reverts_per_year_all)
    { $line_html .= &thcb ($yyyy) ; }
    $out_html .= &tr ($line_html) ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromRegUserRevertByRegUserIsSelf') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromRegUserRevertByRegUserNonSelf') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromRegUserRevertByAnonUser') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromRegUserRevertByBot') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromAnonUserRevertByRegUser') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromAnonUserRevertByAnonUserIsSelf') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromAnonUserRevertByAnonUserNonSelf') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromAnonUserRevertByBot') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromBotRevertByRegUser') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromBotRevertByAnonUser') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromBotRevertByBotIsSelf') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromBotRevertByBotNonSelf') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromUnknownRevertByRegUser') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromUnknownRevertByAnonUser') ;
    $out_html .= &RSyearly_all  ('ArticleRevertedEditFromUnknownRevertByBot') ;
    $out_html .= &RSyearly_all  ('OtherRevertedEditFromRegUser') ;
    $out_html .= &RSyearly_all  ('OtherRevertedEditFromAnonUser') ;
    $out_html .= &RSyearly_all  ('OtherRevertedEditFromBot') ;
    $out_html .= &RSyearly_all  ('OtherRevertedEditFromUnknown') ;
    $out_html .= &tr (&thlb99 ('&nbsp;totals reverts per year')) ;
    $line_html = '' ;
    for $yyyy (keys_sorted_alpha_desc %reverts_per_year_all)
    { $line_html .= &tdcb (&i2KM4 ($reverts_per_year_all {$yyyy})) ; }
    $out_html .= &tr ($line_html) ;
    $out_html .= "</table>\n" ;

    $out_html .= "</td></tr>" ;

  # $out_html .= "<tr><td>&nbsp;</td><td colspan=99>Above is distribution of all reverts, detected by md5 matching or specific comments, for all namespaces<br>" .
  #                                                "Below is distribution of reverts detected by md5 matching, for article namespace only</td></tr>" ;

    $out_html .= "<tr><td>&nbsp;</td><td>&nbsp;&nbsp;</td><td valign=top><p>" ;

    $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Distribution of Reverts2'>\n" ;
    $out_html .= &tr (&thlb99 ('&nbsp;Distribution of reverts, like table above, but percentages are share<br>&nbsp;of md5 detected reverts only, for article namespace only')) ;
    $out_html .= &tr (&thcb2 ('<font color=\'#FFFFDD\'>Namespace(s)</font>'). &thcb2 ('Reverted editor'). &thcb2 ('Revert by'). &thcb2 ('Self revert')) ;
    $out_html .= &tr (&tdecrsb (2,12) . &RS4 (4,'Reg user',  'ArticleRevertedEditFromRegUser') .  &RS4 (2,'Reg user',  'ArticleRevertedEditFromRegUserRevertByRegUser') .   &RS4 (1,'Self',   'ArticleRevertedEditFromRegUserRevertByRegUserIsSelf')) ;
    $out_html .= &tr (                                                                                                                                    &RS4 (1,'Others', 'ArticleRevertedEditFromRegUserRevertByRegUserNonSelf')) ;
    $out_html .= &tr (                                                          &RS4 (1,'Anon user', 'ArticleRevertedEditFromRegUserRevertByAnonUser')) ;
    $out_html .= &tr (                                                          &RS4 (1,'Bot',       'ArticleRevertedEditFromRegUserRevertByBot')) ;
    $out_html .= &tr (&RS4 (4,'Anon user', 'ArticleRevertedEditFromAnonUser').  &RS4 (1,'Reg user',  'ArticleRevertedEditFromAnonUserRevertByRegUser')) ;
    $out_html .= &tr (                                                          &RS4 (2,'Anon user', 'ArticleRevertedEditFromAnonUserRevertByAnonUser') . &RS4 (1,'Self',   'ArticleRevertedEditFromAnonUserRevertByAnonUserIsSelf')) ;
    $out_html .= &tr (                                                                                                                                    &RS4 (1,'Others', 'ArticleRevertedEditFromAnonUserRevertByAnonUserNonSelf')) ;
    $out_html .= &tr (                                                          &RS4 (1,'Bot',       'ArticleRevertedEditFromAnonUserRevertByBot')) ;
    $out_html .= &tr (&RS4 (4,'Bot',       'ArticleRevertedEditFromBot') .      &RS4 (1,'Reg user',  'ArticleRevertedEditFromBotRevertByRegUser')) ;
    $out_html .= &tr (                                                          &RS4 (1,'Anon user', 'ArticleRevertedEditFromBotRevertByAnonUser')) ;
    $out_html .= &tr (                                                          &RS4 (2,'Bot',       'ArticleRevertedEditFromBotRevertByBot')       .     &RS4 (1,'Self',   'ArticleRevertedEditFromBotRevertByBotIsSelf')) ;
    $out_html .= &tr (                                                                                                                                    &RS4 (1,'Others', 'ArticleRevertedEditFromBotRevertByBotNonSelf')) ;
    $out_html .= &tr ( &tdc99b ("Reg = registered, Anon = anonymous")) ;
    $out_html .= "</table>\n" ;

    $out_html .= "</td><td>&nbsp;&nbsp;</td><td valign=top><p>" ;

    $out_html .= "<table border=1 cellspacing=0 style='' summary='Distribution of Reverts per Year'>\n" ;
    $out_html .= &tr (&thlb99 ('&nbsp;Distribution of reverts, like table above, but percentages are<br>&nbsp;share of md5 detected reverts only, for article namespace only')) ;
    $line_html = '' ;
    for $yyyy (keys_sorted_alpha_desc %reverts_per_year_all)
    { $line_html .= &thcb ($yyyy) ; }
    $out_html .= &tr ($line_html) ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromRegUserRevertByRegUserIsSelf') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromRegUserRevertByRegUserNonSelf') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromRegUserRevertByAnonUser') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromRegUserRevertByBot') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromAnonUserRevertByRegUser') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromAnonUserRevertByAnonUserIsSelf') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromAnonUserRevertByAnonUserNonSelf') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromAnonUserRevertByBot') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromBotRevertByRegUser') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromBotRevertByAnonUser') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromBotRevertByBotIsSelf') ;
    $out_html .= &RSyearly_md5 ('ArticleRevertedEditFromBotRevertByBotNonSelf') ;
    $out_html .= &tr (&thlb99 ('&nbsp;totals reverts per year')) ;
    $line_html = '' ;

    for $yyyy (keys_sorted_alpha_desc %reverts_per_year_all)
    { $line_html .= &tdcb (&i2KM4 ($reverts_per_year_md5 {$yyyy})) ; }

    $out_html .= &tr ($line_html) ;
    $out_html .= "</table>\n" ;

    $out_html .= "</td></tr>" ;
    $out_html .= "</table><p>" ;

    $out_html .= "<h3>Top Rankings</h3>\n" ;

    $out_html .= "<table border=1 cellspacing=0 id=table3 style='' summary='Byp Users'>\n" ;
    $out_html .= &tr (&thcb4 ("Users") .
                      &thcb4 ("Content")) ;
    $out_html .= &tr (&thlb2 ("&nbsp;Most Active Reverters&nbsp;") .
                      &thlb2 ("&nbsp;Most Reverted Editors&nbsp;") .
                      &thlb2 ("&nbsp;Most Reverted Articles&nbsp;") .
                      &thlb2 ("&nbsp;Most Reverted Other Non-Project Pages&nbsp;")) ;

    $out_html .= &tr (&thcb ("# Rv") .
                      &thlb ("&nbsp;User/Bot&nbsp;") .
                      &thcb ("# Rv") .
                      &thlb ("&nbsp;User/Bot&nbsp;") .
                      &thcb ("# Rv") .
                      &thlb ("&nbsp;Article&nbsp;") .
                      &thcb ("# Rv") .
                      &thlb ("Page")) ;

    for ($i = 0 ; $i < 50 ; $i++)
    {
      $user_reverting       = $top_reverting_users [$i] ;
      $user_reverted        = $top_reverted_users  [$i] ;
      $article_reverted     = $top_reverted_articles [$i] ;
      $non_article_reverted = $top_reverted_non_articles [$i] ;

      last if (($user_reverting eq '') && ($user_reverted eq '') && ($article_reverted eq '') && ($non_article_reverted eq '')) ;

      ($count_reverting,   $user_reverting)       = split (',', $user_reverting) ;
      ($count_reverted,    $user_reverted)        = split (',', $user_reverted) ;
      ($count_article,     $article_reverted)     = split (',', $article_reverted) ;
      ($count_non_article ,$non_article_reverted) = split (',', $non_article_reverted) ;

      $userpage = $out_userpages {$wp} ;
      if (! defined ($userpage))
      { $userpage = "user" ; }

      $url_user    = $out_urls {$wp} . $out_wikipage . $userpage ;
      $url_article = $out_urls {$wp} . $out_wikipage ;
      $url_other   = $out_urls {$wp} . $out_wikipage ;

      ($user_reverting2 = $user_reverting) =~ s/ /_/g ;
      ($user_reverted2  = $user_reverted)  =~ s/ /_/g ;
      ($article_reverted2 = $article_reverted) =~ s/ /_/g ;
      ($non_article_reverted2 = $non_article_reverted) =~ s/ /_/g ;

      $non_article_reverted =~ s/^(\d+):/$namespaces{$1}.":"/e ;

      $user_reverting2       = encode_url $user_reverting2 ;
      $user_reverted2        = encode_url $user_reverted2 ;
      $article_reverted2     = encode_url $article_reverted2 ;
      $non_article_reverted2 = encode_url $non_article_reverted2 ;


      if (&IsBot ($user_reverting))
      { $user_reverting = "<font color=#800000>$user_reverting</font>" ; }

      if (&IsBot ($user_reverted))
      { $user_reverted = "<font color=#800000>$user_reverted</font>" ; }

      $out_html .= &tr (&tdrb ($count_reverting) .
                        &tdlb ("<a href='$url_user:$user_reverting2'>" . unicode_to_html($user_reverting) . "</a>") .
                        &tdrb ($count_reverted) .
                        &tdlb ("<a href='$url_user:$user_reverted2'>" . unicode_to_html($user_reverted) . "</a>").
                        &tdrb ($count_article) .
                        &tdlb ("<a href='$url_article$article_reverted2'>" . unicode_to_html($article_reverted) . "</a>") .
                        &tdrb ($count_non_article) .
                        &tdlb ("<a href='$url_other:$non_article_reverted2'>" . unicode_to_html($non_article_reverted) . "</a>")
                        ) ;
    }
    $out_html .= &tr (&tdc4b ("<small>Bot names are in <font color=#800000>dark red</font></small>") . &tdc99b ("&nbsp;")) ;
    $out_html .= &tr (&tdc99b ("<small>#Rv is <i>revert actions</i>, not <i>reverted revisions</i> (sometimes a revert action undoes several revisions).")) ;
    $out_html .= &tr (&tdc99b ("<small>Only reverts detected by md5 match are considered here, not (partial) reverts only detectable via comments.")) ;
    $out_html .= &tr (&tdc99b ("<small>Projects pages are excluded due to enormous amount of false positives: some status pages are cleared often as normal process")) ;
    $out_html .= "</table>" ;
  }

#  print "\n\n" ;
#  open CSV_REVERTS, '>', 'W:/# Out Test/csv_wp/RevertedEditsNL.csv' ;
#  &Log ("Reverts per month\n\n") ;
#  foreach $yyyymm (keys_sorted_alpha_asc %reverts_per_month)
#  {
#    print "$yyyymm= " . sprintf ("%5d", $reverts_per_month {$yyyymm}) . "\n" ;
#    $yyyy = substr ($yyyymm,0,4) ;
#    $mm = substr ($yyyymm,4,2) ;
#    print CSV_REVERTS "\"=DATE($yyyy,$mm,1)\",${reverts_per_month {$yyyymm}}\n" ;
#  }
#  close CSV_REVERTS ;

  $generate_sitemap = $false ;
  $sitemap_new_layout = $false ;

  &GenerateColophon ($false, $false, $true) ;

  $out_html .= "</body>\n</html>" ;

  foreach $lang (sort {$out_languages {$a} cmp $out_languages {$b}} keys %{$editstottype{'R'}})
  {
    my $edits = &i2KM4 ($editstottype {'R'}{$lang} + $editstottype {'A'}{$lang} + $editstottype {'B'}{$lang}) ;
    my $file_html = "EditsReverts" . uc ($lang) . ".htm" ;
    my $file_csv  = "$path_in\/RevertedEdits" . uc($lang) . ".csv" ;
    if (-e $file_csv)
    { push @index_languages1, "<a href='$file_html'>${out_languages {$lang}}</a>" ; }
    else
    { push @index_languages1, ${out_languages {$lang}} ; }
  }

  foreach $lang (sort keys %{$editstottype{'R'}})
  {
    my $edits = &i2KM4 ($editstottype {'R'}{$lang} + $editstottype {'A'}{$lang} + $editstottype {'B'}{$lang}) ;
    my $file_html = "EditsReverts" . uc ($lang) . ".htm" ;
    my $file_csv  = "$path_in\/RevertedEdits" . uc($lang) . ".csv" ;
    if (-e $file_csv)
    { push @index_languages2, "<a href='$file_html'>$lang</a>" ; }
    else
    { push @index_languages2, $lang ; }
  }

  foreach $lang (keys_sorted_by_value_num_desc %{$editstottype{'R'}})
  {
    my $edits = &i2KM4 ($editstottype {'R'}{$lang} + $editstottype {'A'}{$lang} + $editstottype {'B'}{$lang}) ;
    my $file_html = "EditsReverts" . uc ($lang) . ".htm" ;
    my $file_csv  = "$path_in\/RevertedEdits" . uc($lang) . ".csv" ;
    if (-e $file_csv)
    { push @index_languages3, "<a href='$file_html'>${out_languages{$lang}}</a> ($edits)" ; }
    else
    { push @index_languages3, $out_languages{$lang} ; }
  }

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


  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  my $file_html = $path_out . "/EditsReverts" . uc ($wp) . ".htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub RSyearly_all
{
  my $key = shift ;
  my $line_html = '' ;
  for $yyyy (keys_sorted_alpha_desc %reverts_per_year_all)
  { $line_html .= &tdcb (&RS3_all ($yyyy,$key)) ; }
  return (&tr ($line_html)) ;
}

sub RSyearly_md5
{
  my $key = shift ;
  my $line_html = '' ;
  for $yyyy (keys_sorted_alpha_desc %reverts_per_year_all) # use hash ...year_all for keys: in small wikis some year may be missing
  { $line_html .= &tdcb (&RS3_md5 ($yyyy,$key)) ; }
  return (&tr ($line_html)) ;
}

sub RS
{
  my ($rows,$text,$key) = @_ ;
  my $count = $revertstats {$key} ;
  my $perc = '-' ;
  if ($revertstotal > 0)
  { $perc = sprintf ("%.1f", 100 * $count / $revertstotal) ; }
  return (&tdlmr ($rows,"<b>$text</b>") . &tdrmr ($rows,"$perc\%")) ;
}

sub RS4
{
  my ($rows,$text,$key) = @_ ;
  my $count = $revertstats {$key} ;
  my $perc = '-' ;
  if ($revertstotal_article_md5 > 0)
  { $perc = sprintf ("%.1f", 100 * $count / $revertstotal_article_md5) ; }
  return (&tdlmr ($rows,"<b>$text</b>") . &tdrmr ($rows,"$perc\%")) ;
}

sub RS2
{
  my ($rows,$text,$key1,$key2) = @_ ;
  my $count1 = $revertstats {$key1} ;
  my $count2 = $revertstats {$key2} ;
  my $perc = '-' ;
  if ($count1 > 0)
  { $perc = sprintf ("%.1f", 100 * $count2 / $count1) ; }
  return (&tdlmr ($rows,"<b>$text</b>") . &tdrmr ($rows,"$perc\%")) ;
}

sub RS3_all
{
  my ($yyyy,$key) = @_ ;
  my $count = $revertstats {$key.$yyyy} ;
  my $peryear = $reverts_per_year_all {$yyyy} ;
  my $perc = '-' ;
  if (($count > 0) && ($peryear > 0))
  {
    $perc = sprintf ("%.1f", 100 * $count / $peryear) ;
    if ($perc < 1)
    { $perc = "<small><small><font color=#808080>$perc%</font></small></small>" ; }
    else
    { $perc .= '%' ; }
  }
  return ($perc) ;
}

sub RS3_md5
{
  my ($yyyy,$key) = @_ ;
  my $count = $revertstats {$key.$yyyy} ;
  my $peryear = $reverts_per_year_md5 {$yyyy} ;
  my $perc = '-' ;
  if (($count > 0) && ($peryear > 0))
  {
    $perc = sprintf ("%.1f", 100 * $count / $peryear) ;
    if ($perc < 1)
    { $perc = "<small><small><font color=#808080>$perc%</font></small></small>" ; }
    else
    { $perc .= '%' ; }
  }
  return ($perc) ;
}

sub IsBot
{
  my $name = shift ;
  return ($bots {$name} || (($name =~ /bot\b/i) && ($name !~ /(?:Paucabot|Niabot|Marbot)\b/i))) ; # name(part) ends on bot, Paucabot is verified real user
}

1;
