#!/usr/bin/perl

sub GenerateCategoryReports
{
  $maxdepth = 12 ;

#&GenerateCategoryTree ("af") ; # test
#&GenerateCategoryTree ("nl") ; # test

  my $root = uc ($language) ;
  if (! $wikimedia)
  { $path_out_categories =~ s/EN/$root/ ; }

  foreach my $wp (@languages)
  {
    # if (($wp ne "zz") &&  ($wp ne "en")) # test only, en takes long time
    # if ($wp eq "nl") test
    if (($wp ne "zz") && ($wp ne "en"))
    { &GenerateCategoryTree ($wp) ; }
  }
  &GenerateCategoryTree ("en") ; # takes very long do last

  if (! $category_index)
  { return ; }

  open (CATEGORIES_NDX_HTML, ">", $path_out_categories. "CategoryOverviewIndex.htm") ;

  my $out_page_title    = $out_category_trees ;
  my $out_page_subtitle = $out_index ;
  my $out_html_title    = $out_page_title ;
  my $out_explanation   = "" ;
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

  $out_html .= "<table border=1 cellspacing=0 id=table1 style='' summary='Category files'>\n" ;
  foreach $wp (@languages)
  {
    if ($wp eq "zz") { next ; }

    $wpc = $wp ;
    #if ($wp eq "simple")
    #{ $wpc = "se" ; }

    $file_categories_all = "CategoryOverview_".uc($wp)."_Complete.htm" ;
    $file_categories_top = "CategoryOverview_".uc($wp)."_Concise.htm" ; # top 4
    $file_categories_tip = "CategoryOverview_".uc($wp)."_Main.htm" ;    # tip of the iceberg = top 3
    $size_all = -s $path_out_categories . $file_categories_all ;
    $size_top = -s $path_out_categories . $file_categories_top ;
    $size_tip = -s $path_out_categories . $file_categories_tip ;
    if ($size_all > 0)
    {
      if ($size_all > 500 * 1024)
      { $out_size_all = " (" . i2KbMb ($size_all) . "!)" ; }
      else
      { $out_size_all = "" ; }

      if ($size_top > 500 * 1024)
      { $out_size_top = " (" . i2KbMb ($size_top) . "!)" ; }
      else
      { $out_size_top = "" ; }

      if ($size_tip > 500 * 1024)
      { $out_size_tip = " (" . i2KbMb ($size_tip) . "!)" ; }
      else
      { $out_size_tip = "" ; }

      $line_html = ($wikimedia ? &tdcb ($wpc) : &tdlb ($wpc)) .
                   ($wikimedia ? &tdlb ($out_languages {$wp}) : "") .
                   &tdlb (&w("<a href='$file_categories_all'> " . $out_categories_complete . "</a>" . $out_size_all)) ;
      if ($mode_wp)
      {
        if ($size_top > 0)
        { $line_html .= &tdlb (&w("<a href='$file_categories_top'> " . $out_categories_concise . "</a>" . $out_size_top)) ; }
        else
        { $line_html .= &tdeb ; }
        if ($size_tip > 0)
        { $line_html .= &tdlb (&w("<a href='$file_categories_top'> " . $out_categories_main . "</a>" . $out_size_tip)) ; }
        else
        { $line_html .= &tdeb ; }
      }

      $out_html .= &tr ($line_html) ;
    }
  }
  $out_html .= "</table>\n" ;

  &GenerateColophon ($false, $false) ;

  print CATEGORIES_NDX_HTML $out_html ;

  print CATEGORIES_NDX_HTML "</body>\n</html>\n" ;
  close CATEGORIES_NDX_HTML ;

  return ;

}

