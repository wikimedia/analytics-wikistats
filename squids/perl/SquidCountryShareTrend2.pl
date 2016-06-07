#!/usr/bin/perl

# hashes are prefixed with h_

$max_countries = 10 ;
$yyyymm_lo = "999999" ;
$yyyymm_hi = "000000" ;

# Q&D fixed file paths, to be externalized

$file_pageviews_in  = "/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthly.csv" ;
$file_pageviews_out = "/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthlyAggregated.csv" ;
$file_countries     = "/a/wikistats_git/squids/csv/meta/CountryCodes.csv" ;

die "File '$file_pageviews_in' not found" if ! -e $file_pageviews_in ;
die "File '$file_countries' not found" if ! -e $file_countries ;

&ReadCountryNames ;
&InitProjectNames ;
&CollectCounts ;

print "\nNo project name defined for these codes:\n" ;
foreach $key (keys %codes_undefined)
{ print "$key:" . $codes_undefined {$key} . "\n" ; }


print"\n\nReady\n\n" ;
exit ;

sub CollectCounts
{
  open IN, '<', $file_pageviews_in || die "Input file '$file_pageviews_in' could not be opened" ;
  while ($line = <IN>)
  {
    chomp $line ;

    next if $line =~ /user-agent|json|http|test|action|window|upload|\w+=/ ; 

    ($yyyymm,$project,$language,$country,$user,$count) = split (',', $line) ;

    if ($yyyymm lt $yyyymm_lo)
    { $yyyymm_lo = $yyyymm ; }
    if ($yyyymm gt $yyyymm_hi)
    { $yyyymm_hi = $yyyymm ; }

    next if $user ne 'U' ;
    next if length ($language) > 20 ;
  # next if $project ne 'wn' ; # test

    $project =~ s/[^a-z]//g ;
  
    $yyyy = substr ($yyyymm,0,4) ;

    $h_project                       {$project}                                += $count ;
    $h_project_language              {$project} {$language}                    += $count ;
    $h_project_language_country      {$project} {$language} {$country}         += $count ;  
    $h_project_language_country_yyyy {$project} {$language} {$country} {$yyyy} += $count ;  
    $h_project_language_yyyy         {$project} {$language} {$yyyy}            += $count ;  
  }
  close IN ;


  $yyyy_lo = substr ($yyyymm_lo,0,4) ;
  $yyyy_hi = substr ($yyyymm_hi,0,4) ;
  $mm_lo   = substr ($yyyymm_lo,5,2) ;
  $mm_hi   = substr ($yyyymm_hi,5,2) ;
  $yyyy_lo_rescale = 12 / (13 - $mm_lo) ; 
  $yyyy_hi_rescale = 12 / $mm_hi ; 
  die "invalid mm_lo $mm_lo, yyyymm_lo $yyyymm_lo" if $mm_lo !~ /^(01|02|03|04|05|06|07|08|09|10|11|12)$/ ;
  die "invalid mm_hi $mm_hi, yyyymm_hi $yyyymm_hi" if $mm_hi !~ /^(01|02|03|04|05|06|07|08|09|10|11|12)$/ ;
  print "yyyymm_lo $yyyymm_lo -> yyyy_lo $yyyy_lo, mm_lo $mm_lo, yyyy_lo_rescale $yyyy_lo_rescale\n" ;
  print "yyyymm_hi $yyyymm_hi -> yyyy_hi $yyyy_hi, mm_hi $mm_hi, yyyy_hi_rescale $yyyy_hi_rescale\n" ;

  open OUT, '>', $file_pageviews_out || die "Output file '$file_pageviews_out' could not be opened" ;
  foreach $project (sort keys %h_project)
  {
    print OUT "1 $project\n" ;

    @languages = keys %{$h_project_language {$project}} ;
    foreach $language (sort {$h_project_language {$project} {$b} <=> $h_project_language {$project} {$a}} @languages)
    {
      next if $h_project_language {$project} {$language} < 100 ;

      $language_name = $out_languages {$language} ;      
      $project_name = &GetProjectName ($project) ;

      print OUT "\n\n$language_name ($language) $project_name\n" ;

    # next if $language ne 'as' ; # test
      @countries = keys %{$h_project_language_country{$project} {$language}} ;
      # print OUT "countries: " . join ("|", splice (@countries,0,10)) . "\n\n";

      @countries = sort {$h_project_language_country{$project} {$language} {$b} <=> $h_project_language_country{$project} {$language} {$a}} @countries ;
      @years     = sort keys %{$h_project_language_yyyy {$project} {$language}} ; 
      $years = @years ; # count total years for this project and language

      $countries = 0 ;
      $line = "year,total,% of max," ;
      foreach $country (@countries)
      {      
        $avg_yearly_project_language_country = $h_project_language_country {$project} {$language} {$country} / $years ;
        last if $avg_yearly_project_language_country < 1 ;

        $countries++ ;
        $line .= $country_names {$country} . ',' ;
        last if $countries >= $max_countries ;
      }
      $line .= 'Other' ;
      print OUT "$line\n" ;

      $total_yearly_scaled_max = 0 ;
      foreach $year (@years)
      {
        $total_yearly = $h_project_language_yyyy {$project} {$language} {$year} ;
        $total_yearly_scaled = $total_yearly ;

        # rescale for incomplete year
        if ($year == $yyyy_lo)
        { $total_yearly_scaled = sprintf ("%.0f", $total_yearly * $yyyy_lo_rescale) ; }
        if ($year == $yyyy_hi)
        { $total_yearly_scaled = sprintf ("%.0f", $total_yearly * $yyyy_hi_rescale) ; }

        if ($total_yearly_scaled_max < $total_yearly_scaled)
        { $total_yearly_scaled_max = $total_yearly_scaled ; }
      }

      foreach $year (@years)
      {
        $total_yearly = $h_project_language_yyyy {$project} {$language} {$year} ;
        $total_yearly_scaled = $total_yearly ;

        # rescale for incomplete year
        if ($year == $yyyy_lo)
        { $total_yearly_scaled = sprintf ("%.0f", $total_yearly * $yyyy_lo_rescale) ; }
        if ($year == $yyyy_hi)
        { $total_yearly_scaled = sprintf ("%.0f", $total_yearly * $yyyy_hi_rescale) ; }

        $total_yearly_perc_of_max = sprintf ("%.0f", 100 * $total_yearly_scaled / $total_yearly_scaled_max) . '%' ;
        $line = "$year,$total_yearly_scaled,$total_yearly_perc_of_max," ;

        $countries = 0 ;
        $perc_cumulative = 0 ;
        foreach $country (@countries)
        {      
        # next if $h_project_language_country{$project} {$language} {$country} / $h_project_language {$project} {$language} < 0.01 ;  
 
          $count = $h_project_language_country_yyyy {$project} {$language} {$country} {$year} ;
          $avg_yearly_project_language_country = $h_project_language_country {$project} {$language} {$country} / $years ;
        # print "$country avg:  $avg_yearly_project_language_country\n" ;
          last if $avg_yearly_project_language_country < 1 ;

          $countries++ ;
          last if $countries > $max_countries ;
        # print "$project $language $country $year: $count \/ $total_yearly\n" ;
        # next if $total < 100 ;
          $perc = 0 ;
          if (($count > 0) && ($total_yearly > 0))    
          { 
            $perc = sprintf ("%.1f", 100 * $count / $total_yearly) ; 
            $perc_cumulative += $perc ;
            if ($perc eq "0.0")
            { $perc = 0 ; }
          # print OUT "3a $year $total: $project $language $country $perc\n" ;
          # $line .= "$country:$perc\%," ; # debug
            $line .= "$perc\%," ;
          }
          else
          { 
            $line .= ',' ; 
          } 
        }
        $other = sprintf ("%.1f",(100-$perc_cumulative)) ;
        
        if ($other =~ /\-/) # total > 100% due to rounding errors?
        { $other = '' ; }
        $line =~ s/\,$/,$other\%/ ;
      # print "$project $year b perc_cum $perc_cumulative, other $other, $line\n" ;
        print OUT "$line\n" ;  
      }
    }
  } 
  close OUT ;
}

