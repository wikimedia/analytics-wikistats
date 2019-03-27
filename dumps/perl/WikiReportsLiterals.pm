#!/usr/bin/perl
# test input:
# -m  wp -l en -i "D:\@Wikimedia\# Out Bayes\csv_wp" -o "D:\@Wikimedia\# Out Test\htdocs" -g -t
# to do change: figures for first months are too low -> figures for early 2001
# and remove this notice at all on project pages that start to report from 2002 or later

# Copyright (C) 2003-2008 Erik Zachte , email ezachte a-t wikimedia d-o-t org
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, at
# http://www.fsf.org/licenses/gpl.html

  # use Statistics:LineFit ;
  # use warnings ;
  # use strict 'vars' ;

  no warnings qw (qw) ; # skip "Possible attempt to put comments into ..."

  use WikiReports_AST ;
  use WikiReports_BG ;
  use WikiReports_BR ;
  use WikiReports_CA ;
  use WikiReports_CS ;
  use WikiReports_DA ;
  use WikiReports_DE ;
  use WikiReports_EN ;
  use WikiReports_EO ;
  use WikiReports_ES ;
  use WikiReports_FR ;
  use WikiReports_HE ;
  use WikiReports_HU ;
  use WikiReports_ID ;
  use WikiReports_IT ;
  use WikiReports_JA ;
  use WikiReports_NL ;
  use WikiReports_NN ;
  use WikiReports_PL ;
  use WikiReports_PT ;
  use WikiReports_RO ;
  use WikiReports_RU ;
  use WikiReports_SK ;
  use WikiReports_SL ;
  use WikiReports_SR ;
  use WikiReports_SV ;
  use WikiReports_WA ;
  use WikiReports_ZH ;

  use warnings qw (qw) ;

  # Jan 31, 2019
  $out_announcement = 
# "<table width=1000 align=left><tr><td colspan=999 style='background-color:DD8;text-align:left'>" .
  "<big><font color=#107000>&nbsp;<br>$sp2".
  "<b>Jan 31, 2019: This is the final release of Wikistats-1 dump-based reports. " .
  "Part of these data are available in the first release of Wikistats 2. ".
  "Read more <a href='http://stats.wikimedia.org/Wikistats_1_announcements.htm'>here</a></big></font></b>".
# "</td></tr></table>$sp2</b>" . 
  "<br>&nbsp;" ;
 

  
