#!/usr/bin/perl
# Copyright (C) 2003-2010 Erik Zachte , email erikzachte\@xxx.com (nospam: xxx=infodisiac)
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, at
# http://www.fsf.org/licenses/gpl.html

# Disclaimer: most of these sources have been developed in limited free time.  
# Over the years complexity of the sources grew, sometimes at the expense of maintainability.
# Some design decisions have not scaled well.
# Some parts of the code are hard to read due to overly concise or obscure variable names
# (WikiCounts.. files suffer less from this than WikiReports.. files).
# although in general I try to choose descriptive variable and function names.
# There is little documentation, too few comments in the code. 
# Sometimes obsolete code has been commented out rather than deleted to ease re-activation.
# Version numbering has been inconsistent.
# Some code contains hard coded file paths mainly to Erik's test environment (Windows)

# On the bright side: 
# Most code produces a decent audit trail, which can help understand process flow. 
# The scripts have been modified again and again to cope with ever more colossal input files,
# without overtaxing system resources. (e.g. by externalizing huge memory structures)
# Great care has been taken to produce output that is tuned to each specific project. 

# Rudimentary documentations at:
# http://meta.wikimedia.org/wiki/Wikistats
# http://www.mediawiki.org/wiki/Manual:Wikistats/TrafficReports
 
# to do on revert counts:
#   eliminate self reverts
#   separate revert rv from vandal rvv
#   count reverts per user

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (10) ;

  # set defaults mainly for tests on local machine
# default_argv "-u 10|-f|-x|-m wp|-t|-l strategy|-d 20100930|-i 'D:/\@Wikimedia/# In Dumps'|-o 'D:/\@Wikimedia/# Out Test/csv_wp'|-s 'D:/\@Wikimedia/# Out Zwinger/mnt/languages'" ;
  default_argv "-e|-f|-x|-m wp|-t|-l strategy|-d 20100930|-i 'D:/\@Wikimedia/# In Dumps'|-o 'D:/\@Wikimedia/# Out Test/csv_wp'|-s 'D:/\@Wikimedia/# Out Zwinger/mnt/languages'" ;

# todo WikiCountsOutput update UpdateEditsPerArticle, one file per language
#      WikiCountsInput  make 25 language dependent: if ($tot_revisions >= 25)

#END # detect performance breakers in regexps: $1` $' $&
#{
#  use Devel::SawAmpersand ;
## use Devel::FindAmpersand ; # does not work on threaded perl
#  print 'Naughty variable was ' . ((Devel::SawAmpersand::sawampersand)?'':'not ') . 'used;\n' ;
#}

  # use warnings ;
  # use strict ;

  use WikiCountsArguments ;
  use WikiCountsBooks ;
  use WikiCountsBots ;
  use WikiCountsCategories ;
  use WikiCountsConversions ;
  use WikiCountsDate ;
  use WikiCountsInput ;
  use WikiCountsLanguage ;
  use WikiCountsLog ;
  use WikiCountsOutput ;
  use WikiCountsProcess ;
  use WikiCountsTimelines ;
# use WikiCountsWebalizer ;

  $version   = "3.0" ;
  $timestart = time ;
  $bhi       = 127 ;
  $b2hi      = 128*128-1 ;
  $b3hi      = 128*128*128-1 ;
  $b4hi      = 128*128*128*128-1 ;
  $deltaLogC = 20 ;
  $nohashes = "skip" ;
  $log_enabled = $false ;
  $skip_on_dumpdate = $false ;


  $weekly_plotdata = $false ;
  if ($weekly_plotdata)
  { $period_significant_digits = 8 ; } # compare dates on day level, only process last edit per article per day
  else
  { $period_significant_digits = 6 ; } # compare dates on month level, only process last edit per article per month

# $forecast_partial_month = $false ; # obsolete ? when counts for current month were shown
                                     # a forecast was added for end of current mont full month  partial momtn in th epast for last siz month for this wiki the rati
                                     # to this end an average ratio for last six motnhs was determined between
                                     # (very) active editors on day x  / (very) active editors for full month

  if ($hostname eq 'bayes')
  {
    $threshold_filesize_large = 1000_000_000 ; # compressed dump size (to do: make this dependant on compression type)
    $threshold_tie_file       = 1000_000_000 ; # compressed dump size (to do: make this dependant on compression type)
    $threshold_edits_only     = 10_000 ;  # edits in namepace 0 on previous run
  #  $threshold_edits_only     = 10_000_000 ;  # edits in namepace 0 on previous run
  #  $threshold_edits_only     = 100_000_000_000 ; # edits in namepace 0 on previous run
  }
  else
  {
    $threshold_filesize_large = 100_000_000 ; # uncompressed dump size
    $threshold_tie_file       = 1000_000_000 ; # uncompressed dump size
    $threshold_edits_only     = 100_000_000_000 ; # edits in namepace 0 on previous run
  }

  $useritem_id = 0 ;
  $useritem_first = 1 ;
  $useritem_last = 2 ;
  $useritem_ip_namespace_a = 3 ;
  $useritem_ip_namespace_x = 4 ;
  $useritem_reg_namespace_a = 5 ;
  $useritem_reg_namespace_x = 6 ;
  $useritem_reg_recent_namespace_a = 7 ;
  $useritem_reg_recent_namespace_x = 8 ;
  $useritem_edits_10 = 9 ;

  $file_log_concise = "./WikiCountsLogConcise.txt" ;

  &ParseArguments ;
  &SetEnvironment ;
  &OpenLog ;
  &SpoolPreviousErrors ;
  open (STDERR, ">>", $file_errors) ;

  if (defined ($path_perl))
  { &CheckForNonAscii ; }

