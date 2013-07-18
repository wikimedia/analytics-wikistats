#!/usr/bin/perl

# Q&D script, no command line arguments

# issues 'new' and starting' are wrong, YoY -10100% = wrong (e.g. ve 2008)
# generate for all projects, monthly

  use warnings ;
  use strict ;

  our $show_flawed_metric = 0 ;

# my $project = 'wp' ;
# my $dir_in   = "w:/# out stat1/csv_$project" ;

  my ($project_code, $project,$dir_in,$dir_out) = &ParseArguments ;

  # my $file_in           = "$dir_in/StatisticsMonthly.csv" ;
  my $file_in           = "$dir_in/StatisticsUserActivitySpread.csv" ;
  my $file_out_raw      = "$dir_out/StateOfTheWikiRaw" . uc($project_code) . ".csv" ;
  my $file_out_overview = "$dir_out/StateOfTheWikiOverview" . uc($project_code) . ".csv" ;


  &CollectData ($project_code, $project, $file_in, $file_out_raw, $file_out_overview) ;

  print "\n\nReady\n\n" ;
  exit ;

sub ParseArguments
{
  use Getopt::Std ;

  my %options ;
  getopt ("iop", \%options) ;

  my $project_code = $options {'p'} ;
  my $dir_in       = $options {'i'} ;
  my $dir_out      = lc ($options {'o'}) ;

  die "Specify input folder as '-i [folder]'"  if $dir_in eq '' ;
  die "Specify output folder as '-o [folder]'" if $dir_out eq '' ;
  die "Specify project as '-p [wb|wk|wn|wp|wq|wo|ws|wv]'"  if $project_code eq '' or $project_code !~ /^(?:wb|wk|wn|wp|wq|wo|ws|wv)$/ ;
  die "Input folder not found: '$dir_in'"  if ! -e $dir_in ;
  die "Output folder not found: '$dir_out'"  if ! -e $dir_in ;

  print "Input folder: $dir_in\n" ;
  print "Output folder: $dir_out\n" ;
  print "Project code: $project_code\n" ;

     if ($project_code eq 'wb') { $project = 'Wikibooks' ; }
  elsif ($project_code eq 'wk') { $project = 'Wiktionary' ; }
  elsif ($project_code eq 'wn') { $project = 'Wikinews' ; }
  elsif ($project_code eq 'wp') { $project = 'Wikipedia' ; }
  elsif ($project_code eq 'wq') { $project = 'Wikiquote' ; }
  elsif ($project_code eq 'wo') { $project = 'Wikivoyage' ; }
  elsif ($project_code eq 'ws') { $project = 'Wikisource' ; }
  elsif ($project_code eq 'wv') { $project = 'Wikiversity' ; }
  else  { die ("Invalid project code $project_code") ; }

  return ($project_code, $project, $dir_in, $dir_out) ;
}