sub SetLanguageInfo
{
  # taken from http://meta.wikimedia.org/wiki/List_of_Wikipedias
  # see also http://www.loc.gov/standards/iso639-2/php/English_list.php
  # url might have been generated from language code, but there were (and will be?) exceptions
  # see also http://meta.wikimedia.org/wiki/Special:SiteMatrix
  # latest language name corrections provided by Mark Williamson
  # see also http://meta.wikimedia.org/wiki/Languages

  # July 2017 new updates by Erik Zachte for 20 largest languages from infobox in articles on wp:en
  # note that nearly all 20 languages were adjusted downward
  # ideally (some day, now now) numbers will be drawn from wikidata

  # numbers in square brackets: number of speakers in millions according to
  # http://en.wikipedia.org/w/index.php?title=List_of_languages_by_total_number_of_speakers
  # includes secondary speakers (hence adds up to much more than 6 billion)
  %wikipedias = (
# mediawiki=>"http://wikimediafoundation.org Wikimedia",
  wikidata=>"http://www.wikidata.org Wikidata",
  nostalgia=>"http://nostalgia.wikipedia.org Nostalgia",
  sources=>"http://wikisource.org Multilingual&nbsp;Wikisource",
  meta=>"http://meta.wikimedia.org Meta-Wiki",
  beta=>"http://beta.wikiversity.org Beta",
  species=>"http://species.wikipedia.org Wikispecies",
  commons=>"http://commons.wikimedia.org Commons",
  foundation=>"http://wikimediafoundation.org Foundation",
  strategy=>"http://strategy.wikimedia.org Strategic&nbsp;Planning",
  outreach=>"http://outreach.wikimedia.org Outreach",
  incubator=>"http://incubator.wikimedia.org Incubator",
  usability=>"http://usability.wikimedia.org Usability&nbsp;Initiative",
  sep11=>"http://sep11.wikipedia.org In&nbsp;Memoriam",
  nlwikimedia=>"http://nl.wikimedia.org Wikimedia&nbsp;Nederland",
  plwikimedia=>"http://pl.wikimedia.org Wikimedia&nbsp;Polska",
  mediawiki=>"http://www.mediawiki.org MediaWiki",
  dewikiversity=>"http://de.wikiversity.org Wikiversit&auml;t",
  frwikiversity=>"http://fr.wikiversity.org Wikiversit&auml;t",
  wikimania2005=>"http://wikimania2005.wikimedia.org Wikimania 2005",
  wikimania2006=>"http://wikimania2006.wikimedia.org Wikimania 2006",
  aa=>"http://aa.wikipedia.org Afar [1.4,AF]",
  ab=>"http://ab.wikipedia.org Abkhazian [0.113,AS]",
  ace=>"http://ace.wikipedia.org Acehnese [3.5,AS]",
  af=>"http://af.wikipedia.org Afrikaans [13,AF]",
  ak=>"http://ak.wikipedia.org Akan [19,AF]",
  als=>"http://als.wikipedia.org Alemannic [10,EU]", # was Elsatian
  am=>"http://am.wikipedia.org Amharic [25,AF]",
  an=>"http://an.wikipedia.org Aragonese [0.0741,EU]",
  ang=>"http://ang.wikipedia.org Anglo-Saxon [,EU]",
  ar=>"http://ar.wikipedia.org Arabic [422,AF,AS]", # was 530 till July 2017
  arc=>"http://arc.wikipedia.org Aramaic [2.2,AS]",
  arz=>"http://arz.wikipedia.org Egyptian Arabic [76,AF]",
  as=>"http://as.wikipedia.org Assamese [13,AS,I]",
  ast=>"http://ast.wikipedia.org Asturian [0.450,EU]",
  atj=>"http://atj.wikipedia.org Atikamekw [0.008,NA]",
  av=>"http://av.wikipedia.org Avar [0.76,EU]",
  ay=>"http://ay.wikipedia.org Aymara [2.8,SA]",
  az=>"http://az.wikipedia.org Azeri [27,AS]",
  ba=>"http://ba.wikipedia.org Bashkir [1.2,AS]",
  bar=>"http://bar.wikipedia.org Bavarian [12,EU]",
  bat_smg=>"http://bat-smg.wikipedia.org Samogitian [0.5,EU]",
  "bat-smg"=>"http://bat-smg.wikipedia.org Samogitian 0.5,EU]",
  bcl=>"http://bcl.wikipedia.org Central Bicolano [2.5,AS]",
  be=>"http://be.wikipedia.org Belarusian [6.5,EU]",
  "be-tarask"=>"http://be-tarask.wikipedia.org Belarusian (Taraškievic) [6.5,EU]", # was be-x-old
  be_tarask=>"http://be-tarask.wikipedia.org Belarusian (Taraškievic:) [6.5,EU]",  # was be_x_old
  "be-x-old"=>"http://be-x-old.wikipedia.org Belarusian (Taraškievic) [6.5,EU]",
  be_x_old=>"http://be-x-old.wikipedia.org Belarusian (Taraškievic) [6.5,EU]",
  bg=>"http://bg.wikipedia.org Bulgarian [12,EU]",
  bh=>"http://bh.wikipedia.org Bihari [,AS,I]",
  bi=>"http://bi.wikipedia.org Bislama [0.2,OC]",
  bjn=>"http://bjn.wikipedia.org Banjar [3.5,AS]",
  bm=>"http://bm.wikipedia.org Bambara [6,AF]",
  bn=>"http://bn.wikipedia.org Bengali [261.8,AS,I]",
  bo=>"http://bo.wikipedia.org Tibetan [7,AS]",
  bpy=>"http://bpy.wikipedia.org Bishnupriya Manipuri [2.2,AS,I]",
  br=>"http://br.wikipedia.org Breton [0.226,EU]",
  bs=>"http://bs.wikipedia.org Bosnian [3.0,EU]", # Wikipedia 2.5-3.5 million
  bug=>"http://bug.wikipedia.org Buginese [4,AS]",
  bxr=>"http://bxr.wikipedia.org Buryat [0.33,AS]",
  ca=>"http://ca.wikipedia.org Catalan [9,EU]",
  cbk_zam=>"http://cbk-zam.wikipedia.org Chavacano [1.2,AS]",
  "cbk-zam"=>"http://cbk-zam.wikipedia.org Chavacano [1.2,AS]",
  cdo=>"http://cdo.wikipedia.org Min Dong [9.1,AS,C]",
  ce=>"http://ce.wikipedia.org Chechen [1.4,EU]",
  ceb=>"http://ceb.wikipedia.org Cebuano [20,AS]",
  ch=>"http://ch.wikipedia.org Chamorro [0.06,OC]",
  cho=>"http://cho.wikipedia.org Choctaw [0.0179,NA]", # was Chotaw
  chr=>"http://chr.wikipedia.org Cherokee [0.316,NA]",
  chy=>"http://chy.wikipedia.org Cheyenne [0.000712,NA]",
  ckb=>"http://ckb.wikipedia.org Sorani [7.5,AS]",
  co=>"http://co.wikipedia.org Corsican [0.2,EU]",
  cr=>"http://cr.wikipedia.org Cree [0.120,NA]",
  crh=>"http://crh.wikipedia.org Crimean Tatar [0.480,EU,AS]",
  cs=>"http://cs.wikipedia.org Czech [12,EU]",
  csb=>"http://csb.wikipedia.org Cassubian [0.108,EU]",
  cu=>"http://cv.wikipedia.org Old Church Slavonic [,EU]",
  cv=>"http://cv.wikipedia.org Chuvash [1.1,AS]",
  cy=>"http://cy.wikipedia.org Welsh [0.74,EU]",
  da=>"http://da.wikipedia.org Danish [6,EU]",
  de=>"http://de.wikipedia.org German [132,EU]", # was 185 till July 2017
  diq=>"http://diq.wikipedia.org Zazaki [1.6,AS]",
  dk=>"http://dk.wikipedia.org Danish [5.5,EU]",
  dsb=>"http://dsb.wikipedia.org Lower Sorbian [0.0069,EU]",
  dv=>"http://dv.wikipedia.org Divehi [0.3,AS,I]",
  dz=>"http://dz.wikipedia.org Dzongkha [0.6,AS,I]",
  ee=>"http://ee.wikipedia.org Ewe [3.5,AF]",
  el=>"http://el.wikipedia.org Greek [15,EU]",
  eml=>"http://eml.wikipedia.org Emilian-Romagnol [1.56,EU]",
  en=>"http://en.wikipedia.org English [1121,EU,NA,OC,AS,AF]",
  eo=>"http://eo.wikipedia.org Esperanto [2,AL]",
  es=>"http://es.wikipedia.org Spanish [513,EU,NA,SA,AS,AF]", # was 500 till July 2017
  et=>"http://et.wikipedia.org Estonian [1.1,EU]",
  eu=>"http://eu.wikipedia.org Basque [0.635,EU]", # Wikipedia 550,000-720,000
  ext=>"http://ext.wikipedia.org Extremaduran [0.2,EU]",
  fa=>"http://fa.wikipedia.org Persian [110,AS]",
  ff=>"http://ff.wikipedia.org Fulfulde [13,AF]",
  fi=>"http://fi.wikipedia.org Finnish [6,EU]",
  "fiu-vro"=>"http://fiu-vro.wikipedia.org Voro [0.087,EU]",
  fiu_vro=>"http://fiu-vro.wikipedia.org Voro [0.07,EU]",
  fj=>"http://fj.wikipedia.org Fijian [0.55,OC]",
  fo=>"http://fo.wikipedia.org Faroese [0.066,EU]", # was Faeroese, then Faaroese
  fr=>"http://fr.wikipedia.org French [285,EU,NA,SA,AS,AF,OC]", # was 200 till July 2017
  frp=>"http://frp.wikipedia.org Arpitan [0.140,EU]",
  frr=>"http://frr.wikipedia.org North Frisian [0.01,EU]",
  fur=>"http://fur.wikipedia.org Friulian [0.6,EU]",
  fy=>"http://fy.wikipedia.org Frisian [0.48,EU]",
  ga=>"http://ga.wikipedia.org Irish [1.205,EU]",
  gan=>"http://gan.wikipedia.org Gan [35,AS,C]",
  gay=>"http://gay.wikipedia.org Gayo [0.3,AS]",
  gd=>"http://gdi.wikipedia.org Scots Gaelic [0.087,EU]", # was Scottish Gaelic
  gl=>"http://gl.wikipedia.org Galician [2.4,EU]", # was Galego
  glk=>"http://glk.wikipedia.org Gilaki [3.3,AS]",
  gn=>"http://gn.wikipedia.org Guarani [7,SA]",
  gom=>"http://gom.wikipedia.org Goan Konkani [7.4,AS,I]",
  got=>"http://got.wikipedia.org Gothic [,EU]",
  gu=>"http://gu.wikipedia.org Gujarati [46,AS,I]",
  gv=>"http://gv.wikipedia.org Manx [0.00015,EU]", # was Manx Gaelic
  ha=>"http://ha.wikipedia.org Hausa [63.1,AF]",
  hak=>"http://hak.wikipedia.org Hakka [34,AS,C]",
  haw=>"http://haw.wikipedia.org Hawai'ian [0.024,OC]", # was Hawaiian
  he=>"http://he.wikipedia.org Hebrew [8.2,AS]",
  hi=>"http://hi.wikipedia.org Hindi [442,AS]", # wp:en/Hindi /  was 380 until Sep 2018 / was 550 till July 2017
  hif=>"http://hif.wikipedia.org Fiji Hindi [0.400,OC]",
  ho=>"http://ho.wikipedia.org Hiri Motu [0.12,AS]",
  hr=>"http://hr.wikipedia.org Croatian [6.2,EU]",
  hsb=>"http://hsb.wikipedia.org Upper Sorbian [0.013,EU]",
  ht=>"http://ht.wikipedia.org Haitian [12,NA]",
  hu=>"http://hu.wikipedia.org Hungarian [15,EU]",
  hy=>"http://hy.wikipedia.org Armenian [5.5,AS]",
  hz=>"http://hz.wikipedia.org Herero [0.13,AF]",
  ia=>"http://ia.wikipedia.org Interlingua [0.0015,AL]",
  iba=>"http://iba.wikipedia.org Iban [1.49, AS]",
  id=>"http://id.wikipedia.org Indonesian [199,AS]", # was 250 till July 2017
  ie=>"http://ie.wikipedia.org Interlingue [,AL]",
  ig=>"http://ig.wikipedia.org Igbo [22.5,AF]",
  ii=>"http://ii.wikipedia.org Yi [2,AS,C]",
  ik=>"http://ik.wikipedia.org Inupiak [0.0021,NA]",
  ilo=>"http://ilo.wikipedia.org Ilokano [10,AS]",
  io=>"http://io.wikipedia.org Ido [0.00015,AL]",
  is=>"http://is.wikipedia.org Icelandic [0.33,EU]",
  it=>"http://it.wikipedia.org Italian [67.8,EU]",
  iu=>"http://iu.wikipedia.org Inuktitut [0.03,NA]",
  ja=>"http://ja.wikipedia.org Japanese [128.3,AS]", # was 132 till July 2017
  jbo=>"http://jbo.wikipedia.org Lojban [,AL]",
  jv=>"http://jv.wikipedia.org Javanese [84.3,AS]", # was 80 till July 2017
  ka=>"http://ka.wikipedia.org Georgian [4.3,EU]",
  kaa=>"http://kaa.wikipedia.org Karakalpak [0.58,AS]",
  kab=>"http://ka.wikipedia.org Kabyle [8,AF]",
  kaw=>"http://kaw.wikipedia.org Kawi [,AS]",
  kbd=>"http://kbd.wikipedia.org Kabardian [1.6,AS]",
  kg=>"http://kg.wikipedia.org Kongo [7,AF]",
  ki=>"http://ki.wikipedia.org Kikuyu [6.6,AF]",
  kj=>"http://kj.wikipedia.org Kwanyama [0.67,AF]",
  kk=>"http://kk.wikipedia.org Kazakh [12,AS]",
  kl=>"http://kl.wikipedia.org Greenlandic [0.05,NA]",
  km=>"http://km.wikipedia.org Khmer [18.5,AS]", # was Cambodian
  kn=>"http://kn.wikipedia.org Kannada [47,AS,I]",
  ko=>"http://ko.wikipedia.org Korean [77.2,AS]",
  koi=>"http://koi.wikipedia.org Komi-Permyak [0.063,EU]",
  kr=>"http://kr.wikipedia.org Kanuri [4.2,AF]",
  ks=>"http://ks.wikipedia.org Kashmiri [4.6,AS,I]",
  ksh=>"http://ksh.wikipedia.org Ripuarian [0.9,EU]",
  ku=>"http://ku.wikipedia.org Kurdish [26,AS]",
  kv=>"http://kv.wikipedia.org Komi [0.293,EU]",
  kw=>"http://kw.wikipedia.org Cornish [0.000557,EU]", # was Kornish
  ky=>"http://ky.wikipedia.org Kyrghyz [4.3,AS]",
  la=>"http://la.wikipedia.org Latin [,W]",
  lad=>"http://lad.wikipedia.org Ladino [0.122,AS]",
  lb=>"http://lb.wikipedia.org Luxembourgish [0.39,EU]", # was Letzeburgesch
  lbe=>"http://lbe.wikipedia.org Lak [0.150,AS]",
  lez=>"http://lez.wikipedia.org Lezgian [1,EU]",
  lg=>"http://lg.wikipedia.org Ganda [10,AF]",
  li=>"http://li.wikipedia.org Limburgish [1.3,EU]",
  lij=>"http://lij.wikipedia.org Ligurian [0.5,EU]",
  lmo=>"http://lmo.wikipedia.org Lombard [3.6,EU]",
  ln=>"http://ln.wikipedia.org Lingala [25,AF]",
  lo=>"http://lo.wikipedia.org Laotian [22.5,AS]", # Wikipedia 20-25 million
  ls=>"http://ls.wikipedia.org Latino Sine Flexione",
  lt=>"http://lt.wikipedia.org Lithuanian [3.0,EU]",
  ltg=>"http://ltg.wikipedia.org Latgalian [0.175,EU]", # Wikipedia says 150,000-200,000
  lv=>"http://lv.wikipedia.org Latvian [1.75,EU]",
  mad=>"http://mad.wikipedia.org Madurese [15,AS]",
  mai=>"http://mai.wikipedia.org Maithili [30,AS]",
  mak=>"http://mak.wikipedia.org Makasar [2.1,AS]",
  map_bms=>"http://map-bms.wikipedia.org Banyumasan [13.5,AS]",
  "map-bms"=>"http://map-bms.wikipedia.org Banyumasan [13.5,AS]",
  mdf=>"http://mdf.wikipedia.org Moksha [0.39,EU]",
  mg=>"http://mg.wikipedia.org Malagasy [20,AF]",
  mh=>"http://mh.wikipedia.org Marshallese [0.0439,OC]",
  mhr=>"http://mhr.wikipedia.org Eastern Mari [0.47,EU]",
  mi=>"http://mi.wikipedia.org Maori [0.150,OC]",
  min=>"http://min.wikipedia.org Minangkabau [6.5,AS]",
  minnan=>"http://minnan.wikipedia.org Minnan [47,AS]",
  mk=>"http://mk.wikipedia.org Macedonian [2.5,EU]",
  ml=>"http://ml.wikipedia.org Malayalam [37,AS,I]",
  mn=>"http://mn.wikipedia.org Mongolian [5.2,AS]",
  mo=>"http://mo.wikipedia.org Moldovan [,EU]",
  mr=>"http://mr.wikipedia.org Marathi [74.7,AS,I]", # was 90 till July 2017
  mrj=>"http://mrj.wikipedia.org Western Mari [0.3,A]",
  ms=>"http://ms.wikipedia.org Malay [281,AS]", # was 300 till July 2017
  mt=>"http://mt.wikipedia.org Maltese [0.520,EU]",
  mus=>"http://mus.wikipedia.org Muskogee [0.006,NA]",
  mwl=>"http://mwl.wikipedia.org Mirandese [0.015,EU]",
  my=>"http://my.wikipedia.org Burmese [52,AS]",
  myv=>"http://myv.wikipedia.org Erzya [0.39,AS]",
  mzn=>"http://mzn.wikipedia.org Mazandarani [3.3,AS]",
  na=>"http://na.wikipedia.org Nauruan [0.007,OC]", # was Nauru
  nah=>"http://nah.wikipedia.org Nahuatl [1.5,NA]",
  nap=>"http://nap.wikipedia.org Neapolitan [7.5,EU]",
  nds=>"http://nds.wikipedia.org Low Saxon [10,EU]",
  nds_nl=>"http://nds-nl.wikipedia.org Dutch Low Saxon [10,EU]",
  "nds-nl"=>"http://nds-nl.wikipedia.org Dutch Low Saxon [10,EU]",
  ne=>"http://ne.wikipedia.org Nepali [30,AS,I]",
  new=>"http://new.wikipedia.org Nepal Bhasa [0.86,AS,I]",
  ng=>"http://ng.wikipedia.org Ndonga [0.690,AF]",
  nl=>"http://nl.wikipedia.org Dutch [28,EU,SA]",
  nov=>"http://nov.wikipedia.org Novial [,AL]",
  nrm=>"http://nrm.wikipedia.org Norman [0.1,EU]",
  nn=>"http://nn.wikipedia.org Nynorsk [0.4,EU]", # was Neo-Norwegian
  no=>"http://no.wikipedia.org Norwegian [5.2,EU]",
  nso=>"http://nso.wikipedia.org Northern Sotho [13.8,AF]",
  nv=>"http://nv.wikipedia.org Navajo [0.170,NA]",
  ny=>"http://ny.wikipedia.org Chichewa [9.3,AF]",
  oc=>"http://oc.wikipedia.org Occitan [0.45,EU]", #Wikipedia: estimates range from 100,000-800,000
  om=>"http://om.wikipedia.org Oromo [25.5,AF]",
  or=>"http://or.wikipedia.org Oriya [31,AS,I]",
  os=>"http://os.wikipedia.org Ossetic [0.57,AS]",
  pa=>"http://pa.wikipedia.org Punjabi [148.3,AS,I]",
  pag=>"http://pag.wikipedia.org Pangasinan [1.5,AS]",
  pam=>"http://pam.wikipedia.org Kapampangan [1.9,AS]",
  pap=>"http://pap.wikipedia.org Papiamentu [0.271,SA]",
  pcd=>"http://pcd.wikipedia.org Picard [0.7,EU]",
  pdc=>"http://pdc.wikipedia.org Pennsylvania German [0.250,NA]",
  pi=>"http://pi.wikipedia.org Pali [,AS]",
  pih=>"http://pih.wikipedia.org Norfolk [0.0004,OC]",
  pl=>"http://pl.wikipedia.org Polish [43,EU]",
  pms=>"http://pms.wikipedia.org Piedmontese [1.6,EU]",
  pnb=>"http://pnb.wikipedia.org Western Panjabi [60,AS]",
  pnt=>"http://pnt.wikipedia.org Pontic [0.325,EU]",
  ps=>"http://ps.wikipedia.org Pashto [26,AS]",
  pt=>"http://pt.wikipedia.org Portuguese [236.5,EU,SA,AF,AS]", # was 290 till July 2017
  qu=>"http://qu.wikipedia.org Quechua [10.4,SA]",
  rue=>"http://rue.wikipedia.org Rusyn [0.62,EU]",
  rm=>"http://rm.wikipedia.org Romansh [0.060,EU]", # was Rhaeto-Romance
  rmy=>"http://rmy.wikipedia.org Romani [4,EU]",
  rn=>"http://rn.wikipedia.org Kirundi [4.6,AF]",
  ro=>"http://ro.wikipedia.org Romanian [28,EU]",
  roa_rup=>"http://roa-rup.wikipedia.org Aromanian [0.25,EU]",
  "roa-rup"=>"http://roa-rup.wikipedia.org Aromanian [0.5]",
  roa_tara=>"http://roa-tara.wikipedia.org Tarantino [0.3,EU]",
  "roa-tara"=>"http://roa-tara.wikipedia.org Tarantino [0.3,EU]",
  ru=>"http://ru.wikipedia.org Russian [264.3,EU,AS]", # was 278 till July 2017
  ru_sib=>"http://ru-sib.wikipedia.org Siberian",
  "ru-sib"=>"http://ru-sib.wikipedia.org Siberian",
  rw=>"http://rw.wikipedia.org Kinyarwanda [12,AF]",
  sa=>"http://sa.wikipedia.org Sanskrit [0.014,AS,I]",
  sah=>"http://sah.wikipedia.org Sakha [0.450,AS]",
  sc=>"http://sc.wikipedia.org Sardinian [1.0,EU]",
  scn=>"http://scn.wikipedia.org Sicilian [8,EU]",
  sco=>"http://sco.wikipedia.org Scots [1.54,EU]",
  sd=>"http://sd.wikipedia.org Sindhi [41,AS,I]",
  se=>"http://se.wikipedia.org Northern Sami [0.025,EU]",
  sg=>"http://sg.wikipedia.org Sangro [3,AF]",
  sh=>"http://sh.wikipedia.org Serbo-Croatian [23,EU]",
  si=>"http://si.wikipedia.org Sinhala [19,AS]",
  simple=>"http://simple.wikipedia.org Simple English [1500,EU,NA,OC,AS,AF]",
  sk=>"http://sk.wikipedia.org Slovak [7,EU]",
  sl=>"http://sl.wikipedia.org Slovene [2.5,EU]",
  sm=>"http://sm.wikipedia.org Samoan [0.510,OC]",
  sn=>"http://sn.wikipedia.org Shona [7,AF]",
  so=>"http://so.wikipedia.org Somali [13.5,AF]",
  sq=>"http://sq.wikipedia.org Albanian [6,EU]",
  sr=>"http://sr.wikipedia.org Serbian [12,EU]",
  srn=>"http://srn.wikipedia.org Sranan [0.3,SA]",
  ss=>"http://ss.wikipedia.org Siswati [3,AF]",
  st=>"http://st.wikipedia.org Sesotho [13.5,AF]",
  stq=>"http://stq.wikipedia.org Saterland Frisian [0.001,EU]",
  su=>"http://su.wikipedia.org Sundanese [27,AS]",
  sv=>"http://sv.wikipedia.org Swedish [10,EU]",
  sw=>"http://sw.wikipedia.org Swahili [98.3,AF]",
  szl=>"http://szl.wikipedia.org Silesian [0.510,EU]",
  ta=>"http://ta.wikipedia.org Tamil [74.6,AS,I]",
  tcy=>"http://tcy.wikipedia.org Tulu [1.7,AS,I]",
  te=>"http://te.wikipedia.org Telugu [79.7,AS,I]",
  test=>"http://test.wikipedia.org Test",
  tet=>"http://tet.wikipedia.org Tetum [0.55,AS]",
  tg=>"http://tg.wikipedia.org Tajik [7.9,AS]",
  th=>"http://th.wikipedia.org Thai [60.5,AS]",
  ti=>"http://ti.wikipedia.org Tigrinya [6.7,AF]",
  tk=>"http://tk.wikipedia.org Turkmen [9,AS]",
  tl=>"http://tl.wikipedia.org Tagalog [70,AS]", # was 90 till July 2017
  tlh=>"http://tlh.wikipedia.org Klingon",
  tn=>"http://tn.wikipedia.org Setswana [12.9,AF]",
  to=>"http://to.wikipedia.org Tongan [0.105,OC]",
  tokipona=>"http://tokipona.wikipedia.org Tokipona [0.0001,AL]",
  tpi=>"http://tpi.wikipedia.org Tok Pisin [5.5,AS]",
  tr=>"http://tr.wikipedia.org Turkish [78.9,EU,AS]",
  ts=>"http://ts.wikipedia.org Tsonga [16.4,AF]",
  tt=>"http://tt.wikipedia.org Tatar [8,AS]",
  tum=>"http://tum.wikipedia.org Tumbuka [2.6,AF]",
  turn=>"http://turn.wikipedia.org Turnbuka",
  tuv=>"http://tuv.wikipedia.org Tuvan [0.265,AS]",
  tw=>"http://tw.wikipedia.org Twi [14.8,AF]",
  ty=>"http://ty.wikipedia.org Tahitian [0.120,OC]",
  tyv=>"http://tyv.wikipedia.org Tuvan [0.280,AS]",
  udm=>"http://udm.wikipedia.org Udmurt [0.340,AS]",
  ug=>"http://ug.wikipedia.org Uyghur [10,AS,C]",
  uk=>"http://uk.wikipedia.org Ukrainian [45,EU]",
  ur=>"http://ur.wikipedia.org Urdu [66,AS,I]", # wp:en/Urdu
  uz=>"http://uz.wikipedia.org Uzbek [23.5,AS]",
  ve=>"http://ve.wikipedia.org Venda [3.0,AF]",
  vec=>"http://vec.wikipedia.org Venetian [3.9,EU]",
  vep=>"http://vep.wikipedia.org Vepsian [0.0016,EU]",
  vi=>"http://vi.wikipedia.org Vietnamese [67.9,AS]", # was 80 till July 2017
  vls=>"http://vls.wikipedia.org West Flemish [1.4,EU]",
  vo=>"http://vo.wikipedia.org Volap&uuml;k [0.000020,AL]",
  wa=>"http://wa.wikipedia.org Walloon [0.6,EU]",
  war=>"http://war.wikipedia.org Waray-Waray [2.6,AS]",
  wo=>"http://wo.wikipedia.org Wolof [4.2,AF]",
  wuu=>"http://wuu.wikipedia.org Wu [80.7,AS,C]",
  xal=>"http://xal.wikipedia.org Kalmyk [0.805,EU]",
  xh=>"http://xh.wikipedia.org Xhosa [7.9,AF]",
  yi=>"http://yi.wikipedia.org Yiddish [3.2,W]",
  yo=>"http://yo.wikipedia.org Yoruba [25,AF]",
  za=>"http://za.wikipedia.org Zhuang [14,AS,C]",
  zea=>"http://zea.wikipedia.org Zealandic [0.220,EU]",
  zh=>"http://zh.wikipedia.org Chinese [1107,AS]",
  zh_min_nan=>"http://zh-min-nan.wikipedia.org Min Nan [50.1,AS,C]",
  "zh-min-nan"=>"http://zh-min-nan.wikipedia.org Min Nan [50.1,AS,C]",
  zh_classical=>"http://zh-classical.wikipedia.org Classical Chinese [,AS,C]",
  "zh-classical"=>"http://zh-classical.wikipedia.org Classical Chinese [,AS,C]",
  zh_yue=>"http://zh-yue.wikipedia.org Cantonese [73.7,AS,C]",
  "zh-yue"=>"http://zh-yue.wikipedia.org Cantonese [73.7,AS,C]",
  zu=>"http://zu.wikipedia.org Zulu [26,AF]",
  zz=>"&nbsp; All&nbsp;languages",
  zzz=>"&nbsp; All&nbsp;languages except English"
  );
}