#>>>>>> temp
#&ReadFileCsvAll ($file_language_codes) ;
#foreach $line (@csv)
#{
#  if ($line =~ /^$language,/)
#  {
#    ($language_, $encoding_, $category_, $image_, $user_, $redirtag_) = split (',', $line) ;
#   if ($redirtag_ =~ /\#redirect/i)
#   { &abort ("Already redirect tag") ; }
#    last ;
#  }
#}
#<<<<<<< temp

  &TraceMem ;
  if ((! defined ($webalizer_only)) && (! $skip_on_dumpdate))
  {
    &ReadBots ;
    &UpdateBots ;
    &AssumeBots ;

    if (! $testmode)
    {
      if (-e $file_in_sql_usergroups)
      {
        &ReadAccessLevels ;
        &UpdateAccessLevels ;
      }
    }

    &ReadLanguageSettings ;

    &ReadInputXml ;

    if ($reverts_only)
    { &LogT ("\n\nRevert data collected. Stop further processing.\n\n") ; exit ; }

    if (&TraceJob)
    {
      &LogT ("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n") ;
      my $text = `ls -l $path_temp` ;
      &LogT ("\nll =>\n" . $text) ;
      &LogT ("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n") ;
    }

    &UpdateNamespaces ;

    if ($length_line_event eq "")
    {
      &UpdateLog ;
      &abort ("No relevant events found") ;
    }

    &SortArticleHistoryOnArticleDateTime ; # for CountArticlesPerFewDays and CountArticlesUpTo
    &CountArticlesPerNamespacePerMonth ; # -> UpdateMonthlyStats
    &CountEditsPerNamespacePerMonth ;    # -> UpdateMonthlyStats
    &CountArticlesPerMonth ;             # -> UpdateMonthlyStats
    &CollectUserStats ;                  # -> UpdateMonthlyStats
    &CollectActiveUsersPerMonth ;        # -> UpdateMonthlyStats
    &UpdateMonthlyStats ;

  # to be replaced: do no longer update weekly stats for Ploticus plots ->
  # to be replaced with (R?) plots based on monthly data
    if ($weekly_plotdata)
    {
      &SortArticleHistoryOnDateTime ;
      &CountUsersPerWeek ;
      &UpdateWeeklyStats ;
    }

    &RankUserStats ;
    &UpdateActiveUsers ;
    &UpdateSleepingUsers ;
    &UpdateBotEdits ;

    &CountBinariesPerExtensionPerMonth ;
    &UpdBinariesStats ;

    &UpdateUsers ; # for $file_csv_user and $file_csv_edit_distribution

    &UpdateSizeDistribution ;
    &UpdateEditsPerArticle ;
    &UpdateReverts ;

  # to be replaced: do no longer update weekly stats for Ploticus plots ->
  # to be replaced with (R?) plots based on monthly data
    if ($weekly_plotdata)
    { &CountArticlesPerFewDays ; }

    &UpdateTimelines ;

    &WriteCategoryInfo ;

    &UpdateZeitGeist ;

    &UpdateLog ;

    if ($mode eq "wp")
    { &WriteTimelineOverviews ; }
    # { &WriteTimelineOverview ; }

    if (($mode eq "wb") || ($mode eq "wv"))
    { &WriteWikibooksInfo ; }

    &WriteJobRunStats ;
    &UpdateUsersAnonymous ; # last: huge sort

    &SignalReportingToDo ;  # run WikiReports.pl

  # &GetWebalizerPages ; webalizer inactive, no use to fetch new pages
  }

# &CountWebalizerStats ;

# &LogT ("\n\nExecution took " . ddhhmmss (time - $timestart). ".\n") ;
# &LogT ("Ready\n\n") ;
  close "FILE_LOG" ;

  if ($min_run > 1)
  {
    ($min, $hour) = (localtime (time))[1,2] ;
    &LogC ("\n" . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min) .
           " Ready in " . ddhhmmss (time - $timestart). "\n") ;
  }
  else
  { &LogC (" -> " . ddhhmmss (time - $timestart). "\n") ; }

  &WriteDiskStatus ;

  rmdir $path_temp ; # remove if empty
  if (-d $path_temp)
  {
    &LogT ("Temp $path_temp/\@Ready written\n") ;
    open READY, '>', "$path_temp/\@Ready" ;
    print READY "Ready" ;
    close READY ;
  }
  else
  { &LogT ("Temp $path_temp removed\n") ; }

  exit ;