sub CollectData
{
  my ($project_code, $project, $file_in, $file_out_raw, $file_out_overview) = @_ ;

  my ($line, $editors, $editors_avg, $editors_hi, $ratio_size_hi, $comment, $lang, $usertype, $contenttype, $delta, $size, $count, $YoY_avg, @details, $margin, $sort_key, $size_key, $round, $diff, $dummy1, $dummy2) ;
  my ($date, $dd, $mm, $yyyy, $yyyy_mm, $yyyy_mm_hi, $yyyy_mm_year_ago, $avg_in_year, $avg_in_year_prev, $lang_yyyy, $lang_yyyy_prev, $lang_yyyy_mm, $lang_yyyy_mm_prev, $YoY_avg2) ;
  my (@data_raw, @data_raw2, %languages, %years, %months_in_year, %total_in_year, %avg_in_year, %avg_in_year_hi, %max_avg_in_year, %YoY, %YoY_tot, %YoY_avg_hi, %YoY_months, %YoY_avg, %YoY_avg_in_year, %wikis, %monthly_editors, %editors_max_per_lang) ;

  die "File not found '$file_in'" if ! -e $file_in ;
  open CSV_IN, '<', $file_in || die "Could not open file '$file_in'" ;

  my $lang_prev = '' ;

  while ($line = <CSV_IN>)
  {
    chomp $line ;
  # my ($lang,$date,@values) = split (',', $line) ; # for StatisticsMonthly.csv
  # $editors = $values [2] ;                        # for StatisticsMonthly.csv

    my ($lang,$date,$usertype,$contenttype,@values) = split (',', $line) ;
    next if $usertype    ne 'R' ; # registered user
    next if $contenttype ne 'A' ; # article
    next if $lang =~ /^zz+/ ; # project wide totals

    $editors = 0 ;
    if (defined $values [2])
    { $editors = $values [2] ; } # 5+ edits

    next if $project eq "wp" && $lang eq 'commons' ;

    if ($lang ne $lang_prev)
    {
      $size = '' ; $delta = '' ;
      push @details, "\n" ;
    }
    $lang_prev = $lang ;

    $mm   = substr ($date,0,2) ;
    $dd   = substr ($date,3,2) ;
    $yyyy = substr ($date,6,4) ;
    $yyyy_mm           = "$yyyy-$mm" ;
    $lang_yyyy         = "$lang-$yyyy" ;
    $lang_yyyy_prev    = "$lang-" . ($yyyy-1) ;
    $lang_yyyy_mm      = "$lang-$yyyy-$mm" ;
    $lang_yyyy_mm_prev = "$lang-" . sprintf ("%04d-%02d", $yyyy-1, $mm) ;

    if ((! defined $yyyy_mm_hi) || ($yyyy_mm gt $yyyy_mm_hi))
    { $yyyy_mm_hi = $yyyy_mm ; }

    if (! defined ($editors_max_per_lang {$lang}))
    { $editors_max_per_lang {$lang} = $editors ; }
    elsif ($editors_max_per_lang {$lang} < $editors)
    { $editors_max_per_lang {$lang} = $editors ; }

    $monthly_editors {$lang_yyyy_mm} = $editors ;

    if ($show_flawed_metric)
    {
      if (defined $monthly_editors {$lang_yyyy_mm_prev})
      {
        if ($monthly_editors {$lang_yyyy_mm_prev} > 0)
        {
          $YoY_months {$lang_yyyy}++ ;
          $YoY_tot    {$lang_yyyy} += $monthly_editors {$lang_yyyy_mm} / $monthly_editors {$lang_yyyy_mm_prev} ;
          $YoY_avg    {$lang_yyyy} = sprintf ("%.9f", $YoY_tot {$lang_yyyy} / $YoY_months {$lang_yyyy}) ;
        }
        else
        { ; } # not sure if ignoring is better than setting a default value, there was considerable gain, from 0 to some number
      }       # anyway it will only occur on tiny wikis
      else
      { ; }
    }

    $languages {$lang} ++ ; # collect languages codes
    $years     {$yyyy} ++ ; # collect years

    $months_in_year {$lang_yyyy} ++ ;
    $total_in_year  {$lang_yyyy} += $editors ;
    $avg_in_year    {$lang_yyyy} = sprintf ("%.2f", $total_in_year  {$lang_yyyy} / $months_in_year  {$lang_yyyy}) ;

    if (defined ($avg_in_year {$lang_yyyy_prev}))
    {
      if ($avg_in_year {$lang_yyyy_prev} > 0)
      { $YoY_avg_in_year {$lang_yyyy} = $avg_in_year {$lang_yyyy} / $avg_in_year {$lang_yyyy_prev} ; }
    }
  }
  close CSV_IN ;

  foreach $lang (sort keys %languages)
  {
    next if $editors_max_per_lang {$lang} == 0;

    foreach $yyyy (sort keys %years)
    {
      $lang_yyyy = "$lang-$yyyy" ;
      next if ! defined ($avg_in_year {$lang_yyyy}) ;

      if (! defined $avg_in_year_hi {$yyyy})
      { $avg_in_year_hi {$yyyy} = $avg_in_year {$lang_yyyy} ; }
      elsif ($avg_in_year_hi {$yyyy} < $avg_in_year {$lang_yyyy})
      { $avg_in_year_hi {$yyyy} = $avg_in_year {$lang_yyyy} ; }
    }
  }

  my $margin_tiny   = 0.5 ;
  my $margin_small  = 0.2 ;
  my $margin_medium = 0.1 ;
  my $margin_large  = 0.05 ;
  my $margin_huge   = 0.02 ;

  foreach $lang (sort keys %languages)
  {
    next if $editors_max_per_lang {$lang} == 0;

    foreach $yyyy (sort keys %years)
    {
      $lang_yyyy      = "$lang-$yyyy" ;
      $lang_yyyy_prev = "$lang-" . ($yyyy - 1) ;

      next if ! defined ($avg_in_year {$lang_yyyy}) ;

      next if ! defined ($avg_in_year_hi {$yyyy}) ;
      next if $avg_in_year_hi {$yyyy} == 0 ;

      $ratio_size_hi = sprintf ("%0.6f", $avg_in_year {$lang_yyyy} / $avg_in_year_hi {$yyyy}) ;

         if ($ratio_size_hi == 1)     { $size = 'huge' ;   $margin = 0.02 ; $size_key = 5 ; $round = "%.0f" ; }
      elsif ($ratio_size_hi > 0.1)    { $size = 'huge' ;   $margin = 0.02 ; $size_key = 5 ; $round = "%.1f" ; }
      elsif ($ratio_size_hi > 0.01)   { $size = 'large' ;  $margin = 0.05 ; $size_key = 4 ; $round = "%.2f" ; }
      elsif ($ratio_size_hi > 0.001)  { $size = 'medium' ; $margin = 0.1 ;  $size_key = 3 ; $round = "%.3f" ; }
      elsif ($ratio_size_hi > 0.0001) { $size = 'small' ;  $margin = 0.2 ;  $size_key = 2 ; $round = "%.4f" ; }
      else                            { $size = 'tiny' ;   $margin = 0.5 ;  $size_key = 1 ; $round = "%.5f" ; }

      $ratio_size_hi = sprintf ($round, 100 * $ratio_size_hi) . '%' ;

      if ($show_flawed_metric)
      {
        if (defined ($YoY_avg {$lang_yyyy}))
        {
          $YoY_avg = sprintf ("%0.9f", $YoY_avg {$lang_yyyy}) ;
             if ($YoY_avg < 1 - $margin) { $delta = 'declining' ; }
          elsif ($YoY_avg > 1 + $margin) { $delta = 'growing' ; }
          else                           { $delta = 'steady' ; }
        }
        else
        {
          $YoY_avg = '-' ;
          $delta   = '-' ;
        }
      }

      $editors_avg = $avg_in_year    {$lang_yyyy}  ;
      $editors_hi =  sprintf ("%.1f", $avg_in_year_hi {$yyyy})  ;

         if ($editors_avg > 10)  { $editors_avg = sprintf ("%.0f", $editors_avg) ; }
      elsif ($editors_avg > 1)   { $editors_avg = sprintf ("%.1f", $editors_avg) ; }
      elsif ($editors_avg > 0.1) { $editors_avg = sprintf ("%.2f", $editors_avg) ; }
      else                       { $editors_avg = sprintf ("%.3f", $editors_avg) ; }

      if ($show_flawed_metric)
      {
        if ($YoY_avg ne '-')
        {
          $YoY_avg = 100 * $YoY_avg - 100 ;
          if (($YoY_avg > 9.9) || ($YoY_avg < -9.9))
          { $YoY_avg = (sprintf ("%.0f", $YoY_avg)) . '%' ; }
          else
          { $YoY_avg = (sprintf ("%.1f", $YoY_avg)) . '%' ; }
        }
      }

      $delta = '-' ;
      $sort_key = $yyyy . "-0" ; # sort last
      if (defined ($YoY_avg_in_year {$lang_yyyy}))
      {
        $YoY_avg2 = $YoY_avg_in_year {$lang_yyyy} ;

           if ($YoY_avg2 < 1 - $margin) { $delta = 'declining' ; }
        elsif ($YoY_avg2 > 1 + $margin) { $delta = 'growing' ; }
        else                            { $delta = 'steady' ; }

        $sort_key = $yyyy . '-' . $size_key . '-' . sprintf ("%7d",$YoY_avg2*1000000) ;

        $YoY_avg2 = 100 * $YoY_avg2 - 100 ;

        if ($show_flawed_metric)
        {
          if ($YoY_avg ne '-')
          {
            my $t = $YoY_avg ;
            $t =~ s/\%// ;
            $diff = sprintf ("%.1f", $t - $YoY_avg2) ;
          }
          else
          { $diff = '-' ; }
        }

        if (($YoY_avg2 > 9.9) || ($YoY_avg2 < -9.9))
        { $YoY_avg2 = (sprintf ("%.0f", $YoY_avg2)) . '%' ; }
        else
        { $YoY_avg2 = (sprintf ("%.1f", $YoY_avg2)) . '%' ; }
      }
      else
      {
        $YoY_avg2 = '-' ;
      }

      $comment = '' ;
      if ($editors_avg == $editors_hi)
      { $comment = "largest editor community in $yyyy: $editors_hi" ; }

    # print            "$yyyy,$lang,avg:$editors_avg,hi:$editors_hi,$ratio_size_hi,$size,$YoY_avg,$delta\n" ;

      if ($show_flawed_metric)
      {
      # so YoY_avg was: yearly average of monthly YoY's (is flawed, to be removed after everyone has acknowledged, keep till then for demo)
      #    YoY_avg2 is: YoY of yearly average of monthly data
        push @data_raw,  "$sort_key,$yyyy,$lang,$editors_avg,$size,$delta,,$ratio_size_hi,$YoY_avg,$YoY_avg2,$diff,$comment\n" ;
        push @data_raw2, "$lang,$yyyy,$editors_avg,$size,$delta,,$ratio_size_hi,$YoY_avg,$YoY_avg2,$diff,$comment\n" ;
      }
      else
      {
        push @data_raw,  "$sort_key,$yyyy,$lang,$editors_avg,$ratio_size_hi,\"->\",$size,$YoY_avg2,\"->\",$delta,$comment\n" ;
        push @data_raw2, "$lang,$yyyy,$editors_avg,$ratio_size_hi,\"->\",$size,$YoY_avg2,\"->\",$delta,$comment\n" ;
      }

      $wikis {"$yyyy,$size,$delta"} ++ ;
    }
  }

  @data_raw = sort {$b cmp $a} @data_raw ;

  open CSV_OUT_RAW, '>', $file_out_raw || die "Could not open file '$file_out_raw'" ;
  print CSV_OUT_RAW "All data are about number of active editors (5+ edits per month) in countable namespaces (mostly namespace 0)\n" ;
  print CSV_OUT_RAW "All data are about yearly averages of monthly counts of this metric\n\n" ;
  if ($project_code eq 'wp')
  { print CSV_OUT_RAW "Size label is based on relative size to largest editor base in that year (for Wikipedia always English Wikipedia)\n" ; }
  else
  { print CSV_OUT_RAW "Size label is based on relative size to largest editor base in that year\n" ; }
  print CSV_OUT_RAW "huge: relative size > 10%\n" ;
  print CSV_OUT_RAW "large: relative size between 1% and 10%\n" ;
  print CSV_OUT_RAW "medium: relative size between 0.1% and 1%\n" ;
  print CSV_OUT_RAW "small: relative size between 0.01% and 0.1%\n" ;
  print CSV_OUT_RAW "tiny: relative size < 0.01%\n\n" ;

  print CSV_OUT_RAW "Trend label is based on year over year change (YoY) of editor base\n" ;
  print CSV_OUT_RAW "For different community sizes different margins are used for 'trend is steady'\n" ;
  print CSV_OUT_RAW "huge: margin 2%\n" ;
  print CSV_OUT_RAW "large: margin 5%\n" ;
  print CSV_OUT_RAW "medium: margin 10%\n" ;
  print CSV_OUT_RAW "small: margin 20%\n" ;
  print CSV_OUT_RAW "tiny: margin 50%\n\n" ;

  print CSV_OUT_RAW "Data up to $yyyy_mm_hi (data for incomplete year can have seasonal component)\n\n" ;

  my ($yyyy_prev,$size_prev) ;
  $yyyy_prev = '' ;
  $size_prev = '' ;

  print CSV_OUT_RAW "\n\n>> Scroll down for same data sorted by language/year <<\n\n" ;
  print CSV_OUT_RAW "\n\nSorted by year/size/year over year (YoY):\n" ;
  print CSV_OUT_RAW "year,lang,avg editors,rel.size,,size,YoY,,trend\n" ;
  foreach $line (@data_raw)
  {
    ($sort_key,$line) = split (',', $line, 2) ;

    if ($show_flawed_metric)
    { ($yyyy,$lang,$editors,$size,$delta) = split (',', $line) ; }
    else
    { ($yyyy,$lang,$editors_avg,$ratio_size_hi,$dummy1,$size,$YoY_avg2,$dummy2,$delta,$comment) = split (',', $line) ; }

    next if $delta eq '-' ;

    if (($yyyy ne $yyyy_prev and $yyyy_prev ne '') or ($size_prev ne $size))
    { print CSV_OUT_RAW "\n" ; }

  # print CSV_OUT_RAW "$sort_key,$line" ;
    print CSV_OUT_RAW $line ;

    $yyyy_prev = $yyyy ;
    $size_prev = $size ;
  }

  $lang_prev = '' ;
  print CSV_OUT_RAW "\n\nSorted by language/year:\n" ;
  print CSV_OUT_RAW "lang,year,avg editors,rel.size,,size,YoY,,trend\n" ;
# print CSV_OUT_RAW "language,year,editors,size,trend,, editors compared to largest languange,editors YoY\n" ;
  foreach $line (@data_raw2)
  {
    ($lang,$yyyy) = split (',', $line) ;

    if ($lang ne $lang_prev and $lang_prev ne '')
    { print CSV_OUT_RAW "\n" ; }
    print CSV_OUT_RAW "$line" ;
    $lang_prev = $lang ;
  }

  $line = "\n\nLanguages which never reached 5+ edits from one user in any month:\n" ;
  foreach $lang (sort keys %editors_max_per_lang)
  {
    if ($editors_max_per_lang {$lang} == 0)
    { $line .= "$lang," ; }
  }
  $line =~ s/,$// ;
  print CSV_OUT_RAW $line ;

  close CSV_OUT_RAW ;

  my $margin_tiny_perc   = $margin_tiny   * 100 . "+%" ;
  my $margin_small_perc  = $margin_small  * 100 . "+%" ;
  my $margin_medium_perc = $margin_medium * 100 . "+%" ;
  my $margin_large_perc  = $margin_large  * 100 . "+%" ;
  my $margin_huge_perc   = $margin_huge   * 100 . "+%" ;

  open CSV_OUT_OVERVIEW, '>', $file_out_overview || die "Could not open file '$file_out_overview" ;
# print CSV_OUT_OVERVIEW "lang,last month in year,editors avg, as ratio of larget language,avg editors in year,size,,delta\n" ;

  my $largest = '' ;
  if ($project eq 'wp')
  { $largest = '(always wp:en)' ; }

  print CSV_OUT_OVERVIEW "Breakdown of $project wikis by relative size and year over year (YoY) change in editor base\n\n" ;
  print CSV_OUT_OVERVIEW "Definitions:\n\n" ;
  print CSV_OUT_OVERVIEW "Community sizes are yearly averages of active editors (5+ edits) per month\n" ;
  print CSV_OUT_OVERVIEW "LC = largest community size in that year\n\n" ;
  print CSV_OUT_OVERVIEW "Growing community: at least x% larger than the year before\n" ;
  print CSV_OUT_OVERVIEW "Declining community: at least x% smaller than the year before\n" ;
  print CSV_OUT_OVERVIEW "x being dependant on size of community\n\n" ;

  print CSV_OUT_OVERVIEW "Data up to $yyyy_mm_hi (data for incomplete year can have seasonal component)\n\n" ;

  print CSV_OUT_OVERVIEW "\n\nyear,LC,,\"huge: 10%-100% of LC\",,,,\"large: 1%-10% of LC\",,,,\"medium: 0.1%-1% x LC\",,,,\"small: 0.01%-0.1% of LC\",,,,\"tiny: < 0.01% of LC\"\n" ;
  print CSV_OUT_OVERVIEW ",,,growing,steady,declining,,growing,steady,declining,,growing,steady,declining,,growing,steady,declining,,growing,steady,declining\n" ;
  print CSV_OUT_OVERVIEW ",,,$margin_huge_perc larger,,$margin_huge_perc smaller,,$margin_large_perc larger,,$margin_large_perc smaller,,$margin_medium_perc larger,,$margin_medium_perc smaller,,$margin_small_perc larger,,$margin_small_perc smaller,,$margin_tiny_perc larger,,$margin_tiny_perc smaller\n" ;

  my $years = 0 ;
  foreach $yyyy (sort keys %years)
  {
    next if $years++ == 0; # skip earliest year no YoY data

    print "$yyyy," ;
    print CSV_OUT_OVERVIEW "$yyyy," . sprintf ("%.0f", $avg_in_year_hi {$yyyy}) . ",," ;
    foreach $size (split ',', "huge,large,medium,small,tiny")
    {
      foreach $delta (split ',', "growing,steady,declining")
      {
        $count = $wikis {"$yyyy,$size,$delta"} ;
        if (! defined $count)
        { $count = '' ; }
        print "$count," ;
        print CSV_OUT_OVERVIEW "$count," ;
      }
      print CSV_OUT_OVERVIEW "," ;
    }
    print "\n" ;
    print CSV_OUT_OVERVIEW "\n" ;
  }
  print CSV_OUT_OVERVIEW "\n\n"  ;
  print CSV_OUT_OVERVIEW @details ;

  close CSV_OUT_OVERVIEW ;
}


