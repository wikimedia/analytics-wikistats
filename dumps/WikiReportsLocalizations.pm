#!/usr/bin/perl

# http://konieczny.be/unicode.html  utf-8 -> unicode

# get language links with api:
# http://en.wikipedia.org/w/api.php?action=query&limit=100&prop=langlinks&titles=Africa

  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  use WikiReportsNoWikimedia ;

  $refresh_language_files_after_days_php = 30 ;
  $refresh_language_files_after_days_wp  = 30 ;
  $refresh_translate_wiki_data           =  1 ;

sub TestLanguageTranslations
{
  print "TestLanguageTranslations language $language\n" ;
  $path_in  = "W:/\# out bayes/csv_wp/" ;
  $path_out = "W:/\# out bayes/csv_wp/" ;

  $file_csv_language_names_php    = $path_in . "LanguageNamesViaPhp.csv" ;
  $file_csv_language_names_wp     = $path_in . "LanguageNamesViaWpEn.csv" ;
  $file_csv_language_names_wp_cl  = $path_in . "LanguageNamesViaWpEnEdited.csv" ;
  $file_csv_language_names_diff   = $path_in . "LanguageNamesViaSvnAndWpCompared.csv" ;

  &CleanUpLanguageTranslationsFromWpEn ("de") ;
  &CompareLanguageTranslationsFromSvnAndWpEn ;
  print "Ready\n" ;

  $file_out = $path_out . "LanguageTranslationsOverview.html" ;
  print $file_out ;

  open HTML, '>', $file_out ;

  $language_job = $language ;
  foreach $languagecode (sort split (',', $crossref))
  {
    $language = $languagecode ;
    print "\n\n$languagecode\n" ;
    print HTML "<h2>$languagecode</h2>\n" ;
    undef %out_languages ;
    undef @real_languages ;
    &SetLiterals ;
    &Localization ;

    foreach $languagecode2 (sort @real_languages)
    { print HTML "$languagecode2: <font color=#008000>${out_languages {$languagecode2}}</font><br>\n" ; }
  }
  $language = $language_job ;
  close HTML ;
}

sub UpdateLanguageTranslations
{
  &UpdateLanguageTranslationsFromPhp ;
  &UpdateLanguageTranslationsFromWpEn ;
# &TestLanguageTranslations ;
}

