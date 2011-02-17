#!/usr/bin/perl
my $timegm_2001_01_01 = timegm (0,0,0,1, 1-1, 2001-1900) ;

# unicode issues
# some functions pack data in binary format to minimize memory requirements
# perl 5.6+ treats data as unicode values by default
# hence substr ($x,$y,1) might very well return a 3 bytes value, from an offset greater than $x bytes
# I tried different bincode options but somehow could not get perl to handle data one byte at a time
# when some byte sequences happened to be valid high order utf-8 sequences
# tried :raw :bytes etc but for some reason could not get it right
# so finally dedided to pack data using hex 7F and lower so no character sequences can be confused with unicode

sub dmy
{
  my $datetime = shift ;
  (my $day, my $month, my $year) = (localtime ($datetime))[3,4,5] ;
  return (sprintf ("%02d/%02d/%02d", $day, $month + 1, $year - 100)) ;
}

sub mmddyyyy
{
  my $datetime = shift ;
  if ($datetime == 0)
  { return "n.a." ; }
  (my $day, my $month, my $year) = (localtime ($datetime))[3,4,5] ;
  return (sprintf ("%02d/%02d/%04d", $month + 1, $day, $year + 1900)) ;
}

# code time as months since January 2000 (2 bytes) and minutes since start of month (3 bytes)
sub t2bbbbb
{
  my $time = shift ;
  (my $min, my $hour, my $day, my $month, my $year) = (localtime $time) [1,2,3,4,5] ;
  $month += 1 ;
  $year  += 1900 ;
  return (&yyyymm2bb ($year, $month) . &ddhhmm2bbb ($day, $hour, $min)) ;
}

# code days,hours,minutes as minutes since start of month (3 bytes)
sub ddhhmm2bbb
{
  my $dd = shift ;
  my $hh = shift ;
  my $mm = shift ;
  my $int = ($dd - 1) * 1440 + ($hh*60) + $mm ;
  return (&i2bbb ($int)) ;
}

# decode minutes since start of month (3 bytes) back to days,hours,minutes
sub bbb2ddhhmm
{
  my $bbb = shift ;
  my $int = &bbb2i ($bbb) ;
  my $mm  = $int % 60 ;
  $int    = int ($int / 60 );
  my $hh  = $int % 60 ;
  my $dd  = int (($int - $hh) / 24) + 1 ;
  return (sprintf ("%02d%02d%02d", $dd, $hh, $mm)) ;
}

# convert months since January 2000 (2 byte) and minutes since start of month (3 bytes)
# to days since January 1 2001
sub bbbbb2d
{
  $bbbbb = shift ;
  $m  = &bb2i  (substr ($bbbbb,0,2)) ;
  $mm = &bbb2i (substr ($bbbbb,2,3)) ;
  $days = $days_since_begin_2001 {$m} ;
  $days += int ($mm / 1440) + 1 ;
}

sub d2mmddyyyy
{
  my $days = shift ;
  my ($dummy1,$dummy2,$dummy3,$day,$month,$year) = gmtime ($timegm_2001_01_01 + ($days-1)*24*60*60) ;
  return sprintf ("%02d/%02d/%04d", $month+1, $day, $year+1900) ;
}

# code year,month as months since january 2000 (2 bytes)
sub yyyymm2bb
{
  my $year  = shift ;
  my $month = shift ;
  my $months = ($year - 2000) * 12 + $month ;
  return (&i2bb ($months)) ;
}

# decode months since january 2000 (2 bytes) back to year,month
sub bb2yymm
{
  my $months  = &bb2i (shift) ;
  my $year    = int (($months - 1) / 12) ;
  my $month   = $months - $year * 12 ;
  return (sprintf ("%02d%02d", $year, $month)) ;
}

# decode months since january 2000 (2 bytes) back to year,month
sub bb2mmyyyy
{
  my $months  = &bb2i (shift) ;
  my $year    = int (($months - 1) / 12) ;
  my $month   = $months - $year * 12 ;
  return (sprintf ("%02d/%04d", $month, 2000+$year)) ;
}

# decode months since january 2000 back to year,month
sub i2yymm
{
  my $months  = shift ;
  my $year    = int (($months - 1) / 12) ;
  my $month   = $months - $year * 12 ;
  return (sprintf ("%02d%02d", $year, $month)) ;
}

