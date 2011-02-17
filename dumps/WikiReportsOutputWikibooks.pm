#!/usr/bin/perl

  require "WikiReports.pl" ;
  # use strict 'vars' ;
  # use vars qw ($false $true) ;

sub GenerateWikibookReports
{
  my ($wp,$wpc) ;

# &GenerateWikibookReport ("en") ; # test
# return ;

  foreach $wp (@languages)
  {
    # if (($wp ne "zz") &&  ($wp ne "en")) # test only, en takes long time
    if ($wp ne "zz")
    # if ($wp eq "de")
    { &GenerateWikibookReport ($wp) ; }
  }

  open (WIKIBOOKS_NDX_HTML, ">", $path_out_wikibooks . "WikiBookIndex.htm") ;

  my $out_page_title    = "$out_stats_per $out_wikibook" ;
  my $out_page_subtitle = $out_index ;
  my $out_html_title    = $out_page_title ;
  my $out_explanation   = "Statistics per wikibook" ;
  my $out_msg           = "" ;

  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
    $out_explanation = &GetDate ($dumpdate2) ;
  }

  $out_crossref = &GenerateCrossReference ("") ;

  $out_html = "" ;
  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      "", "", "", $out_crossref, $out_msg) ;

  $out_html .= "<table border=1 cellspacing=0 id=table1 style='' summary='Wiki books'>\n" ;
  foreach $wp (@languages)
  {
    if ($wp eq "zz") { next ; }

    $wpc = $wp ;
    #if ($wp eq "simple")
    #{ $wpc = "se" ; }

    $file_wikibooks_report = "Wikibooks_" . uc($wp) . ".htm" ;
    $size = -s $path_out_wikibooks . $file_wikibooks_report ;
    if ($size > 0)
    {
      $out_size = '' ;
      if ($size > 250 * 1024)
      { $out_size = " (" . &i2KbMb ($size) . '!)' ; }
      $line_html = &tdcb ($wpc) .
                   &tdlb (&w("<a href='$file_wikibooks_report'> " . $out_languages {$wp} . "</a>$out_size")) ;
      $out_html .= &tr ($line_html) ;
    }
  }
  $out_html .= "</table>\n" ;

  &GenerateColophon ($false, $false) ;
  print WIKIBOOKS_NDX_HTML $out_html ;

  print WIKIBOOKS_NDX_HTML "</body>\n</html>\n" ;
  close WIKIBOOKS_NDX_HTML ;
  return ;

}