sub Localization
{
  &LogT ("\nLocalization\n") ;

  # move -> language files
  $out_wikiversity   = "Wikiversity" ;
  $out_wikiversities = "Wikiversities" ;
  $out_wikiversity   = "Wikiversity" ; ;
  $out_wikiteachers  = "Contributors" ; ;

  $unicode = $false ;

     if ($language eq "ast") { &SetLiterals_AST ; }
  elsif ($language eq "bg")  { &SetLiterals_BG ; }
  elsif ($language eq "br")  { &SetLiterals_BR ; }
  elsif ($language eq "ca")  { &SetLiterals_CA ; }
  elsif ($language eq "cs")  { &SetLiterals_CS ; }
  elsif ($language eq "da")  { &SetLiterals_DA ; }
  elsif ($language eq "de")  { &SetLiterals_DE ; }
  elsif ($language eq "eo")  { &SetLiterals_EO ; }
  elsif ($language eq "es")  { &SetLiterals_ES ; }
  elsif ($language eq "fr")  { &SetLiterals_FR ; }
  elsif ($language eq "he")  { &SetLiterals_HE ; }
  elsif ($language eq "hu")  { &SetLiterals_HU ; }
  elsif ($language eq "id")  { &SetLiterals_ID ; }
  elsif ($language eq "it")  { &SetLiterals_IT ; }
  elsif ($language eq "ja")  { &SetLiterals_JA ; }
  elsif ($language eq "nl")  { &SetLiterals_NL ; }
  elsif ($language eq "nn")  { &SetLiterals_NN ; }
  elsif ($language eq "pl")  { &SetLiterals_PL ; }
  elsif ($language eq "pt")  { &SetLiterals_PT ; }
  elsif ($language eq "ro")  { &SetLiterals_RO ; }
  elsif ($language eq "ru")  { &SetLiterals_RU ; }
  elsif ($language eq "sk")  { &SetLiterals_SK ; }
  elsif ($language eq "sl")  { &SetLiterals_SL ; }
  elsif ($language eq "sr")  { &SetLiterals_SR ; }
  elsif ($language eq "sv")  { &SetLiterals_SV ; }
  elsif ($language eq "wa")  { &SetLiterals_WA ; }
  elsif ($language eq "zh")  { &SetLiterals_ZH ; }
  else                       { &SetLiterals_EN ; }


  $file_csv_language_names_1 = $file_csv_language_names_wp_cl ;
  $file_csv_language_names_2 = $file_csv_language_names_php ;
  if ($language eq "id") # swap which file takes precedence
  {
    $file_csv_language_names_1 = $file_csv_language_names_php ;
    $file_csv_language_names_2 = $file_csv_language_names_wp_cl ;
  }

  if (-e $file_csv_language_names_1)
  {
    open FILE_IN, "<", $file_csv_language_names_1 ;
    while ($line = <FILE_IN>)
    {
      if ($line =~ /^$language\,/)
      {
        chomp ($line) ;
        ($dummy, $code, $name_unicode, $name_html) = split (',', $line) ;
        if ($out_languages {$code} eq "")
        {
          $out_languages {$code} = $name_html ;
          $code =~ s/-/_/g ; # I need to normalize to either fiu-vro or fiu_vro everywhere
          $out_languages {$code} = $name_html ;
        }
      }
    }
    close FILE_IN ;
  }

  if (-e $file_csv_language_names_2)
  {
    open FILE_IN, "<", $file_csv_language_names_2 ;
    while ($line = <FILE_IN>)
    {
      if ($line =~ /^$language\,/)
      {
        chomp ($line) ;
        ($dummy, $code, $name_unicode, $name_html) = split (',', $line) ;
        if ($out_languages {$code} eq "")
        {
          $out_languages {$code} = $name_html ;
          $code =~ s/-/_/g ; # I need to normalize to either fiu-vro or fiu_vro everywhere
          $out_languages {$code} = $name_html ;
        }
      }
    }
    close FILE_IN ;
  }

  $language_names_force_case = "lc" ;
  if ($language =~ /^(?:$languages_force_case_uc)/)
  { $language_names_force_case = "uc" ; }

  foreach $code (keys %out_languages)
  {
    $out_languages {$code} =~ s/[\x00-\x1F]//g ;

    if (ord (substr ($out_languages {$code}, 0,1)) < 128)
    {
      if ($language_names_force_case eq "lc")
      { $out_languages {$code} = lc ($out_languages {$code}) ; }
      else
      { $out_languages {$code} = ucfirst ($out_languages {$code}) ; }
    }

    if ($language eq "de")
    { $out_languages {$code} =~ s/e?\s*\-?sprache//i ; } # also occurs in php file
  }

  if (-e "WikiReports_EN.pm")
  {
    &Log ("\nTest language file:\n\n") ;
    open SOURCE, "<", "WikiReports_EN.pm" ;
    while ($line = <SOURCE>)
    { $line =~ s/(\$[a-zA-Z_\d]+)/&TestVar($1)/e ; }
    close SOURCE ;
    &Log ("\n") ;
  }

  # non Wikimedia sites: reuse scheme for literal replacement introduced for wiktionaries
  if (! $wikimedia)
  {
    &SetLiterals_NoWikimedia ;

    if ($out_wiktionary =~ /wikicities/i) # legacy
    {
      $out_publication  = $out_wiktionary ;
      $out_publications = $out_wiktionaries ;
      $out_publishers   = $out_wiktionarians ;
    }
  }

  if ($out_publications eq "")
  { $out_publications = $out_wikipedias ; }
  if ($out_publication eq "")
  { $out_publication  = $out_wikipedia ; }
  if ($out_publishers eq "")
  { $out_publishers   = $out_wikipedians ; }

  if ($wikimedia & $mode_wp)
  {
  # $out_sort_order  = "Wikipedias are initially ordered by participation level: registered editors with 5<sup>+</sup> edits per million speakers" ;
    $out_sort_order  = "Wikipedias are initially ordered by number of speakers of the language" ;
    $out_sort_order2 = "Wikipedias are ordered by hourly page views in recent days " ;
  }
  else
  { $out_sort_order = "Wikipedias are ordered by hourly page views in recent days " }

  if ((! $mode_wp) || (! $wikimedia))
  {
    if ($mode_wb)
    {
      $out_publications = $out_wikibooks ;
      $out_publication  = $out_wikibook ;
      $out_publishers   = $out_wikibookies ;
    }

    if ($mode_wk)
    {
      $out_publications = $out_wiktionaries ;
      $out_publication  = $out_wiktionary ;
      $out_publishers   = $out_wiktionarians ;
    }

    if ($mode_wn)
    {
      $out_publications = $out_wikinewssites ;
      $out_publication  = $out_wikinews ;
      $out_publishers   = $out_wikireporters ;
    }

    if ($mode_wq)
    {
      $out_publications = $out_wikiquotes ;
      $out_publication  = $out_wikiquote ;
      $out_publishers   = $out_wikiquotarians ;
    }

    if ($mode_ws)
    {
      $out_publications = $out_wikisourcesites ;
      $out_publication  = $out_wikisources ;
      $out_publishers   = $out_wikilibrarians ;
    }

    if ($mode_wv)
    {
      $out_publications = $out_wikiversities ;
      $out_publication  = $out_wikiversity ;
      $out_publishers   = $out_wikiteachers ;
    }

    if ($mode_wx)
    {
      $out_publications = $out_wikispecials ;
      $out_publication  = $out_wikispecial ;
      $out_publishers   = $out_wikispecialists ;
    }

    $ut_report_descriptions [4] =~ s/\s?\([^\)]*\)// ; # remove (official) : alternate counts not used for Wiktionary
    if (! defined ($out_wikimedia_sites))
    { $out_wikimedia_sites = "Wikimedia sites" ; }
    $out_report_descriptions [15] =~ s/$out_wikipedias/$out_wikimedia_sites/g ;
    $out_tbl3_legend [15]         =~ s/$out_wikipedias/$out_wikimedia_sites/g ;
    $out_statistics               =~ s/$out_wikipedias/$out_publications/g ;
    $out_charts                   =~ s/$out_wikipedias/$out_publications/g ;
    $out_phaseIII                 =~ s/$out_wikipedias/$out_publications/g ;
    $out_sort_order               =~ s/$out_wikipedias/$out_publications/g ;
    $out_comparison               =~ s/$out_wikipedias/$out_publications/g ;
    $out_skip_values              =~ s/$out_wikipedias/$out_publications/g ;

    $out_report_descriptions [15] =~ s/$out_wikipedia/$out_wikimedia_sites/g ;
    $out_tbl3_legend [15]         =~ s/$out_wikipedia/$out_wikimedia_sites/g ;
    $out_statistics               =~ s/$out_wikipedia/$out_publication/g ;
    $out_charts                   =~ s/$out_wikipedia/$out_publication/g ;
    $out_phaseIII                 =~ s/$out_wikipedia/$out_publication/g ;
    $out_sort_order               =~ s/$out_wikipedia/$out_publication/g ;
    $out_skip_values              =~ s/$out_wikipedia/$out_publication/g ;
    $out_categories               =~ s/$out_wikipedia/$out_publication/g ;
    $out_category_trees           =~ s/$out_wikipedia/$out_publication/g ;
    $out_category_tree            =~ s/$out_wikipedia/$out_publication/g ;

    if ($language eq "eo")
    {
      $out_statistics =~ s/Vikipediaj/Vikivortaraj/ ;
      $out_charts     =~ s/Vikipediaj/Vikivortaraj/ ;
    }

    if (! defined ($out_wikipedians))
    { $out_wikipedians = $out_tbl3_hdr1a ; }
    if (! defined ($out_wiktionarians))
    { $out_wiktionarians = $out_wikipedians ; }
    # replace 'wikipedians' by 'wiktionarians', but keep case of first letter
    # this assumes that both words start with same letter in all languages (??)
    $out_tbl1_intro              =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl2_intro              =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl3_intro              =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl3_hdr1a              =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl3_legend [0]         =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl3_legend [1]         =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl3_legend [2]         =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl3_legend [3]         =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_plot_legend [0]         =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_plot_legend [1]         =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_report_descriptions [0] =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_report_descriptions [1] =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_report_descriptions [2] =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_report_descriptions [3] =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;
    $out_tbl8_intro              =~ s/($out_wikipedians)/(substr($1,0,1) eq uc (substr($1,0,1))) ? ucfirst ($out_publishers) : lcfirst ($out_publishers)/ieg ;

    # if ($mode_wx)
    # { $out_tbl3_legend [0] .= " (sep11: all)" ; }
  }
}