#======================
#== WikiCountsOutput ==
#======================

#sub UpdateUsers
#  UPDATE  ($file_csv_user) ;
#  -> @user_stats_reg


#sub UpdateUsersAnonymous
#  UPDATE  ($file_csv_anonymous_users) ;
#  -> %edits_per_user_ip_namespace_0


#sub UpdateActiveUsers
#  UPDATE  ($file_csv_active_users) ;
#  -> @user_stats_reg


#sub UpdateSleepingUsers
#  UPDATE  ($file_csv_sleeping_users) ;
#  -> @user_stats_reg


#sub UpdateBots                                 BOT
#  UPDATE  ($file_csv_bot_users) ;              BOT
#  -> @user_stats_reg                           BOT


#sub UpdateMonthlyStats
#  UPDATE ($file_csv_monthly_stats) ;
#  UPDATE ($file_csv_namespace_stats) ;
#  -> @user_stats_reg
#  -> %active_users_per_month_5
#  -> %active_users_per_month_100


#sub UpdateLog
#  UPDATE  ($file_csv_log) ;
#  -> %active_users_per_month
#  -> %active_users_per_partial_month

#=======================
#== WikiCountsProcess ==
#=======================

#sub CollectActiveUsersPerMonth
#  -> %edits_per_user_per_month
#  -> %edits_per_user_per_month_partial
#  %active_users_per_month_5           ->
#  %active_users_per_month_100         ->
#  %active_users_per_partial_month   ->
#  READ %files_events_user_month
#  READ %files_events_user_month_partial


#sub CollectUserStats
#  -> %edits_per_user_reg_namespace_0
#  -> %edits_per_user_reg_namespace_x
#  -> %edits_per_user_reg_recent_namespace_0
#  -> %edits_per_user_reg_recent_namespace_x
#  -> %userfirst
#  -> %userlast
#  @user_stats_reg ->


#sub RankUserStats
#  -> @user_stats_reg ->
#  @user_stats_ip ->

#=====================
#== WikiCountsInput ==
#=====================

#sub ReadInputXmlPage
#  %users_per_month ->
#  %months_edited_per_article ->
#  %zeitgeist_reg_users_rank  ->
#  %zeitgeist_reg_users_title ->


#sub ReadInputXmlRevision
#  %contributing_reg_users           ->
#  %contributing_reg_users_per_month ->
#  %contributing_ip_users            ->


#sub CollectUserCounts
#  %edits_per_user_ip_namespace_0  ->
#  %edits_per_user_ip_namespace_x  ->
#  %edits_per_user_reg_namespace_0 ->
#  %edits_per_user_reg_namespace_x ->
#  %edits_per_user_reg_recent_namespace_0 ->
#  %edits_per_user_reg_recent_namespace_x ->
#  WRITE %files_events_user_month
#  WRITE %files_events_user_month_partial
#  %edits_per_user_per_month         ->
#  %edits_per_user_per_partial_month ->
#  -> %userfirst ->
#  -> %userlast ->


