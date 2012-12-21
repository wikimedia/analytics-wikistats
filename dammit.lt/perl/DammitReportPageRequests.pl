#!/usr/bin/perl

  use lib "../../dumps/perl" ; # WikiReports*.pm modules
  use lib "../../squids/perl" ; # SquidReportArchive.pl

  use EzLib ;
  ez_lib_version (8) ;
  $trace_on_exit = $false ;

  use WikiReportsDate ;
  use WikiReportsLiterals ;
  use WikiReportsOutputMisc ;
  use WikiReportsScripts ;
  use WikiReportsNoWikimedia ;
  use WikiReportsLocalizations ;
  use WikiReportsConversions ;
  use WikiReportsHtml ;

  $| = 1; # flush output

  $max_rows = 1000 ;

# $start_from_language_project = 'en.z' ; # test only
# $stop_after_language_project = 'en.z' ; # test only

  my $options ;
  getopt ("iomt", \%options) ;
  $true  = 1 ;
  $false = 0 ;

  print "\n" . "="x80 . "\n\n" ;
  &GetArguments ;
  my ($yyyy,$mm) = &FindFirstMonth ($arg_months) ;
  &InitProjectNames ;
  &SetLiterals ;
  &SetScripts ;

  &ProcessReports ($arg_months,$yyyy,$mm) ;

  print "\n\nReady\n\n" ;
  exit ;

sub GetArguments
{
  $dir_in     = $options {'i'} ;
  $dir_out    = $options {'o'} ;
  $dir_temp   = $options {'t'} ;
  $arg_months = $options {'m'} ;

  die "Input folder '$dir_in' not found"   if ! -d $dir_in ;
  die "Output folder '$dir_out' not found" if ! -d $dir_out ;
  die "Input folder '$dir_temp' not found" if ! -d $dir_temp ;

  if ($arg_months !~ /^\d+$/)
  {
    print "No valid month range specified . Assume default '-m 1'" ;
    $arg_months = 1 ;
  }

  print "\nDir in '$dir_in'\n" ;
  print "Dir out '$dir_out'\n" ;
  print "Dir temp '$dir_temp'\n" ;
  print "Months: $arg_months\n\n" ;
}

sub FindFirstMonth
{
  my $arg_months = shift ;
 
  my ($mm,$yyyy) = (localtime(time)) [4,5];
  $mm ++ ;
  $yyyy += 1900 ;

  while ($arg_months-- > 0)
  {
    $mm -- ;
    if ($mm == 0)
    { 
      $mm = 12 ;
      $yyyy-- ; 
    }
  }  
  return ($yyyy,$mm) ;
}

sub ProcessReports
{
  my ($arg_months,$yyyy,$mm) = @_ ;
 
  while ($arg_months -- > 0)
  {
    print "Process month $yyyy-$mm\n" ;
    $yyyymm = sprintf ("%4d-%2d", $yyyy, $mm) ;
    $file = "pagecounts-$yyyymm-views-ge-5" ;

    # &PrepInput ($file) ; # qqq
    &GenerateOutput ($yyyymm, "$file.sorted") ;

    $mm++ ;
    if ($mm > 12)
    {
      $mm = 1 ;
      $yyyy++ ;
    }
  }
} 

sub PrepInput 
{
  my ($file) = @_ ;	

  $cmd = "rm $dir_temp/pagecounts-*-views-ge-5*" ;
  print "$cmd\n" ;
#  $result = `$cmd` ;

  print "Process $file\n" ;

  unlink $dir_temp/$file.sorted if -s "$dir_temp/$file.sorted" == 0 ; # previous sort failed or was aborted

  if (! -e "$dir_temp/$file.sorted")
  {
    $cmd = "cp $dir_in/$file.bz2 $dir_temp/$file.bz2" ;
    print "$cmd\n" ;
    $result = `$cmd` ;
    
    $cmd = "bunzip2 $dir_temp/$file.bz2" ;
    print "$cmd\n" ;
    $result = `$cmd` ;
    
    $cmd = "sort -T $dir_temp -k 1,1  -k 3gr,3 -k 2,2 $dir_temp/$file > $dir_temp/$file.sorted" ;
    print "$cmd\n" ;
    $result = `$cmd` ;
  }  

  die "cp/bunzip2/sort failed for '$dir_temp/$file'" if ! -e "$dir_temp/$file.sorted" ; 

  unlink "$dir_temp/$file" ;
}