sub ReadLanguageNames
{
  &ReadFileCsv ($file_csv_language_codes, "") ;
  foreach $line (@csv)
  {
    my ($wp, $encoding, $category, $image, $user, $redirect) = split (',', $line) ;
    $imagecodes {$wp} = $image ;
  }
}

sub UpdateLanguageTranslationsFromPhp
{
  if (! $wikimedia)
  { return ; }

  my $get = $false ;
  if (! (-e $file_csv_language_names_php))
  { $get = $true ; }
  else # unless done very recently
  {
    $file_age = -M $file_csv_language_names_php ;
    if ($file_age > $refresh_language_files_after_days_php)
    { $get = $true ; }
  }

  if (! $get)
  {
    my $file ;
    ($file = $file_csv_language_names_php) =~ s/.*[\\\/]//g ; # remove path
    &Log ("Refresh file $file not needed. File is recent.\n") ;
    return ;
  }

  my @languages = split (',', $crossref) ;
  foreach $languagecode (sort @real_languages)
  { &GetLanguageNamesFromSVN ($languagecode) ; }
}

sub UpdateLanguageTranslationsFromWpEn
{
  my $get = $false ;
  if (! (-e $file_csv_language_names_wp))
  { $get = $true ; }
  else # unless done very recently
  {
    $file_age = -M $file_csv_language_names_wp ;
    if ($file_age > $refresh_language_files_after_days_wp)
    { $get = $true ; }
  }

  if (! $get)
  {
    my $file ;
    ($file = $file_csv_language_names_wp) =~ s/.*[\\\/]//g ; # remove path
    &Log ("Refresh file $file not needed. File is recent.\n") ;
    return ;
  }

#  my ($code,$data) ;
#  foreach $code (sort keys %wikipedias)
#  {
#    if ($code =~ /_/) { next ; } # fiu-vro yes, fiu_vro no
#    $data = $wikipedias {$code} ;
#    if ($data !~ /wikipedia.org/) { next ; } # only real language names
#    if ($data =~ /(?:nostalgia|sep11|species)/) { next ; }
#    $code =~ s/"//g ;
#  }

  foreach $languagecode (sort @real_languages)
  {
    &GetLanguageNamesFromWpEn ($languagecode) ;
    sleep 1 ;
  }

  &CleanUpLanguageTranslationsFromWpEn ;
}

