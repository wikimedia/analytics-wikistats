#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;

sub ParseArguments
{
  &LogT ("ParseArguments\n") ;
  my $options ;
  my ($year, $month) , ;
  getopt ("dilmopsu", \%options) ;

  foreach $key (keys %options)
  {
    $options {$key} =~ s/^\s*(.*?)\s*$/$1/ ;
    $options {$key} =~ s/^'(.*?)'$/$1/ ;
    $options {$key} =~ s/\@/\\@/g ;
  }

  &LogArguments ;

  abort ("Specify input folder for xml dump files as: -i path") if (! defined ($options {"i"})) ;
  abort ("Specify output folder as: -o path") if (! defined ($options {"o"})) ;

  $path_perl        = $options {"p"} ;
  $path_php         = $options {"s"} ; # s for scripts
  $path_in          = $options {"i"} ;
  $path_out         = $options {"o"} ;

  $webalizer_only   = $options {"w"} ;
  $mode             = $options {"m"} ;
# $input_xml        = $options {"x"} ; # obsolete: only xml allowed now (sql mode removed)

  $project          = $options {"l"} ; # l for language project
  $dumpdate         = $options {"d"} ;
  $dump2csv         = $options {"c"} ;

  $path_log = -d '/a/wikistats_git' ? '/a/wikistats_git/dumps/logs' : '/a/wikistats/dumps/logs' ;
  $file_log_concise = "log_" . $mode . "_wikistats_concise.txt" ;
  if ($job_runs_on_production_server)
  { $file_log_concise = "$path_log/$file_log_concise" ; }

  $edits_only = $false ;
  if (defined ($options {"e"}))
  {
    $edits_only = $true ;
    print "option -e -> edits only\n" ;
  }

  $reverts_sampling = 1 ;
  if (defined ($options {"u"})) # u for undo (r for revert was already taken)
  {
    $reverts_only = $true ;
    $reverts_sampling = $options {"u"} ;
    if ($reverts_sampling < 2)  # sample every nth article
    { $reverts_sampling = 1 ; } # 1 means no sampling
  }

  @keys = keys %options ;

# hmm, never used ?
# if (defined ($options {"t"}))
# {
#    $collect_timestamps_only = $true ;
#   return ;
# }

  if (defined ($options {"y"})) # 'y' as join symbol = merge
  {
    $merge_user_edits_one_project = $true ;
    $file_csv_content_namespaces  = $path_out . "StatisticsContentNamespaces.csv" ; 
    $file_csv_content_namespaces  =~ s/csv_\w\w/csv_mw/ ; # collected in global dir by job 'collect_countable_namespaces.sh'
    return ;
  }
  if (defined ($options {"z"}))
  {
    $merge_user_edits_all_projects = $true ;
    $file_csv_content_namespaces  = $path_out . "StatisticsContentNamespaces.csv" ; 
    $file_csv_content_namespaces  =~ s/csv_\w\w/csv_mw/ ; # collected in global dir by job 'collect_countable_namespaces.sh'
    return ;
  }

  if (defined ($options {"b"}))
  { $ext_bz2 = $true ; }

  if (defined ($options {"f"}))
  { $force_run = $true ; }
  else
  { $force_run = $false ; }

  if (defined ($options {"r"}))
  { $traceresources = $true ; }
  else
  { $traceresources = $false ; }


  abort ("Specify language code as: -l xx") if (! defined ($options {"l"})) ;
  abort ("Specify xml dump date as: -d yyyymmdd") if (! defined ($options {"d"})) ;

  $language  = $project ;
  $language_ = $language ;
  $language_ =~ s/-/_/g ;

  if ($mode eq "")
  { $mode = "wp" ; }
  if ($mode !~ /^(?:wb|wk|wn|wo|wp|wq|ws|wx|wv)$/)
  { abort ("Specify mode as: -m [wb|wk|wn|wo|wp|wq|ws|wx|wv]\n(wp=wikipedia (default), wb=wikibooks, wk=wiktionary, wn=wikinews, wo=wikivoyage, wq=wikiquote, ws=wikisource, wx=wikispecial, wv=wikiversity)") ; }

  $job_code = "c:$mode:$language" ;
  $job_code_uc = uc $job_code ;

  abort ("Project $project is skipped: 'mania' and/or 'team' in the name") if ($project =~ /(?:mania|team)/i) ;

  if ($project =~ /wik(?:|ibooks|inews|iquote|isource|tionary|iversity|ivoyage)$/i)
  {
    $project_suffix = $project ;
    $project_suffix =~ s/wik(?:|ibooks|inews|iquote|isource|tionary|iversity|ivoyage)$// ;
  }
  $language =~ s/wik(?:|ibooks|inews|iquote|isource|tionary|iversity|ivoyage)$// ;

  if ($project =~ /wiki$/i)
  {
    $project_suffix = $project ;
    $project_suffix =~ s/wiki$// ;
  }
  $language =~ s/wiki$// ;

  if (($mode eq "wx") && ($language eq "commons")) # need full dump for upload stats (e.g. category [[Category:Uploaded with UploadWizard]] )
  {
    $edits_only = $false ;
    print "commons -> not edits only\n" ;
  }

  &LogT ("Project '$project' -> language '$language'\n\n") ;
  &LogC ("\n" . &GetDateTimeEnglishShort(time) . " $mode" . ": '$project' ") ;
}