# nv:
#Total Elapsed Time = 39.87786 Seconds
#  User+System Time = 34.59086 Seconds
#Exclusive Times
#%Time ExclSec CumulS #Calls sec/call Csec/c  Name
# 18.0   6.227  6.227 126993   0.0000 0.0000  main::csvkey_lang_date
# 16.7   5.789  6.498  10983   0.0005 0.0006  main::CollectArticleCounts
# 8.17   2.826 19.212   1816   0.0016 0.0106  main::ReadInputXmlPage
# 5.37   1.858  1.858 407432   0.0000 0.0000  main::csvkey_lang_edits
# 5.24   1.812  1.812 345318   0.0000 0.0000  main::csvkey_lang_type_date
# 5.04   1.745  1.745    170   0.0103 0.0103  main::LogT
# 4.88   1.689  8.543      1   1.6890 8.5427  main::CountArticlesPerFewDays
# 4.15   1.437  1.437     21   0.0684 0.0684  main::WriteFileCsv
# 3.88   1.343  1.343     21   0.0640 0.0640  main::ReadFileCsv
# 3.69   1.276  2.155  14572   0.0001 0.0001  main::ReadInputXmlRevision
# 3.66   1.265  1.265  30960   0.0000 0.0000  main::XmlToSql
# 2.71   0.939  3.572      1   0.9393 3.5716  main::UpdateMonthlyStats
# 2.62   0.908  0.908  65556   0.0000 0.0000  main::XmlReadUntil
# 1.69   0.585  2.895      1   0.5851 2.8952  main::UpdateUsersAnonymous
# 1.55   0.535  0.535 287348   0.0000 0.0000  main::days_in_month
# 1.50   0.519  0.972  14572   0.0000 0.0001  main::CollectUserCounts
# 1.29   0.445  8.356  14572   0.0000 0.0006  main::ProcessRevision
# 1.27   0.438  0.438  41272   0.0000 0.0000  main::csvkey_lang_rank_first3
# 1.12   0.389  0.485   1816   0.0002 0.0003  Tie::File::TIEARRAY
# 0.97   0.334  0.334  16388   0.0000 0.0000  Tie::File::_write_record
# 0.82   0.282  0.390     51   0.0055 0.0076  main::BEGIN
# 0.79   0.272  1.199      1   0.2719 1.1989  main::UpdateWeeklyStats
# 0.73   0.253  0.253  89680   0.0000 0.0000  main::bbbb2i
# 0.71   0.247  0.247  14572   0.0000 0.0000  main::IncUserData
# 0.69   0.239  0.239 104512   0.0000 0.0000  main::NameSpaceArticle
# 0.67   0.233  0.233     25   0.0093 0.0093  main::LogPhase
# 0.64   0.222  0.222  16388   0.0000 0.0000  Tie::File::_read_record
# 0.64   0.220  0.220   1816   0.0001 0.0001  Tie::File::_chop_file
# 0.63   0.219  0.551     65   0.0034 0.0085  main::CountArticlesUpTo
# 0.59   0.203  1.137  14572   0.0000 0.0001  Tie::File::_fetch
# 0.58   0.202  0.722   1762   0.0001 0.0004  main::d2mmddyyyy
# 0.58   0.200  0.248  10983   0.0000 0.0000  main::WriteEvent
# 0.55   0.189  0.348  14572   0.0000 0.0000  main::XmlReadBetween
# 0.54   0.187  0.508  14572   0.0000 0.0000  Tie::File::_store_deferred
# 0.51   0.176  0.208  20020   0.0000 0.0000  Tie::File::_seek
# 0.50   0.172  0.254  14572   0.0000 0.0000  Tie::File::Heap::_insert_new
# 0.47   0.161  0.161  41656   0.0000 0.0000  Tie::File::Cache::_heap_move
# 0.46   0.158  0.593      1   0.1580 0.5930  main::SortArticleHistoryOnDateTime
# 0.45   0.157  0.443  14572   0.0000 0.0000  Tie::File::Heap::insert
# 0.42   0.146  0.302  11863   0.0000 0.0000  main::CountPrev
# 0.42   0.145  0.795  14572   0.0000 0.0001  Tie::File::STORE
# 0.40   0.139  0.170  14572   0.0000 0.0000  main::GetUserData
# 0.37   0.127  0.127  29608   0.0000 0.0000  main::IpAddress
# 0.37   0.127  0.192  14572   0.0000 0.0000  Tie::File::_cache_too_full
# 0.37   0.127  0.127  18203   0.0000 0.0000  Tie::File::_annotate_ad_history
# 0.37   0.127  0.272  14572   0.0000 0.0000  Tie::File::Heap::remove
# 0.37   0.127  0.127  14858   0.0000 0.0000  Time::Local::_daygm
# 0.36   0.126  0.126  47171   0.0000 0.0000  main::i2bbbb
# 0.36   0.126  0.173  26090   0.0000 0.0000  main::csv
# 0.36   0.126  0.126  11616   0.0000 0.0000  main::csvkey_lang_rank_first2