sub GenerateCategoryTree
{
  my $wp = shift ;
  my $file_categories = $path_in . "Categories".uc($wp).".csv" ;
  if (! -e $file_categories)
  { return ; }

  $lines_invalid = 0 ;
  $lines_read    = 0 ;
  &Log ("Process $file_categories\n") ;
  open "FILE_CATEGORIES", "<", $file_categories || abort ("File '$file_categories' could not be opened.") ;
  while ($line = <FILE_CATEGORIES>)
  {
    chomp ($line) ;
    if ($line =~ /^\#/) { next ; }

    $lines_read ++ ;

    $line =~ s/\#\*\$\@/\'/g ; # put back quotes (should be done before writing the file)
    my ($category, $parents, $articles, $bytes) = split (',', $line) ;
    $category =~ s/\&comma;/,/g ;
    $category =~ s/\&pipe;/\|/g ;
    $category = ucfirst ($category) ;
    $ArticlesPerCategory {$category} = $articles ;
    if ($parents eq '')
    { push @TopCategories, $category ; }
    else
    {
      $parents =~ s/\&comma;/,/g ;
      my @parents = split ('\|', $parents) ;
      foreach my $parent (@parents)
      {
        $parent =~ s/\&pipe;/\|/g ;
        $parent = ucfirst ($parent) ;
        if ($category ne $parent) # safety measure
        { $Subcategories {$parent} .= "\|$category" ; }
        # &Log2 ("Title $title : '$cat' is part of '$catparent'\n") ; # debug
      }
      $Supercategories {$category} = $parents ;
      # &Log2 ("Cat $cat Super $catlist\n") ;
    }
  }

  close "FILE_CATEGORIES" ;
  if ($lines_read >= 10)
  { &GenerateCategoryOverviews ($wp) ; }
  else
  {
    $file_categories_all = $path_out_categories."CategoryOverview_".uc($wp)."_Complete.htm" ;
    $file_categories_top = $path_out_categories."CategoryOverview_".uc($wp)."_Concise.htm" ;
    $file_categories_tip = $path_out_categories."CategoryOverview_".uc($wp)."_Main.htm" ;
    unlink $file_categories_all ;
    unlink $file_categories_top ;
    unlink $file_categories_tip ;
  }
}

sub GenerateCategoryOverviews
{
  my $wp = shift ;
  my $timestart = time ;

  $maxdepthfound = 0 ;

  &ReadFileCsv ($file_csv_language_codes, $wp) ;
  if ($#csv == -1)
  { $categorytag = "Category" ; }
  else
  {
    ($dummy1, $dummy2, $categorytag) = split (',', $csv [0]) ;
    $categorytag =~ s/[\(\)]//g ;
  }
  $categorytag = encode_non_ascii($categorytag) ;

 &Log ("\nGenerate category tree for language " . uc ($wp) . ", tag = '$categorytag'") ;

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

  $file_categories_all = $path_out_categories."CategoryOverview_".uc($wp)."_Complete.htm" ;
  $file_categories_top = $path_out_categories."CategoryOverview_".uc($wp)."_Concise.htm" ;
  $file_categories_tip = $path_out_categories."CategoryOverview_".uc($wp)."_Main.htm" ;

  open (CATEGORIES_ALL_HTML, ">", $file_categories_all) ;
  open (CATEGORIES_TOP_HTML, ">", $file_categories_top) ;
  open (CATEGORIES_TIP_HTML, ">", $file_categories_tip) ;

  my $out_page_title    = $out_category_tree ;
  my $out_page_subtitle = uc ($wp) . " - <a href='" . $out_urls {$wp} . "'>" . $out_languages {$wp} . "</a>" ;
  my $out_html_title    = $out_page_title ;
  my $out_explanation   = $out_explanation_categories ;
  if ($out_follow_links ne "")
  { $out_explanation .= "<br>" . $out_follow_links ; }

  my $out_button_switch_all = &btn (" " . $out_categories_complete, "CategoryOverview_".uc($wp)."_Complete.htm") ;
  my $out_button_switch_top = &btn (" " . $out_categories_concise,  "CategoryOverview_".uc($wp)."_Concise.htm") ;
  my $out_button_switch_tip = &btn (" " . $out_categories_main,     "CategoryOverview_".uc($wp)."_Main.htm") ;

  if ((! $mode_wp) || ($lines_read < 500))
  {
    $out_button_switch_all = "&nbsp;" ;
    $out_button_switch_top = "&nbsp;" ;
    $out_button_switch_tip = "&nbsp;" ;
  }

  my ($out_page_subtitle_all, $out_page_subtitle_top, $out_page_subtitle_tip) ;
  my $out_msg = "" ;

  $out_html = "" ;
  if ($singlewiki)
  {
    $out_page_subtitle_all = $out_categories_complete ;
    $out_page_subtitle_top = $out_categories_concise ;
    $out_page_subtitle_tip = $out_categories_main ;
  }
  else
  {
    $out_page_subtitle_all = $out_page_subtitle . " - $out_categories_complete" ;
    $out_page_subtitle_top = $out_page_subtitle . " - $out_categories_concise" ;
    $out_page_subtitle_tip = $out_page_subtitle . " - $out_categories_main" ;
  }

  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle_all, $out_explanation,
                      "", "", $out_button_switch_top, "", $out_msg) ;
  print CATEGORIES_ALL_HTML $out_html ;
  $out_html = "" ;
  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle_top, $out_explanation,
                      "", "", $out_button_switch_tip, "", $out_msg) ;
  print CATEGORIES_TOP_HTML $out_html ;
  $out_html = "" ;
  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle_tip, $out_explanation,
                      "", "", $out_button_switch_all, "", $out_msg) ;
  print CATEGORIES_TIP_HTML $out_html ;
  $out_html = "" ;

  if ($mode_wb)
  { $base = "http://$wp.wikibooks.org/wiki/" ; }
  if ($mode_wk)
  { $base = "http://$wp.wiktionary.org/wiki/" ; }
  if ($mode_wn)
  { $base = "http://$wp.wikinews.org/wiki/" ; }
  if ($mode_wp)
  { $base = "http://$wp.wikipedia.org/wiki/" ; }
  if ($mode_wq)
  { $base = "http://$wp.wikiquote.org/wiki/" ; }
  if ($mode_ws)
  { $base = "http://$wp.wikisource.org/wiki/" ; }
  if ($mode_wv)
  { $base = "http://$wp.wikiversity.org/wiki/" ; }
  if ($mode_wx)
  {
    if ($wp eq "sources")
    { $base = "http://wikisource.org/wiki/" ; }
    if ($wp eq "meta")
    { $base = "http://meta.wikimedia.org/wiki/" ; }
    if ($wp eq "sep11")
    { $base = "http://sep11.wikipedia.org/wiki/" ; }
    if ($wp eq "foundation")
    { $base = "http://wikimediafoundation.org/wiki/" ; }
    if ($wp eq "commons")
    { $base = "http://commons.wikipedia.org/wiki/" ; }
    if ($wp =~ /(\w\w+)(wikimedia)/)
    { $base = "http://$1.wikimedia.org/wiki/" ; }
    if ($wp eq "species")
    { $base = "http://species.wikipedia.org/wiki/" ; }
    if ($wp eq "mediawiki")
    { $base = "http://www.mediawiki.org/wiki/" ; }
  }
  if ($wikimedia)
  { $base =~ s/_/-/g ; } # e.g. zh-min-nan
  if ($base_nowikimedia ne "")
  { $base = $base_nowikimedia ; }