sub GetProjectName
{
  my $project = shift ;

     if ($project eq 'wb') { $project = 'Wikibooks' ; }
  elsif ($project eq 'wk') { $project = 'Wiktionary' ; }
  elsif ($project eq 'wn') { $project = 'Wikinews' ; }
  elsif ($project eq 'wp') { $project = 'Wikipedia' ; }
  elsif ($project eq 'wq') { $project = 'Wikiquote' ; }
  elsif ($project eq 'wo') { $project = 'Wikivoyage' ; }
  elsif ($project eq 'ws') { $project = 'Wikisource' ; }
  elsif ($project eq 'wv') { $project = 'Wikiversity' ; }
  elsif ($project eq 'wx') { $project = 'Other Projects' ; }
  else  { $codes_undefined {$project}++ ; }

  return ($project) ;
}

sub ReadCountryNames
{

  open    CSV_COUNTRIES, '<', $file_countries ;
  binmode CSV_COUNTRIES ;
  $country_names {'-'}  = 'Unknown' ;
  $country_names {'--'} = 'Unknown' ;
  $country_names {'-P'} = 'IPv6' ;
  $country_names {'-X'} = 'Unknown' ;
  $country_names {'AN'} = 'Netherlands Antilles' ; # not yet in MaxMind database
  $country_names {"XX"} = "Unknown" ;

  while ($line = <CSV_COUNTRIES>)
  {
    chomp $line ;

    next if $line =~ /^#/ ;

    $line =~ s/\"//g ;

    $line =~ s/[\x00-\x1f]//g ;
    $line =~ s/UNDEFINED/Undefined/g ;
    $line =~ s/territories/Territories/ ;
    $line =~ s/(Falkland Islands).*$/$1/g ; # - (Malvinas)
    $line =~ s/Reunion/Réunion/ ;
    $line =~ s/Aland Islands/Åland Islands/ ;
    $line =~ s/Bonaire, Saint Eustatius and Saba/Caribbean Netherlands/ ;
    $line =~ s/Congo, The Democratic Republic of the/Congo Dem. Rep./ ;
    $line =~ s/Congo$/Congo Rep./ ;
    $line =~ s/Curacao/Curaçao/ ;
    $line =~ s/Brunei Darussalam/Brunei/ ;
    $line =~ s/Holy See.*$/Vatican City/ ;
    $line =~ s/Iran, Islamic Republic of/Iran/ ;
    $line =~ s/Korea, Democratic People's Republic of/North Korea/ ;
    $line =~ s/Korea, Republic of/South Korea/ ;
    $line =~ s/Lao People's Democratic Republic/Laos/ ;
    $line =~ s/Libyan Arab Jamahiriya/Libya/ ;
    $line =~ s/Micronesia, Federated States of/Micronesia/ ;
    $line =~ s/Moldova, Republic of/Moldova/ ;
    $line =~ s/Myanmar/Burma/ ;
    $line =~ s/Palestinian Territory/Palestinian Territories/ ;
    $line =~ s/Pitcairn/Pitcairn Islands/ ;
    $line =~ s/Russian Federation/Russia/ ;
    $line =~ s/American American Samoa/American Samoa/ ;
    $line =~ s/Saint Bartelemey/Saint Barthélemy/ ;
    $line =~ s/Sao Tome and Principe/São Tomé and Príncipe/ ;
    $line =~ s/Syrian Arab Republic/Syria/ ;
    $line =~ s/Tanzania, United Republic of/Tanzania/ ;
    $line =~ s/Virgin Islands, British/Virgin Islands, UK/ ;
    $line =~ s/Virgin Islands, U.S./Virgin Islands, US/ ;

    # ($country_code,$region_code,$north_south_code,$country_name) = split (',', $line,4) ;
    ($country_code,$country_name) = split (',', $line,2) ;

    $country_name =~ s/"//g ;

    # next if $country_name eq "Anonymous Proxy" ;
    # next if $country_name eq "Satellite Provider" ;
    # next if $country_name eq "Other Country" ;
    # next if $country_name eq "Asia/Pacific Region" ;
    # next if $country_name eq "Europe" ;

#    if ($country_meta_info {$country}  eq "")
#    {
#      if ($country_meta_info_not_found_reported {$country} ++ == 0)
#      { print "Meta info not found for country '$country'\n" ; }
#    }

    $country_names_found {$country_name} ++ ;
    $country_names       {$country_code} = $country_name ;
    $country_codes_all   {"$country_name|$country_code"} ++ ;
  }

  close CSV_COUNTRY_CODES ;
}

sub InitProjectNames
{
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
ib=>"http://ru-sib.wikipedia.org Siberian",
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


