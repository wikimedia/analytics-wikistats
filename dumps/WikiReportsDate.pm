#!/usr/bin/perl

# blank_text_after -> EzLib use as blank_text_after ("15/01/2009",$text) ;

sub GetDateTime
{
  my $time = shift ;
  my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  my $language_save = $language ;
  $language = "en" ;
  my $timestamp = sprintf ("%2d:%02d ", $hour, $min) . &GetDate ($time) ;
  $timestamp =~ s/\&nbsp\;/ /g ;
  $language = $language_save ;
  return ($timestamp) ;
}

sub GetDate
{
  my $time = shift ;
  if (! defined ($time))
  { return ("?") ; }

  no warnings qw (qw) ; # skip "Possible attempt to put comments into ..."

  my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst) = localtime($time) ;
  my @weekdays_ast = qw (Domingu Llunes Martes Mi&eacute;rcoles Xueves Vienres S&aacute;badu) ;
  my @months_ast   = qw (Xineru Febreru Marzu Abril Mayu Xunu Xunetu
                         Agostu Setiembre Ochobre Payares Avientu) ;

  my @weekdays_br =  ('Sul', 'Lun', 'Meurzh', 'Merc&#146;her', 'Yaou', 'Gwener', 'Sadorn') ;
  my @months_br   = qw (Genver C&#146;hwevrer Meurzh Ebrel Mae Mezheven Gouere
                        Eost Gwengolo Here Du Kerzu) ;

  my @weekdays_ca = qw (Diumenge Dilluns Dimarts Dimecres Dijous Divendres Dissabte) ;
  my @months_ca   = qw (Gener Febrer Mar&ccedil; Abril Maig Juny Juliol
                        Agost Setembre Octubre Novembre Desembre) ;

  my @weekdays_cs = qw (ned&#283;le pond&#283;lí úterý st&#345;eda &#269;tvrtek pátek sobota) ;
  my @months_cs   = qw (ledna února b&#345;ezna dubna kv&#283;tna &#269;ervna &#269;ervence srpna zá&#345;í &#345;íjna listopadu prosince) ;

  my @weekdays_da = qw (s&oslash;ndag mandag tirsdag onsdag torsdag fredag l&oslash;rdag) ;
  my @months_da   = qw (januar februar marts april maj juni juli
                        august september oktober november december) ;

  my @weekdays_de = qw (Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag) ;
  my @months_de   = qw (Januar Februar M&auml;rz April Mai Juni Juli
                        August September Oktober November Dezember) ;

  my @weekdays_en = qw (Sunday Monday Tuesday Wednesday Thursday Friday Saturday) ;
  my @months_en   = qw (January February March April May June July
                        August September October November December) ;

  my @weekdays_eo = qw (diman&#265;o lundo mardo merkredo &#309;audo vendredo sabato) ;
  my @months_eo   = qw (januaro februaro marto aprilo majo junio julio
                        a&#365;gusto septembro oktobro novembro decembro) ;

  my @weekdays_es = qw (domingo lunes martes mi&eacute;rcoles jueves viernes s&aacute;bado) ;
  my @months_es   = qw (enero febrero marzo abril mayo junio julio
                        agosto septiembre octubre noviembre diciembre) ;

  my @weekdays_fr = qw (dimanche lundi mardi mercredi jeudi vendredi samedi) ;
  my @months_fr   = qw (janvier f&eacute;vrier mars avril mai juin juillet
                        ao&ucirc; septembre octobre novembre d&eacute;cembre ) ;


  my @weekdays_he = qw(&#1512;&#1488;&#1513;&#1493;&#1503; &#1513;&#1504;&#1497;
                       &#1513;&#1500;&#1497;&#1513;&#1497; &#1512;&#1489;&#1497;&#1506;&#1497;
                       &#1495;&#1502;&#1497;&#1513;&#1497; &#1513;&#1497;&#1513;&#1497;
                       &#1513;&#1489;&#1514;) ;

  my @months_he   = qw (&#1497;&#1504;&#1493;&#1488;&#1512; &#1508;&#1489;&#1512;&#1493;&#1488;&#1512;
                        &#1502;&#1512;&#1509; &#1488;&#1508;&#1512;&#1497;&#1500; &#1502;&#1488;&#1497;
                        &#1497;&#1493;&#1504;&#1497; &#1497;&#1493;&#1500;&#1497;
                        &#1488;&#1493;&#1490;&#1493;&#1505;&#1496;
                        &#1505;&#1508;&#1496;&#1502;&#1489;&#1512;
                        &#1488;&#1493;&#1511;&#1496;&#1493;&#1489;&#1512;
                        &#1504;&#1493;&#1489;&#1502;&#1489;&#1512; &#1491;&#1510;&#1502;&#1489;&#1512;) ;

  my @weekdays_it = qw (Domenica Luned&igrave; Marted&igrave; Mercoled&igrave; Gioved&igrave; Vederd&igrave; Sabato) ;
  my @months_it   = qw (Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio
                        Agosto Settembre Ottobre Novembre Dicembre);

  my @weekdays_ja = qw (&#26085;&#26332; &#26376;&#26332; &#28779;&#26332;
                        &#27700;&#26332; &#26408;&#26332; &#37329;&#26332; &#22303;&#26332;);
  my @months_ja   = qw (1&#26376; 2&#26376; 3&#26376; 4&#26376; 5&#26376; 6&#26376; 7&#26376;
                        8&#26376; 9&#26376; 10&#26376; 11&#26376; 12&#26376;);

  my @weekdays_nl = qw (zondag maandag dinsdag woensdag donderdag vrijdag zaterdag) ;
  my @months_nl   = qw (januari februari maart april mei juni juli
                        augustus september oktober november december) ;

  my @weekdays_nn = qw (sundag m&aring;ndag tysdag onsdag torsdag fredag laurdag);
  my @months_nn   = qw (januar februar mars april mai juni juli
                        august september oktober november desember);

  my @weekdays_pl = qw (Niedziela Poniedzia&lstroke;ek Wtorek &Sacute;roda Czwartek Pi&aogonek;tek Sobota);
  my @months_pl   = qw (Stycze&#324; Luty Marzec Kwiecie&nacute; Maj Czerwiec Lipiec
                        Sierpie&#324; Wrzesie&nacute; Pa&#378;dziernik Listopad Grudzie&nacute;);

  my @weekdays_pt = qw (Domingo Segunda-feira Ter&ccedil;a-feira Quarta-feira
                        Quinta-feira Sexta-feira S&aacute;bado);

  my @months_pt   = qw (janeiro fevereiro mar&ccedil;o abril maio junho julho
                        agosto setembro outubro novembro dezembro);

  my @weekdays_ro = qw (Duminica Luni Marti Miercuri Joi Vineri S&#244;mbata);
  my @months_ro   = qw (Ianuarie Februarie Martie Aprilie Mai Iunie Iulie
                        August Septembrie Octombrie Noiembrie Decemberie);

  my @weekdays_ru = qw (&#1042;&#1086;&#1089;&#1082;&#1088;&#1077;&#1089;&#1077;&#1085;&#1100;&#1077; &#1055;&#1086;&#1085;&#1077;&#1076;&#1077;&#1083;&#1100;&#1085;&#1080;&#1082; &#1042;&#1090;&#1086;&#1088;&#1085;&#1080;&#1082; &#1057;&#1088;&#1077;&#1076;&#1072; &#1063;&#1077;&#1090;&#1074;&#1077;&#1088;&#1075; &#1055;&#1103;&#1090;&#1085;&#1080;&#1094;&#1072; &#1057;&#1091;&#1073;&#1073;&#1086;&#1090;&#1072;);
  my @months_ru   = qw (&#1071;&#1085;&#1074;&#1072;&#1088;&#1100; &#1060;&#1077;&#1074;&#1088;&#1072;&#1083;&#1100; &#1052;&#1072;&#1088;&#1090; &#1040;&#1087;&#1088;&#1077;&#1083;&#1100; &#1052;&#1072;&#1081; &#1048;&#1102;&#1085;&#1100; &#1048;&#1102;&#1083;&#1100;
                        &#1040;&#1074;&#1075;&#1091;&#1089;&#1090; &#1057;&#1077;&#1085;&#1090;&#1103;&#1073;&#1088;&#1100; &#1054;&#1082;&#1090;&#1103;&#1073;&#1088;&#1100; &#1053;&#1086;&#1103;&#1073;&#1088;&#1100; &#1044;&#1077;&#1082;&#1072;&#1073;&#1088;&#1100;);

  my @weekdays_sl = qw (nedelja ponedeljek torek sreda &#267;etrtek petek sobota);
  my @months_sl   = qw (januar februar marec april maj junij julij
                        avgust september oktober november december);

  my @weekdays_sr = qw(&#1053;&#1077;&#1076;&#1077;&#1113;&#1072; &#1055;&#1086;&#1085;&#1077;&#1076;&#1077;&#1113;&#1072;&#1082; &#1059;&#1090;&#1086;&#1088;&#1072;&#1082; &#1057;&#1088;&#1077;&#1076;&#1072; &#1063;&#1077;&#1090;&#1074;&#1088;&#1090;&#1072;&#1082; &#1055;&#1077;&#1090;&#1072;&#1082; &#1057;&#1091;&#1073;&#1086;&#1090;&#1072;);

  my @months_sr   = qw (&#1032;&#1072;&#1085;&#1091;&#1072;&#1088; &#1060;&#1077;&#1088;&#1073;&#1088;&#1091;&#1072;&#1088; &#1052;&#1072;&#1088;&#1090; &#1040;&#1087;&#1088;&#1080;&#1083; &#1052;&#1072;&#1112; &#1032;&#1091;&#1085;&#1080; &#1032;&#1091;&#1083;&#1080;
                        &#1040;&#1074;&#1075;&#1091;&#1089;&#1090; &#1057;&#1077;&#1087;&#1090;&#1077;&#1084;&#1073;&#1072;&#1088; &#1054;&#1082;&#1090;&#1086;&#1073;&#1072;&#1088; &#1053;&#1086;&#1074;&#1077;&#1084;&#1073;&#1072;&#1088; &#1044;&#1077;&#1094;&#1077;&#1084;&#1073;&#1072;&#1088;);

  my @weekdays_sv = qw (s&ouml;ndag m&acirc;ndag tisdag onsdag torsdag fredag l&ouml;rdag);

  my @months_sv   = qw (januari februari mars april maj juni juli
                        augusti september oktober november december);

  my @weekdays_wa = qw (dimegne londi m&aring;rdi mierkidi djudi v&eacute;nrdi semdi);

  my @months_wa   = qw (djanv&icirc; fevr&icirc; m&aring;ss avri may djun djulete
                        awousse setimbe oct&ocirc;be n&ocirc;vimbe decimbe);

  my @weekdays_zh = qw (&#26143;&#26399;&#26085; &#26143;&#26399;&#19968; &#26143;&#26399;&#20108;
                        &#26143;&#26399;&#19977; &#26143;&#26399;&#22235; &#26143;&#26399;&#20116;
                        &#26143;&#26399;&#20845;);
  my @months_zh   = @months_ja ;

  use warnings qw (qw) ;

  if ($language eq "ja")
  { return ($weekdays_ja[$wday] . " " .
           (1900 + $year). "&#24180;" .
           $months_ja[$mon] .
           $day . "&#26085;&#12288;") ; }
  elsif ($language eq "zh")
  { return ($weekdays_zh[$wday] . " " .
           (1900 + $year). "&#24180;" .
           $months_zh[$mon] .
           $day . "&#26085;&#12288;") ; }
  elsif ($language eq "ast")
  {
    if (($mon == 3) || ($mon == 7) || ($mon == 9) || ($mon == 11))
    { return ($weekdays_ast[$wday] . "&nbsp;" . $day . "&nbsp;d'" . lcfirst($months_ast[$mon]) . "&nbsp;del&nbsp;" . (1900 + $year)) ; }
    else
    { return ($weekdays_ast[$wday] . "&nbsp;" . $day . "&nbsp;de " . lcfirst($months_ast[$mon]) . "&nbsp;del&nbsp;" . (1900 + $year)) ; }
  }

  elsif ($language eq "br")
  { return ($weekdays_br[$wday] . "&nbsp;" . $day . "&nbsp;" . $months_br[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "ca")
  {
    if (($mon == 3) || ($mon == 6) || ($mon == 7))
    { return ($weekdays_ca[$wday] . "&nbsp;" . $day . "&nbsp;d'" . $months_ca[$mon] . "&nbsp;del&nbsp;" . (1900 + $year)) ; }
    else
    { return ($weekdays_ca[$wday] . "&nbsp;" . $day . "&nbsp;de " . $months_ca[$mon] . "&nbsp;del&nbsp;" . (1900 + $year)) ; }
  }

  elsif ($language eq "cs")
  { return ($weekdays_cs[$wday] . "&nbsp;" . $day . ".&nbsp;" . $months_cs[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "da")
  { return ($weekdays_da[$wday] . "&nbsp;" . $day . ".&nbsp;" . $months_da[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "de")
  { return ($weekdays_de[$wday] . "&nbsp;" . $day . "&nbsp;" . $months_de[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "eo")
  { return ($weekdays_eo[$wday] . "&nbsp;" . $day . "&nbsp;" . $months_eo[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "es")
  { return ($weekdays_es[$wday] . "&nbsp;" . $day . "&nbsp;de " . $months_es[$mon] . "&nbsp;de " . (1900 + $year)) ; }

  elsif ($language eq "fr")
  { return ($weekdays_fr[$wday] . "&nbsp;" . $day . ",&nbsp;" . $months_fr[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "he")
  { return ($weekdays_he[$wday] . "&nbsp;" . $day . "&nbsp;&#1489;" . $months_he[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "it")
  { return ($weekdays_it[$wday] . "&nbsp;" . $day . "&nbsp;" . $months_it[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "nl")
  { return ($weekdays_nl[$wday] . "&nbsp;" . $day . "&nbsp;" . $months_nl[$mon] . "&nbsp;" . (1900 + $year)) ; }
# Language format in Portuguese: Segunda-feira, 16 de agosto de 2004

  elsif ($language eq "nn")
  { return ($weekdays_nn[$wday] . "&nbsp;" . $day . ".&nbsp;" . $months_nn[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "pl")
  { return ($weekdays_pl[$wday] . "&nbsp;" . (1900 + $year) . "&nbsp;" . $months_pl[$mon] . "&nbsp;" . $day) ; }

  elsif ($language eq "pt")
  { return ($weekdays_pt[$wday] . ",&nbsp;" . $day . "&nbsp;de " . $months_pt[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "ro")
  { return ($weekdays_ro[$wday] . "&nbsp;" . $day . "&nbsp;" . $months_ro[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "ru")
  { return ($day . ".&nbsp;" . $months_ru[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "sl")
  { return ($weekdays_sl[$wday] . ",&nbsp;" . $day . ".&nbsp;" . $months_sl[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "sr")
  { return ($weekdays_sr[$wday] . "&nbsp;" . $day . ".&nbsp;" . $months_sr[$mon] . "&nbsp;" . (1900 + $year)) . "." ; }

  elsif ($language eq "sv")
  { return ($weekdays_sv[$wday] . "&nbsp;" . $day . "&nbsp;" . $months_sv[$mon] . "&nbsp;" . (1900 + $year)) ; }

  elsif ($language eq "wa")
  {
    if ($day == 1)
    { return ($weekdays_wa[$wday] . "&nbsp;" . "1&icirc;&nbsp;d'&nbsp;" . $months_wa[$mon] . "&nbsp;" . (1900 + $year)) ; }
    elsif (($day == 2) || ($day == 3) || ($day == 20) || ($day == 22) || ($day == 23))
    { return ($weekdays_wa[$wday] . "&nbsp;" . $day . "&nbsp;d'&nbsp;" . $months_wa[$mon] . "&nbsp;" . (1900 + $year)) ; }
    elsif (($mon ==4) || ($mon == 8) || ($mon == 10))
    { return ($weekdays_wa[$wday] . "&nbsp;" . $day . "&nbsp;d'&nbsp;" . $months_wa[$mon] . "&nbsp;" . (1900 + $year)) ; }
    else
    { return ($weekdays_wa[$wday] . "&nbsp;" . $day . "&nbsp;di&nbsp;" . $months_wa[$mon] . "&nbsp;" . (1900 + $year)) ; }
  }

  else
  { return ($weekdays_en[$wday] . "&nbsp;" . $months_en[$mon] . "&nbsp;" .  $day . ",&nbsp;" . (1900 + $year)) ; }
}

sub GetDateShort
{
  my $date    = shift ;
  if (! defined ($date))
  { return ("?") ; }

  my $showday = shift ;
  my $year    = substr ($date,6,4) ;
  my $month   = substr ($date,0,2) ;
  my $day     = substr ($date,3,2) ;

  if($day < days_in_month ($year, $month))
  { $showday = $true ; }

# 2003&#24180;8&#26376;18&#26085;&#12288;
  if (($language eq "ja") || ($language eq "zh"))
  { return ($year. "&#24180;" .
            &GetMonthShort($month) .
           ($showday ? ($day . "&#26085;"):"")) ; }
  elsif (($language eq "nl") or ($language eq "de") or
         ($language eq "fr") or ($language eq "eo") or
         ($language eq "wa") or ($language eq "nn"))
  { return (($showday ? ($day . "&nbsp;"):"") . &GetMonthShort($month) . "&nbsp;" . $year) ; }
  elsif ($language eq "cs")
  { return (($showday ? ($day . ".&nbsp;"):"") . &GetMonthShort($month) . ".&nbsp;" . $year) ; }
  else
  { return (&GetMonthShort($month) . "&nbsp;" .  ($showday ? ($day . ",&nbsp;"):""). $year) ; }
}

sub GetDateShort2
{
  my $month          = shift ;
  my $ignore_dumpday = shift ;
  my $year  = 2000 ;
  if (! defined ($month))
  { return ("?") ; }
  while ($month > 12)
  { $month -= 12 ; $year ++ ; }

  my $date ;

  if (($year != $dumpyear) || ($month != $dumpmonth) || $ignore_dumpday)
  { $date = sprintf ("%02d/%02d/%04d", $month, days_in_month ($year, $month), $year) ; }
  else
  { $date = sprintf ("%02d/%02d/%04d", $dumpmonth, $dumpday, $dumpyear) ; }

  return &GetDateShort ($date, $false) ;
}

sub GetDateShort2En
{
  my $month = shift ;
  my $language_save = $language ;
  $language = "en" ;
  my $date = &GetDateShort2 ($month)  ;
  $language = $language_save ;
  return ($date) ;
}


sub GetMonthShort
{
  my $month = shift ;
  if (! defined ($month))
  { return ("?") ; }

  while ($month > 12) { $month -= 12 ; }
  $month-- ;

  no warnings qw (qw) ; # skip "Possible attempt to put comments into ..."

  my @months_ast  = qw (Xin Feb Mar Abr May Xun Xnt
                        Ago Set Oc Pay Avi);
  my @months_br   = qw (Gen C&#146;hwe Meu Ebr Mae Mez Goue
                        Eos Gwe Her Du Kzu);
  my @months_ca   = qw (Gen Feb Mar Abr Mai Jun Jul
                        Ago Set Oct Nov Dec);
  my @months_cs   = qw (1 2 3 4 5 6 7 8 9 10 11 12);
  my @months_da   = qw (jan feb mar apr maj jun jul
                        aug sep okt nov dec);
  my @months_de   = qw (Jan Feb M&auml;r Apr Mai Jun Jul
                        Aug Sep Okt Nov Dez);
  my @months_eo   = qw (jan feb mrt apr maj jun jul
                        a&#365;g sep okt nov dec);
  my @months_en   = qw (Jan Feb Mar Apr May Jun Jul
                        Aug Sep Oct Nov Dec);
  my @months_es   = qw (Ene Feb Mar Abr May Jun Jul
                        Ago Sep Oct Nov Dic);
  my @months_fr   = qw (jan f&eacute;v mar avr mai juin juil
                        ao&uuml;t sep oct nov d&eacute;c );
  my @months_he   = qw (&#1497;&#1504;&#1493; &#1508;&#1489;&#1512; &#1502;&#1512;&#1509;
                        &#1488;&#1508;&#1512; &#1502;&#1488;&#1497; &#1497;&#1493;&#1504;&#1497;
                        &#1497;&#1493;&#1500;&#1497; &#1488;&#1493;&#1490; &#1505;&#1508;&#1496;
                        &#1488;&#1493;&#1511; &#1504;&#1493;&#1489; &#1491;&#1510;&#1502;);
  my @months_it   = qw (Gen Feb Mar Apr Mag Giu Lug
                        Ago Set Ott Nov Dec);
  my @months_ja   = qw (1&#26376; 2&#26376; 3&#26376; 4&#26376; 5&#26376; 6&#26376; 7&#26376;
                        8&#26376; 9&#26376; 10&#26376; 11&#26376; 12&#26376;);
  my @months_nl   = qw (jan feb mrt apr mei jun jul
                        aug sep okt nov dec) ;
  my @months_nn   = qw (Jan Feb Mar Apr Mai Jun Jul
                        Aug Sep Okt Nov Des);
  my @months_pl   = qw (Sty Lut Mar Kwi Maj Cze Lip
                        Sie Wrz Pa&#378; Lis Gru);
  my @months_pt   = qw (jan fev mar abr mai jun jul
                        ago set out nov dez);
  my @months_ro   = qw (Ian Feb Mar Apr Mai Iun Iul
                        Aug Sep Oct Nov Dec);
  my @months_ru   = qw (&#1071;&#1085;&#1074; &#1060;&#1077;&#1074; &#1052;&#1072;&#1088; &#1040;&#1087;&#1088; &#1052;&#1072;&#1081; &#1048;&#1102;&#1085; &#1048;&#1102;&#1083;
                        &#1040;&#1074;&#1075; &#1057;&#1077;&#1085; &#1054;&#1082;&#1090; &#1053;&#1086;&#1103; &#1044;&#1077;&#1082;);
  my @months_sl   = qw (jan feb mar apr maj jun jul
                        avg sep okt nov dec);
  my @months_sr   = qw (&#1032;&#1072;&#1085; &#1060;&#1077;&#1073; &#1052;&#1072;&#1088; &#1040;&#1087;&#1088; &#1052;&#1072;&#1112; &#1032;&#1091;&#1085; &#1032;&#1091;&#1083;
                        &#1040;&#1074;&#1075; &#1057;&#1077;&#1087; &#1054;&#1082;&#1090; &#1053;&#1086;&#1074; &#1044;&#1077;&#1094;);
  my @months_sv   = qw (jan feb mar apr maj jun jul
                        aug sep okt nov dec);
  my @months_wa   = qw (dja fev m&acirc;s avr may djn djl
                        awo set oct n&ocirc;v dec);
  my @months_zh   = @months_ja ;

  use warnings qw (qw) ;

     if ($language eq "ast") { return ($months_ast[$month]) }
  elsif ($language eq "br")  { return ($months_br[$month]) }
  elsif ($language eq "ca")  { return ($months_ca[$month]) }
  elsif ($language eq "cs")  { return ($months_cs[$month]) }
  elsif ($language eq "da")  { return ($months_da[$month]) }
  elsif ($language eq "de")  { return ($months_de[$month]) }
  elsif ($language eq "eo")  { return ($months_eo[$month]) }
  elsif ($language eq "es")  { return ($months_es[$month]) }
  elsif ($language eq "fr")  { return ($months_fr[$month]) }
  elsif ($language eq "he")  { return ($months_he[$month]) }
  elsif ($language eq "it")  { return ($months_it[$month]) }
  elsif ($language eq "ja")  { return ($months_ja[$month]) }
  elsif ($language eq "nl")  { return ($months_nl[$month]) }
  elsif ($language eq "nn")  { return ($months_nn[$month]) }
  elsif ($language eq "pl")  { return ($months_pl[$month]) }
  elsif ($language eq "pt")  { return ($months_pt[$month]) }
  elsif ($language eq "ro")  { return ($months_ro[$month]) }
  elsif ($language eq "ru")  { return ($months_ru[$month]) }
  elsif ($language eq "sl")  { return ($months_sl[$month]) }
  elsif ($language eq "sr")  { return ($months_sr[$month]) }
  elsif ($language eq "sv")  { return ($months_sv[$month]) }
  elsif ($language eq "wa")  { return ($months_wa[$month]) }
  elsif ($language eq "zh")  { return ($months_zh[$month]) }
  else                       { return ($months_en[$month]) }
}

sub GetDateEnglish
{
  my $time = shift ;
  $language_prev = $language ;
  $language = "en" ;
  my $date = &GetDate ($time) ;
  $language = $language_prev ;
  return ($date) ;
}

1;