# pack integer into 4 bytes (binary), range = 0 - 7F7F7F7F = 0 - 268435455
# see also unicode issues above
sub i2bbbb
{
   my $i = shift ;
   die "Function i2bbbb failed: integer ($i) exceeds max (268435455)" if ($int > 268435455) ;
   my $b4  = $i % 128 ;
   my $b3  = int ($i / 128) % 128 ;
   my $b2  = int ($i / (128 * 128)) % 128 ;
   my $b1  = int ($i / (128 * 128 * 128)) ;
   return (chr($b1).chr($b2).chr($b3).chr($b4)) ;
}

# pack integer into 3 bytes (binary), range = 0 - 7F7F7F = 0 - 2097151
sub i2bbb
{
   my $i = shift ;
   die "Function i2bbb failed: integer ($i) exceeds max (2097151)" if ($i > 2097151) ;
   my $b3  = $i % 128 ;
   my $b2  = int ($i / 128) % 128 ;
   my $b1  = int ($i / (128 * 128)) ;
   return (chr($b1).chr($b2).chr($b3)) ;
}

# pack integer into 2 bytes (binary), range = 0 - 7F7F = 0 - 16383
sub i2bb
{
   my $i = shift ;
   die "Function i2bb failed: integer ($i) exceeds max (16383)" if ($i > 16383) ;
   my $b2  = $i % 128 ;
   my $b1  = int ($i / 128) % 128 ;
   return (chr($b1).chr($b2)) ;
}

# pack integer into 1 byte (binary), range = 0 - 7F = 0 - 127
sub i2b
{
   my $i = shift ;
   die "Function i2b failed: integer ($i) exceeds max (127)" if ($i > 127) ;
   return (chr($i)) ;
}

# unpack 4 bytes (binary) back to integer
sub bbbb2i
{
  my $bbbb = shift ;
  return (ord (substr ($bbbb,0,1)) * 128 * 128 * 128 +
          ord (substr ($bbbb,1,1)) * 128 * 128 +
          ord (substr ($bbbb,2,1)) * 128 +
          ord (substr ($bbbb,3,1))) ;
}

# unpack 3 bytes (binary) back to integer
sub bbb2i
{
  my $bbb = shift ;
  return (ord (substr ($bbb,0,1)) * 128 * 128 +
          ord (substr ($bbb,1,1)) * 128 +
          ord (substr ($bbb,2,1))) ;
}

# unpack 2 bytes (binary) back to integer
sub bb2i
{
  my $bb = shift ;
  return (ord (substr ($bb,0,1)) * 128 +
          ord (substr ($bb,1,1))) ;
}

# unpack 1 bytes (binary) back to integer
# completely trivial function to make calling code symmetric, what a waste :)
sub b2i
{
  my $b = shift ;
  return (ord ($b)) ;
}

sub i2KM
{
  my $v = shift ;
  if ($v > 1000000)
  { $v = sprintf ("%.1f",($v / 1000000)) . " M" ; }
  elsif ($v > 1000)
  { $v = sprintf ("%.0f",($v / 1000)) . " K" ; }
  return ($v) ;
}

sub i2KbMb
{
  my $v = shift ;
  if ($v > $Mb)
  { $v = sprintf ("%.1f",($v / $Mb)) . " Mb" ; }
  else
  { $v = sprintf ("%.0f",($v / $Kb)) . " Kb" ; }
  return ($v) ;
}

sub ddmmyy2mmddyy
{
  my $date = shift ;
  return (substr ($date,3,2) . "/" . substr ($date,0,2) . "/" . substr ($date,6,2)) ;
}

sub ddmmyy2mmddyyyy
{
  my $date = shift ;
  return (substr ($date,3,2) . "/" . substr ($date,0,2) . "/" . (2000 + substr ($date,6,2))) ;
}

sub mmddyy2ddmmyy
{
  my $date = shift ;
  return (substr ($date,3,2) . "/" . substr ($date,0,2) . "/" . substr ($date,6,2)) ;
}

sub csv
{
  my $s = shift ;
  return (&csv2($s) . ",") ;
}

sub csv2
{
  my $s = shift ;
  if (defined ($s))
  {
    $s =~ s/^\s+// ;
    $s =~ s/\s+$// ;
    $s =~ s/\,/&#44;/g ;
  }
  if ((! defined ($s)) || ($s eq ""))
  { $s = 0 ; } # not all fields are numeric, but those that aren't are never empty
  return ($s) ;
}

sub csv3
{
  my $s = shift ;
  $s =~ s/\n/\\n/gos ;
  return (&csv ($s)) ;
}