#Total Elapsed Time = 18.25020 Seconds
#  User+System Time = 14.41020 Seconds
#Exclusive Times
#%Time ExclSec CumulS #Calls sec/call Csec/c  Name
# 36.5   5.266  6.139  10983   0.0005 0.0006  main::CollectArticleCounts
# 9.57   1.379  2.358  14572   0.0001 0.0002  main::ReadInputXmlRevision
# 8.31   1.198  1.198  30960   0.0000 0.0000  main::XmlToSql
# 8.22   1.184  1.215    173   0.0068 0.0070  main::LogT
# 5.39   0.777  0.777  65556   0.0000 0.0000  main::XmlReadUntil
# 4.73   0.681 12.183   1816   0.0004 0.0067  main::ReadInputXmlPage
# 2.98   0.429  7.683  14572   0.0000 0.0005  main::ProcessRevision
# 2.14   0.309  0.618  14572   0.0000 0.0000  main::CollectUserCounts
# 2.06   0.297  0.435  14572   0.0000 0.0000  main::XmlReadBetween
# 2.04   0.294  0.294 104512   0.0000 0.0000  main::NameSpaceArticle
# 1.92   0.276  0.276  89680   0.0000 0.0000  main::bbbb2i
# 1.91   0.275  0.552      1   0.2753 0.5517  main::CountArticlesPerFewDays
# 1.73   0.249  0.494     65   0.0038 0.0076  main::CountArticlesUpTo
# 1.50   0.216  0.216  47171   0.0000 0.0000  main::i2bbbb
# 1.40   0.202  0.202  14572   0.0000 0.0000  main::IncUserData
# 1.31   0.189  0.189  14572   0.0000 0.0000  main::GetUserData
# 1.31   0.189  0.249  10983   0.0000 0.0000  main::WriteEvent
# 1.29   0.186  0.186     25   0.0074 0.0074  main::LogPhase
# 1.18   0.170  0.186  14856   0.0000 0.0000  Time::Local::timegm
# 1.06   0.153  0.153  51436   0.0000 0.0000  main::bb2i
# 1.06   0.153  0.275  14222   0.0000 0.0000  main::t2bbbbb
# 0.88   0.127  0.531      1   0.1270 0.5310  main::SortArticleHistoryOnDateTime
# 0.87   0.126  0.219     36   0.0035 0.0061  main::BEGIN
# 0.85   0.123  0.244      1   0.1233 0.2445  main::CountUsersPerWeek
# 0.74   0.107  0.186  25719   0.0000 0.0000  main::csv
# 0.74   0.107  0.107  29608   0.0000 0.0000  main::IpAddress
# 0.63   0.091  0.122      1   0.0914 0.1217  main::UpdateMonthlyStats
# 0.55   0.079  0.079  25778   0.0000 0.0000  main::csv2
# 0.52   0.075  0.165  22321   0.0000 0.0000  main::bbbbb2d
# 0.51   0.074  0.229  11863   0.0000 0.0000  main::CountPrev
# 0.51   0.073  0.073  43932   0.0000 0.0000  main::i2b
# 0.43   0.062  0.062  25536   0.0000 0.0000  main::i2bb
# 0.43   0.062  0.108  14489   0.0000 0.0000  main::yyyymm2bb
# 0.42   0.061  0.061  25205   0.0000 0.0000  main::i2bbb
# 0.32   0.046  0.076  10984   0.0000 0.0000  main::bb2yymm
# 0.31   0.045  0.045  40186   0.0000 0.0000  main::bbb2i
# 0.22   0.032  0.032      3   0.0107 0.0107  main::LogC
# 0.22   0.032  0.032     21   0.0015 0.0015  main::WriteFileCsv
# 0.22   0.031  0.031      1   0.0310 0.0310  main::PrepTempDir
# 0.22   0.031  0.031    188   0.0002 0.0002  main::Log
# 0.22   0.031  1.177      1   0.0309 1.1767  main::CountArticlesPerMonth
# 0.21   0.030  0.030   1632   0.0000 0.0000  main::CollectCategories
# 0.11   0.016  0.016      1   0.0160 0.0160  main::SortArticleHistoryOnArticleD
#                                             ateTime
# 0.11   0.016  0.016      8   0.0020 0.0020  DynaLoader::dl_load_file
# 0.11   0.016  0.016     12   0.0013 0.0013  main::file_time
# 0.11   0.016  0.016      8   0.0020 0.0020  URI::BEGIN
# 0.11   0.016  0.031      3   0.0053 0.0103  Win32::BEGIN
# 0.10   0.015  0.015  14857   0.0000 0.0000  Time::Local::_daygm
# 0.10   0.015  0.015      1   0.0150 0.0150  main::CollectUserStats
# 0.10   0.015  0.015      1   0.0150 0.0150  main::UpdBinariesStats

# fy
#%Time ExclSec CumulS #Calls sec/call Csec/c  Name
#Total Elapsed Time = 427.4852 Seconds
#  User+System Time = 399.9112 Seconds
#Exclusive Times
# 38.9   155.6 182.10 186897   0.0008 0.0010  main::CollectArticleCounts
# 9.77   39.06 399.99  22503   0.0017 0.0178  main::ReadInputXmlPage
# 6.72   26.88 30.437 459347   0.0001 0.0001  main::XmlToSql
# 5.40   21.59 34.761 218422   0.0001 0.0002  main::ReadInputXmlRevision
# 3.25   12.98 12.986 661526   0.0000 0.0000  Time::HiRes::time
# 3.16   12.65 12.655 963704   0.0000 0.0000  main::XmlReadUntil
# 3.12   12.45 19.171 330763   0.0000 0.0000  main::RecordTime
# 2.39   9.577 219.79 218422   0.0000 0.0010  main::ProcessRevision
# 2.05   8.193 13.724 218422   0.0000 0.0001  main::CollectUserCounts
# 1.84   7.358 17.414     88   0.0836 0.1979  main::CountArticlesUpTo
# 1.63   6.511  6.511 240925   0.0000 0.0000  Tie::File::_read_record
# 1.58   6.313  6.313 240930   0.0000 0.0000  Tie::File::_write_record
# 1.58   6.301 24.413      1   6.3014 24.413  main::CountArticlesPerFewDays
# 1.56   6.247  8.748 104582   0.0000 0.0000  Time::Local::timegm
# 1.52   6.083 18.843  22505   0.0003 0.0008  Tie::File::_flush