sub GetLanguageNamesFromSVN
{
  my $language = shift ;
  my $language2 = $language ;
  if ($language eq "kk") { $language2 = "kk_cyrl" ; }
  if ($language eq "ku") { $language2 = "kk_arab" ; }
  if ($language eq "sr") { $language2 = "sr_ec" ; }
  if ($language eq "tg") { $language2 = "tg_cyrl" ; }
  if ($language eq "zh") { $language2 = "zh_hans" ; }

  my $raw_url = "http://svn.wikimedia.org/viewvc/mediawiki/trunk/extensions/cldr/LanguageNames" . ucfirst ($language2) . ".php?view=co&content-type=text%2Fplain" ;

  my ($content, $attempts) ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  &Log ("\nFetch language names for language code '$language' from:\n'$raw_url'\n") ;

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikipedia WikiReports job");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://www.wikipedia.org");

  my $success = $false ;

  for ($attempts = 1 ; ($attempts <= 2) && (! $success) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { ; } # { &Log (" -> 404\n") ; }
      else
      { &Log ("Web page could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
      return ($false) ;
    }

    $content = $response->content();
    if (! ($content =~ /<?php/))
    {
      &Log ("Page does not contain valid data:\n  '$raw_url'\n") ;
      return ($false) ;
    }

    if (! ($content =~ m/\);/i))
    {
      &Log ("Page is incomplete:\n  '$raw_url'\n") ;
      next ;
    }

    $success = $true ;
  }

  if ($success)
  {
    &Log ("Page downloaded\n") ;

    my @csv ;
    if (-e $file_csv_language_names_php)
    {
      open FILE_IN, "<", $file_csv_language_names_php ;
      while ($line = <FILE_IN>)
      {
        if ($line !~ /^$language\,/)
        { push @csv, $line ; }
      }
      close FILE_IN ;
    }

    @content = split ("\n", $content) ;
    push @csv, "#updated for $language: " . &GetDateTime(time) . "\n" ;
    foreach $line (@content)
    {
       chomp ($line) ;
       if ($line =~ /'.*?'\s*=>\s*'.*?'\s*,/)
       {
         $line =~ s/'(.*?)'\s*=>\s*'(.*?)'\s*,/($code=$1,$name=$2)/e ;
         $name =~ s/[\x00-\x1F]//g ;
         ($name2 = $name) =~ s/([\x80-\xFF]+)/unicode_to_html($1)/ge ;
         push @csv, "$language,$code,$name,$name2\n" ;
       }
    }

    @csv = sort @csv ;

    open "FILE_OUT", ">", $file_csv_language_names_php ;
    print FILE_OUT @csv ;
    close "FILE_OUT" ;
  }
  else
  { &Log ("\nWeb page not retrieved after " . (--$attempts) . " attempts !!\n\n") ; }

  return ($success) ;
}