#sub csvkey_lang_date
#{
#  my ($language, $date) = split (",", shift) ;
#  return ($language . substr ($date,6,4) . substr ($date,0,2) . substr ($date,3,2)) ;
#}

#sub csvkey_lang_type_date
#{
#  my ($language, $date, $type) = split (",", (shift)) ;
#  return ($language . $type . substr ($date,6,4) . substr ($date,0,2) . substr ($date,3,2)) ;
#}

#sub csvkey_lang_edits
#{
#  my ($language, $edits_namespace_a) = split (",", (shift)) ;
#  return ($language . sprintf ("%08d", $edits_namespace_a)) ;
#}

sub csvkey_lang_date_val10
{
  my ($language, $date, @values) = split (",", (shift)) ;
  return ($language . substr ($date,6,4) . substr ($date,0,2) . substr ($date,3,2) . sprintf ("%010d", $values[9])) ;
}

sub csvkey_edits_first
{
  my $record = shift ;
  my $edits_namespace_a = substr ($record,0,8) ;
  my $first             = substr ($record,48,10) ;
  return (sprintf ("%08d", (99999999 - $edits_namespace_a)) . sprintf ("%10d", $first)) ;
}

sub csvkey_editsprev_first
{
  my $record = shift ;
  my $edits_namespace_a      = substr ($record,0,8) ;
  my $edits_prev_namespace_0 = substr ($record,10,8) ;
  my $first                  = substr ($record,48,10) ;
  return (sprintf ("%08d", (99999999 - ($edits_namespace_a - $edits_prev_namespace_0))) . sprintf ("%10d", $first)) ;
}

sub csvkey_lang_rank_first1
{
  my ($language,
      $edits_namespace_a, $edits_recent_namespace_a,  $edits_namespace_x, $edits_recent_namespace_x,
      $rank, $rank2, $first, $ago, $user) = split (",", (shift)) ;

  return ($language . sprintf ("%05d", $rank) . sprintf ("%05d", (99999 - $ago))) ;
}

sub csvkey_lang_rank_first2
{
  my ($language, $name,
      $edits_namespace_a, $edits_recent_namespace_a,  $edits_namespace_x, $edits_recent_namespace_x,
      $rank, $rank2, $first, $ago) = split (",", (shift)) ;

  return ($language . sprintf ("%05d", $rank) . sprintf ("%05d", (99999 - $ago))) ;
}

sub csvkey_lang_rank_first3
{
  my ($language, $name, $edits_namespace_a, $edits_namespace_x, $rank, $rank2, $first, $ago) = split (",", (shift)) ;
  return ($language . sprintf ("%05d", $rank) . sprintf ("%05d", (99999 - $ago))) ;
}

sub csvkey_date_size
{
  my ($language, $date) = split (",", (shift)) ;
  return (substr ($date,6,2) . substr ($date,0,2) . substr ($date,3,2) . $sort_languages {$language}) ;
}