sub GenerateWikibookReport
{
  my $wp = shift ;

  my $file_csv_wikibooks = $path_in . "Wikibooks".uc($wp).".csv" ;
  if (! -e $file_csv_wikibooks)
  { return ; }

  $legend = "\n\n<p><hr><hr><p><h3>Legend</h3><b>Section title</b><br><a href=''><b>[Aaaa]</b></a> = book section when article with same title does exist<br><b>[Aaaa]</b> = book section when article with same title does not exist<p><b>Chapter size</b><br>\n" .
            "Chapter size in bytes: Xaaa &gt; 2000 &ge; Yaaa &ge; 500 &gt; Zaaa " .
            "will be shown as: <span class=ch1>Xaaa</span> / <span class=ch2>Yaaa</span> / <span class=ch3>Zaaa</span> / <span class=ch1>Xaaa</span> / <span class=ch2>Yaaa</span> / <span class=ch3>Zaaa</span><p>\n\n" .
            "Choose from three display modes (click below at 'Select' to change display mode, changing may take a few seconds on large files)<p>\n" .
            "<span onclick='set_style_booklinks (1)'><b><font color=blue>Select</font></b> mode \"<span class=ch1a>Xaaa</span> / <span class=ch2a>Yaaa</span> / <span class=ch3a>Zaaa</span>\"</span>&nbsp;&nbsp;&nbsp;&nbsp;=> font color varies, large chapters are shown in bold type<br>\n" .
            "<span onclick='set_style_booklinks (2)'><b><font color=blue>Select</font></b> mode&nbsp;&nbsp;&nbsp;\"<span class=ch1b>Xaaa</span> / <span class=ch2b>Yaaa</span> / <span class=ch3b>Zaaa</span>\"</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=> font color and size vary<br>\n" .
            "<span onclick='set_style_booklinks (3)'><b><font color=blue>Select</font></b> mode&nbsp;&nbsp;&nbsp;\"<span class=ch1c>Xaaa</span> / <span class=ch2c>Yaaa</span> / <span class=ch3c>Zaaa</span>\"</span>&nbsp;&nbsp;=> font color, size and weight vary<br>\n " .
            "" ;

#            "<a href=''><span onclick='set_style_booklinks (1)'><b>1</b></span></a> <span class=ch1a>Xaaa</span>/<span class=ch2a>Yaaa</span>/<span class=ch3a>Zaaa</span> " .
#            "<a href=''><span onclick='set_style_booklinks (2)'><b>2</b></span></a> <span class=ch1b>Xaaa</span>/<span class=ch2b>Yaaa</span>/<span class=ch3b>Zaaa</span> " .
#            "<a href=''><span onclick='set_style_booklinks (3)'><b>3</b></span></a> <span class=ch1c>Xaaa</span>/<span class=ch2c>Yaaa</span>/<span class=ch3c>Zaaa</span> " .

#  &ReadFileCsv ($file_csv_language_codes, $wp) ;
#  if ($#csv == -1)
#  { $encoding = "utf-8" ; }
#  else
#  {
#    ($dummy, $encoding) = split (',', @csv [0]) ;
#    $encoding =~ s/[\(\)]//g ;
#  }
# $encoding = "utf-8" ;
  $encoding = "iso-8859-1" ;

  my $dumpdate ;
  if (defined ($dumpdate_hi))
  {
    $dumpdate = timegm (0,0,0,
                        substr ($dumpdate_hi,6,2),
                        substr ($dumpdate_hi,4,2)-1,
                        substr ($dumpdate_hi,0,4)-1900) ;
#   $out_html_date = "<h2>" . &GetDate ($dumpdate) . "<\/h2>\n" ;
  }

  my $out_page_title    = "$out_stats_per $out_wikibook" ;
  $out_page_title =~ s/$out_wikipedia/$out_wikibook/ ;
  my $out_page_subtitle = uc ($wp) . " - <a href='" . $out_urls {$wp} . "'>" . $out_languages {$wp} . "</a>" ;
  my $out_html_title    = $out_page_title ;

  my $out_explanation   = "Wikibooks rankings and chapter lists" ;

  my $out_button_switch = "" ;
  my $out_button_home       = &btn (" " . $out_index, "WikiBookIndex.htm") ;
  my $out_msg = "" ;
  $out_html = "" ;

  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      "", "", "&nbsp;", "", $out_msg) ;
  $out_html =~ s/(<body[^>]*)>/$1 onload='set_style_booklinks (0)'>/ ;
  $out_html =~ s/CategoryOverviewIndex/WikiBookIndex/ ; # dirty hack, cleanup !

  if ($language =~ /^(?:ja|zh)$/)
  { $out_html =~ s/(h\d\s*\{[^\}]+)(\})/$1; font-weight:normal$2/g ; }

  my $base ;
  if ($mode_wb)
  { $base = "http://$wp.wikibooks.org/wiki" ; }
  if ($mode_wv)
  { $base = "http://$wp.wikiversity.org/wiki" ; }