# fy option _O50
# $record_time_collect_article_counts = $false
#Total Elapsed Time = 320.0660 Seconds
#  User+System Time = 303.4680 Seconds
#Exclusive Times
#%Time ExclSec CumulS #Calls sec/call Csec/c  Name
# 49.6   150.5 156.39 186897   0.0008 0.0008  main::CollectArticleCounts
# 11.8   35.79 319.05  22503   0.0016 0.0142  main::ReadInputXmlPage
# 7.63   23.15 24.108 459347   0.0001 0.0001  main::XmlToSql
# 6.31   19.16 31.351 218422   0.0001 0.0001  main::ReadInputXmlRevision
# 4.04   12.25 12.268 963704   0.0000 0.0000  main::XmlReadUntil
# 2.25   6.814  9.547     88   0.0774 0.1085  main::CountArticlesUpTo
# 1.87   5.663 15.857  22505   0.0003 0.0007  Tie::File::_flush
# 1.81   5.502  5.502 240930   0.0000 0.0000  Tie::File::_write_record
# 1.79   5.427  9.134 218422   0.0000 0.0000  main::CollectUserCounts
# 1.75   5.317  5.317 240925   0.0000 0.0000  Tie::File::_read_record
# 1.72   5.228 176.64 218422   0.0000 0.0008  main::ProcessRevision
# 1.61   4.890  5.402  22503   0.0002 0.0002  Tie::File::TIEARRAY
# 1.30   3.943  3.943 129062   0.0000 0.0000  main::csvkey_lang_date
# 1.14   3.458  5.362 218422   0.0000 0.0000  main::XmlReadBetween
# 1.14   3.457 10.681      1   3.4570 10.680  main::CountArticlesPerFewDays
# 1.06   3.220  4.090 104582   0.0000 0.0000  Time::Local::timegm
# 0.90   2.730  2.730  22503   0.0001 0.0001  Tie::File::_chop_file
# 0.90   2.721  2.721 218422   0.0000 0.0000  main::IncUserData
# 0.85   2.577  2.634 218422   0.0000 0.0000  main::GetUserData
# 0.67   2.038  2.397 186897   0.0000 0.0000  main::WriteEvent
# 0.67   2.031  2.031 211081   0.0000 0.0000  main::bbbb2i
# 0.65   1.971  2.173 285934   0.0000 0.0000  Tie::File::_seek
# 0.62   1.894  1.894 776676   0.0000 0.0000  main::i2bbbb
# 0.58   1.766  2.735 459223   0.0000 0.0000  main::CountPrev
# 0.55   1.659  1.659 449600   0.0000 0.0000  main::csvkey_lang_edits
# 0.52   1.579  2.614 218420   0.0000 0.0000  Tie::File::_store_deferred
# 0.52   1.579  2.581 218422   0.0000 0.0000  Tie::File::Heap::remove
# 0.50   1.509  1.509 630798   0.0000 0.0000  Tie::File::Cache::_heap_move
# 0.49   1.472  1.472 347034   0.0000 0.0000  main::csvkey_lang_type_date
# 0.48   1.465  1.580  22507   0.0001 0.0001  Tie::File::_oadjust
# 0.48   1.451  1.451     21   0.0691 0.0691  main::WriteFileCsv
# 0.47   1.419  4.000 240923   0.0000 0.0000  Tie::File::Cache::remove
# 0.46   1.392  1.392 154914   0.0000 0.0000  main::NameSpaceArticle
# 0.43   1.296  1.296     21   0.0617 0.0617  main::ReadFileCsv
# 0.40   1.220 12.010 218424   0.0000 0.0001  Tie::File::_fetch
# 0.38   1.146  5.491  22507   0.0001 0.0002  Tie::File::_mtwrite
# 0.38   1.139  3.244 218420   0.0000 0.0000  Tie::File::Cache::insert
# 0.32   0.972  0.972 441381   0.0000 0.0000  main::IpAddress
# 0.31   0.938  4.108  22506   0.0000 0.0002  Tie::File::_downcopy
# 0.28   0.855  0.855 104582   0.0000 0.0000  Time::Local::_daygm
# 0.27   0.827  0.826      1   0.8268 0.8259  main::SortArticleHistoryOnDateTime
# 0.27   0.821 12.831 218422   0.0000 0.0001  Tie::File::FETCH
# 0.25   0.761  2.106 218422   0.0000 0.0000  Tie::File::Heap::insert
# 0.23   0.688  0.875  19812   0.0000 0.0000  main::CollectCategories
# 0.22   0.663  0.663 218422   0.0000 0.0000  Tie::File::_fixrecs
# 0.21   0.642  0.642 218424   0.0000 0.0000  Tie::File::Cache::lookup
# 0.21   0.639  0.639 402882   0.0000 0.0000  main::i2bbb
# 0.21   0.630  1.164 218422   0.0000 0.0000  Tie::File::Heap::_insert_new
# 0.21   0.628  0.628 963700   0.0000 0.0000  Time::HiRes::time
# 0.20   0.613  4.386 218422   0.0000 0.0000  Tie::File::STORE