# my $topcat = "Top categories: " . $#TopCategories ;
# print CATEGORIES_ALL_HTML "$topcat<p>\n" ;
# print CATEGORIES_TOP_HTML "$topcat<p>\n" ;
# print CATEGORIES_TIP_HTML "$topcat<p>\n" ;

  foreach $cat (keys %Supercategories)
  {
    $CategoryDepthShort {$cat} = 999 ;
    &ScanSupercategories (1, $cat, $cat, "") ;
    $CategoryIdShort {$cat} = ++$catid ;
  }

  @TopCategories = sort { $CategoryDepthTop {$b} <=> $CategoryDepthTop {$a} } @TopCategories ;

  @CategoriesCircularRef = sort keys %CategoriesCircularRef ;
  if ($#CategoriesCircularRef > -1)
  { print CATEGORIES_ALL_HTML "<font color='A00000'><b>Circular references found! <a href='#CircRef'>=></a></b></font><p>\n" ; }

  foreach $topcat (@TopCategories)
  {
     if ($mode_wp)
     {
       if ($CategoryDepthTop {$topcat} < 1)
       { next ; }
     }

#    if (@ArticlesPerCategory {$topcat} > 20)
#    {
      # print CATEGORIES_ALL_TXT  "\n\n1 \[\[:Category:$topcat\|$topcat\]\] " . (0+@ArticlesPerCategory {$topcat}) . "\n" ;
      # print CATEGORIES_TOP_TXT  "\n\n1 \[\[:Category:$topcat\|$topcat\]\] " . (0+@ArticlesPerCategory {$topcat}) . "\n" ;
      # print CATEGORIES_TIP_TXT  "\n\n1 \[\[:Category:$topcat\|$topcat\]\] " . (0+@ArticlesPerCategory {$topcat}) . "\n" ;
      print CATEGORIES_ALL_HTML "<ul><li>1 <a href='base$categorytag\:" . encode_url ($topcat) . "'>" . &EncodeHtml ($topcat) .
                                "</a> " . (0+$ArticlesPerCategory {$topcat}) . "\n" ;
      print CATEGORIES_TOP_HTML "<ul><li>1 <a href='$base$categorytag\:" . encode_url ($topcat) . "'>" . &EncodeHtml ($topcat) .
                                "</a> " . (0+$ArticlesPerCategory {$topcat}) . "\n" ;
      print CATEGORIES_TIP_HTML "<ul><li>1 <a href='$base$categorytag\:" . encode_url ($topcat) . "'>" . &EncodeHtml ($topcat) .
                                "</a> " . (0+$ArticlesPerCategory {$topcat}) . "\n" ;
      &ListSubcategories ($wp, "All", 1, $topcat, "") ;
      print CATEGORIES_ALL_HTML "</ul>\n<p>\n" ;
      print CATEGORIES_TOP_HTML "</ul>\n<p>\n" ;
      print CATEGORIES_TIP_HTML "</ul>\n<p>\n" ;
#    }
  }

  if ($#CategoriesCircularRef > -1)
  {
#   print CATEGORIES_ALL_HTML "<a name='CircRef'></a><font color='#A00000'>" . ($#CategoriesCircularRef+1) . " circular references found:<p>\n" ;
    print CATEGORIES_ALL_HTML "<hr><p><a name='CircRef'></a><h2>Circular references found</h2><p><font color='#A00000'>\n" ;
    foreach $circref (@CategoriesCircularRef)
    {
#     $circref =~ s/\|/&gt;/g ;
#     print CATEGORIES_ALL_HTML &EncodeHtml ($circref) . "<br>\n" ;
      $circref =~ s/\s*\|\s*/\|/g ;
      my @categories = split ('\|', $circref) ;
      my $prefix = "<p>" ;
      foreach my $cat (@categories)
      {
        print CATEGORIES_ALL_HTML "$prefix <a href='$base$categorytag\:" . encode_url ($cat) . "'>". &EncodeHtml ($cat) . "</a>" ;
        $prefix = " > " ;
      }
      print CATEGORIES_ALL_HTML "<br>\n" ;
    }
#   print CATEGORIES_ALL_HTML "</font>\n" ;
    print CATEGORIES_ALL_HTML "</font>\n" ;
  }

  if ($out_categories_redirects ne "")
  { $out_categories_redirects = "<br>$out_categories_redirects" ; }
  $out_html = "<hr><p><small>$out_categories_templates$out_categories_redirects</small>" ;
  print CATEGORIES_ALL_HTML $out_html ;
  print CATEGORIES_TOP_HTML $out_html ;
  print CATEGORIES_TIP_HTML $out_html ;

  $out_html = '' ;
  &GenerateColophon ($false, $false) ;
  print CATEGORIES_ALL_HTML $out_html ;
  print CATEGORIES_TOP_HTML $out_html ;
  print CATEGORIES_TIP_HTML $out_html ;

  print CATEGORIES_ALL_HTML "</body>\n</html>\n" ;
  print CATEGORIES_TOP_HTML "</body>\n</html>\n" ;
  print CATEGORIES_TIP_HTML "</body>\n</html>\n" ;
  &Log (" in " . ddhhmmss (time - $timestart). ", max depth: $maxdepthfound\n") ;

#  foreach $cat (sort keys %ArticlesPerCategory)
#  {
#    print CATEGORIES "\n" ;
#    &ListSupercategories (1, $cat, "") ;
#  }

  # close CATEGORIES_ALL_TXT ;
  # close CATEGORIES_TOP_TXT ;
  # close CATEGORIES_TIP_TXT ;
  close CATEGORIES_ALL_HTML ;
  close CATEGORIES_TOP_HTML ;
  close CATEGORIES_TIP_HTML ;

  if ($#TopCategories == -1)
  {
    unlink $file_categories_all ;
    unlink $file_categories_top ;
    unlink $file_categories_tip ;
  }
  if (($lines_read < 500) || (! $mode_wp))
  { unlink $file_categories_top ; }

  undef (@TopCategories) ;
  undef (%CategoriesListed) ;
  undef (%Subcategories) ;
  undef (%Supercategories) ;
  undef (%CategoryAnchors) ;
  undef (%ArticlesPerCategory) ;
  undef (%CategoriesCollected) ;
  undef (%CategoryDepthTop) ;
  undef (%CategoryDepthShort) ;
  undef (%CategoryIdShort) ;
  undef (%CategoryPathShort) ;
  undef (%CategoriesCircularRef) ;
  undef (%CategoriesCircularRefStop)
}

sub ListSupercategories
{
  my $depth = shift ;
  my $cat  = shift ;
  my $path = (shift) . "|$cat"  ;
  $path =~ s/^\|// ;

  my $supercats = $Supercategories {$cat} ;
# &Log2 ("Depth $depth, Cat '$cat', Supercats '$supercats'\n") ;

  if ($depth > $maxdepth)
  { $supercats = "" ; }

  if ($supercats eq "")
  { print CATEGORIES "$path\n" ; }
  else
  {
    my @supercats = split ('\|', $supercats) ;
    foreach my $supercat (@supercats)
    { &ListSupercategories (++$depth, $supercat, $path) ; }
  }
}

sub ScanSupercategories
{
  my $depth  = shift ;
  my $catorg = shift ;
  my $cat    = shift ;
  my $path   = "$cat | " . (shift)   ;
  $path =~ s/^\s*\|\s*// ;
# &Log2 (" Cat $catorg Depth $depth, Path $path\n") ;

  my $supercats = $Supercategories {$cat} ;

  if ($depth > $maxdepth)
  { $supercats = "" ; }

  if ($depth < $CategoryDepthShort {$catorg})
  {
    if ($supercats eq "")
    {
      $CategoryDepthShort {$catorg} = $depth ;
      $CategoryPathShort  {$catorg} = $path ;
      if ($depth > $CategoryDepthTop {$cat})
      { $CategoryDepthTop {$cat} = $depth ; }
    # &Log2 (">>> Cat $catorg Depth $depth, Path $path\n") ;
    }
    else
    {
      $depth++ ;
      my @supercats = split ('\|', $supercats) ;
      foreach my $supercat (@supercats)
      {
        if ($CategoriesCircularRefStop {$supercat} > 0)
        { next ; }
        if (index ($path, "| $supercat |") == -1)
        { &ScanSupercategories ($depth, $catorg, $supercat, $path) ; }
        else
        {
          my $path_circ = "| $supercat | $path" ;
          # &Log2 ("Circular reference 1: path = '$path_circ', supercat = '$supercat'\n") ;
          $path_circ =~ s/([^\w\\])/\\$1/g ;
          $supercat  =~ s/([^\w\\])/\\$1/g ;
          $path_circ =~ s/^.*\| ($supercat \| $supercat) \|.*$/$1/ ;
          $path_circ =~ s/^.*\| ($supercat \|.*?\| $supercat) \|.*$/$1/ ;
          $path_circ =~ s/\\([^\w\\])/$1/g ;
          $supercat  =~ s/\\([^\w\\])/$1/g ;
          $CategoriesCircularRef {$path_circ}++ ;
          $CategoriesCircularRefStop {$supercat}++ ;
        }
      }
    }
  }
}

sub CollectCategories
{
  my $depth = shift ;
  my $cat  = shift ;

  if ($CategoriesCollected {$cat} ne "")
  { return ; }

  $CategoriesCollected {$cat} ++ ;

  my $supercats = $Supercategories {$cat} ;
  if ($depth > $maxdepth)
  { $supercats = "" ; }
  if ($supercats ne "")
  {
    my @supercats = split ('\|', $supercats) ;
    foreach my $supercat (@supercats)
    { &CollectCategories (++$depth, $supercat) ; }
  }
}

sub ListSubcategories
{
  my $wp    = shift ;
  my $mode  = shift ;
  my $depth = shift ;
  my $cat   = shift ;
  my $path  = (shift) . " \| $cat" ;

  $path =~ s/^\s*\|\s*// ;

#  my $indent = "- " x ($depth-1) ;
#  $indent =~ s/- - /- = /g ;
  my $indent  = ":" x ($depth-1) . " $depth ";
  my $indent2 = ":" x ($depth) . " " . ($depth+1) . " ";

  my $istop = $false ;
  my $istip = $false ;
  if ($depth <= 3)
  { $istop = $true ; }
  if ($depth <= 2)
  { $istip = $true ; }

  $CategoriesListed {$cat} = $path ;
  $CategoryAnchors  {$cat} = $anchors ;

  if ($CategoriesCircularRefStop {$cat} > 0)
  {
    # &Log2 ("\nBreak on circular referenced depth $depth path $path\ncategory '$cat' \n") ;
    return ;
  }
  my $subcats = $Subcategories {$cat} ;
  if ($subcats eq "")
  { return ; }
  $subcats = substr ($subcats,1) ;

  if ($depth > $maxdepthfound)
  { $maxdepthfound = $depth ; }

  if (++$depth > $maxdepth)
  { return ; }

  if ($mode ne "Top")
  { print CATEGORIES_ALL_HTML "<ul><li>\n" ; }
  if ($istop) # (($istop) && ($depth < 4))
  { print CATEGORIES_TOP_HTML "<ul><li>\n" ; }
  if ($istip) # (($istip) && ($depth < 3))
  { print CATEGORIES_TIP_HTML "<ul><li>\n" ; }

  my @subcats = split ('\|', $subcats) ;

  my $txt1 = "" ;
  my $txt2 = " $depth" ;
  my $txt3 = "" ;
  my $txt4 = " $depth" ;

  foreach my $subcat (@subcats)
  {
    my $pages      = $ArticlesPerCategory {$subcat} ;
    my $path_short = $CategoryPathShort   {$subcat} ;
    $path_short    =~ s/\s*\|\s*$// ;

    # &Log2 ("0 '$subcat'\n1 '$path_short'\n2 '$path'\n\n") ;

    $anchor = "" ;
    if (substr ($path_short, 0, length ($path)) eq $path)
    {
      $catid = $CategoryIdShort {$subcat} ;
      $anchor = "<a name='$catid'></a>" ;
    }

    # $txt1 = "" ;
    # $txt2 = "" ;
    # $txt3 = "" ;
    # $txt4 = "" ;
    # if ($depth == 4)
    # { $txt1 = " &#47; " ; }
    # else
    # { $txt2 = " <li>$depth" ; }
    # if ($depth == 3)
    # { $txt3 = " &#47; " ; }
    # else
    # { $txt4 = " <li>$depth" ; }

    $subcat2 = $subcat ;
    $subcat2 =~ s/\s/&nbsp;/g ;
    $line_all = "$anchor<li>$depth <a href=\'$base$categorytag\:" . encode_url ($subcat) . "'>" .
                 &EncodeHtml ($subcat2) . "</a>:&nbsp;$pages\n" ;
    $line_top = "$txt1$anchor$txt2 <a href=\'$base$categorytag\:" . encode_url ($subcat) . "'>" .
                 &EncodeHtml ($subcat2) . "</a>:&nbsp;$pages\n" ;
    $line_tip = "$txt3$anchor$txt4 <a href=\'$base$categorytag\:" . encode_url ($subcat) . "'>" .
                 &EncodeHtml ($subcat2) . "</a>:&nbsp;$pages\n" ;

    if ($pages > 0)
    {
      if ($mode ne "Top")
      {
        # print CATEGORIES_ALL_TXT "$indent\[\[:Category:$subcat\|$subcat\]\] $pages\n" ;
        print CATEGORIES_ALL_HTML $line_all ;
      }
      if ($istop)
      {
        # print CATEGORIES_TOP_TXT "$indent\[\[:Category:$subcat\|$subcat\]\] $pages\n" ;
        print CATEGORIES_TOP_HTML $line_top ;
      }
      if ($istip)
      { print CATEGORIES_TIP_HTML $line_tip ; }
    }
    else
    {
      if ($mode ne "Top")
      {
        # print CATEGORIES_ALL_TXT "$indent\[\[:Category:$subcat\|$subcat\]\]\n" ;
        print CATEGORIES_ALL_HTML $line_all ;
      }
      if ($istop)
      {
        # print CATEGORIES_TOP_TXT "$indent\[\[:Category:$subcat\|$subcat\]\]\n" ;
        print CATEGORIES_TOP_HTML $line_top ;
      }
      if ($istip)
      {
        # print CATEGORIES_TOP_TXT "$indent\[\[:Category:$subcat\|$subcat\]\]\n" ;
        print CATEGORIES_TIP_HTML $line_tip ;
      }
    }
    if ($depth == 4)
    {
      $txt2 = "" ;
      $txt1 = " &#47; " ;
    }
    else
    { $txt1 = "<li>" ; }
    if ($depth == 3)
    {
      $txt4 = "" ;
      $txt3 = " &#47; " ;
    }
    else
    { $txt3 = "<li>" ; }

    if (defined ($Subcategories {$subcat}))
    {
      if (substr ($path_short, 0, length ($path)) ne $path)
      {
        if ($mode ne "Top")
        {
          # print CATEGORIES_ALL_TXT "$indent2 > $path_short\n" ;
          print CATEGORIES_ALL_HTML "<ul><li>" . ($depth+1) . " &gt; <a class='in' href='\#" . $CategoryIdShort {$subcat} . "'>" .
                                     &EncodeHtml ($path_short) . "</a>\n</ul>" ;
        }

        if (index ($path, "| $subcat |") == -1)
        { &ListSubcategories ($wp, "Top", $depth, $subcat, $path) ; }
        #else
        #{ &Log2 ("Circular reference: path = '$path', cat = '$subcat'\n") ; }
      }
      else
      {
        if (index ($path, "| $subcat |") == -1)
        { &ListSubcategories ($wp, $mode, $depth, $subcat, $path) ; }
        #else
        #{ &Log2 ("Circular reference: path = '$path', cat = '$subcat'\n") ; }
      }
    }
  }
  if ($mode ne "Top")
  { print CATEGORIES_ALL_HTML "</ul>\n" ; }
  if ($istop) # (($istop) && ($depth < 4))
  { print CATEGORIES_TOP_HTML "</ul>\n" ; }
  if ($istip) # (($istip) && ($depth < 3))
  { print CATEGORIES_TIP_HTML "</ul>\n" ; }
}


1;