# $out_html .= "<font color=#600000>This overview is experimental. At the present there are no strict rules for article naming on wikibooks. " .
#              "As a result the division<br>of article titles into book name and chapter name in the following report is not and can't be perfect. " .
#              "See also used <a href='#algorithm'>algorithm</a> below.</font>" ;
  $out_html .= "The algorithm used for deriving book and section titles from chapter (article) titles is described <a href='#algorithm'>below</a>." ;
  # $out_html .= "$legend" ;

  if (($wp eq "en") && ($mode_wb))
  {
    $out_html .= "<p>Non English books which have been moved to another wikibook site and " .
                 "for which only the history is kept here are not shown." ; # "<br>" .
                 # "There are still quite many books that should be moved and a template similar to " .
                 # "<a href='http://en.wikibooks.org/wiki/Template:Bereits_nach_de.wikibooks.org_verschoben'>this notice</a> should be added. " ;
    $out_html .= "<hr>" ;
  }
  else
  { $out_html .= "<p>" ; }

  $out_html .= "\@LISTS\@" ;
  $out_html .= "<hr><hr>" ;
  $out_html .= "\@TOC\@" ;

  $out_html .= "$legend" ;

  open (WIKIBOOKS_CSV, "<", $file_csv_wikibooks) ;
  @books = <WIKIBOOKS_CSV> ;
  close (WIKIBOOKS_CSV) ;

  if ($#books < 10)
  {
    $file_wikibooks_report = $path_out_wikibooks . "Wikibooks_" . uc($wp) . ".htm" ;
    unlink $file_wikibooks_report ;
    return ;
  }

  @books = sort { &csvkey_chapters ($b) <=> &csvkey_chapters ($a)} @books ;

  # $out_html .= "<p><hr><p><h3>Books with more than one chapter</h3>" ;
  $prev_parts = 0 ;
  $idnamebook = 1 ;
  $indexcnt = 0 ;
  undef @url_chapters ;
  undef %hrefbook ;
  undef %tocbook ;
  foreach my $line (@books)
  {
    undef %chapter_urls ;
    undef %chapter_size ;

    if ($line =~ /^\#/) { next ; } # comment
    chomp ($line) ;
    $line =~ s/^\|// ;
    $line =~ s^\#\*\$\@^'^g ; # restore single quotes (shoul already be done in count job)
    $line =~ s^\\\"^\"^g ;
    my ($book, $parts, $edits, $size, $words, $authors, $chapterlist) = split (',', $line) ;

    $book     =~ s/&pipe;/\|/g ;
    $book     =~ s/&comma;/\,/g ;
    $book     =~ s/&star;/\*/g ;

    # &Log2 ("== Book '$book' ==\n\n") ;

    @chapters = split ('\|', $chapterlist) ;

    $href= "" ;
    $hrefbook {$book} = ++$idnamebook ;
    $href = "\n\n<a id='$idnamebook' name='$idnamebook'></a>\n" ;
    if (($size > 10*1024) && ($parts > 1))
    {
      $indexcnt++ ;
      $tocbook {$book} = $idnamebook ;
    }

    foreach $chapter (@chapters)
    {
      $chapter =~ s/&pipe;/\|/g ;
      $chapter =~ s/&comma;/\,/g ;
      ($chapter,$link,$size) = split ('\*', $chapter) ;
      $chapter =~ s/^[\_\:\/\-]+// ;
      $chapter =~ s/[\_\:\/\-]+$// ;
      $chapter =~ s/&star;/\*/g ;
      $link    =~ s/&star;/\*/g ;
      $chapter_urls {$chapter} = $link ;
      $chapter_size {$chapter} = $size ;
    }

    if ($parts == 1)
    {
      $chapter = $chapters [0] ;
      $chapter2 = $chapter ;
      $chapter2 =~ s/_/ /g ;
      $chapter2 =~ s/^[\:\_\-\/]+// ;
      $url_chapter = encode_url ("$base/" . $chapter_urls {$chapter}) ;
      $book =~ s/\_/&nbsp;/g ;
      # ($tag1, $tag2) = &FormatSize ($size) ;
      my $class = &ClassSize ($size) ;
      # push @url_chapters, "$book|$href<a href='$url_chapter'>$tag1" . &EncodeHtml (convert_unicode ($book)) . "$tag2</a>\n";
      push @url_chapters, "$book|$href<a href='$url_chapter'><span class=$class>" . &EncodeHtml (convert_unicode ($book)) . "</span></a>\n";
      $prev_parts = 1 ;
      next ;
    }

    $url_book = '' ;
    if ($chapter_urls {$book} ne '')
    {
      $url_book = encode_url ("$base/" . $chapter_urls {$book}) ;
      $book =~ s/\_/&nbsp;/g ;
      $link_book = "<a href='$url_book'>" . &EncodeHtml (convert_unicode ($book)) . "</a>" ;
      $out_html .= "<hr>$href<p><h4>$link_book</h4>\n$parts chapters, $edits edits, size " .
                   &i2KbMb($size) . ", $words words" . ", $authors registered authors<p>\n";
    }
    else
    {
      $book =~ s/\_/&nbsp;/g ;
      $out_html .= "<hr>$href<p><h4>" . &EncodeHtml (convert_unicode ($book)) . "</h4>\n$parts chapters, $edits edits, size " .
                   &i2KbMb($size) . ", $words words<p>" ;
    }
    $line_html = "" ;

    @chapters = sort {csvkey_chapter($a) cmp csvkey_chapter($b)} @chapters ;

    $book =~ s/&comma;/\,/g ;
    $book2 = $book ;
    $book2 =~ s/_/ /g ;

    &FindSubBooks ;
    &WriteChapters ($base) ;

    $out_html  .= "$line_html" ;
  }

  $charprev= '' ;
  $out_html .= "<p><hr><hr><p><h3>Remainder</h3>Books that seemingly are not divided into chapters<br>" ;
  foreach $line_html (sort {$a cmp $b} @url_chapters)
  {
    my ($name, $html) = split ('\|', $line_html, 2) ;

#  print "\n\nName $name Len " . length ($name) . "\n" ;
    my $char = $name ;
    $char =~ s/^((?:[\x00-\xbf]|
                    [\xc0-\xdf][\x80-\xbf]|
                    [\xe0-\xef][\x80-\xbf]{2}|
                    [\xf0-\xf7][\x80-\xbf]{3})).*$/$1/x ;

#    $char = substr ($name,0,1) ;
#    if (ord ($char) > 127)
#    {
#      $char = substr ($name,0,2) ;
#      if (ord (substr ($char,1,1)) > 127)
#      { $char = substr ($name,0,3) ; }
#  print "\n\nChar $char Len " . length ($char) . "\n" ;
#  for ($i = 0 ; $i < 3 ; $i++)
#  { print ", $i =" . ord (substr ($char,$i,1)) ; }
#  print "\n" ;

    if (length ($char) > 1)
    { $char = &UnicodeToHtml ($char) ; }
    if ($char ne $charprev)
    {
      $line_html = "&nbsp;<br><font size='+1'><b>$char</b></font>&nbsp;\n". $html ;
      $charprev = $char ;
    }
    else
    { $line_html = " &#47; " . $html ; }
    $out_html  .= "$line_html" ;
  }

  $line_html = '' ;
  $charprev  = "" ;
  if ($indexcnt > 10)
  {
    $line_html = "<p><h3>Alphabetical Index</h3>\nBooks larger than 10 Kb and more than one chapter:<p>" ;
    foreach $book (sort {$a cmp $b} keys %tocbook)
    {
      $book2 = $book ;
      $book2 =~ s/_/ /g ;

      my $char = $book2 ;
      $char =~ s/^((?:[\x00-\xbf]|
                      [\xc0-\xdf][\x80-\xbf]|
                      [\xe0-\xef][\x80-\xbf]{2}|
                      [\xf0-\xf7][\x80-\xbf]{3})).*$/$1/x ;

      if (length ($char) > 1)
      { $char = &UnicodeToHtml ($char) ; }
      #$char = substr ($book2,0,1) ;
      #if (ord ($char) > 127)
      #{
      #  $char = substr ($book2,0,2) ;
      #  if (ord (substr ($char,1,1)) > 127)
      #  { $char = substr ($book2,0,3) ; }
      #  $char = &EncodeHtml (convert_unicode ($char)) ; # &UnicodeToHtml ($char) ;
      #}
      if ($char ne $charprev)
      {

        $line_html .= "&nbsp;<br><font size='+1'><b>$char</b></font>&nbsp;\n" ;
        $charprev = $char ;
      }
      else
      { $line_html .= " &#47; " ; }

      $line_html .= "<a href='\#" . $tocbook {$book} . "'>" . &EncodeHtml (convert_unicode ($book2)) . "</a>\n" ;
    }
  }

  $out_html =~ s/\@TOC\@/$line_html/ ;

  my $listmax = 100 ;
  if ($listmax > ($#books + 1))
  { $listmax = $#books + 1 ; }

  $out_lists  = "\n\n" ;
  $out_lists .= "<table border=0 cellspacing=5 style=''><tr><td>\n" ;
  @books = sort { &csvkey_size ($b) <=> &csvkey_size ($a)} @books ;
  &ListBooksOrderedBy ('size in bytes', $listmax, 3) ;
  $out_lists .= "</td>\n<td>\n" ;
  @books = sort { &csvkey_edits ($b) <=> &csvkey_edits ($a)} @books ;
  &ListBooksOrderedBy ('number of edits', $listmax, 2) ;
  $out_lists .= "</td>\n<td>\n" ;
  @books = sort { &csvkey_authors ($b) <=> &csvkey_authors ($a)} @books ;
  &ListBooksOrderedBy ('number of registered authors', $listmax, 5) ;
  $out_lists .= "</td>\n<td>\n" ;
  @books = sort { &csvkey_chapters ($b) <=> &csvkey_chapters ($a)} @books ;
  &ListBooksOrderedBy ('number of chapters', $listmax, 1) ;
  $out_lists .= "</td>\n</tr>\n</table>\n<p>\n\n" ;

  $out_html =~ s/\@LISTS\@/$out_lists/ ;

#  $out_html .= "<hr><p><small>Category tags that were inserted via a template are <b>not yet</b> recognised." .
#              "<br>Also this overview may lists categories pages that only contain a redirect tag.</small>" ;

  $out_html .= "$legend" ;

  if ($mode_wb)
  { $out_html .= "<hr><hr><p><a name=algorithm></a><h3>Algorithm</h3><p>" .
                 "The algorithm used to detect book titles is roughly this:<p>" .
                 "On a first pass through the input, article titles are scanned for candidate book and chapter names as follows:<br>".
                 "Find the first colon, forward slash and hyphen. Whichever of these comes first determines division between book and chapter title.<br>" .
                 "If none of these are found treat text between brackets as chapter title, rest as book title.<br>" .
                 "If no brackets are found and the article title ends with one or more digits, assume this is a numbered chapter.<br>" .
                 # "If none of the above applies, treat first space as divison between book and chapter title.<p>" .
                 "On a second pass book titles that occurred less than three times are marked as possible false positives<br>" .
                 "Article titles which match exactly a candidate book name that occurs more than twice, are added to the selection<br>" .
                 "(these are introductory pages, first chapters, or how you want to call them)<br> " .
                 "Counts are now collected.<p>" .
                 "Before writing the report, books are further divided into 'subbooks' and single chapters, using almost the same algorithm as above,<br>" .
                 "except that now subbook titles without colon, slash, hyphen, bracket or trailing digit are matched for the longest text <br>" .
                 "that occurs several times within one book."  ; }
  if ($mode_wv)
  { $out_html .= "<hr><hr><p><a name=algorithm></a><h3>Algorithm</h3><p>" .
                 "This overview of book and chapter titles is modelled after a similar overview for the Wikibooks project,<br>" .
                 "The main difference is that here only slashes are accepted as marker to separate book and titles,<br>" .
                 "where on Wikibooks a complicated algorithm was used to cater for legacy naming schemes.<hr><hr>" ; }

  &GenerateColophon ($false, $false) ;

  if ($language =~ /^(?:ja|zh)$/)
  { $out_html =~ s/<\/?b>//g ; }

  $file_wikibooks_report = $path_out_wikibooks . "Wikibooks_" . uc($wp) . ".htm" ;
  open (WIKIBOOKS_REPORT, ">", $file_wikibooks_report) ;
  print WIKIBOOKS_REPORT $out_html ;
  close WIKIBOOKS_REPORT ;
}

sub ListBooksOrderedBy
{
  my $order = shift ;
  my $max   = shift ;
  my $ndx   = shift ;

  $out_lists .= "<table border=1 cellspacing=0 id='table1' style=''  summary='$max largest books ordered by $order'>\n" ;
  $out_lists .= "<tr><th colspan='2' align=left class=l>$max books ordered by $order</th></tr>\n" ;
  $linecnt = 0 ;
  foreach my $line (@books)
  {
    if ($line =~ /^\#/) { next ; } # comment
    chomp ($line) ;
    if (++$linecnt > $max) { last ; }

    $line =~ s/^\|// ;
    $line =~ s^\#\*\$\@^'^g ; # restore single quotes (shoul already be done in count job)
    $line =~ s^\\\"^\"^g ;
    my (@fields) = split (',', $line) ;
    $book = $fields [0] ;
    $book =~ s/&pipe;/\|/g ;
    $book =~ s/&comma;/\,/g ;
    $book =~ s/&star;/\*/g ;

    $link_book = "<a href='\#" . $hrefbook {$book} . "'>" . &EncodeHtml (convert_unicode ($book)) . "</a>\n" ;
    $out_lists .= &trc (&tdr (&i2KM ($fields[$ndx])) . &tdl($link_book)) ;
  }
  $out_lists .= "</table>\n<p>" ;
}

sub FindSubBooks
{
  my ($chapter, $booktitle) ;

  undef %booktitles ;
  undef %booktitles2 ;
  undef %book ;
  undef %showchapter ;

  for (my $pass = 1 ; $pass <= 2 ; $pass++)
  {
    foreach $chapter (@chapters)
    {
      $chapter2   = $chapter ;
      # $chapter2   =~ s/^[\:\_\-\/]+// ;
      $booktitle = $chapter2 ;

      $title_found = $true ;

      $poscolon   = index ($chapter2, ':') ;
      $posslash   = index ($chapter2, '/') ;
      $poshyphen  = index ($chapter2, ' - ') ;
      if ($poshyphen == -1)
      { $poshyphen  = index ($chapter2, '_-_') ; }
      if ($poshyphen == -1)
      { $poshyphen  = index ($chapter2, '-') ; }
      $posbracket = index ($chapter2, '(') ;
      $posspace   = index ($chapter2, '_') ;
      # $posspace   = index (substr ($chapter2,4), '_') + 4 ;

      $posnum = -1 ;
      if ($chapter2 =~ /\_?\d+$/)
      {
        $chapter3 = $chapter2 ;
        $chapter3 =~ s/\_?\d+$// ;
        $posnum = length ($chapter3) ;
      }

      $poscolon   = ($poscolon   < 1 ? 9999 : $poscolon) ;
      $posslash   = ($posslash   < 2 ? 9999 : $posslash) ;
      $poshyphen  = ($poshyphen  < 2 ? 9999 : $poshyphen) ;
      $posbracket = ($posbracket < 2 ? 9999 : $posbracket) ;
      $posnum     = ($posnum     < 2 ? 9999 : $posnum) ;
      $posspace   = ($posspace   < 1 ? 9999 : $posspace) ;

      if ($mode_wv) # accept only slash as chapter delimiter
      {
        $poscolon   = 9999 ;
        $poshyphen  = 9999 ;
        $posbracket = 9999 ;
        $posnum     = 9999 ;
        $posspace   = 9999 ;
      }

      # &Log2 ("\nChapter $pass '$chapter2'\n") ;
      # &Log2 ("colon $poscolon slash $posslash hyphen $poshyphen bracket $posbracket num $posnum space $posspace\n") ;

      if (($poscolon < 9999) && ($poscolon < $posslash) && ($poscolon < $poshyphen))
      {
        $booktitle =~ s/\:.*$// ;
        $chapter2   = substr ($chapter2, length ($booktitle)) ;
      }
      elsif (($posslash < 9999) && ($posslash < $poscolon) && ($posslash < $poshyphen))
      {
        $booktitle =~ s/\/.*$// ;
        $chapter2   = substr ($chapter2, length ($booktitle)) ;
      }
      elsif (($poshyphen < 9999) && ($poshyphen < $poscolon) && ($poshyphen < $posslash))
      {
        $booktitle =~ s/\_?\-.*$// ;
        $chapter2  = substr ($chapter2, length ($booktitle)) ;
      }
      elsif ($posbracket < 9999)
      {
        # if ($pass == 1)
        # { &Log2 ("posbracket $posbracket $chapter\n") ; }
        $booktitle =~ s/^.*\(([^\)]+)\).*$/$1/ ;
        $chapter2  =~ s/^(.*)\([^\)]+\)(.*)$/$1 $2/ ;
        # if ($pass == 1)
        # { &Log2 ("'$booktitle' '$chapter2'\n") ; }
      }
      elsif ($posnum < 9999)
      {
        # if ($pass == 1)
        # { &Log2 ("posnum $posnum $chapter\n") ; }
        $booktitle = substr ($chapter2, 0, $posnum)  ;
        $chapter2  = substr ($chapter2, $posnum) ;
        # if ($pass == 1)
        # { &Log2 ("'$booktitle' '$chapter2'\n") ; }
      }
      elsif ($posspace < 9999)
      {
        # &Log2 ("\n\nPosSpace '$booktitle'\n") ;
        my @words = split ('\_', $booktitle) ;
        $booktitle = shift (@words) ;
        # &Log2 ("Booktitle '$booktitle'\n") ;
        while ($#words >= 0)
        {
          my $matches = 0 ;
          $testtitle = $booktitle . '_' . shift (@words) ;
          # &Log2 ("Testtitle '$testtitle'\n") ;
          foreach $testchapter (@chapters)
          {
            if (substr ($testchapter, 0, length ($testtitle)) eq $testtitle)
            {
              # &Log2 ("Match with '$testchapter'\n") ;
              $matches ++ ;
              if ($matches > 2) { last ; }
            }
          }
          # &Log2 ("Matches '$matches'\n") ;
          if ($matches < 2) { last ; }
          $booktitle = $testtitle ;

        }
        if ($booktitle =~ /^[\_\:\/\-]*(?:the|an|of|le|la|les|un|une|de|des|du|een|het|ein|eine|das|die)[\_\:\/\-]*$/i)
        { $booktitle = $chapter2 ; }
        else
        { $chapter2  = substr ($chapter2, length ($booktitle)) ; }
        # &Log2 ("Booktitle '$booktitle' Chapter '$chapter2'\n") ;
      }
      else
      {
        $booktitle   = $chapter2 ;
        $title_found = $false ;
      }

      $booktitle =~ s/^[\_\:\/\-]+// ;
      $booktitle =~ s/[\_\:\/\-]+$// ;

      if ($pass == 1)
      {
        $booktitles {$booktitle} ++ ;
        next ;
      }

      if ($booktitles {$chapter} >= 2)
      {
        $booktitle = $chapter ;
        $chapter2  = $chapter ;
      }

      $booktitles2 {$booktitle} ++ ;
      $book        {$chapter} = $booktitle ;
      $showchapter {$chapter} = $chapter2 ;
    }
  }

  foreach $chapter (@chapters)
  {
    if (@booktitles2 {$book {$chapter}} == 1)
    {
      $book        {$chapter} = chr(255) ;
      $showchapter {$chapter} = $chapter ;
    }
    else
    {
      if ($showchapter {$chapter} eq $chapter)
      { $showchapter {$chapter} = 'Idem' ; }
    }

    $showchapter {$chapter} =~ s/^[\_\:\/\-]+// ;
    $showchapter {$chapter} =~ s/[\_\:\/\-]+$// ;
  }

  @chapters = sort { $book {$a} cmp $book {$b}} @chapters ;

  foreach $chapter (@chapters)
  {
    if ($book {$chapter} eq chr(255))
    { $book {$chapter} = '' ; }
    # &Log2 ("book " . @book {$chapter} . ": chapter: " . @showchapter {$chapter} . "\n") ;
  }
}

sub WriteChapters
{
  my $base = shift ;
  my $subbook ;
  my $subbookprev = '' ;
  my $url_subbook = '' ;

  foreach my $chapter (@chapters)
  {
    $subbook = $book {$chapter} ;
    if ($subbook ne $subbookprev)
    {
      $line_html =~ s/\&[^\&]*$/<br>/ ;
      if ($subbook ne '')
      {
        # $line_html .= "<img src='../bookshelf.gif' alt='Book shelf'>" ;
        if ($showchapter {$subbook} eq "Idem")
        {
          $url_subbook = encode_url ("$base/" . $chapter_urls {$subbook}) ;
          $subbook2 = $subbook ;
          $subbook2 =~ s/\_/&nbsp;/g ;
          $line_html .= "<a href='$url_subbook'><b>[" . &EncodeHtml (convert_unicode ($subbook2)) . "]</b></a>&nbsp;&nbsp; " ;
        }
        else
        {
          $subbook2 = $subbook ;
          $subbook2 =~ s/\_/&nbsp;/g ;
          $line_html .= "<b>[" . &EncodeHtml (convert_unicode ($subbook2)) . "]</b>&nbsp;&nbsp; " ;
        }
      }
      else
      { $line_html .= "<br>" ; }
    }
    $subbookprev = $subbook ;

    $size  = $chapter_size {$chapter} ;
    $url_chapter = encode_url ("$base/" . $chapter_urls {$chapter}) ;

    if ($url_chapter eq $url_book) { next ; }
    if ($url_chapter eq $url_subbook) { next ; }

    $chapter = $showchapter {$chapter} ;
    $chapter2 = $chapter ;
    $chapter =~ s/&pipe;/\|/g ;
    $chapter =~ s/&comma;/\,/g ;
    $chapter =~ s/\_/&nbsp;/g ;
    $prefix = '-' ;
    if (($chapter eq 'Idem'|| ($subbook eq '')))
    { $prefix = '' ; }

    #if ($subbook ne "")
    #{ $chapter2 = "$subbook/$chapter2" ; }
    #$size  = @chapter_size {$chapter2} ;
    # ($tag1, $tag2) = &FormatSize ($size) ;
    my $class = &ClassSize ($size) ;

    # $line_html .= "<a href='$url_chapter'>$tag1$prefix" . &EncodeHtml (convert_unicode ($chapter)) . "$tag2</a> &#47; " ;
    $line_html .= "<a href='$url_chapter'><span class=$class>$prefix" . &EncodeHtml (convert_unicode ($chapter)) . "</span></a> &#47; " ;
  }
  $line_html =~ s/\&[^\&]*$// ;
}

#sub FormatSize
#{
#  my $size = shift ;
#  $tag1 = '' ;
#  $tag2 = '' ;
#  if ($size > 2000)
#  {
#    $tag1 = "<b>" ;
#    $tag2 = "</b>" ;
#  }
#  elsif ($size < 500)
#  {
#    $tag1 = "<font color=#AAAA00>" ;
#    $tag2 = "</font>" ;
#  }
#  else
#  {
#    $tag1 = "<font color=#000070>" ;
#    $tag2 = "</font>" ;
#  }
#  return ($tag1, $tag2) ;
#}

sub ClassSize
{
  my $size = shift ;
  my $class = 'ch2' ;
  if ($size > 2000)
  { $class = 'ch3' ; }
  elsif ($size < 500)
  { $class = 'ch1' ; }
  return ($class) ;
}


1;