#Total Elapsed Time = 255.7334 Seconds
#  User+System Time = 233.9394 Seconds
#Exclusive Times
#%Time ExclSec CumulS #Calls sec/call Csec/c  Name
# 64.4   150.7 156.58 186897   0.0008 0.0008  main::CollectArticleCounts
# 8.75   20.47 20.472 459347   0.0000 0.0000  main::XmlToSql
# 8.05   18.83 29.732 218422   0.0001 0.0001  main::ReadInputXmlRevision
# 4.61   10.78 10.779 963704   0.0000 0.0000  main::XmlReadUntil
# 4.17   9.747 240.49  22503   0.0004 0.0107  main::ReadInputXmlPage
# 2.87   6.713  9.727     88   0.0763 0.1105  main::CountArticlesUpTo
# 2.68   6.271 10.060 218422   0.0000 0.0000  main::CollectUserCounts
# 1.95   4.558 177.49 218422   0.0000 0.0008  main::ProcessRevision
# 1.54   3.598  4.386      1   3.5980 4.3861  main::CountArticlesPerFewDays
# 1.28   3.004  3.078 218422   0.0000 0.0000  main::GetUserData
# 1.23   2.882  2.882 218422   0.0000 0.0000  main::IncUserData
# 1.19   2.779  4.986 218422   0.0000 0.0000  main::XmlReadBetween
# 0.91   2.138  2.138 776676   0.0000 0.0000  main::i2bbbb
# 0.87   2.035  2.369 186897   0.0000 0.0000  main::WriteEvent
# 0.80   1.867  1.867 211081   0.0000 0.0000  main::bbbb2i
# 0.76   1.789  3.015 459223   0.0000 0.0000  main::CountPrev
# 0.65   1.514  1.514 154914   0.0000 0.0000  main::NameSpaceArticle
# 0.63   1.477  1.845 218729   0.0000 0.0000  Time::Local::timegm
# 0.37   0.875  0.889      1   0.8748 0.8889  main::SortArticleHistoryOnDateTime
# 0.30   0.699  1.061      1   0.6993 1.0611  main::CountUsersPerWeek
# 0.28   0.648  0.648 441381   0.0000 0.0000  main::IpAddress
# 0.26   0.609  0.609 402882   0.0000 0.0000  main::i2bbb
# 0.25   0.576 10.664      1   0.5762 10.663  main::CountArticlesPerMonth
# 0.21   0.486  0.747  19812   0.0000 0.0000  main::CollectCategories
# 0.20   0.461  0.461 116480   0.0000 0.0000  main::bb2i
# 0.18   0.422  1.094 215985   0.0000 0.0000  main::t2bbbbb
# 0.17   0.406  0.406 403859   0.0000 0.0000  main::i2bb
# 0.16   0.378  0.378 218730   0.0000 0.0000  Time::Local::_daygm
# 0.14   0.328  0.328 977020   0.0000 0.0000  main::bbb2i
# 0.11   0.261  0.261  19450   0.0000 0.0000  main::CollectCategory
# 0.11   0.258  0.294 186898   0.0000 0.0000  main::bb2yymm
# 0.10   0.233  0.233     25   0.0093 0.0093  main::LogPhase
# 0.09   0.204  0.264     36   0.0057 0.0073  main::BEGIN
# 0.08   0.188  0.572 215985   0.0000 0.0000  main::ddhhmm2bbb
# 0.08   0.187  0.187      1   0.1870 0.1869  main::SortArticleHistoryOnArticleD
#                                             ateTime
# 0.07   0.171  0.186      1   0.1708 0.1863  main::CollectActiveUsersPerMonth
# 0.07   0.156  0.156      1   0.1560 0.1560  main::PrepTempDir
# 0.06   0.141  0.156      1   0.1410 0.1560  main::WriteCategoryInfo
# 0.04   0.094  0.094      1   0.0940 0.0940  main::UpdateEditsPerArticle
# 0.04   0.094  0.094  40700   0.0000 0.0000  main::csv2
# 0.04   0.090  0.183 377961   0.0000 0.0000  main::bbbbb2d
# 0.03   0.071  0.071  45006   0.0000 0.0000  Time::HiRes::time
# 0.03   0.065  0.074   4537   0.0000 0.0000  main::NewUserData
# 0.02   0.054  0.145  22503   0.0000 0.0000  main::RecordTime
# 0.02   0.047  0.047      1   0.0470 0.0470  main::CollectUserStats
# 0.02   0.047  0.063      1   0.0469 0.0627  main::UpdateUsersAnonymous
# 0.02   0.036  0.102      1   0.0360 0.1023  main::UpdateMonthlyStats
# 0.01   0.031  0.031      1   0.0310 0.0310  main::UpdBinariesStats
# 0.01   0.027  0.046      1   0.0268 0.0465  main::CountArticlesPerNamespacePer
#                                             Month
# 0.01   0.026  0.026   3122   0.0000 0.0000  main::d2mmddyyyy