sub SetLiterals
{
  @report_names = (
  "WikipediansContributors",
  "WikipediansNew",
  "WikipediansEditsGt5",
  "WikipediansEditsGt100",
  "ArticlesTotal",
  "ArticlesTotalAlt",
  "ArticlesNewPerDay",
  "ArticlesEditsPerArticle",
  "ArticlesBytesPerArticle",
  "ArticlesGt512Bytes",
  "ArticlesGt2048Bytes",
  "DatabaseEdits",
  "DatabaseSize",
  "DatabaseWords",
  "DatabaseLinks",
  "DatabaseWikiLinks",
  "DatabaseImageLinks",
  "DatabaseExternalLinks",
  "DatabaseRedirects",
  "UsagePageRequest",
  "UsageVisits",
  "RecentTrends"
  ) ;

  # provide default, may be overruled at localization file
  foreach $key (keys %wikipedias)
  {
    my $wikipedia = $wikipedias {$key} ;
    if ($wikipedia =~ /\[.*\]/)
    {
      $wikipedia2 = $wikipedia ;
      $wikipedia2 =~ s/^.*?\[// ;
      $wikipedia2 =~ s/\].*$// ;
      ($speakers, $regions) = split (',', $wikipedia2,2) ;
      @regions = split (',', $regions) ;
      $out_speakers {$key} = $speakers ;

      if ($speakers > $speakers_max)
      { $speakers_max = $speakers ; }

      foreach $region (@regions)
      {
        if (length ($region) != 2) # land codes China, India
        { $region = "" ; }
      }
      @regions = sort {$a cmp $b} @regions ;
      $out_regions  {$key} = join (',', @regions) ;
      $regions = join (',', @regions) ;
    }
    $wikipedia =~ s/\s*\[.*$// ; # remove speakers
    $out_urls      {$key} = $wikipedia ;
    $out_languages {$key} = $wikipedia ;

    if (($key !~ /_/) && ($key !~ /(?:nostalgia|sep11|species)/) && ($wikipedia =~ /wikipedia.org/)) # fiu-vro yes, fiu_vro no / also meta, commons etc no
    {
      ($key2 = $key) =~ s/"//g ;
      push @real_languages, $key2 ;
    }

    $out_urls      {$key} =~ s/(^[^\s]+).*$/$1/ ;
    $out_languages {$key} =~ s/^[^\s]+\s+(.*)$/$1/ ;
    $out_article   {$key} = "http://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
    $out_article   {$key} =~ s/ /_/g ;

    if ($mode_wb) { $out_urls {$key} =~ s/wikipedia/wikibooks/ ; }
    if ($mode_wk) { $out_urls {$key} =~ s/wikipedia/wiktionary/ ; }
    if ($mode_wn) { $out_urls {$key} =~ s/wikipedia/wikinews/ ; }
    if ($mode_wo) { $out_urls {$key} =~ s/wikipedia/wikivoyage/ ; }
    if ($mode_wq) { $out_urls {$key} =~ s/wikipedia/wikiquote/ ; }
    if ($mode_ws) { $out_urls {$key} =~ s/wikipedia/wikisource/ ; }
    if ($mode_wv) { $out_urls {$key} =~ s/wikipedia/wikiversity/ ; }
    if ($mode_wx) { $out_urls {$key} = $wikipedia ;

    $out_urls {$key} =~ s/(^[^\s]+).*$/$1/ ; }
  }

  %out_languages_en = %out_languages ;

  # language names in original language
  $out_languages_org {"ast"} = "Asturianu" ;
  $out_languages_org {"bg"} = "&#1073;&#1098;&#1083;&#1075;&#1072;&#1088;&#1089;&#1082;&#1080;" ;
  $out_languages_org {"br"} = "Brezhoneg" ;
  $out_languages_org {"ca"} = "Catal&agrave;" ;
  $out_languages_org {"cs"} = "&#269;e&#353;tina" ;
  $out_languages_org {"da"} = "Dansk" ;
  $out_languages_org {"de"} = "Deutsch" ;
  $out_languages_org {"en"} = "English" ;
  $out_languages_org {"eo"} = "Esperanto" ;
  $out_languages_org {"es"} = "Espa&ntilde;ol" ;
  $out_languages_org {"fr"} = "Fran&ccedil;ais" ;
  $out_languages_org {"hu"} = "Magyar" ; ;
  $out_languages_org {"he"} = "&#1506;&#1489;&#1512;&#1497;&#1514;" ;
  $out_languages_org {"id"} = "Bahasa Indonesia" ;
  $out_languages_org {"it"} = "Italiano" ;
  $out_languages_org {"ja"} = "&#26085;&#26412;&#35486;" ;
  $out_languages_org {"nl"} = "Nederlands" ;
  $out_languages_org {"nn"} = "Nynorsk" ;
  $out_languages_org {"pl"} = "Polski" ;
  $out_languages_org {"pt"} = "Portugu&ecirc;s" ;
  $out_languages_org {"ro"} = "Rom&#226;n&#259;" ;
  $out_languages_org {"ru"} = "&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;" ;
  $out_languages_org {"sk"} = "Sloven&#269;ina" ;
  $out_languages_org {"sl"} = "Sloven&#353;&#269;ina" ;
  $out_languages_org {"sr"} = "&#1057;&#1088;&#1087;&#1089;&#1082;&#1080;" ;
  $out_languages_org {"sv"} = "Svenska" ;
  $out_languages_org {"wa"} = "Walon" ;
  $out_languages_org {"zh"} = "&#20013;&#25991;" ;

  $out_none          = "" ;
  $out_html_doc      = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" " .
                       "\"http://www.w3.org/TR/html4/loose.dtd\">\n";

  # no unicode support
  $out_meta_8859     = "<meta http-equiv=\"Content-type\" content=\"text/html; charset=iso-8859-1\">\n" ;
  $out_meta_utf8     = "<meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\">\n" ;
  $out_meta_robots   = "<meta name=\"robots\" content=\"index,follow\">\n" ;

  $out_scriptfile    = "<script language=\"javascript\" type=\"text/javascript\" src=\"../WikipediaStatistics15.js\"></script>\n" ;

  $out_html_language = $language ; # default only, override when needed
  $out_web_address   = "http://" . $wp . ".wikipedia.org" ; # default only
  $out_mainpage      = "http://" . $wp . ".wikipedia.org" ;
  $out_wikipage      = "/wiki/" ;

  $out_csv_files     = "CSV files" ;


# ten thousand two hundred three + 4/10 = 10,203.4
  $out_thousands_separator = "," ;
  $out_decimal_separator   = "." ;

  if (defined ($wikipedias {$language}))
  { ($out_webaddress, $out_language_long) = split (" ", $wikipedias {$language}) ; }

  $out_no_wikimedia = "This script has been developed for <a href='http://www.wikimedia.org'>Wikimedia</a>.<br>" .
                      "Results on other sites running Mediawiki software may vary.<br>" .
                      "For comparison: <a href='http://stats.wikimedia.org/EN/Sitemap.htm'>Wikipedia statistics</a>." ;

  $out_webalizer_note = "Note: Webalizer data are not consistently available. Low figures for Dec 2003 are result of major server outage." ;
  $out_svg_firefox  = "<br><a href='http://magnusmanske.de/wikimaps/index.php/How_to_SVG-enable_Firefox'>How to enable SVG in Firefox for Windows</a>" ;

  # used for category reports, for now only in English
  $out_summary      = "Summary" ;
  $out_index        = "Index" ;
  $out_complete     = "Complete" ;
  $out_concise      = "Concise" ;
  $out_category_trees = "Wikipedia Category Overviews" ;
  $out_category_tree  = "Wikipedia Category Overview" ;

  $out_license      = "All data and images on this page are in the public domain." ;

  &Localization ;

  $out_html_stats = $out_webaddress . "/stats/index.html" ;
  foreach $line (@out_tbl3_legend)
  {
    if ($line =~ /webalizer/i)
    { $line =~ s/\'\'/$out_html_stats/ ; }
  }

  if ($#report_names != $#out_report_descriptions)
  { die "Table 'report_names' contains " . $#report_names . " entries.\n" .
        "Table 'out_report_descriptions' contains " . $#out_report_descriptions . " entries.\n" ; }
  if ($#report_names != $#out_tbl3_legend)
  { die "Table 'report_names' contains " . $#report_names . " entries.\n" .
        "Table 'out_tbl3_legend' contains " . $#out_tbl3_legend . " entries.\n" ; }

  $out_colors_perc = "<p><small>" .
                     "<font color='#800000'>x &lt; 0\%</font>&nbsp;&nbsp;&nbsp;&nbsp;" .
                     "<font color='#000000'>0\% &lt; x &lt; 25\%</font>&nbsp;&nbsp;&nbsp;&nbsp;" .
                     "<font color='#008000'>25\% &lt; x &lt; 75\%</font>&nbsp;&nbsp;&nbsp;&nbsp;" .
                     "<font color='#008000'><u>75\% &lt; x</u></font></small>\n" ;

  $out_documentation = "Documentation" ; # was "For documentation see <a href='http://meta.wikipedia.org/wiki/Wikistats'>meta</a>" ;
  $out_download_reports = "You can download the English version of these reports <a href='https://dumps.wikimedia.org/other/wikistats_1/reports/'>here</a> (also download <a href='https://dumps.wikimedia.org/other/wikistats_1/reports/common_files.zip'>common_files.zip</a>)" ;
  $out_download_data = "You can download aggregated data <a href='https://dumps.wikimedia.org/other/wikistats_1/'>here</a>"; 
}

sub GetProjectBaseUrl
{
  my $wp = shift ;
  my $base ;

  if ($mode_wb)
  { $base = "http://$wp.wikibooks.org/" ; }
  if ($mode_wk)
  { $base = "http://$wp.wiktionary.org/" ; }
  if ($mode_wn)
  { $base = "http://$wp.wikinews.org/" ; }
  if ($mode_wo)
  { $base = "http://$wp.wikivoyage.org/" ; }
  if ($mode_wp)
  { $base = "http://$wp.wikipedia.org/" ; }
  if ($mode_wq)
  { $base = "http://$wp.wikiquote.org/" ; }
  if ($mode_ws)
  { $base = "http://$wp.wikisource.org/" ; }
  if ($mode_wv)
  { $base = "http://$wp.wikiversity.org/" ; }

  if ($mode_wx)
  {
    if ($wp eq "sources")
    { $base = "http://wikisource.org/" ; }
    elsif ($wp eq "sep11")
    { $base = "http://sep11.wikipedia.org/" ; }
    elsif ($wp eq "foundation")
    { $base = "http://wikimediafoundation.org/" ; }
    elsif ($wp =~ /(\w\w+)(wikimedia)/)
    { $base = "http://$1.wikimedia.org/" ; }
    elsif ($wp eq "species")
    { $base = "http://species.wikipedia.org/" ; }
    elsif ($wp eq "mediawiki")
    { $base = "http://www.mediawiki.org/" ; }
    elsif ($wp eq "wikidata")
    { $base = "http://www.wikidata.org/" ; }
    else
    { $base = "http://$wp.wikimedia.org/" ; }
  }

  $base =~ s/_/-/g ; # e.g. zh-min-nan

  # print "GetProjectBaseUrl wp $wp base $base\n" ;
  return $base ;
}

sub GetDeepLinkWikistats2
{
  my $wp = shift ;
  my $lang = $out_languages {$wp} ;
  my $name = "Wiki unspecified for code '$wp'" ;
  my $url ;

  if ($mode_wb) { $name = "Wikibooks $lang"   ;  $domain = "$wp.wikibooks.org"   ; }
  if ($mode_wk) { $name = "Wiktionary $lang"  ;  $domain = "$wp.wiktionary.org"  ; }
  if ($mode_wn) { $name = "Wikinews $lang"    ;  $domain = "$wp.wikinews.org"    ; }
  if ($mode_wo) { $name = "Wikivoyage $lang"  ;  $domain = "$wp.wikivoyage.org"  ; } 
  if ($mode_wp) { $name = "Wikipedia $lang"   ;  $domain = "$wp.wikipedia.org"   ; }
  if ($mode_wq) { $name = "Wikiquote $lang"   ;  $domain = "$wp.wikiquote.org"   ; }
  if ($mode_ws) { $name = "Wikisource $lang"  ;  $domain = "$wp.wikisource.org"  ; }
  if ($mode_wv) { $name = "Wikiversity $lang" ;  $domain = "$wp.wikiversity.org" ; }

  if ($mode_wx)
  {
    if ($wp eq "sources")                      { $domain = "wikisource.org" ; }
    elsif ($wp eq "sep11")                     { $domain = "sep11.wikimedia.org" ; }
    elsif ($wp eq "foundation")                { $domain = "wikimediafoundation.org" ; }
    elsif ($wp =~ /(\w\w+)(wikimedia)/)        { $domain = "$wp wiki" ; }
    elsif ($wp eq "species")                   { $domain = "$wp.unspecified.org" ; }
    elsif ($wp eq "mediawiki")                 { $domain = "mediawiki.org" ; }
    elsif ($wp eq "wikidata")                  { $domain = "wikidata.org" ; }
  }

  my $link = "<a href='https://stats.wikimedia.org/v2/#/$domain'>$name</a>" ;
  return $link ;
}

1;