sub GenerateOutput 
{
  my ($yyyymm, $file) = @_ ;

  print "\nGenerate html pages from $file\n\n" ;

  $lang_project_prev  = '' ;
  $lines_lang_project = 0 ;

  open COUNTS_SORTED, '<', "$dir_temp/$file" || die "Could not open file $file\n" ;
  while ($line = <COUNTS_SORTED>)
  {
    next if $line =~ /^#/ ;
    next if $line =~ /^[A-Z]/ ;

    chomp $line ;
    ($lang_project = $line) =~ s/\s.*$// ;

    if ($start_from_language_project ne '') # test only
    {
      next if $lang_project lt $start_from_language_project ;
      $start_from_language_project = '' ;
    }

    if ($lang_project ne $lang_project_prev)
    {
      last if (($stop_after_language_project ne '') && ($lang_project gt $stop_after_language_project)) ; # test only
    
      if ($lang_project_prev ne '')
      { 
	print "\nProject $lang_project_prev: $lines_lang_project lines\n" ; 
      # &GenerateFileCsv  ($yyyymm, $lang_project_prev, @lines) ;
        &GenerateFileHtml ($yyyymm, $lang_project_prev, @lines) ;
	undef @lines ;
      }

      $lang_project_prev  = $lang_project ;
      $lines_lang_project = 0 ;
    }  

    if (++ $lines_lang_project <= $max_rows)
    {
     # print "$lines_lang_project $line\n" ;
       push @lines, $line ;
    }   
  }

# &GenerateFileCsv  ($yyyymm, $lang_project_prev, @lines) ;
  &GenerateFileHtml ($yyyymm, $lang_project_prev, @lines) ;

  unlink "$dir_out/$yyyymm/reports-$yyyymm.zip" ;

  $cmd = "cd $dir_out/$yyyymm/ ; zip reports-$yyyymm.zip  *.csv *.html" ;
  print "$cmd\n" ;
  `$cmd` ;
}

sub GenerateFileCsv
{
  my ($yyyymm, $lang_project, @lines) = @_ ;

  my $dir = "$dir_out/$yyyymm" ;
  if (! -d $dir)
  { mkdir "$dir" || die "Could not create dir '$dir'" ; }
 
  ($lang,$project) = split ('\.', $lang_project) ;
  
  next if project eq 'y' ;

  $project =~ s/^b$/wikibooks/ ;
  $project =~ s/^d$/wiktionary/ ;
  $project =~ s/^n$/wikinews/ ;
  $project =~ s/^wo$/wikivoyage/ ;
  $project =~ s/^z$/wikipedia/ ;
  $project =~ s/^q$/wikiquote/ ;
  $project =~ s/^s$/wikisource/ ;
  $project =~ s/^v$/wikiversity/ ;
  $project =~ s/^mw$/wikipedia-mobile/ ;

  $project_lang = "$project-" . uc ($lang) ;

  my $file_csv  = "$dir/most-requested-pages-${yyyymm}_$project_lang.csv" ;
  open CSV, '>', $file_csv || die "Can't open file $file_csv" ;
  print CSV "rank,requests,title\n" ;	  
  
  my $rank = 0 ;
  foreach $line (@lines)
  {
    $rank++ ;
    ($lang_project,$title,$total,$counts) = split (' ', $line,4) ;
  # $line =~ s/^(\S+\s+\S+\s+\S+\s+).*$/$1/ ;
    print CSV "$rank,$total,$title\n" ;	  
  }

  close CSV ;
}

