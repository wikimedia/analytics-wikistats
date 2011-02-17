#!/usr/bin/perl

sub dmy
{
  my $datetime = shift ;
  (my $day, my $month, my $year) = (localtime ($datetime))[3,4,5] ;
  return (sprintf ("%02d/%02d/%02d", $day, $month + 1, $year - 100)) ;
}

sub i2KM
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 100000000)
  {
    $v = sprintf ("%.0f",($v / 1000000)) . "&nbsp;" . $out_million ;
    $v =~ s/(\d+?)(\d\d\d[^\d])/$1,$2/ ;
  }
  elsif ($v >= 1000000)
  { $v = sprintf ("%.1f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 10000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  elsif ($v >= 1000)
  { $v = sprintf ("%.1f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

sub i2KM2
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 1000000)
  { $v = sprintf ("%.0f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

sub i2KM3
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 1000000)
  { $v = sprintf ("%.1f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

sub i2KM4
{
  my $v = &i2KM3(shift) ;

  # $v =~ s/&nbsp;//g ;
  # $v =~ s/ //g ;
  return ($v) ;
}

sub i2KM5
{
  my $v = &i2KM3(shift) ;
  $v =~ s/&nbsp;//g ;
  return ($v) ;
}

sub i2K2
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 1000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

sub i2KbMb
{
  my $v = shift ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 10 * $Gb)
  { $v = sprintf ("%.0f",($v / $Gb)) . "&nbsp;" . $out_gigabytes ; }
  elsif ($v >= $Gb)
  { $v = sprintf ("%.1f",($v / $Gb)) . "&nbsp;" . $out_gigabytes ; }
  elsif ($v >= 10 * $Mb)
  { $v = sprintf ("%.0f",($v / $Mb)) . "&nbsp;" . $out_megabytes ; }
  elsif ($v >= $Mb)
  { $v = sprintf ("%.1f",($v / $Mb)) . "&nbsp;" . $out_megabytes ; }
  elsif ($v >= 10 * $Kb)
  { $v = sprintf ("%.0f",($v / $Kb)) . "&nbsp;" . $out_kilobytes  ; }
  elsif ($v >= $Kb)
  { $v = sprintf ("%.1f",($v / $Kb)) . "&nbsp;" . $out_kilobytes  ; }
  else
  { $v .= "&nbsp;" . $byte ; }
  return ($v) ;
}

sub mmddyyyyDec
{
  my $date = shift ;
  my $m = substr ($date,0,2) ;
  my $d = substr ($date,3,2) ;
  my $y = substr ($date,6,4) ;
  $d-- ;
  if ($d < 1)
  {
    $m-- ;
    if ($m < 1)
    { $m = 12 ; $y -- ; }
    $d = days_in_month ($y,$m) ;
  }
  $date = sprintf ("%02d/%02d/%04d", $m, $d, $y) ;
  return ($date) ;
}

sub mmddyyyyInc
{
  my $date = shift ;
  my $m = substr ($date,0,2) ;
  my $d = substr ($date,3,2) ;
  my $y = substr ($date,6,4) ;
  $d++ ;
  if ($d > days_in_month ($y,$m))
  {
    $d = 1 ;
    $m++ ;
    if ($m > 12)
    { $m = 1 ; $y ++ ; }
  }
  $date = sprintf ("%02d/%02d/%04d", $m, $d, $y) ;
  return ($date) ;
}

sub ddmmyy2mmddyy
{
  my $date = shift ;
  return (substr ($date,3,2) . "/" . substr ($date,0,2) . "/" . substr ($date,6,2)) ;
}

sub mmddyyyy2ddmmyy
{
  my $date = shift ;
  return (substr ($date,3,2) . "/" . substr ($date,0,2) . "/" . substr ($date,8,2)) ;
}

sub mmddyyyy2ddmmyyyy
{
  my $date = shift ;
  return (substr ($date,3,2) . "/" . substr ($date,0,2) . "/" . substr ($date,6,4)) ;
}

sub mmddyyyy2mmddyy
{
  my $date = shift ;
  return (substr ($date,0,2) . "/". substr ($date,3,2) . "/" . substr ($date,8,2)) ;
}

sub m2mmddyyyy
{
  my $month = shift ;
  my $year  = 2000 ;
  while ($month > 12)
  { $month -= 12 ; $year ++ ; }
  if (($year != $dumpyear) || ($month != $dumpmonth))
  { return (sprintf ("%02d/%02d/%04d", $month, days_in_month ($year, $month), $year)) ; }
  else
  { return (sprintf ("%02d/%02d/%04d", $dumpmonth, $dumpday, $dumpyear)) ; }
}

# code year,month as monthes since january 2000 (1 byte)
sub yyyymm2b
{
  my $year  = shift ;
  my $month = shift ;
  my $monthes = ($year - 2000) * 12 + $month ;
  return (chr ($monthes)) ;
}

# determine monthes since january 2000
sub yyyymmdd2i
{
  my $yyyymmdd = shift ;
  my $year  = substr ($yyyymmdd,0,4) ;
  my $month = substr ($yyyymmdd,4,2) ;
  my $monthes = ($year - 2000) * 12 + $month ;
  return ($monthes) ;
}

sub csv
{
  my $s = shift ;
  if (defined ($s))
  {
    $s =~ s/^\s+// ;
    $s =~ s/\s+$// ;
  }
  if ((! defined ($s)) || ($s eq ""))
  { $s = 0 ; } # not all fields are numeric, but those that aren't are never empty
  return ($s . ",") ;
}

sub csv2
{
  my $s = shift ;
  if (defined ($s))
  {
    $s =~ s/^\s+// ;
    $s =~ s/\s+$// ;
  }
  if ((! defined ($s)) || ($s eq "") || ($s == 0))
  { $s = "" ; } # not all fields are numeric, but those that aren't are never empty
  return ($s . ",") ;
}

sub csv3
{
  my $s = shift ;
  return (($s+0) . ",") ;
}

sub csvkey_date
{
  (my $language, my $date) = split (",", (shift)) ;
  return (substr ($date,6,4) . substr ($date,0,2) . substr ($date,3,2)) ;
}

sub csvkey_date2
{
  (my $language, my $date) = split (",", (shift)) ;
  return ($date) ;
}

sub csvkey_lang_date
{
  (my $language, my $date) = split (",", (shift)) ;
  return ($language . substr ($date,6,4) . substr ($date,0,2) . substr ($date,3,2)) ;
}

sub csvkey_lang_timegm
{
  my ($language, $timegm, @fields) = split (",", (shift)) ;
  return ($language . (9999999999 - $timegm)) ;
}

sub csvkey_date_size
{
  my ($language, $date) = split (",", (shift)) ;
  return (substr ($date,6,4) . substr ($date,0,2) . substr ($date,3,2) . $sort_languages {$language}) ;
}

sub csvkey_name_edits
{
  my ($language, $edits, $rank, $delta, $name) = split (",", (shift)) ;
  return ($name . sprintf ("%9d", 999999999 - $edits)) ;
}

sub csvkey_chapter
{
  my $chapter = uc (shift) ;
  $chapter =~ s/^\:// ;
  $chapter =~ s/^\_*\-*\_*// ;
  return ($chapter) ;
}

sub csvkey_chapters
{
  my ($book, $chapters) = split (",", (shift)) ;
  return ($chapters) ;
}

sub csvkey_edits
{
  my ($book, $chapters, $edits) = split (",", (shift)) ;
  return ($edits) ;
}

sub csvkey_size
{
  my ($book, $chapters, $edits, $size) = split (",", (shift)) ;
  return ($size) ;
}

sub csvkey_authors
{
  my ($book, $chapters, $edits, $size, $words, $authors) = split (",", (shift)) ;
  return ($authors) ;
}

sub abort
{
  &Log (("\n***** " . (shift) . " *****\n") . "\nExecution aborted.") ;
  close "FILE_LOG" ;
  exit ;
}

sub format
{
  my $value  = shift ;
  my $column = shift ;
  if (($column =~ /[EFLN-U]/) || (($column =~ /A/) && $pageviews))
  { $value = &i2KM ($value) ; }
  elsif ($column =~ /[M]/)
  { $value = &i2KbMb ($value) ; }
  elsif ($column eq "")
  {
    $value =~ s/^(\d)(\d\d\d)$/$1,$2/ ;
    $value =~ s/^(\d\d)(\d\d\d)$/$1,$2/ ;
    $value =~ s/^(\d\d\d)(\d\d\d)$/$1,$2/ ;
    $value =~ s/^(\d)(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
    $value =~ s/^(\d\d)(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
    $value =~ s/^(\d\d\d)(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
  }
  elsif ($column =~ /[X]/)
  {
    if ($value > 1000)
    { $value = &i2KM ($value) ; }
    elsif ($value < 0.1)
    { $value = sprintf ("%.2f", $value) ; }
    elsif ($value < 3)
    { $value = sprintf ("%.1f", $value) ; }
    else
    { $value = sprintf ("%.0f", $value) ; }
  }
  elsif ($value == 0)
  { $value = "&nbsp;" ; }

  if ($value =~ /\d\./)
  {
    if ($out_decimal_separator ne ".")
    { $value =~ s/\./$out_decimal_separator/ ; }
  }

  return ($value) ;
}

# try to translate html tags into ascii codes
# convert hexadecimal notation to decimal notation
# convert codes into ascii when decimal value < 256
sub HtmlToAscii {

  my $html = shift ;

  my $value = $html ;
  my $ndx ;

  if ($html =~ /\&\#x[\d]{2,10}\;/)
  {
    $value =~ s/\&\#x([\d]{2,10})\;/$1/ ;
    $html = "\&\#" . hex ("0x" . $value) . ";"  ;
  }
  if ($html =~ /\&\#[\d]{2,5}\;/)
  {
    $value =~ s/\&\#([\d]{2,5})\;/$1/ ;
    if ($value < 32)
    { return ("?") ; }
    elsif ($value < 256)
    { return (chr ($value)) ; }
    else
    { return ($html) ; }
  }
  else
  {
    $ndx = index ($AsciiHtmlSymbols, $html) ;
    if ($ndx != -1)
    { return (substr ($AsciiHtmlSymbols,$ndx-1,1)) ; }
    else
    { return ("?") ; }
  }
}

sub SetConversionTables
{
  foreach my $symbol (&HTMLsymbols)
  {
    my ($ascii, $html, $html2) = split(/\s\s*/,$symbol);
     if ((index ($html, '?') == -1) && # stores &...; codes only
         (index ($html, '#') == -1))   # convert numeric codes directly
     { $AsciiHtmlSymbols .= $ascii . $html ; }
  }

  foreach my $symbol (&EsperantoCodesXbased)
  {
    my ($html, $ascii) = split(/\s\s*/,$symbol);
    $EsperantoCodesX {$html} = $ascii ;
  }
}

# used to convert symbolic html codes into ascii
# decimal html tags (3rd column) not used anymore, kept for info only
sub HTMLsymbols {
        return (
        "\!  ?          &#33;",
        "\"  &quot;     &#34;",
        "\"  &ldquo;    &#34;", # approximation
        "\"  &rdquo;    &#34;", # approximation
        "\#  ?          &#35;",
        "$   ?          &#36;",
        "%   ?          &#37;",
# "&   &amp;      &#38;",
        "'   ?          &#39;",
        "'   &apos;     &#39;",
        "'   &lsquo;    &#39;", # approximation
        "'   &rsquo;    &#39;", # approximation
        "(   ?          &#40;",
        ")   ?          &#41;",
        "*   ?          &#42;",
        "+   ?          &#43;",
        ",   ?          &#44;",
        "-   ?          &#45;",
        "-   &ndash;    &#45;", # approximation
        "-   &mdash;    &#45;", # approximation
        ".   ?          &#46;",
        "/   ?          &#47;",
        ":   ?          &#58;",
        ";   ?          &#59;",
        "<   &lt;       &#60;",
        "=   ?          &#61;",
        ">   &gt;       &#62;",
        "?   ?          &#63;",
        "©   &copy;     &#64;",
        "[   ?          &#91;",
        "\\  ?          &#92;",
        "]   ?          &#93;",
        "^   ?          &#94;",
        "_   ?          &#95;",
        "`   ?          &#96;",
        "{   ?          &#123;",
        "|   ?          &#124;",
        "}   ?          &#125;",
        "~   ?          &#126;",
        "    ?          &#160;",
        "¡   &iexcl;    &#161;",
        "¢   &cent;     &#162;",
        "£   &pound;    &#163;",
        "¤   &curren;   &#164;",
        "¥   &yen;      &#165;",
        "¦   &brvbar;   &#166;",
        "§   &sect;     &#167;",
        "¨   &uml;      &#168;",
        "©   &copy;     &#169;",
        "ª   &ordf;     &#170;",
        "«   &laquo;    &#171;",
        "¬   &not;      &#172;",
        "­   &shy;      &#173;",
        "®   &reg;      &#174;",
        "¯   &macr;     &#175;",
        "°   &deg;      &#176;",
        "±   &plusmn;   &#177;",
        "²   &sup2;     &#178;",
        "³   &sup3;     &#179;",
        "´   &acute;    &#180;",
        "µ   &micro;    &#181;",
        "¶   &para;     &#182;",
        "·   &middot;   &#183;",
        "¸   &cedil;    &#184;",
        "¹   &sup1;     &#185;",
        "º   &ordm;     &#186;",
        "»   &raquo;    &#187;",
        "¼   &frac14;   &#188;",
        "½   &frac12;   &#189;",
        "¾   &frac34;   &#190;",
        "¿   &iquest;   &#191;",
        "®   &reg;",
        "À   &Agrave;   &#192;",
        "Á   &Aacute;   &#193;",
        "Â   &Acirc;    &#194;",
        "Ã   &Atilde;   &#195;",
        "Ä   &Auml;     &#196;",
        "Å   &Aring;    &#197;",
        "Æ   &AElig;    &#198;",
        "Ç   &Ccedil;   &#199;",
        "È   &Egrave;   &#200;",
        "É   &Eacute;   &#201;",
        "Ê   &Ecirc;    &#202;",
        "Ë   &Euml;     &#203;",
        "Ì   &Igrave;   &#204;",
        "Í   &Iacute;   &#205;",
        "Î   &Icirc;    &#206;",
        "Ï   &Iuml;     &#207;",
        "Ð   &ETH;      &#208;",
        "Ñ   &Ntilde;   &#209;",
        "Ò   &Ograve;   &#210;",
        "Ó   &Oacute;   &#211;",
         "Ô   &Ocirc;    &#212;",
        "Õ   &Otilde;   &#213;",
        "Ö   &Ouml;     &#214;",
        "×   &times;    &#215;",
        "Ø   &Oslash;   &#216;",
        "Ù   &Ugrave;   &#217;",
        "Ú   &Uacute;   &#218;",
        "Û   &Ucirc;    &#219",
        "Ü   &Uuml;     &#220;",
        "Ý   &Yacute;   &#221;",
        "Þ   &THORN;    &#222;",
        "ß   &szlig;    &#223;",
        "à   &agrave;   &#224;",
        "á   &aacute;   &#225;",
        "â   &acirc;    &#226;",
        "ã   &atilde;   &#227;",
        "ä   &auml;     &#228;",
        "å   &aring;    &#229;",
        "æ   &aelig;    &#230;",
        "ç   &ccedil;   &#231;",
        "è   &egrave;   &#232;",
        "é   &eacute;   &#233;",
        "ê   &ecirc;    &#234;",
        "ë   &euml;     &#235;",
        "ì   &igrave;   &#236;",
        "í   &iacute;   &#237;",
        "î   &icirc;    &#238;",
        "ï   &iuml;     &#239;",
        "ð   &eth;      &#240;",
        "ñ   &ntilde;   &#241;",
        "ò   &ograve;   &#242;",
        "ó   &oacute;   &#243;",
        "ô   &ocirc;    &#244;",
        "õ   &otilde;   &#245;",
        "ö   &ouml;     &#246;",
        "÷   &divide;   &#247;",
        "ø   &oslash;   &#248;",
        "ù   &ugrave;   &#249;",
        "ú   &uacute;   &#250;",
        "û   &ucirc;    &#251;",
        "ü   &uuml;     &#252;",
        "ý   &yacute;   &#253;",
        "þ   &thorn;    &#254;",
        "ÿ   &yuml;     &#255;")
}

sub EsperantoCodesXbased {
        return (
        "&#265; cx", # c+circumflex  Esperanto x-based notation
        "&#264; CX", # C+circumflex  Esperanto x-based notation
        "&#285; gx", # g+circumflex  Esperanto x-based notation
        "&#284; GX", # G+circumflex  Esperanto x-based notation
        "&#293; hx", # h+circumflex  Esperanto x-based notation
        "&#292; HX", # H+circumflex  Esperanto x-based notation
        "&#309; jx", # j+circumflex  Esperanto x-based notation
        "&#308; JX", # J+circumflex  Esperanto x-based notation
        "&#349; sx", # s+circumflex  Esperanto x-based notation
        "&#348; SX", # S+circumflex  Esperanto x-based notation
        "&#365; ux", # u+breve       Esperanto x-based notation
        "&#364; UX") # U+breve       Esperanto x-based notation
}

sub ConvertUnicode
{
  my $string  = shift ;
  my $unicode = ($string =~ m/[\xc0-\xdf][\x80-\xbf]|
                              [\xe0-\xef][\x80-\xbf]{2}|
                              [\xf0-\xf7][\x80-\xbf]{3}/x) ;

  # unicode -> html character codes &#nnnn;
  if ($unicode)
  { $string =~ s/([\x80-\xFF]+)/unicode_to_html/ge ; }
  return ($string) ;
}

sub EncodeHtml
{
  my $text = shift ;
  $text = convert_unicode ($text) ;
  $text =~ s/([\<\>\'\"])/"\&\#" . ord($1) . "\;"/ge ;
  $text =~ s/\n/<br>/g ;
  return ($text) ;
}

sub hsv_to_rgb2 {
  my($h, $s, $v) = @_;
  $v = $v >= 1.0 ? 255 : $v * 256;

  # Grey image.
  return((int($v)) x 3) if ($s == 0);

  $h /= 60;
  my $i = int($h);
  my $f = $h - int($i);
  my $p = int($v * (1 - $s));
  my $q = int($v * (1 - $s * $f));
  my $t = int($v * (1 - $s * (1 - $f)));
  $v = int($v);

     if($i == 0) { return($v, $t, $p); }
  elsif($i == 1) { return($q, $v, $p); }
  elsif($i == 2) { return($p, $v, $t); }
  elsif($i == 3) { return($p, $q, $v); }
  elsif($i == 4) { return($t, $p, $v); }
  else           { return($v, $p, $q); }
}

sub hsv_to_rgb {

   my $h = shift;
   my $s = shift;
   my $v = shift;

   # limit this to h values between 0 and 360 and s/v values
   # between 0 and 1

   unless (defined($h) && defined($s) && defined($v) &&
          $h >= 0 && $s >= 0 && $v >= 0 &&
          $h <= 360 && $s <= 1 && $v <= 1) {
     return (undef, undef, undef);
   }

   my $r;
   my $g;
   my $b;

   # 0.003 is less than 1/255; use this to make the floating point
   # approximation of zero, since the resulting rgb values will
   # normally be used as integers between 0 and 255.  Feel free to
   # change this approximation of zero to something else, if this
   # suits you.

   if ($s < 0.003) {
     $r = $g = $b = $v;
   }
   else {

     $h /= 60;
     my $sector = int($h);
     my $fraction = $h - $sector;

     my $p = $v * (1 - $s);
     my $q = $v * (1 - ($s * $fraction));
     my $t = $v * (1 - ($s * (1 - $fraction)));

        if ($sector == 0) { $r = $v; $g = $t; $b = $p; }
     elsif ($sector == 1) { $r = $q; $g = $v; $b = $p; }
     elsif ($sector == 2) { $r = $p; $g = $v; $b = $t; }
     elsif ($sector == 3) { $r = $p; $g = $q; $b = $v; }
     elsif ($sector == 4) { $r = $t; $g = $p; $b = $v; }
     else                 { $r = $v; $g = $p; $b = $q; }
   }

   # Convert the r/g/b values to all be between 0 and 255; use the
   # ol' 0.003 approximation again, with the same comment as above.

   $r = ($r < 0.003 ? 0.0 : $r * 255);
   $g = ($g < 0.003 ? 0.0 : $g * 255);
   $b = ($b < 0.003 ? 0.0 : $b * 255);

   return ($r, $g, $b);
 }

sub hsv2rgb
{
  my($h,$s,$v,$p,$q,$color) ;
  ($h, $s, $v) = @_;
  ($v,$p,$q) = hsv_to_rgb ($h,$s,$v) ;
  $color = "\#" . sprintf ("%02X", int($v)) . sprintf ("%02X", int($p)) . sprintf ("%02X", int($q)) ;
  return ($color) ;
}



sub hsl2rgb
{
  my ($h, $s, $l) = @_;
#print "h=$h, s=$s l=$l\n" ;
  if ($s == 0)           # HSL values = 0 ÷ 1
  {
     $r = $l * 255 ;      # RGB results = 0 ÷ 255
     $g = $l * 255 ;
     $b = $l * 255 ;
  }
  else
  {
     if ($l < 0.5)
     { $var_2 = $l * ( 1 + $s ) ; }
     else
     { $var_2 = ( $l + $s ) - ( $s * $l ) }

     $var_1 = 2 * $l - $var_2 ;

     $r = 255 * hue2rgb ($var_1, $var_2, $h + ( 1 / 3 )) ;
     $g = 255 * hue2rgb ($var_1, $var_2, $h) ;
     $b = 255 * hue2rgb ($var_1, $var_2, $h - ( 1 / 3 )) ;
  }
  my $color = "\#" . sprintf ("%02X", $r) . sprintf ("%02X", $g) . sprintf ("%02X", $b) ;
  return ($color) ;
}
# http://www.easyrgb.com/math.php?MATH=M19#text19
sub hue2rgb
{
  my ($v1, $v2, $vH) = @_;
  if ($vH < 0) { $vH += 1 ; }
  if ($vH > 1) { $vH -= 1 ; }
  if ((6 * $vH) < 1) { return ($v1 + ( $v2 - $v1 ) * 6 * $vH) ; }
  if ((2 * $vH) < 1) { return ($v2) ; }
  if ((3 * $vH) < 2) { return ($v1 + ( $v2 - $v1 ) * ( ( 2 / 3 ) - $vH ) * 6) ; }
  return ($v1)
}

sub log10
{
  my $n = shift;
  return log($n)/log(10);
}

sub IpAddress
{
  my $user = shift ;
  if (($user eq "Emme.pi.effe") || ($user eq ".mau.") || # exceptions on it:
      ($user eq "Crochet.david.bot") || # exception on en: (Wikiversity)
      ($user eq "A.R. Mamduhi") ||      # exception  on eo:
      ($user =~ /Rob.Mocking/i))        # exception  on qo: (non Wikimedia)
  { return ($false) ; }

  if (($user =~ m/[^\.]{2,}\.[^\.]{2,}\.[^\.]{2,4}$/) ||
      ($user =~ m/^\d+\.\d+\.\d+\./) ||
      ($user =~ m/\.com$/i))
  { return ($true) ; }
  else
  { return ($false) ; }
}


1 ;