# Fetch via interwikilinks
sub GetLanguageNamesFromWpEn
{
  my $langcode_translate_this = shift ;
  my $term = $out_article {$langcode_translate_this} ; # code -> article title on wp:en:
  $term =~ s/^.*\/// ;

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikipedia WikiReports job");
  $ua->timeout(60);

  $url = "http://en.wikipedia.org/w/api.php?action=query&limit=10&redirects&prop=langlinks&titles=$term" ;
  $url =~ s/ /%20/g ;
  &Log ("\n\nFetch interwiki links for term $term from:\n'$url'\n\n") ;

  my $success = $false ;
  my $callsmax = 100 ;
  my $response ;
  my %interwikis ;

  my ($calls,$code_lang,$name) ;

  my @csv ;
  if (-e $file_csv_language_names_wp)
  {
    open FILE_IN, "<", $file_csv_language_names_wp ;
    while ($line = <FILE_IN>)
    {
      if ($line =~ /^#/) { next ; }
      if ($line =~ /^[^\,]+,$langcode_translate_this\,/)
      {
        chomp $line ;
        ($langcode_translate_into,$langcode_translate_this,$name_utf8,$name_html) = split (',', $line) ;
        $interwikis {"$langcode_translate_into,$langcode_translate_this"} = "$name_utf8,$name_html" ;
        next ;
      }
      push @csv, $line ;
    }
    close FILE_IN ;
  }

  print "EN $langcode_translate_this ${out_languages_en {$langcode_translate_this}}\n" ;
  $interwikis {"en,$langcode_translate_this"} = $out_languages_en {$langcode_translate_this} . "," . unicode_to_html ($out_languages_en {$langcode_translate_this})  ;

  $continueprev = "" ;
  while ($url ne "")
  {
    my $req = HTTP::Request->new(GET => $url);
    $req->referer ("http://www.wikipedia.org");

    $success = $false ;
    $calls ++ ;
    if ($calls > $callsmax) { &Abort ("Number of api calls exceeds safety limit $calls") ; }
    $content = "" ;

    for ($attempts = 1 ; ($attempts <= 2) && (! $success) ; $attempts++)
    {
      $response = $ua->request($req);
      if ($response->is_error())
      {
        if (index ($response->status_line, "404") != -1)
        { ; } # { &Log (" -> 404\n") ; }
        else
        { &Log ("Web page could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
        return ($false) ;
      }

      $content = $response->content();
      $content =~ s/&lt;/</g ;
      $content =~ s/&gt;/>/g ;
      $content =~ s/&quot;/'/g ;

      if ($content !~ /MediaWiki API Result/i)
      {
        &Log ("Page does not contain valid data:\n  '$url'\n") ;
        return ($false) ;
      }

      if ($content !~ m/<\/html>/i)
      {
        &Log ("Page is incomplete:\n  '$url'\n") ;
        next ;
      }

      $success = $true ;
    }

    if (! $success )
    {
       &Log ("Web page could not be fetched:\n  '$url'\nReason: "  . $response->status_line . "\n") ;
       return ;
    }

    $continue = "" ;
    @content = split ("\n", $content) ;
    foreach $line (@content)
    {
      if ($line =~ /<ll lang=/)
      {
        $line =~ s/<ll lang='([^']*)'[^<]*><\/span>([^<]*)</($langcode_translate_into=$1,$name_utf8=$2)/e ;
        $name_utf8 =~ s/[\x00-\x1F]//g ;
        ($name_html = $name_utf8) =~ s/([\x80-\xFF]+)/unicode_to_html($1)/ge ;
        $interwikis {"$langcode_translate_into,$langcode_translate_this"} = "$name_utf8,$name_html" ; # overwrite old value, this way only values are added, never lost
        print "$langcode_translate_into,$langcode_translate_this,$name_utf8,$name_html\n" ;
      }

      if ($line =~ /llcontinue/)
      { $line =~ s/llcontinue='([^']*)'/($continue = $1)/e ; }
    }

    &Log2 ("\n\n$url\n$result $content\n\n") ;

    if ($continue ne "")
    {
      $url = "http://en.wikipedia.org/w/api.php?action=query&limit=10&redirects&prop=langlinks&titles=$term&llcontinue=$continue" ;
      $url =~ s/ /%20/g ;
    # &Log ("+++ continue with '$continue'\n$url\n\n") ;
      &Log ("+++ continue with '$continue'\n\n") ;
    }
    else
    { $url = "" ; }

    if (($continue eq $continueprev) && ($continue ne ""))
    {
      &Log ("Loop encountered\n\ncontinue: $continue\n\nprevious string'$continueprev'\n\ncontent: '$content'") ;
      $content = "" ;
      $url = "" ;
    }

    $continueprev = $continue ;
  }

  foreach $key (keys %interwikis)
  {
    $data = $interwikis{$key} ;
    $data =~ s/,$// ;
    push @csv, "$key,$data\n" ;
  }

  if ($#csv == -1) { return ; }

  @csv = sort @csv ;

  open "FILE_OUT", ">", $file_csv_language_names_wp ;
  print FILE_OUT "#target language,name_code,name_utf8,name_html\n" ;
  print FILE_OUT @csv ;
  close "FILE_OUT" ;
}

sub CleanUpLanguageTranslationsFromWpEn
{
  my $showlang = shift ;
  my ($language,$langcode_translate_this,$name_utf8,$name_html) ;

  open NAMES_IN,  '<', $file_csv_language_names_wp ;
  open NAMES_OUT, '>', $file_csv_language_names_wp_cl ;

  my $list_edited = "ast,de,eo,es,it,nn,simple" ;
  print           "#Language names edited for: $list_edited\n" ;
  print NAMES_OUT "#Language names edited for: $list_edited\n" ;

  while ($line = <NAMES_IN>)
  {
    $msg = "" ;

    if ($line =~ /^#/)
    { print NAMES_OUT $line ; next }

    chomp $line ;
    ($language,$langcode_translate_this,$name_utf8,$name_html) = split (',', $line) ;

    $name_utf8_new = $name_utf8 ;
    $name_html_new = $name_html ;

  # language specific editing >>

    if ($language eq "ast")
    { $name_utf8_new =~ s/(?:idioma|llingua)\s*//i ; }

    if ($language eq "bg")
    { $name_utf8_new =~ s/\s*\xD0\xB5\xD0\xB7\xD0\xB8\xD0\xBA\s*//i ; }

    if ($language eq "de")
    {
      $name_utf8_new =~ s/e?\s*\-?sprache//i ;
    }

    if ($language eq "eo")
    {
      $name_utf8_new =~ s/\s*\-?\(?lingvo\)?//i ;
      $name_utf8_new =~ s/\s*dialek\w+\s*//i ;
    }

    if ($language eq "es")
    { $name_utf8_new =~ s/idioma\s*//i ; }

    if ($language eq "hu")
    { $name_utf8_new =~ s/\s*nyelv\w*\s*//i ; }

    if ($language eq "id")
    { $name_utf8_new =~ s/\s*Bahasa\s*//i ; }

    if ($language eq "it")
    { $name_utf8_new =~ s/(?:lingua|dialetto)\s*//i ; }

    if ($language eq "nn")
    { $name_utf8_new =~ s/\s*spr.{2}k//i ; }

    if ($language eq "pl")
    {
      $name_utf8_new =~ s/\s*dialekt\s*//i ;
      $name_utf8_new =~ s/\s*j.{2}zyk\s*//i ;
    }

    if ($language eq "pt")
    { $name_utf8_new =~ s/\s*l.{2}ngua\s*//i ; }

    if ($language eq "ro")
    { $name_utf8_new =~ s/\s*limba\s*//i ; }

    if ($language eq "ru")
    { $name_utf8_new =~ s/\s*\xD1\x8F\xD0\xB7\xD1\x8B\xD0\xBA\s*//i ; }

    if ($language eq "simple")
    { $name_utf8_new =~ s/\s*\-?\(?language\)?//i ; }

    if ($language eq "sv")
    { $name_utf8_new =~ s/\s*spr.{2}k//i ; }

  # << language specific editing

    $name_utf8_new =~ s/\s*\(.*?\)\s*// ;
    if ($name_utf8 ne $name_utf8_new)
    {
      $msg = "'$name_utf8'->'$name_utf8_new'" ;
      ($name_html_new = $name_utf8_new) =~ s/([\x80-\xFF]+)/unicode_to_html($1)/ge ;

      if ($language eq $showlang)
      { print "$language $msg\n" ; }
    }

    $line = "$language,$langcode_translate_this,$name_utf8_new,$name_html_new" ;
    if ($msg ne "")
    { $line .= ",$msg" ; }

    print NAMES_OUT "$line\n" ;
  }

  close NAME_IN ;
  close NAME_OUT ;
}

sub CompareLanguageTranslationsFromSvnAndWpEn
{
  open NAMES_PHP,  '<', $file_csv_language_names_php ;
  open NAMES_WP,   '<', $file_csv_language_names_wp_cl ;
  open NAMES_DIFF, '>', $file_csv_language_names_diff ;

  $lines_php = 0;
  while ($line = <NAMES_PHP>)
  {
   if ($line =~ /^#/) { next ; }
   chomp ($line) ;
   # print "php $line\n" ;
   # if ($lines_php++ > 10) { last ; }
   ($a,$b,$c,$d) =split (',', $line) ;
   $names_php {"$a,$b"} = "$c,$d" ;
   $keys_php_wp {"$a,$b"} ++ ;
  }

  $lines_wp = 0;
  while ($line = <NAMES_WP>)
  {
   if ($line =~ /^#/) { next ; }
   chomp ($line) ;
   # print "wp $line\n" ;
   # if ($lines_wp++ > 10) { last ; }
   ($a,$b,$c,$d) =split (',', $line) ;
   $names_wp {"$a,$b"} = "$c,$d" ;
   $keys_php_wp {"$a,$b"} ++ ;
  }

  foreach $key (sort keys %keys_php_wp)
  {
    if (lc ($names_php {$key}) eq lc ($names_wp {$key}))
    {
      print NAMES_DIFF "same,$key,${names_php {$key}}\n" ;
      $count_same++ ;
    }
    else
    {
      if (($names_php {$key} ne "") && ($names_wp {$key} ne ""))
      { $count_diff ++ ; }
      else
      {
        if ($names_php {$key} ne "") { $count_php ++ ; }
        if ($names_wp  {$key} ne "") { $count_wp  ++ ; }
      }

      if ($names_php {$key} ne "")
      { print NAMES_DIFF "php ,$key,${names_php {$key}}\n" ; }
      if ($names_wp {$key} ne "")
      { print NAMES_DIFF "wpen,$key,${names_wp  {$key}}\n" ; }
    }
  }

  $line = "SAME $count_same DIFF $count_diff PHP ONLY $count_php WP ONLY $count_wp\n" ;
  print "$line\n" ;
  print NAMES_DIFF "\n\n$line" ;

}

sub TestVar
{
  my $var = shift ;
  if ($var eq "") { return ; }
  my $value = eval($var) ;
  if ($value eq "")
  { &Log ("No value specified for '$var' !\n") ; }
}

sub GetTranslateWikiData
{
  my $get = $false ;
  my $success = $false ;

  if (-e  $file_csv_translatewiki)
  {
    my $file ;
    ($file = $file_csv_translatewiki) =~ s/.*[\\\/]//g ; # remove path
    &Log ("Refresh file $file not needed. File is recent.\n") ;

    open  FILE_TRANSLATE_WIKI, '<', $file_csv_translatewiki ;
    while ($line = <FILE_TRANSLATE_WIKI>)
    {
      chomp ($line) ;
      ($code, $level) = split (',', $line) ;
      $translate_wiki {$code} = $level ;
      $code =~ s/-/_/g ;
      $translate_wiki {$code} = $level ;
    }
    close FILE_TRANSLATE_WIKI ;

    $file_age = -M $file_csv_translatewiki ;
    if ($file_age > $refresh_translate_wiki_data)
    { $get = $true ; }
  }
  else
  { $get = $true ; }

  if (! $get ) { return ; }

  my $raw_url = "http://translatewiki.net/static/stats/wmf.csv" ;

  my ($content, $attempts) ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  &Log ("\nFetch localization levels from '$raw_url'\n") ;

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikipedia WikiReports job");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://www.wikipedia.org");

  for ($attempts = 1 ; ($attempts <= 2) && (! $success) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { ; } # { &Log (" -> 404\n") ; }
      else
      { &Log ("Web page could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
      return ($false) ;
    }

    $content = $response->content();

    if (! ($content =~ m/\nzh/))
    {
      &Log ("Page is incomplete:\n  '$raw_url'\n") ;
      next ;
    }

    $success = $true ;
  }

  if ($success)
  {
    &Log ("Page downloaded\n") ;

    @content = split ("\n", $content) ;
    foreach $line (@content)
    {
      chomp ($line) ;
      ($code,$level) = split (';', $line) ;
      $translate_wiki {$code} = $level ;
      $code =~ s/-/_/g ;
      $translate_wiki {$code} = $level ;
    }
    $translate_wiki {'simple'} = $translate_wiki {'en'} ;

    open FILE_TRANSLATE_WIKI, ">", $file_csv_translatewiki ;
    foreach $code (sort keys %translate_wiki)
    { print FILE_TRANSLATE_WIKI "$code,${translate_wiki{$code}}\n" ; } ;
    close FILE_TRANSLATE_WIKI ;
  }
  else
  { &Log ("\nWeb page not retrieved after " . (--$attempts) . " attempts !!\n\n") ; }

  return ($success) ;
}

1;
 ;