# fy option _IO50
#Total Elapsed Time = 413.8686 Seconds
#  User+System Time = 392.9026 Seconds
#Inclusive Times
#%Time ExclSec CumulS #Calls sec/call Csec/c  Name
# 96.7   0.015 380.12      1   0.0150 380.12  main::ReadInputXml
# 96.7   0.243 380.10      1   0.2435 380.10  main::ReadFileXml
# 96.5   41.73 379.25  22503   0.0019 0.0169  main::ReadInputXmlPage
# 50.4   6.957 198.05 218422   0.0000 0.0009  main::ProcessRevision
# 42.6   154.2 167.73 186897   0.0008 0.0009  main::CollectArticleCounts
# 8.89   21.23 34.948 218422   0.0001 0.0002  main::ReadInputXmlRevision
# 7.62   25.94 29.945 459347   0.0001 0.0001  main::XmlToSql
# 5.98   6.414 23.512      1   6.4136 23.511  main::CountArticlesPerFewDays
# 5.44   1.641 21.361 218422   0.0000 0.0001  Tie::File::FETCH
# 5.02   3.201 19.720 218424   0.0000 0.0001  Tie::File::_fetch
# 4.95   1.078 19.454      1   1.0783 19.454  main::CountArticlesPerMonth
# 4.87   0.156 19.129  22504   0.0000 0.0009  Tie::File::flush
# 4.83   6.248 18.974  22505   0.0003 0.0008  Tie::File::_flush
# 4.27   7.270 16.761     88   0.0826 0.1905  main::CountArticlesUpTo
# 3.79   8.991 14.904 218422   0.0000 0.0001  main::CollectUserCounts
# 3.25   12.75 12.768 963704   0.0000 0.0000  main::XmlReadUntil
# 2.80   0.672 11.017  45005   0.0000 0.0002  Tie::File::STORESIZE
# 2.57   2.417 10.117 218422   0.0000 0.0000  Tie::File::STORE
# 2.41   5.352  9.475 459223   0.0000 0.0000  main::CountPrev
# 2.27   6.741  8.919 104582   0.0000 0.0000  Time::Local::timegm
# 2.13   0.665  8.379   3122   0.0002 0.0027  main::d2mmddyyyy
# 1.97   1.765  7.745 413656   0.0000 0.0000  main::daysinmonth
# 1.85   1.875  7.256 218420   0.0000 0.0000  Tie::File::Cache::insert
# 1.69   1.509  6.643  22507   0.0001 0.0003  Tie::File::_mtwrite
# 1.67   2.122  6.567 240923   0.0000 0.0000  Tie::File::Cache::remove
# 1.63   4.011  6.419 218422   0.0000 0.0000  main::XmlReadBetween
# 1.63   6.411  6.411 240930   0.0000 0.0000  Tie::File::_write_record
# 1.60   5.244  6.291  22503   0.0002 0.0003  Tie::File::TIEARRAY
# 1.58   6.218  6.218 240925   0.0000 0.0000  Tie::File::_read_record
# 1.53   6.022  6.022 129062   0.0000 0.0000  main::csvkey_lang_date
# 1.43   2.965  5.629 218420   0.0000 0.0000  Tie::File::_store_deferred
# 1.37   1.886  5.381 218422   0.0000 0.0000  Tie::File::Heap::insert
# 1.34   5.252  5.252 211081   0.0000 0.0000  main::bbbb2i
# 1.18   1.086  4.626  22506   0.0000 0.0002  Tie::File::_downcopy
# 1.17   1.214  4.585      1   1.2145 4.5847  main::CountUsersPerWeek
# 1.14   1.416  4.481 215985   0.0000 0.0000  main::t2bbbbb
# 1.13   2.665  4.445 218422   0.0000 0.0000  Tie::File::Heap::remove
# 0.99   0.874  3.896  22506   0.0000 0.0002  Tie::File::_extend_file_to
# 0.96   0.884  3.779      1   0.8844 3.7791  main::UpdateMonthlyStats
# 0.94   2.017  3.705 377961   0.0000 0.0000  main::bbbbb2d
# 0.92   3.603  3.603 154914   0.0000 0.0000  main::NameSpaceArticle
# 0.88   2.769  3.448 186897   0.0000 0.0000  main::WriteEvent
# 0.83   3.185  3.278 218422   0.0000 0.0000  main::GetUserData
# 0.83   3.245  3.245 218422   0.0000 0.0000  main::IncUserData
# 0.80   3.161  3.161  22503   0.0001 0.0001  Tie::File::_chop_file
# 0.80   1.976  3.126 481850   0.0000 0.0000  main::RecordTime
# 0.79   2.495  3.122 285934   0.0000 0.0000  Tie::File::_seek
# 0.79   3.097  3.097 776676   0.0000 0.0000  main::i2bbbb
# 0.76   1.715  2.970 218422   0.0000 0.0000  Tie::File::Heap::_insert_new
# 0.75   0.622  2.940      1   0.6219 2.9398  main::UpdateUsersAnonymous