sub abort
{
  my $msg = shift ;

  print "$log_buffer\n" ;
  $log_buffer = "" ;

  if ($path_out eq "")
  {
    print ("\n*****\n$msg\n*****\n\nExecution aborted.\n") ;
  }
  else
  {
    print ("\n*****\n$msg\n*****\n\nExecution aborted.\n") ;
    &Log  ("\n*****\n$msg\n*****\n\nExecution aborted.\n") ;
    close "FILE_LOG" ;
  }

  if ($file_aborted ne "")
  {
    open "FILE_LOG", ">>", $file_aborted || die ("Log file '$file_aborted' could not be opened.") ;
    print FILE_LOG ("\n\n===== WikiCounts / " . &GetDateTime(time) . " / Wikipedia: " . uc ($language) . " =====\n") ;
    print FILE_LOG ((("\n*****\n$msg\n*****\n") . "\nExecution aborted.")) ;
    close "FILE_LOG" ;
  }

  &LogC (" !!\n-> [ $msg ]\n\n") ;

  exit ;
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

  %wikipedias = (
  aa=>"http://aa.wikipedia.org Afar",
  ab=>"http://ab.wikipedia.org Abkhazian",
  af=>"http://af.wikipedia.org Afrikaans",
  als=>"http://als.wikipedia.org Elsatian",
  sq=>"http://sq.wikipedia.org Albanian",
  am=>"http://am.wikipedia.org Amharic",
  ar=>"http://ar.wikipedia.org Arabic",
  an=>"http://an.wikipedia.org Aragonese",
  hy=>"http://hy.wikipedia.org Armenian",
  as=>"http://as.wikipedia.org Assamese",
  ast=>"http://ast.wikipedia.org Asturian",
  ay=>"http://ay.wikipedia.org Aymara",
  az=>"http://az.wikipedia.org Azerbaijani",
  ba=>"http://ba.wikipedia.org Bashkir",
  eu=>"http://eu.wikipedia.org Basque",
  be=>"http://be.wikipedia.org Belorussian",
  bn=>"http://bn.wikipedia.org Bengali",
  dz=>"http://dz.wikipedia.org Bhutani",
  bh=>"http://bh.wikipedia.org Bihari",
  bi=>"http://bi.wikipedia.org Bislama",
  bs=>"http://bs.wikipedia.org Bosnian",
  be=>"http://be.wikipedia.org Breton",
  bug=>"http://bug.wikipedia.org Buginese",
  bg=>"http://bg.wikipedia.org Bulgarian",
  my=>"http://my.wikipedia.org Burmese",
  km=>"http://km.wikipedia.org Cambodian",
  ca=>"http://ca.wikipedia.org Catalan",
  zh=>"http://zh.wikipedia.org Chinese",
  co=>"http://co.wikipedia.org Corsican",
  hr=>"http://hr.wikipedia.org Croatian",
  cs=>"http://cs.wikipedia.org Czech",
  da=>"http://da.wikipedia.org Danish",
  dk=>"http://dk.wikipedia.org Danish",
  nl=>"http://nl.wikipedia.org Dutch",
  dz=>"http://dz.wikipedia.org Dzongkha",
  en=>"http://www.wikipedia.org English",
  eo=>"http://eo.wikipedia.org Esperanto",
  et=>"http://et.wikipedia.org Estonian",
  fo=>"http://fo.wikipedia.org Faeroese",
  fj=>"http://fj.wikipedia.org Fijian",
  fi=>"http://fi.wikipedia.org Finnish",
  fr=>"http://fr.wikipedia.org French",
  fy=>"http://fy.wikipedia.org Frisian",
  gl=>"http://gl.wikipedia.org Galego",
  gay=>"http://gay.wikipedia.org Gayo",
  ka=>"http://ka.wikipedia.org Georgian",
  de=>"http://de.wikipedia.org German",
  el=>"http://el.wikipedia.org Greek",
  kl=>"http://kl.wikipedia.org Greenlandic",
  gn=>"http://gn.wikipedia.org Guarani",
  gu=>"http://gu.wikipedia.org Gujarati",
  ha=>"http://ha.wikipedia.org Hausa",
  hi=>"http://hi.wikipedia.org Hindi",
  he=>"http://he.wikipedia.org Hebrew",
  hu=>"http://hu.wikipedia.org Hungarian",
  iba=>"http://iba.wikipedia.org Iban",
  is=>"http://is.wikipedia.org Icelandic",
  io=>"http://io.wikipedia.org Ido",
  id=>"http://id.wikipedia.org Indonesian",
  ia=>"http://ia.wikipedia.org Interlingua",
  iu=>"http://iu.wikipedia.org Inuktitut",
  ik=>"http://ik.wikipedia.org Inupiak",
  ga=>"http://ga.wikipedia.org Irish",
  it=>"http://it.wikipedia.org Italian",
  ja=>"http://ja.wikipedia.org Japanese",
  jv=>"http://jv.wikipedia.org Javanese",
  kn=>"http://kn.wikipedia.org Kannada",
  ks=>"http://ks.wikipedia.org Kashmiri",
  kaw=>"http://kaw.wikipedia.org Kawi",
  kk=>"http://kk.wikipedia.org Kazakh",
  rw=>"http://rw.wikipedia.org Kinyarwanda",
  ky=>"http://ky.wikipedia.org Kirghiz",
  rn=>"http://rn.wikipedia.org Kirundi",
  ko=>"http://ko.wikipedia.org Korean",
  ku=>"http://ku.wikipedia.org Kurdish",
  lo=>"http://lo.wikipedia.org Laotian",
  la=>"http://la.wikipedia.org Latin",
  ls=>"http://la.wikipedia.org Latino Sine Flexione",
  lv=>"http://lv.wikipedia.org Latvian",
  li=>"http://li.wikipedia.org Ligurian",
  ln=>"http://ln.wikipedia.org Lingala",
  lt=>"http://lt.wikipedia.org Lithuanian",
  nds=>"http://nds.wikipedia.org Low Saxon",
  mk=>"http://mk.wikipedia.org Macedonian",
  mad=>"http://mad.wikipedia.org Madurese",
  mak=>"http://mak.wikipedia.org Makasar",
  mg=>"http://mg.wikipedia.org Malagasy",
  ms=>"http://ms.wikipedia.org Malay",
  ml=>"http://ml.wikipedia.org Malayalam",
  gv=>"http://gv.wikipedia.org Manx Gaelic",
  mi=>"http://mi.wikipedia.org Maori",
  mr=>"http://mr.wikipedia.org Marathi",
  min=>"http://min.wikipedia.org Minangkabau",
  mo=>"http://mo.wikipedia.org Moldavian",
  mn=>"http://mn.wikipedia.org Mongolian",
  nah=>"http://nah.wikipedia.org Nahuatl",
  na=>"http://na.wikipedia.org Nauru",
  ne=>"http://ne.wikipedia.org Nepali",
  no=>"http://no.wikipedia.org Norwegian",
  oc=>"http://oc.wikipedia.org Occitan",
  or=>"http://or.wikipedia.org Oriya",
  om=>"http://om.wikipedia.org Oromo",
  ps=>"http://ps.wikipedia.org Pashto",
  fa=>"http://fa.wikipedia.org Persian",
  pl=>"http://pl.wikipedia.org Polish",
  pt=>"http://pt.wikipedia.org Portuguese",
  pa=>"http://pa.wikipedia.org Punjabi",
  qu=>"http://qu.wikipedia.org Quechua",
  rm=>"http://rm.wikipedia.org Rhaeto-Romance",
  ro=>"http://ro.wikipedia.org Romanian",
  ru=>"http://ru.wikipedia.org Russian",
  sm=>"http://sm.wikipedia.org Samoan",
  sg=>"http://sg.wikipedia.org Sangro",
  sa=>"http://sa.wikipedia.org Sanskrit",
  gd=>"http://gd.wikipedia.org Scottish Gaelic",
  sr=>"http://sr.wikipedia.org Serbian",
  sh=>"http://sh.wikipedia.org Serbo-Croatian",
  st=>"http://st.wikipedia.org Sesotho",
  tn=>"http://tn.wikipedia.org Setswana",
  sn=>"http://sn.wikipedia.org Shona",
  simple=>"http://simple.wikipedia.org Simple English",
  sd=>"http://sd.wikipedia.org Sindhi",
  si=>"http://si.wikipedia.org Singhalese",
  ss=>"http://ss.wikipedia.org Siswati",
  sk=>"http://sk.wikipedia.org Slovak",
  sl=>"http://sl.wikipedia.org Slovene",
  es=>"http://es.wikipedia.org Spanish",
  su=>"http://su.wikipedia.org Sudanese",
  sw=>"http://sw.wikipedia.org Swahili",
  sv=>"http://sv.wikipedia.org Swedish",
  tl=>"http://tl.wikipedia.org Tagalog",
  tg=>"http://tg.wikipedia.org Tajik",
  ta=>"http://ta.wikipedia.org Tamil",
  tt=>"http://tt.wikipedia.org Tatar",
  te=>"http://te.wikipedia.org Telugu",
  th=>"http://th.wikipedia.org Thai",
  bo=>"http://bo.wikipedia.org Tibetan",
  ti=>"http://ti.wikipedia.org Tigrinya",
  to=>"http://to.wikipedia.org Tonga",
  ts=>"http://ts.wikipedia.org Tsonga",
  tr=>"http://tr.wikipedia.org Turkish",
  tk=>"http://tk.wikipedia.org Turkmen",
  tw=>"http://tw.wikipedia.org Twi",
  ug=>"http://ug.wikipedia.org Uighur",
  uk=>"http://uk.wikipedia.org Ukrainian",
  ur=>"http://ur.wikipedia.org Urdu",
  uz=>"http://uz.wikipedia.org Uzbek",
  vi=>"http://vi.wikipedia.org Vietnamese",
  vo=>"http://vo.wikipedia.org Volap&uuml;k",
  wa=>"http://wa.wikipedia.org Walloon",
  cy=>"http://cy.wikipedia.org Welsh",
  wo=>"http://wo.wikipedia.org Wolof",
  xh=>"http://xh.wikipedia.org Xhosa",
  yi=>"http://yi.wikipedia.org Yiddish",
  yo=>"http://yo.wikipedia.org Yoruba",
  za=>"http://za.wikipedia.org Zhuang",
  zu=>"http://zu.wikipedia.org Zulu",
  zz=>"&nbsp; All&nbsp;languages") ;

1 ;