sub GenerateFileHtml
{
  my ($yyyymm, $lang_project, @lines) = @_ ;

  $out_html = '' ; # global
  
  my $dir = "$dir_out/$yyyymm" ;
  if (! -d $dir)
  { mkdir "$dir" || die "Could not create dir '$dir'" ; }

  ($lang,$project) = split ('\.', $lang_project) ;

  next if project eq 'y' ;

  $project =~ s/^b$/wikibooks/ ;
  $project =~ s/^d$/wiktionary/ ;
  $project =~ s/^n$/wikinews/ ;
  $project =~ s/^wo$/wikivoyage/ ;
  $project =~ s/^z$/wikipedia/ ;
  $project =~ s/^q$/wikiquote/ ;
  $project =~ s/^s$/wikisource/ ;
  $project =~ s/^v$/wikiversity/ ;
  $project =~ s/^mw$/wikipedia-mobile/ ;
  $project =~ s/^m$/wikimedia/ ;

  $project_lang = "$project-" . uc ($lang) ;

  undef %articles_found ;
  open IN, '<', "$dir_in/../checked/found-titles-$project_lang.txt" ;
  while ($line = <IN>)
  {
    chomp $line ;
    next if $line eq '' ;
    $articles_found {$line} ++ ;
  }
  close IN ;

  my $file_csv  = "$dir/most-requested-pages-${yyyymm}_$project_lang.csv" ;
  my $file_html = "$dir/most-requested-pages-${yyyymm}_$project_lang.html" ;
  
  $url_root = "http://$lang.$project.org/wiki" ;
  
  my $month_ord  = ord &yyyymm2b (substr ($yyyymm,0,4),substr ($yyyymm,5,2)) ;
  my $month_prev = &month_year_english_short ($month_ord - 1) ;
  my $month_next = &month_year_english_short ($month_ord + 1) ;
  my $month_now  = &month_year_english_short ($month_ord) ;

  my $url_prev = "http://www.yahoo.com" ;
  my $url_next = "" ;
  my $out_button_prev = &btn (" $month_prev ", $url_prev) ;
  my $out_button_next = &btn (" $month_next ", $url_prev) ;

  my $out_zoom = "" ;
  my $out_options = "" ;
  my $out_explanation = "Jump to <a href='#info'>notes</a>" ;
  my $out_page_subtitle = "" ;
  my $out_crossref = "" ;
  my $out_description = "" ;
  my $out_button_switch = "" ;
  my $out_msg = "<b>$month_eng ($period)</b>" ;
  my $out_button_switch = '' ;
 
  my $lang_name = $out_languages {$lang} ;
  my $out_html_title = "$lang_name $project, most requested pages in " . $month_now ;

  my $out_msg = "" ; # "<b>" . &month_year_english_short (ord &yyyymm2b (substr ($yyyymm,0,4),substr ($yyyymm    ,5,2))) . "</b>" ;
  my $out_page_title = $out_html_title ;

# $out_scriptfile = "<script language=\"javascript\" type=\"text/javascript\" src=\"WikipediaStatistics14.js\"></script>\n" ;
# $out_style      =~ s/td/td {font-size:12px}\nth {font-size:12px}\ntd/ ; # script definition needs clean up

  $out_page_subtitle = "<a href='http://stats.wikimedia.org'>Home</a> | <a href='.'>All wikis</a> | <a href=''>$month_prev</a> | <a href=''>$month_next</a> <font color=888888>(published few days after end of month)</font>" ;
# $out_options = &opt ("PageViews${project}-$month-ByViews.html", $project) ;
# foreach $project2 (keys %projects)
# {
#   if ($project2 ne $project)
#   {  $out_options .= &opt ("PageViews${project2}-$month-ByViews.html", $project2) ; }
# }

  $unicode = $true ;
  &GenerateHtmlStart ($out_html_title,  $out_zoom,          $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

# print "$out_html\n" ;
# exit ;
  $out_html =~ s/Sitemap.htm/http:\/\/stats.wikimedia.org/ ; # Q&D patch
  $out_html =~ s/ Home / stats.wikimedia.org / ; # Q&D patch

  @articles = sort {$views {$project}{$b} <=> $views {$project}{$a}} keys %{$views {$project}} ;

  $out_html .= "<p>Also available as " . "<a href='$file_csv'>csv file</a><p>" ;
# $out_html .= "ordered by views: <a href='PageViews${project}-$month-ByViews.txt'>text file</a> / <a href='PageViews${project}-$month-ByViews.csv'>csv file</a>, " ;
# $out_html .= "ordered by title: <a href='PageViews${project}-$month-ByTitle.txt'>text file</a> / <a href='PageViews${project}-$month-ByTitle.csv'>csv file</a><p>" ;
  $out_html .= "<table border=1>\n" ;
  $out_html .= "<tr><th class=cb>Rank</th><th class=cb>Requests</th><th class=lb>Title</th></tr>\n" ;

  $rank = 0 ;
  foreach $line (@lines)
  {
    $rank++ ;
    $line =~ s/^\s+// ;
    ($lang_project,$title,$total,$counts) = split (' ', $line,4) ;

    $title =~ s/^\/// ; # some pages have preceding slash

    ($title2 = $title) =~ s/\%([0-9A-F]{2})/chr(hex($1))/ge ;
    $title2 = unicode_to_html ($title2) ;
    $title2 =~ s/_/ /g ;

    $url = "$url_root/$title" ;
    if (&ArticleExists ($lang_project,$title)) # qqq
    { $show_title = "<a href='$url'>$title2</a>" ; }
    else
    { $show_title = "<a href='$url'><font color=#FF0000>$title2</font></a>" ; }

    $total =~ s/(\d+)(\d\d\d)(\d\d\d)(\d\d\d)$/$1,$2,$3,$4/ ;
    $total =~ s/(\d+)(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
    $total =~ s/(\d+)(\d\d\d)$/$1,$2/ ;
  
    $out_html .= "<tr><td class=rb>$rank</td><td class=rb>$total</td><td class=lb>$show_title</td></tr>\n" ;	  
  }
  $out_html .= "\n</table>\n</html>" ;

  ($sec,$min,$hour) = gmtime(time);
  $out_generated_at = &GetDate (time) . ' ' . sprintf ("%02d:%02d",$hour,$min) ;

  $out_license   = "All data and images on this page are in the public domain." ;
  $out_generated = "Generated on " ;
  $out_author    = "Author" ;
  $out_mail      = "Mail" ;
  $out_site      = "Web site" ;
  $out_myname_ez = "Erik Zachte" ;
  $out_mymail_ez = "ezachte@### (no spam: ### = wikimedia.org)" ;

  $out_html .= "<a name=info id=info></a><p><small><b>Notes:</b><br>\n" .
               "Requests include bot/spider/crawler requests.<br>\n" . 
               "Requests can include not existing pages (status 404 etc).<br>\n" .
	       "Requests for main and mobile site are reported separately.<br>\n" . 
	       "Redirects and upper/lower case differences are counted separately.<br>\n" .
	       "Based on compacted archive of Domas Mituzas' <a href='http://dumps.wikimedia.org/other/pagecounts-raw/'>page request files</a><p>\n" .
	       "Archive only contains articles with 5 or more requests per month<br>\n" .
               $out_generated . $out_generated_at . "<p>\n" .
               $out_author . ":" . $out_myname_ez . "<br>\n" .
               $out_mail . ":" . $out_mymail_ez . "<p>\n" .
               $out_license .
               "</small>\n" ;

  open HTML, '>', $file_html || die "Can't open file $file_html" ;
  print HTML $out_html ;
  close HTML ;

  ($dir_in2 = $dir_in) =~ s/\/[^\/]+$// ;
  $file_titles_checked = "$dir_in2/checked/found-titles-$project_lang.txt" ;
  print "\nFile titles_checked: $file_titles_checked\n" ;
  open OUT, '>', $file_titles_checked ;
  foreach $title (sort keys %articles_found)
  { 
    print OUT "$title\n" ; 
  # print     "$title\n" ; 
  }
  close OUT ;
} 

sub ArticleExists
{
  my ($lang_project,$title) = @_ ;
  
  if ($articles_found {$title} > 0)
  { 
  # print "found earlier: '$title'\n" ;
    return ($true) ; 
  }

  ($lang,$project) = split ('\.', $lang_project) ;

  $project =~ s/^b$/wikibooks/ ;
  $project =~ s/^d$/wiktionary/ ;
  $project =~ s/^n$/wikinews/ ;
  $project =~ s/^wo$/wikivoyage/ ;
  $project =~ s/^z$/wikipedia/ ;
  $project =~ s/^q$/wikiquote/ ;
  $project =~ s/^s$/wikisource/ ;
  $project =~ s/^v$/wikiversity/ ;

  if ($lang_project eq '')
  {
print "empty variable lang_project '$lang_project'\n" ; # qqq
  return ($false) ;
  }

   my $url = "http://$lang.$project.org/w/api.php?action=query&titles=$title&format=xml" ;
  ($success,$content) = GetPage ($url) ;
  
  if (($succes ne '') || ($content =~ /(?:missing|invalid)=\"\"/))
  {
  # print "missing: $title [$url]\n" ; 
    if ($success ne '')
    { print "missing: '$title' -> '$succes'\n" ; }
    else
    { print "missing: '$title'\n" ; }

    return ($false) ;
  }
  else
  {
  # print "found new: '$title'\n" ;
    $articles_found {$title} ++ ;
    return ($true) ;
  }
}

sub GetPage
{
  $indent  = "  " x ($level-1) ;

  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  my $raw_url = shift ;
  my ($success, $content, $attempts) ;
  my $file = $raw_url ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikimedia Perl job / EZ");
  $ua->timeout(5);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  my $succes = $false ;
  
  my $max_attempts = 1 ;  
  for ($attempts = 1 ; ($attempts <= $max_attempts) && (! $succes) ; $attempts++)
  {
    #  if ($requests++ % 2 == 0)
    #    # { sleep (1) ; }
    my $response = $ua->request($req);
    if ($response->is_error())
    {  
      if (index ($response->status_line, "404") != -1)
      { print "$raw_url -> 404\n" ; return ($false,'404') ; }
      else
      {
        print "$raw_url -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n" ;
        if ($response->status_line =~ /500/)
        { return ($false,'500') ; }
      }
      return ($false) ;
    }

    $content = $response->content();
    $succes = $true ;
  }

  if (! $succes)
  { print "$raw_url -> error: \nPage not retrieved after " . (--$attempts) . " attempts !!\n\n" ; }

  return ($succes,$content) ;
}

# translates one unicode character into plain ascii
sub UnicodeToAscii {
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

    if ($value < 256)
    { return (chr ($value)) ; }

    # $unicode =~ s/([\x80-\xFF])/("%".sprintf("%02X",$1))/gie ;
    return ($unicode) ;
  }
}

sub InitProjectNames
{
  &Log ("InitProjectNames\n") ;

  # copied from WikiReports.pl

  %wikipedias = (
# mediawiki=>"http://wikimediafoundation.org Wikimedia",
  nostalgia=>"http://nostalgia.wikipedia.org Nostalgia",
  sources=>"http://wikisource.org Old&nbsp;Wikisource",
  meta=>"http://meta.wikimedia.org Meta-Wiki",
  beta=>"http://beta.wikiversity.org Beta",
  species=>"http://species.wikipedia.org WikiSpecies",
  commons=>"http://commons.wikimedia.org Commons",
  foundation=>"http://wikimediafoundation.org Wikimedia&nbsp;Foundation",
  sep11=>"http://sep11.wikipedia.org In&nbsp;Memoriam",
  nlwikimedia=>"http://nl.wikimedia.org Wikimedia&nbsp;Nederland",
  plwikimedia=>"http://pl.wikimedia.org Wikimedia&nbsp;Polska",
  mediawiki=>"http://www.mediawiki.org MediaWiki",
  dewikiversity=>"http://de.wikiversity.org Wikiversit&auml;t",
  frwikiversity=>"http://fr.wikiversity.org Wikiversit&auml;t",
  wikimania2005=>"http://wikimania2005.wikimedia.org Wikimania 2005",
  wikimania2006=>"http://wikimania2006.wikimedia.org Wikimania 2006",
  aa=>"http://aa.wikipedia.org Afar",
  ab=>"http://ab.wikipedia.org Abkhazian",
  ace=>"http://ace.wikipedia.org Acehnese",
  af=>"http://af.wikipedia.org Afrikaans",
  ak=>"http://ak.wikipedia.org Akan", # was Akana
  als=>"http://als.wikipedia.org Alemannic", # was Elsatian
  am=>"http://am.wikipedia.org Amharic",
  an=>"http://an.wikipedia.org Aragonese",
  ang=>"http://ang.wikipedia.org Anglo-Saxon",
  ar=>"http://ar.wikipedia.org Arabic",
  arc=>"http://arc.wikipedia.org Aramaic",
  arz=>"http://arz.wikipedia.org Egyptian Arabic",
  as=>"http://as.wikipedia.org Assamese",
  ast=>"http://ast.wikipedia.org Asturian",
  av=>"http://av.wikipedia.org Avar", # was Avienan
  ay=>"http://ay.wikipedia.org Aymara",
  az=>"http://az.wikipedia.org Azeri", # was Azerbaijani
  ba=>"http://ba.wikipedia.org Bashkir",
  bar=>"http://bar.wikipedia.org Bavarian",
  bat_smg=>"http://bat-smg.wikipedia.org Samogitian",
  "bat-smg"=>"http://bat-smg.wikipedia.org Samogitian",
  bcl=>"http://bcl.wikipedia.org Central Bicolano",
  be=>"http://be.wikipedia.org Belarusian",
  "be-x-old"=>"http://be.wikipedia.org Belarusian (Tarashkevitsa)",
  be_x_old=>"http://be.wikipedia.org Belarusian (Tarashkevitsa)",
  bg=>"http://bg.wikipedia.org Bulgarian",
  bh=>"http://bh.wikipedia.org Bihari",
  bi=>"http://bi.wikipedia.org Bislama",
  bm=>"http://bm.wikipedia.org Bambara",
  bn=>"http://bn.wikipedia.org Bengali",
  bo=>"http://bo.wikipedia.org Tibetan",
  bpy=>"http://bpy.wikipedia.org Bishnupriya Manipuri",
  br=>"http://br.wikipedia.org Breton",
  bs=>"http://bs.wikipedia.org Bosnian",
  bug=>"http://bug.wikipedia.org Buginese",
  bxr=>"http://bxr.wikipedia.org Buryat",
  ca=>"http://ca.wikipedia.org Catalan",
  cbk_zam=>"http://cbk-zam.wikipedia.org Chavacano",
  "cbk-zam"=>"http://cbk-zam.wikipedia.org Chavacano",
  cdo=>"http://cdo.wikipedia.org Min Dong",
  ce=>"http://ce.wikipedia.org Chechen",
  ceb=>"http://ceb.wikipedia.org Cebuano",
  ch=>"http://ch.wikipedia.org Chamorro", # was Chamoru
  ckb=>"http://ckb.wikipedia.org Sorani",
  cho=>"http://cho.wikipedia.org Choctaw", # was Chotaw
  chr=>"http://chr.wikipedia.org Cherokee",
  chy=>"http://chy.wikipedia.org Cheyenne", # was Sets&ecirc;hest&acirc;hese
  co=>"http://co.wikipedia.org Corsican",
  cr=>"http://cr.wikipedia.org Cree",
  crh=>"http://crh.wikipedia.org Crimean Tatar",
  cs=>"http://cs.wikipedia.org Czech",
  csb=>"http://csb.wikipedia.org Cashubian", # was Kashubian
  cu=>"http://cv.wikipedia.org Old Church Slavonic",
  cv=>"http://cv.wikipedia.org Chuvash", # was Cavas
  cy=>"http://cy.wikipedia.org Welsh",
  da=>"http://da.wikipedia.org Danish",
  de=>"http://de.wikipedia.org German",
  diq=>"http://diq.wikipedia.org Zazaki",
  dk=>"http://dk.wikipedia.org Danish",
  dsb=>"http://dsb.wikipedia.org Lower Sorbian",
  dv=>"http://dv.wikipedia.org Divehi",
  dz=>"http://dz.wikipedia.org Dzongkha",
  ee=>"http://ee.wikipedia.org Ewe",
  el=>"http://el.wikipedia.org Greek",
  eml=>"http://eml.wikipedia.org Emilian-Romagnol",
  en=>"http://en.wikipedia.org English",
  eo=>"http://eo.wikipedia.org Esperanto",
  es=>"http://es.wikipedia.org Spanish",
  et=>"http://et.wikipedia.org Estonian",
  eu=>"http://eu.wikipedia.org Basque",
  ext=>"http://ext.wikipedia.org Extremaduran",
  fa=>"http://fa.wikipedia.org Persian",
  ff=>"http://ff.wikipedia.org Fulfulde",
  fi=>"http://fi.wikipedia.org Finnish",
  "fiu-vro"=>"http://fiu-vro.wikipedia.org Voro",
  fiu_vro=>"http://fiu-vro.wikipedia.org Voro",
  fj=>"http://fj.wikipedia.org Fijian",
  fo=>"http://fo.wikipedia.org Faroese", # was Faeroese
  fr=>"http://fr.wikipedia.org French",
  frp=>"http://frp.wikipedia.org Arpitan",
  fur=>"http://fur.wikipedia.org Friulian",
  fy=>"http://fy.wikipedia.org Frisian",
  ga=>"http://ga.wikipedia.org Irish",
  gan=>"http://gan.wikipedia.org Gan",
  gay=>"http://gay.wikipedia.org Gayo",
  gd=>"http://gd.wikipedia.org Scots Gaelic", # was Scottish Gaelic
  gl=>"http://gl.wikipedia.org Galician", # was Galego
  glk=>"http://glk.wikipedia.org Gilaki",
  gn=>"http://gn.wikipedia.org Guarani",
  got=>"http://got.wikipedia.org Gothic",
  gu=>"http://gu.wikipedia.org Gujarati",
  gv=>"http://gv.wikipedia.org Manx", # was Manx Gaelic
  ha=>"http://ha.wikipedia.org Hausa",
  hak=>"http://hak.wikipedia.org Hakka",
  haw=>"http://haw.wikipedia.org Hawai'ian", # was Hawaiian
  he=>"http://he.wikipedia.org Hebrew",
  hi=>"http://hi.wikipedia.org Hindi",
  hif=>"http://hif.wikipedia.org Fiji Hindi",
  ho=>"http://ho.wikipedia.org Hiri Motu",
  hr=>"http://hr.wikipedia.org Croatian",
  hsb=>"http://hsb.wikipedia.org Upper Sorbian",
  ht=>"http://ht.wikipedia.org Haitian",
  hu=>"http://hu.wikipedia.org Hungarian",
  hy=>"http://hy.wikipedia.org Armenian",
  hz=>"http://hz.wikipedia.org Herero",
  ia=>"http://ia.wikipedia.org Interlingua",
  iba=>"http://iba.wikipedia.org Iban",
  id=>"http://id.wikipedia.org Indonesian",
  ie=>"http://ie.wikipedia.org Interlingue",
  ig=>"http://ig.wikipedia.org Igbo",
  ii=>"http://ii.wikipedia.org Yi",
  ik=>"http://ik.wikipedia.org Inupiak",
  ilo=>"http://ilo.wikipedia.org Ilokano",
  io=>"http://io.wikipedia.org Ido",
  is=>"http://is.wikipedia.org Icelandic",
  it=>"http://it.wikipedia.org Italian",
  iu=>"http://iu.wikipedia.org Inuktitut",
  ja=>"http://ja.wikipedia.org Japanese",
  jbo=>"http://jbo.wikipedia.org Lojban",
  jv=>"http://jv.wikipedia.org Javanese",
  ka=>"http://ka.wikipedia.org Georgian",
  kaa=>"http://kaa.wikipedia.org Karakalpak",
  kab=>"http://ka.wikipedia.org Kabyle",
  kaw=>"http://kaw.wikipedia.org Kawi",
  kg=>"http://kg.wikipedia.org Kongo",
  ki=>"http://ki.wikipedia.org Kikuyu",
  kj=>"http://kj.wikipedia.org Kuanyama", # was Otjiwambo
  kk=>"http://kk.wikipedia.org Kazakh",
  kl=>"http://kl.wikipedia.org Greenlandic",
  km=>"http://km.wikipedia.org Khmer", # was Cambodian
  kn=>"http://kn.wikipedia.org Kannada",
  ko=>"http://ko.wikipedia.org Korean",
  kr=>"http://kr.wikipedia.org Kanuri",
  ks=>"http://ks.wikipedia.org Kashmiri",
  ksh=>"http://ksh.wikipedia.org Ripuarian",
  ku=>"http://ku.wikipedia.org Kurdish",
  kv=>"http://kv.wikipedia.org Komi",
  kw=>"http://kw.wikipedia.org Cornish", # was Kornish
  ky=>"http://ky.wikipedia.org Kirghiz",
  la=>"http://la.wikipedia.org Latin",
  lad=>"http://lad.wikipedia.org Ladino",
  lb=>"http://lb.wikipedia.org Luxembourgish", # was Letzeburgesch
  lbe=>"http://lbe.wikipedia.org Lak",
  lg=>"http://lg.wikipedia.org Ganda",
  li=>"http://li.wikipedia.org Limburgish",
  lij=>"http://lij.wikipedia.org Ligurian",
  lmo=>"http://lmo.wikipedia.org Lombard",
  ln=>"http://ln.wikipedia.org Lingala",
  lo=>"http://lo.wikipedia.org Laotian",
  ls=>"http://ls.wikipedia.org Latino Sine Flexione",
  lt=>"http://lt.wikipedia.org Lithuanian",
  lv=>"http://lv.wikipedia.org Latvian",
  mad=>"http://mad.wikipedia.org Madurese",
  mak=>"http://mak.wikipedia.org Makasar",
  map_bms=>"http://map-bms.wikipedia.org Banyumasan",
  "map-bms"=>"http://map-bms.wikipedia.org Banyumasan",
  mdf=>"http://mdf.wikipedia.org Moksha",
  mg=>"http://mg.wikipedia.org Malagasy",
  mh=>"http://mh.wikipedia.org Marshallese",
  mhr=>"http://mhr.wikipedia.org Eastern Mari",
  mi=>"http://mi.wikipedia.org Maori",
  min=>"http://min.wikipedia.org Minangkabau",
  minnan=>"http://minnan.wikipedia.org Minnan",
  mk=>"http://mk.wikipedia.org Macedonian",
  ml=>"http://ml.wikipedia.org Malayalam",
  mn=>"http://mn.wikipedia.org Mongolian",
  mo=>"http://mo.wikipedia.org Moldavian",
  mr=>"http://mr.wikipedia.org Marathi",
  ms=>"http://ms.wikipedia.org Malay",
  mt=>"http://mt.wikipedia.org Maltese",
  mus=>"http://mus.wikipedia.org Muskogee",
  mwl=>"http://mwl.wikipedia.org Mirandese",
  my=>"http://my.wikipedia.org Burmese",
  myv=>"http://myv.wikipedia.org Erzya",
  mzn=>"http://mzn.wikipedia.org Mazandarani",
  na=>"http://na.wikipedia.org Nauruan", # was Nauru
  nah=>"http://nah.wikipedia.org Nahuatl",
  nap=>"http://nap.wikipedia.org Neapolitan",
  nds=>"http://nds.wikipedia.org Low Saxon",
  nds_nl=>"http://nds-nl.wikipedia.org Dutch Low Saxon",
  "nds-nl"=>"http://nds-nl.wikipedia.org Dutch Low Saxon",
  ne=>"http://ne.wikipedia.org Nepali",
  new=>"http://new.wikipedia.org Nepal Bhasa",
  ng=>"http://ng.wikipedia.org Ndonga",
  nl=>"http://nl.wikipedia.org Dutch",
  nov=>"http://nov.wikipedia.org Novial",
  nrm=>"http://nrm.wikipedia.org Norman",
  nn=>"http://nn.wikipedia.org Nynorsk", # was Neo-Norwegian
  no=>"http://no.wikipedia.org Norwegian",
  nv=>"http://nv.wikipedia.org Navajo", # was Avayo
  ny=>"http://ny.wikipedia.org Chichewa",
  oc=>"http://oc.wikipedia.org Occitan",
  om=>"http://om.wikipedia.org Oromo",
  or=>"http://or.wikipedia.org Oriya",
  os=>"http://os.wikipedia.org Ossetic",
  pa=>"http://pa.wikipedia.org Punjabi",
  pag=>"http://pag.wikipedia.org Pangasinan",
  pam=>"http://pam.wikipedia.org Kapampangan",
  pap=>"http://pap.wikipedia.org Papiamentu",
  pdc=>"http://pdc.wikipedia.org Pennsylvania German",
  pi=>"http://pi.wikipedia.org Pali",
  pih=>"http://pih.wikipedia.org Norfolk",
  pl=>"http://pl.wikipedia.org Polish",
  pms=>"http://pms.wikipedia.org Piedmontese",
  pnb=>"http://pnb.wikipedia.org Western Panjabi",
  pnt=>"http://pnt.wikipedia.org Pontic",
  ps=>"http://ps.wikipedia.org Pashto",
  pt=>"http://pt.wikipedia.org Portuguese",
  qu=>"http://qu.wikipedia.org Quechua",
  rm=>"http://rm.wikipedia.org Romansh", # was Rhaeto-Romance
  rmy=>"http://rmy.wikipedia.org Romani",
  rn=>"http://rn.wikipedia.org Kirundi",
  ro=>"http://ro.wikipedia.org Romanian",
  roa_rup=>"http://roa-rup.wikipedia.org Aromanian",
  "roa-rup"=>"http://roa-rup.wikipedia.org Aromanian",
  roa_tara=>"http://roa-tara.wikipedia.org Tarantino",
  "roa-tara"=>"http://roa-tara.wikipedia.org Tarantino",
  ru=>"http://ru.wikipedia.org Russian",
  ru_sib=>"http://ru-sib.wikipedia.org Siberian",
  "ru-sib"=>"http://ru-sib.wikipedia.org Siberian",
  rw=>"http://rw.wikipedia.org Kinyarwanda",
  sa=>"http://sa.wikipedia.org Sanskrit",
  sah=>"http://sah.wikipedia.org Sakha",
  sc=>"http://sc.wikipedia.org Sardinian",
  scn=>"http://scn.wikipedia.org Sicilian",
  sco=>"http://sco.wikipedia.org Scots",
  sd=>"http://sd.wikipedia.org Sindhi",
  se=>"http://se.wikipedia.org Northern Sami",
  sg=>"http://sg.wikipedia.org Sangro",
  sh=>"http://sh.wikipedia.org Serbo-Croatian",
  si=>"http://si.wikipedia.org Sinhala", # was Singhalese
  simple=>"http://simple.wikipedia.org Simple English",
  sk=>"http://sk.wikipedia.org Slovak",
  sl=>"http://sl.wikipedia.org Slovene",
  sm=>"http://sm.wikipedia.org Samoan",
  sn=>"http://sn.wikipedia.org Shona",
  so=>"http://so.wikipedia.org Somali", # was Somalian
  sq=>"http://sq.wikipedia.org Albanian",
  sr=>"http://sr.wikipedia.org Serbian",
  srn=>"http://srn.wikipedia.org Sranan",
  ss=>"http://ss.wikipedia.org Siswati",
  st=>"http://st.wikipedia.org Sesotho",
  stq=>"http://stq.wikipedia.org Saterland Frisian",
  su=>"http://su.wikipedia.org Sundanese",
  sv=>"http://sv.wikipedia.org Swedish",
  sw=>"http://sw.wikipedia.org Swahili",
  szl=>"http://szl.wikipedia.org Silesian",
  ta=>"http://ta.wikipedia.org Tamil",
  te=>"http://te.wikipedia.org Telugu",
  test=>"http://test.wikipedia.org Test",
  tet=>"http://tet.wikipedia.org Tetum",
  tg=>"http://tg.wikipedia.org Tajik",
  th=>"http://th.wikipedia.org Thai",
  ti=>"http://ti.wikipedia.org Tigrinya",
  tk=>"http://tk.wikipedia.org Turkmen",
  tl=>"http://tl.wikipedia.org Tagalog",
  tlh=>"http://tlh.wikipedia.org Klingon", # was Klignon
  tn=>"http://tn.wikipedia.org Setswana",
  to=>"http://to.wikipedia.org Tongan",
  tokipona=>"http://tokipona.wikipedia.org Tokipona",
  tpi=>"http://tpi.wikipedia.org Tok Pisin",
  tr=>"http://tr.wikipedia.org Turkish",
  ts=>"http://ts.wikipedia.org Tsonga",
  tt=>"http://tt.wikipedia.org Tatar",
  tum=>"http://tum.wikipedia.org Tumbuka",
  turn=>"http://turn.wikipedia.org Turnbuka",
  tw=>"http://tw.wikipedia.org Twi",
  ty=>"http://ty.wikipedia.org Tahitian",
  udm=>"http://udm.wikipedia.org Udmurt",
  ug=>"http://ug.wikipedia.org Uighur",
  uk=>"http://uk.wikipedia.org Ukrainian",
  ur=>"http://ur.wikipedia.org Urdu",
  uz=>"http://uz.wikipedia.org Uzbek",
  ve=>"http://ve.wikipedia.org Venda", # was Lushaka
  vec=>"http://vec.wikipedia.org Venetian",
  vi=>"http://vi.wikipedia.org Vietnamese",
  vls=>"http://vls.wikipedia.org West Flemish",
  vo=>"http://vo.wikipedia.org Volap&uuml;k",
  wa=>"http://wa.wikipedia.org Walloon",
  war=>"http://war.wikipedia.org Waray-Waray",
  wo=>"http://wo.wikipedia.org Wolof",
  wuu=>"http://wuu.wikipedia.org Wu",
  xal=>"http://xal.wikipedia.org Kalmyk",
  xh=>"http://xh.wikipedia.org Xhosa",
  yi=>"http://yi.wikipedia.org Yiddish",
  yo=>"http://yo.wikipedia.org Yoruba",
  za=>"http://za.wikipedia.org Zhuang",
  zea=>"http://zea.wikipedia.org Zealandic",
  zh=>"http://zh.wikipedia.org Chinese",
  zh_min_nan=>"http://zh-min-nan.wikipedia.org Min Nan",
  "zh-min-nan"=>"http://zh-min-nan.wikipedia.org Min Nan",
  zh_classical=>"http://zh-classical.wikipedia.org Classical Chinese",
  "zh-classical"=>"http://zh-classical.wikipedia.org Classical Chinese",
  zh_yue=>"http://zh-yue.wikipedia.org Cantonese",
  "zh-yue"=>"http://zh-yue.wikipedia.org Cantonese",
  zu=>"http://zu.wikipedia.org Zulu",
  zz=>"&nbsp; All&nbsp;languages",
  zzz=>"&nbsp; All&nbsp;languages except English"
  );

  foreach $key (keys %wikipedias)
  {
    my $wikipedia = $wikipedias {$key} ;
    $out_urls      {$key} = $wikipedia ;
    $out_languages {$key} = $wikipedia ;
    $out_urls      {$key} =~ s/(^[^\s]+).*$/$1/ ;
    $out_languages {$key} =~ s/^[^\s]+\s+(.*)$/$1/ ;
    $out_article   {$key} = "http://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
    $out_article   {$key} =~ s/ /_/g ;
    $out_urls {$key} =~ s/(^[^\s]+).*$/$1/ ;
  }
  $out_languages {"www"} = "Portal" ;
}