sub SetEnvironment
{
  &LogT ("SetEnvironment\n") ;

  my ($date, $time, $runtime, $conversions, $fraction_5, $fraction_100, $recently_active_users,
      $edits_total_namespace_a, $edits_total_ip_namespace_a, $edits_total_namespace_x, $edits_total_ip_namespace_x) ;

# wikisource: find wiki specific namespaces for proofread extension
# see also http://www.mediawiki.org/wiki/Extension:Proofread_Page
# file ProofReadCodes.csv is corrupt, but I can't see where the codes are used so disable for now
# if ($mode eq "ws")
# { &SetProofReadNameSpaces ; }

  if ($path_in =~ /\\/)
  { $path_in  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
  else
  { $path_in  =~ s/[\/]*$/\// ; }

  if ($path_out =~ /\\/)
  { $path_out =~ s/[\\]*$/\\/ ; }
  else
  { $path_out =~ s/[\/]*$/\// ; }

  if (! -d $path_out)
  { mkdir $path_out, 0777 ; }

  $path_temp = $path_out ;
  $path_temp =~ s/(\/.*?\/.*?\/).*/$1/ ;
  $path_temp .= "tmp" ;

  $file_log      = $path_out . "WikiCountsLog.txt" ;
  $file_errors   = $path_out . "WikiCountsErrors.txt" ;
  $file_aborted  = $path_out . "WikiCountsRunAborted.txt" ;
  $file_report   = $path_out . "#NewCountsRequireReporting.txt" ;

  if (-e $file_aborted)
  {
    if (-M $file_aborted > 1) # older than one day
    { unlink $file_aborted ; }
  }

  if ($merge_user_edits_one_project || $merge_user_edits_all_projects) # we know enough
  {
    $file_csv_user_month_all_wikis      = $path_out . "/EditsPerUserPerMonthPerNamespaceAllWikis.csv" ;
    $file_csv_user_month_all_projects   = $path_out . "/EditsPerUserPerMonthPerNamespaceAllProjects.csv" ;
    $file_csv_users_activity_spread     = $path_out . "/StatisticsUserActivitySpread.csv" ;
    $file_csv_users_activity_spread_all = $path_out . "/StatisticsUserActivitySpreadAllProjects.csv" ;
    $file_csv_monthly_stats             = $path_out . "/StatisticsMonthly.csv" ;
    $file_csv_bots_all                  = $path_out . "/BotsAll.csv" ;
    $file_csv_wiki_loves_monuments      = $path_out . "/EditsPerUserPerMonthPerNamespaceWikiLovesMonumentsUploaders.csv" ;
    return ;
  }

# if ($webalizer)
#  { $file_in_webalizer = $path_in  . "Webalizer.txt" ; }
# else
# { $file_in_webalizer = $path_out . "Webalizer.txt" ; }
  $file_html_webalizer = $path_out . "Webalizer.txt" ;

# if ($webalizer && (! -e $file_in_webalizer))
# { abort ("Webalizer stats file '" . $file_in_webalizer . "' not found or in use.") ; }
  $file_csv_webalizer_monthly    = $path_out . "Webalizer.csv" ;
  $file_csv_web_requests_daily   = $path_out . "StatisticsWebRequestsDaily.csv" ;
  $file_csv_web_visits_daily     = $path_out . "StatisticsWebVisitsDaily.csv" ;
  $file_csv_web_monthly          = $path_out . "StatisticsWebalizerMonthly.csv" ;
  $file_csv_webalizer_temp       = $path_out . "Webalizer~1.csv" ;
  if (-e $path_out . "Webalizer.csv")
  { unlink $path_out . "Webalizer.csv" ; }

  if (($language eq "ja") || ($language eq "zh") || ($language eq "ko"))
  {
    $ja_zh_ko = $true ;
    $length_stub = 50 ;
  }
  else
  {
    $ja_zh_ko = $false ;
    $length_stub = 200 ;
  }

  $file_csv_log = $path_out . "StatisticsLog.csv" ;

  # code executed twice, to do : put all code that acts upon this file here
  if ($mode eq "wp")
  {
    &ReadFileCsvOnly ($file_csv_log) ;
    if (@csv > 0)
    {
      ($language_log, $date, $time, $runtime, $conversions, $fraction_5, $fraction_100, $recently_active_users,
       $edits_total_namespace_a, $edits_total_ip_namespace_a, $edits_total_namespace_x, $edits_total_ip_namespace_x) = split (',', $csv [0]) ;

       $edits_total_prev_run = $edits_total_namespace_a + $edits_total_ip_namespace_a + $edits_total_namespace_x + $edits_total_ip_namespace_x ;

      abort ("Invalid line read from $file_csv_log:\n" . $csv[0]) if $language ne $language_log ;

      if (! $reverts_only && ($edits_total_namespace_a > $threshold_edits_only))
      {
        &LogT ("\nTotal edits in article namespace on previous run ($edits_total_namespace_a) exceeds $threshold_edits_only\nRun in edits only mode to speed up job\n") ;
        $edits_only = $true ;
      }

      if ($edits_only && ($language =~ /^(?:id|jv|sv|sw|ar|commons)$/))
      {
        &LogT ("Overrule edits only mode for selected wikis, 2011-03: contest on ID/JV, 2011-05: special request on SV\n") ;
        &LogT ("Overrule edits only mode for selected wikis, 2012-04: outreach programs: special request by Annie Lin\n") ;
        &LogT ("Overrule edits only mode for selected wikis, 2014-03: WikiAfrica program: special request by Heather Ford\n") ;
        &LogT ("Overrule may be canceled later (May 2015)\n") ;
        $edits_only = $false ; 
      }
    }
  }

  &LogT ("From May 2015 onwards run all dumps 'edits_only'\n") ;
  $edits_only = $true ; 

# 23/04/2013: revert to letting cmd line set this 
# else
# { $edits_only = $false ; } # for now only speed up Wikipedia, not other mostly much smaller projects

  if ($path_in =~ /\/\d{8,8}[\/\\]$/)
  {
    ($dumpdir = $path_in) =~ /(\d{8,8})[\/\\]$/ ;
    &LogT ("Process dump from explicitly named dir: $dumpdir\n") ;
  }
  else
  {
    if ($dumpdate eq "today")
    {
      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime (time);
      $dumpdate = sprintf ("%04d%02d%02d", $year+1900, $mon+1, $mday) ;
      &LogT ("Process dump till today: $dumpdate\n") ;
    }

    if (($dumpdate eq "auto") || ($dumpdate eq "progress"))
    {
      $dumpdir = &SetDumpDir ($dumpdate, $language)  ;
      if ($dumpdir eq "")
      { abort ("No valid dump dir found within directory $path_in") ; }

      $dumpdate = &SetDumpDate ($path_in)  ;
    }
  }

  if (($language eq "wikidata") && ($dumpdate eq "20150331")) # Q&D fix for wikidata dumps that took too long to complete after several restarts
  {
    $dumpdate = "20150430" ; 
    print "patch dumpdate -> $dumpdate\n" ; 
  }

  if (! ($dumpdate =~ m/^\d{8,8}$/))
  { abort ("Specify xml dump date as: '-d yyyymmdd', not '$dumpdate'") ; }

  $year  = substr ($dumpdate,0,4) ;
  $month = substr ($dumpdate,4,2) ;
  $day   = substr ($dumpdate,6,2) ;
  $dumpdate_gm    = timegm ( 0, 0, 0,$day, $month-1, $year-1900) ;
  $dumpdate_gm_hi = timegm (59,59,23,$day, $month-1, $year-1900) ;
  $dumpmonth_ord  = &bb2i (&yyyymm2bb ($year, $month)) ;
  &LogT ("Ignore revisions beyond $year $month, timestamp $dumpdate_gm_hi\n") ;

  if ($forecast_partial_month)
  {
    $fraction = ($day-0.5) / days_in_month ($year, $month) ;
    for ($m = 1 ; $m <= 5 ; $m++)
    {
      $month -- ;
      if ($month == 0)
      { $month = 12 ; $year -- ; }
      $partial_months [$m] = $fraction * days_in_month ($year, $month) * 1440 ;
    }
  }

  $testmode = defined ($options {"x"}) ; # use input files with language code
  $cur_only = defined ($options {"c"}) ; # skip old dump (for some tests only)

  if (! -d $path_in)
  { abort ("Input directory '" . $path_in . "' not found.") ; }

  if (! -d $path_out)
  { abort ("Output directory '" . $path_out . "' not found.") ; }

# no longer separate folder for timelines
# if ($mode eq "wp")
# {
#   $path_timelines = $path_out . "Timelines" ;
#   if (! -d $path_timelines)
#   { mkdir $path_timelines, 0777 ; }
#   if (! -d $path_timelines)
#   { abort ("Output directory '" . $path_timelines . "' not found and could not be created.") ; }

#   if ($path_timelines =~ /\\/)
#   { $path_timelines  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
#   else
#   { $path_timelines  =~ s/[\/]*$/\// ; }
# }

  # $edits_only = $false ; # for collecting list of full archive dumps see below

  &PrepTempDir ;

  if ($traceresources)
  {
    $text = `df -h $path_temp` ;
    $text =~ s/\n\s*$//s;
    $text =~ s/\n/\n         /s ;
    &Log ("\ndf -h => " . $text) ;

    $text = `du -h $path_temp` ;
    &Log ("\ndu -h => " . $text) ;
  }

  if ($mode eq "wp")
  {
    $path_webalizer = $path_out . "Webalizer" ;
    if (! -d $path_webalizer)
    { mkdir $path_webalizer, 0777 ; }
    if (! -d $path_webalizer)
    { abort ("Output directory '" . $path_webalizer . "' not found and could not be created.") ; }

    if ($path_webalizer =~ /\\/)
    { $path_webalizer  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
    else
    { $path_webalizer  =~ s/[\/]*$/\// ; }
    $path_webalizer = $path_webalizer . uc ($language) ;

    if (! -d $path_webalizer)
    { mkdir $path_webalizer, 0777 ; }
    if (! -d $path_webalizer)
    { abort ("Output directory '" . $path_webalizer . "' not found and could not be created.") ; }

    if ($path_webalizer =~ /\\/)
    { $path_webalizer  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
    else
    { $path_webalizer  =~ s/[\/]*$/\// ; }
  }

  if (! defined ($webalizer_only))
  {
    # For the .7z files, you can use 7-Zip or p7zip to decompress. These are available as free software:
# Something like: 7za e -so pages_current.xml.7z
    my $filedate = $path_in ;
    $filedate =~ s/^.*?(\d{8}).*$/$1/ ;

    if (length ($filedate) != 8)
    { $filedate = "latest" ; }

    &LogT ("\nDump file date $filedate\n") ;

    if ($reverts_only)
    {
      if ($reverts_sampling == 1)
      { &LogT ("Collect revert history only\n\n") ; }
      else
      { &LogT ("Collect revert history only, sample every ${reverts_sampling}th article\n\n") ; }
    }

    if ($testmode)
    {
      if ($file_in_xml_test ne '')
      { $file_in_xml_full = $path_in . $file_in_xml_test ; }
      elsif ($edits_only)
      { $file_in_xml_full = $path_in . "pages_stubs_" .$language_ . ".xml" ; }
      else
      { $file_in_xml_full = $path_in . "pages_full_" .$language_ . ".xml" ; }
    }
    else
    {
      if ($edits_only)
      {
        &LogT ("\nRun in 'edits only' mode\n") ;
        $file_in_xml_full = $path_in . $language_ . "-" . $filedate . "-stub-meta-history.xml.gz" ;
      # $file_in_xml_full = "/a/" . $language_ . "-" . $filedate . "-stub-meta-history.xml.gz " ;
      # $file_in_xml_full =~ s/\d{8}/20090604/g ; # temp
      }
      else
      {
        &LogT ("\nRun in 'full archive' mode\n") ;
        $file_in_xml_full = $path_in . $language_ . "-" . $filedate . "-pages-meta-history.xml.7z" ;
        if ((! -e $file_in_xml_full) || ($ext_bz2))
        { $file_in_xml_full =~ s/\.7z/\.bz2/ ; }
      }

      $file_in_sql_usergroups = $path_in . $language_ . "-" . $filedate . "-user_groups.sql.gz" ;
      if (! -e $file_in_sql_usergroups)
      {
        &LogT ("User groups file not found: '$file_in_sql_usergroups'\n") ;
        $file_in_sql_usergroups = "" ;
      }
      else
      {
        &LogT ("Read user groups: $file_in_sql_usergroups\n") ;
        my $path_in2 = $path_in ;
        $path_in2 =~ s/\/[^\/]*\/$/\// ;
        $path_in2 =~ s/public/private/ ;
        # &Log ("\nScan dir: '$path_in2'\n") ;
        my $hidir = "" ;
        opendir (DIR, $path_in2);
        while (my $file = readdir (DIR))
        {
          if ($file eq "." || $file eq "..")
          { next ; }
          if (-d "$path_in2$file")
          {
            if ($file =~ /^20\d{6}$/)
            {
              # &Log ("Dir found '$file'\n") ;
              if ($file > $hidir)
              { $hidir = $file ; }
            }
          }
        }
       closedir(DIR);
       if ($hidir ne "")
       {
         $file_in_sql_users = "$path_in2$hidir/$project-$hidir-user.sql.gz" ; }
         if (! -e $file_in_sql_users)
         {
           &LogT ("User file not found: '$file_in_sql_users'\n") ;
           $file_in_sql_users = "" ;
         }
         else
         { &LogT ("Read users: $file_in_sql_users\n") ; }
      }
    }

#   $file_in_xml_full =~ s/simplewiki.*$/simplewiki\/20161001\/simplewiki-20161001-stub-meta-history.xml.gz/ ; # Oct 2016 test: hard code input file name

    $file_csv_stats_ploticus        = $path_out . "StatisticsPlotInput.csv" ;
    $file_csv_monthly_stats         = $path_out . "StatisticsMonthly.csv" ;
    $file_csv_monthly_editors       = $path_out . "StatisticsMonthlyEditors.csv" ;
    $file_csv_namespace_stats       = $path_out . "StatisticsPerNamespace.csv" ;
    $file_csv_namespace_edit_stats  = $path_out . "StatisticsEditsPerNamespace.csv" ;
    $file_csv_users_activity_spread = $path_out . "StatisticsUserActivitySpread.csv" ;
    $file_csv_weekly_stats          = $path_out . "StatisticsWeekly.csv" ;
    $file_csv_active_users          = $path_out . "StatisticsActiveUsers.csv" ;
    $file_csv_sleeping_users        = $path_out . "StatisticsSleepingUsers.csv" ;
    $file_csv_size_distribution     = $path_out . "StatisticsSizeDistribution.csv" ;
    $file_csv_edit_distribution     = $path_out . "StatisticsEditDistribution.csv" ;
    $file_csv_edits_per_day         = $path_out . "StatisticsEditsPerDay.csv" ;
    $file_csv_monthly_reverts       = $path_out . "StatisticsRevertsPerMonth.csv" ;
#   $file_csv_user                  = $path_out . "StatisticsUsers.csv" ;
    $file_csv_user                  = $path_out . "EditsPerUser" . uc($language) . ".csv" ;
    $file_csv_user_month_namespace  = $path_out . "EditsPerUserPerMonthPerNamespace" . uc($language) . ".csv" ;
    $file_csv_user_month_all_wikis  = $path_out . "EditsPerUserPerMonthPerNamespaceAllWikis.csv" ;

    # collect edits per user per namespace, when xml is processed, sort and aggregate  
    $file_csv_user_month_namespace_log   = $path_temp . "EditsPerUserPerMonthPerNamespaceLoggedPerArticle" . uc($language) . ".csv" ;
    $file_csv_user_month_namespace_log_s = $path_temp . "EditsPerUserPerMonthPerNamespaceLoggedPerArticleSorted" . uc($language) . ".csv" ;

    $file_csv_anonymous_users       = $path_out . "StatisticsAnonymousUsers.csv" ;
#   $file_csv_timelines             = $path_out . "StatisticsTimelines.csv" ;
    $file_events                    = $path_out . "StatisticsEvents.~1" ;
    $file_csv_categories            = $path_out . "Categories" . uc($language) . ".csv" ;
    $file_language_codes            = $path_out . "LanguageCodes.csv" ;
    $file_csv_wikibooks             = $path_out . "Wikibooks".uc($language).".csv" ;
    $file_csv_edits_per_article     = $path_out . "EditsPerArticle".uc($language).".csv" ;
    $file_csv_edits_per_article2    = $path_out . "TempEditsPerArticle.csv.tmp" ;
    $file_csv_zeitgeist             = $path_out . "ZeitGeist.csv" ;
    $file_csv_binaries_stats        = $path_out . "StatisticsPerBinariesExtension.csv" ;
    $file_csv_namespaces            = $path_out . "Namespaces.csv" ;
    $file_csv_bots                  = $path_out . "Bots.csv" ;  # explicity defined bots
    $file_csv_bots_all              = $path_out . "BotsAll.csv" ;
    $file_csv_bot_actions           = $path_out . "StatisticsBots.csv" ;
    $file_csv_access_levels         = $path_out . "StatisticsAccessLevels.csv" ;
    $file_csv_run_stats             = $path_out . "StatisticsLogRunTime.csv" ;
    $file_csv_babel_templates       = $path_out . "BabelTemplates.csv" ;
    $file_csv_reverts_sample        = $path_out . "RevertsSample" . uc ($language)  . ".csv.tmp" ;
    $file_csv_reverted_edits        = $path_out . "RevertedEdits" . uc ($language)  . ".csv.tmp" ;
    $file_csv_creates               = $path_out . "Creates" . uc ($language)  . ".csv.tmp" ;
    $file_csv_wlm                   = $path_out . "EditsPerUserPerMonthPerNamespaceWLM.csv" ;
    $file_csv_timelines             = $path_out . "Timelines"        . uc ($language) . ".csv" ;
    $file_csv_timelines_skipped     = $path_out . "TimelinesSkipped" . uc ($language) . ".csv" ;

    $file_html_timelines            = $path_out . "Timelines" . uc ($language) . ".htm" ;
    $file_html_timelines_skipped    = $path_out . "TimelinesSkipped" . uc ($language) . ".htm" ;
    
    $file_csv_content_namespaces    = $path_out . "StatisticsContentNamespaces.csv" ; 
    $file_csv_content_namespaces    =~ s/csv_\w\w/csv_mw/ ; # collected in global dir by job 'collect_countable_namespaces.sh'
  }

  if ($testmode)
  {
    if ($file_csv_monthly_stats_test ne '')
    { $file_csv_monthly_stats = $path_out . $file_csv_monthly_stats_test ; }
  }

  $file_trace_progress           = $path_temp . "TraceProgress" ;
  $file_categories               = $path_temp . uc ($mode) . "_" . uc ($language) . "_Categories.txt" ;
  $file_trace_titles             = $path_temp . "TraceTitles" ;
  $file_dump_csv                 = $path_temp . uc ($mode) . "_" . uc ($language) . "_DumpCsv.txt" ;

  $file_revisions                = $path_temp . "RevisionsCached" ;
  unlink $file_revisions ;
  if (-e $file_revisions)
  { abort ("Unable to delete $file_revisions (file open in other process?)") ; }

  unlink $file_csv_creates ;
  unlink $file_csv_reverted_edits ;
  unlink $file_csv_reverts_sample ;
  unlink $file_csv_edits_per_article2 ;

  &LogT ("Read xml file $file_in_xml_full\n") ;
  if (! -e $file_in_xml_full)
  { abort ("XML dump file '" . $file_in_xml_full . "' not found.") ; }

  my ($days, $month, $year, $m) ;
  $year  = 2001 ;
  $month = 1 ;
  $m     = &bb2i (&yyyymm2bb ($year, $month)) ;
  $days  = 0 ;
  while ($m <= $dumpmonth_ord)
  {
    $days_since_begin_2001 {$m} = $days ;
    $m ++ ;
    $month ++ ;
    if ($month > 12)
    { $month = 1 ; $year++ ;}
    $days += days_in_month ($year, $month) ;
  }

  # determine date of previous run
  &ReadFileCsvOnly ($file_csv_log) ;
  if ($#csv > -1)
  {
    ($language_log, $date, $time, $runtime, $conversions, $fraction_5, $fraction_100, $recently_active_users,
     $edits_total_namespace_a, $edits_total_ip_namespace_a, $edits_total_namespace_x, $edits_total_ip_namespace_x) = split (',', $csv [0]) ;
  }

  # if data for last month are not available, rerun counts anyway
  &ReadFileCsvOnly ($file_csv_monthly_stats) ;
  if ($#csv > -1)
  {
    $date_hi = '' ;
    foreach $line (@csv)
    {
      ($lang,$date2,@dummy) = split (',', $line) ;
      $date3 = substr ($date2,6,4) . substr ($date2,0,2) . substr ($date2,3,2) ;
      if ($date3 gt $date_hi)
      { $date_hi = $date3 ; }
    }
    if ($date_hi lt $date)
    {
      &LogT ("\nDump already processed till $date, but not all data found in monthly csv file. Reset last processing date to $date_hi\n") ;
      $date = $date_hi ;
    }
  }

  $edits_total_previous_run = $edits_total_namespace_a + $edits_total_namespace_x ;
  $dumpdate_previous_run = $date ;
  $runtime_previous_run  = $runtime ;
  $runtime_previous_run  =~ s/\&\#44;/,/g ;

  if ($dumpdate le $dumpdate_previous_run)
  {
    if ($force_run)
    { &LogT ("\nProcess dump till $dumpdate\nDump already processed till $dumpdate_previous_run\nRun anyway due to -f for force run\n\n") ; }
    else
    {
      $skip_on_dumpdate = $true ;
      &LogT ("\nProcess dump till $dumpdate\nDump already processed till $dumpdate_previous_run (run with -f to force run)\nStop processing\n") ;
      $trace_on_exit = $false ;
    }
  }

  # meta process grinded to a halt on RevisionCached > 100 Mb for revision history of meta: User:COIBot/LinkReports or nl: De Kroeg
  # meta needs more space for revision history than for internal tables, unlike e.g. enwiki
  if (($job_runs_on_production_server) && (($project eq "metawiki") || ($project eq "nlwiki")))
  {
    $threshold_filesize_large = 2000_000_000 ;
    $threshold_tie_file       = 2000_000_000 ;
  }

  $use_tie = $false ;
  if ((! $edits_only) && (-s $file_in_xml_full > $threshold_tie_file))
  { $use_tie = $true ; }

  # profile critical routines aggressively, despite overhead ?
  $record_time_process_revision_main = $true ;
  $record_time_collect_article_counts_main = $true ;
  if (($mode eq "wp") && ($testmode2 || ($language eq "nv")))
  {
    &LogT ("\nProfile critical routines aggressively, despite overhead\n") ;
    $record_time_process_revision = $true ;
    $record_time_collect_article_counts = $true ;
  }
}

sub LogArguments
{
  my $arguments ;
  foreach $arg (sort keys %options)
  { $arguments .= "-$arg " . $options {$arg} . "\n" ; }
  &LogT ("Arguments\n$arguments\n") ;
}

# not really about arguments but out of the way here
sub CheckForNonAscii
{
  &LogT ("Checking Perl files\n\n") ;
  if ($path_perl =~ /\\/)
  { $path_perl  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
  else
  { $path_perl  =~ s/[\/]*$/\// ; }

  @files_perl = <$path_perl*.pl> ;

  $non_ascii_found = $false ;
  foreach $file (@files_perl)
  {
    if ((! ($file =~ /Count/)) && (! ($file =~ /Report/))) { next ; }

    $time_since = -M $file ;
    $date_upd   = time - $time_since ;
    (my $min, my $hour, my $day, my $month, my $year) = (localtime $date_upd) [1,2,3,4,5] ;
    $date_upd = sprintf ("%02d/%02d/%04d %02d:%02d", ($month+1),$day,($year+1900),$hour,$min) ;
    &LogT ("$file [$date_upd]\n") ;
    open "FILE_IN", "<", $file || abort ("Perl file '$file' could not be opened.") ;
    @lines = <FILE_IN> ;
    close FILE_IN ;
    for ($l = 0 ; $l <= $#lines ; $l++)
    {
      if ($lines [$l] =~ /[\x80-\xff]/)
      {
        $non_ascii_found = $true ;
        &Log ($l . ":" . $lines [$l]) ;
      }
    }
    undef (@lines) ;
  }
  if ($non_ascii_found)
  { abort ("Non ASCII characters found.") ; }
  else
  { &LogT ("No Perl files found with non ASCII characters.\n") ; }
}

sub SetProofReadNameSpaces
{
  $file_proofread_codes = $path_out . "/ProofReadCodes.csv" ;

  print $file_proofread_codes ;
  &ReadFileCsvOnly ($file_proofread_codes) ;
  if ($#csv > -1)
  { ($dummy,$namespacePagePrev,$namespaceIndexPrev) = split (',', $csv [0]) ; }

  # $namespacePage  = &GetKeywordNamespace ("http://$language.wikisource.org/w/api.php?action=query&titles=MediaWiki:Proofreadpage_namespace&rvprop=content&format=xml") ;
  # $namespaceIndex = &GetKeywordNamespace ("http://$language.wikisource.org/w/api.php?action=query&prop=revisions&titles=MediaWiki:Proofreadpage_index_namespace&rvprop=content&format=xml") ;
  # the api version does return empty page for language nl, but proper data for en (nl = protected page (???))
  # until solved use this direct call (more vulnerable for changes)

  $namespacePage  = &GetKeywordNamespace ("http://$language.wikisource.org/wiki/MediaWiki:Proofreadpage_namespace") ;
  $namespaceIndex = &GetKeywordNamespace ("http://$language.wikisource.org/wiki/MediaWiki:Proofreadpage_index_namespace") ;
  if ($namespacePage  eq "--") { $namespacePage  = $namespacePagePrev ; }
  if ($namespaceIndex eq "--") { $namespaceIndex = $namespaceIndexPrev ; }

  &ReadFileCsv ($file_proofread_codes) ;
  push @csv, &csv($language) . &csv($namespacePage). $namespaceIndex ;
  @csv = sort @csv ;
  &WriteFileCsv ($file_proofread_codes) ;
}

sub PrepTempDir
{
  &LogT ("PrepTempDir\n") ;
  print "Temp   $path_temp\n" ;

  if (! -d $path_temp)
  {
    print "Temp   $path_temp not found ->\n" ;
    $path_temp = $path_out ;
    $path_temp =~ s/\/[^\/]*\/$/\// ;
    $path_temp .= "temp" ;
    print "Temp   $path_temp\n" ;
  }

  if ($path_temp =~ /\\/)
  { $path_temp  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
  else
  { $path_temp  =~ s/[\/]*$/\// ; }

  print "\nRemove obsolete dirs\n\n" ;
  opendir (DIR, $path_temp) or die "can't opendir $path_temp: $!";
  while (defined ($file = readdir(DIR)))
  {
    if ($file =~ /^\.+$/) { next ; }

    $path_temp2 = "$path_temp$file" ;
    print "Path   $path_temp2\n" ;
    if ((-d $path_temp2) && (-e "$path_temp2/\@Ready"))
    {
      print "\nEmpty  $path_temp2\n" ;
      opendir (DIR2, $path_temp2) or die "can't opendir $path_temp2 : $!";
      while (defined ($file2 = readdir(DIR2)))
      {
        if ($file2 =~ /^\.+$/) { next ; }

        $path_file = "$path_temp2/$file2" ;
      # print "Remove $path_file\n" ;
        if ($path_file =~ /te?mp/) # ultimate safeguard
        { unlink "$path_file" ; }
      }
      closedir(DIR2);
      print "Remove $path_temp2\n" ;
      if ($path_temp2 =~ /te?mp/) # ultimate safeguard
      { rmdir $path_temp2 ; }
      if (-d $path_temp2)
      { print "Remove $path_temp2 failed!!!\n" ; }
      print "\n" ;
    }
  }
  closedir(DIR);

  $path_temp = "$path_temp$mode\_$language/" ;

  if (! -d $path_temp)
  {
    mkdir $path_temp, 0770 ;
    if (-d $path_temp)
    { print "Temp   $path_temp created\n" ; }
    else
    { abort ("Temp   $path_temp not found and could not be created.") ; }
  }
  else
  {
    print "\nTemp   $path_temp already exists -> clear\n" ;
    opendir (DIR, $path_temp) or die "can't opendir $path_temp: $!";
    while (defined ($file = readdir(DIR)))
    {
      if ($file !~ /^\.+$/)
      {
        print "Remove $path_temp/$file\n" ;
        unlink "$path_temp/$file" ;
      }
    }
  }
}

# to do: if (! edits_only) overrule full archive format of choice (7z or bz2) when only other full archive dump completed succesfully
sub SetDumpDir
{
  &LogT ("SetDumpDir\n") ;
  my ($dumpdate, $language) = @_ ;
  my ($dumpdir,$dir,$file,$scandir,$status) ;

  @files = glob "$path_in*" ;
  &LogT ("SetDumpDir\n\n") ;

  &LogT ("Check folders in $path_in\n\n") ;

  foreach $file (@files)
  {
    next if $file !~ /\/\d{8,8}$/ ;
    next if ! -d $file ;

    ($dir = $file) =~ s/.*?\/(\d{8,8})/$1/ ;
    $scandir = "$path_in$dir" ;

    ($scandir2 = $scandir) =~ s/^.*public/../ ;
    $status = "Check folder $scandir2: " ;

    if (! -e "$scandir/status.html")
    { 
      $status .= "status.html not found\n" ; 
      &LogT ($status) ; 
    }
    elsif (! -e "$scandir/index.html")
    { 
      $status .= "index.html not found\n" ; 
      &LogT ($status) ; 
    }
    else
    {
      $usable_dump_folder_found = $false ;

      open STATUS, '<', "$scandir/index.html" ;
      @lines = <STATUS> ;
      close STATUS ;
      $content = join '', @lines ;

      $dumps_usable = "" ;

      if (($content =~ /<span class='status'>done<\/span> <span class='title'>Creating split stub dumps/) || # obsolete ?
          ($content =~ /<span class='status'>done<\/span> <span class='title'>First-pass for page XML data dumps/))
      {
	# &Log ("Complete stub dumps found\n") ;
        if ($edits_only)
        { $usable_dump_folder_found = $true ; }
        $dumps_usable .= "stub|" ;
      }

      if ($content =~ /<span class='status'>done<\/span> <span class='title'>All pages with complete edit history.{0,10}?7z/)
      {
	# &Log ("Complete full archive dumps found (7z)\n") ;
        if (! $edits_only)
        { $usable_dump_folder_found = $true ; }
        $dumps_usable .= "7z|" ;
      }

      if ($content =~ /<span class='status'>done<\/span> <span class='title'>All pages with complete page edit history.{0,10}?bz2/)
      {
	# &Log ("Complete full archive dumps found (bz2)\n") ;
        if (! $edits_only)
        { $usable_dump_folder_found = $true ; }
        $dumps_usable .= "bz2|" ;

      }
      $dumps_usable =~ s/\|$// ;
      if ($usable_dump_folder_found) # means at least stub dump is usable
      {
        $dumpdir = $dir ;
        $status .= "dumps usable '$dumps_usable'\n" ;
      }
      else
      { 
	$status .= "no usable dumps\n" ; 
	if (($dumps_usable =~ /stub/) && (! $edits_only))
	{ &LogT ("\nStub dump found, but running in 'full archive' mode!!!\n") ; }
      }

#      open STATUS, '<', "$scandir/status.html" ;
#      $line = <STATUS> ;
#      chomp $line ;
#      close STATUS ;

#      $status = "undetermined: $line" ;
#      if ($line =~ /dump complete/i)
#      { $status = "dump complete" ; }
#      elsif ($line =~ /dump aborted/i)
#      { $status = "dump aborted" ; }
#      elsif ($line =~ /dump in progress/i)
#      { $status = "dump in progress" ; }
#      if ($dumpdir lt $dir)
#      {
#        if ($status eq "dump complete")
#        {
#          open INDEX, '<', "$scandir/index.html" ;
#          while ($line = <INDEX>)
#          {
#            if ($line =~ /failed.*?All pages with complete.*?edit history/i)
#            {
#              $status = "dump aborted (dump failed)" ;
#              last ;
#            }
#          }
#          close INDEX ;
#        }
#        if (($status eq "dump complete") || (($status eq "dump in progress") && ($dumpdate eq "progress")))
#        { $dumpdir = $dir ; }
#      }
#      &Log ("$dir: $status\n") ;
    }
    &LogT ($status) ;
  }

  if ($dumpdir ne "")
  { $path_in .= "$dumpdir/" ; }
  &LogT ("\nUse folder $path_in\n\n") ;
  
  return ($dumpdir) ;
}

sub SetDumpDate
{
  my $path_in = shift ;
  my ($date,$year,$month,$day,$datestartdump,$dumpdate) ;

  if (! -e "$path_in/index.html")
  { abort ("$path_in/index.html missing") ; }

  $stub_dump_done = $false ;

  print "Parse index file '$path_in/index.html'\n" ;
  open INDEX_HTML, '<', "$path_in/index.html" ;
  while ($line = <INDEX_HTML>)
  {
    # May 2015 sorry for duplicated code in several branches, needs restructuring
    if ($edits_only)
    {
      if ($line =~ /Extracted page abstracts/) # last dump before stub-meta-history dump -> start time of job step
      {
        print "$line\n" ;    
        $line =~ s/.*?<span class='updates'>// ;
        $year  = substr ($line,0,4) ;
        $month = substr ($line,5,2) ;
        $day   = substr ($line,8,2) ;
        print "1 Extracted page abstracts $year $month $day\n" ;
        if ($year !~ /^2/)
        {
          # new situation in May 2015: job only generates stub dumps -> take dumpdate from folder name
          print "previous step didn't run, job did stub dumps only -> take dumpdate from folder name\n" ;
          chomp $line ;
          $line =~ s/^.*-(\d{8,8})-.*$/$1/ ;
          if (length ($line) != 8)
          { abort ("No date found in Yahoo step in index.html 1\n'$line'\n") ; }
          $year  = substr ($line,0,4) ;
          $month = substr ($line,4,2) ;
          $day   = substr ($line,6,2) ;
          print "2 Extracted page abstracts $year $month $day\n" ;
        }

        $date = sprintf ("%04d%02d%02d", $year, $month, $day) ;
        $datestartdump = $date ;
        
        $month-- ;
        if ($month < 1)
        { $month = 12 ; $year-- ; }
        $day = days_in_month ($year,$month) ;
        $dumpdate = sprintf ("%04d%02d%02d", $year, $month, $day) ;
        print "dumpdate (edits only) $dumpdate\n" ;
        last ;
      }
      if ($line =~ /Creating split stub dumps/)
      {
        &LogT ($line) ;
        if ($line =~ /done/)
        {
          $stub_dump_done = $true ;
          &LogT ("Stub dumps ready on job in progress.") ;
        }
      }
      if ($line =~ /First-pass for page XML data dumps/)
      {
        if ($line =~ /done/)
        {
          $stub_dump_done = $true ;
          &LogT ("Stub dumps ready.") ;
        }
      }
    }
    else # find start of job <- oldest time in update line
    {
      if ($line =~ /<span class='updates'>\d{4}\-\d{2}\-\d{2}/)
      {
        $line =~ s/.*?<span class='updates'>// ;
        $year  = substr ($line,0,4) ;
        $month = substr ($line,5,2) ;
        $day   = substr ($line,8,2) ;
        
        if ($year !~ /^2/)
        {
          # new situation in May 2015: job only generates stub dumps -> take dumpdate from folder name
          print "previous step didn't run, job did stub dumps only -> take dumpdate from folder name\n" ;
          chomp $line ;
          $line =~ s/^.*-(\d{8,8})-.*$/$1/ ;
          if (length ($line) != 8)
          { abort ("No date found in Yahoo step in index.html 2\n'$line'\n") ; }
          $year  = substr ($line,0,4) ;
          $month = substr ($line,4,2) ;
          $day   = substr ($line,6,2) ;
        }

        $date = sprintf ("%04d%02d%02d", $year, $month, $day) ;
        if (($datestartdump eq "") || ($date lt $datestartdump))
        {
          $datestartdump = $date ;
          $month-- ;
          if ($month < 1)
          { $month = 12 ; $year-- ; }
          $day = days_in_month ($year,$month) ;
          $dumpdate = sprintf ("%04d%02d%02d", $year, $month, $day) ;
          print "dumpdate (not 'edits only') $dumpdate\n" ;
        }
      }
    }
  }

  if ($edits_only and (! $stub_dump_done))
  { &abort ("Try to process output from job in progress. Stub dumps not ready. Abort.") ; }

  close INDEX_HTML ;
  &LogT ("\nRead index.html -> Last dump started on $datestartdump -> Process dump till $dumpdate\n") ;
  return ($dumpdate) ;
}

sub GetKeywordNamespace
{
  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  my $raw_url = shift ;
  my $url = URI::Heuristic::uf_urlstr($raw_url);
  my $api = $false ;
  if ($url =~ /api\.php/)
  { $api = $true ; }

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikipedia Wikicounts job");
  $ua->timeout(60);
  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://www.wikipedia.org");

  my $succes = $false ;
  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { ; } # { &Log (" -> 404\n") ; }
      else
      { &LogT ("API call failed:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
      return ("--") ;
    }

    $content = $response->content();
    if (! $api)
    { $succes = $true ; }
    elsif ($content !~ /<rev>.*<\/rev>/s)
    {
      &LogT ("API page does not contain expected data:\n  '$raw_url'\n") ;
      return ("--") ;
    }

    $succes = $true ;
  }

  if ($succes)
  {
    if ($api)
    { $content =~ s/^.*?<rev>([^<]*)<.*$/$1/s ; }
    else
    {
    #  $content =~ s/^.*?<div class="noarticletext">(.*?)<\/div>.*$/$1/s ;
    #  &LogT ("no api line $content\n") ;
      $content =~ s/^.*?<p>\s*([^<]*)<.*$/$1/s ;
      &LogT ("no api line $content\n") ;
    }
    return ($content) ;
  }
  else
  { &LogT ("\nAPI call failed after " . (--$attempts) . " attempts !!\n\n") ; }

  return ("--") ;
}


1;

