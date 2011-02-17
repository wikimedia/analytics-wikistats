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


sub SetLanguageInfo
{
  # taken from http://meta.wikimedia.org/wiki/List_of_Wikipedias
  # see also http://www.loc.gov/standards/iso639-2/php/English_list.php
  # url might have been generated from language code, but there were (and will be?) exceptions
  # see also http://meta.wikimedia.org/wiki/Special:SiteMatrix
  # latest language name corrections provided by Mark Williamson
  # see also http://meta.wikimedia.org/wiki/Languages

  # numbers in square brackets: number of speakers in millions according to
  # http://en.wikipedia.org/w/index.php?title=List_of_languages_by_number_of_native_speakers&oldid=305926069 (Aug 5 2009)
  # includes secondary speakers (hence adds up to much more than 6 billion)
  %wikipedias = (
# mediawiki=>"http://wikimediafoundation.org Wikimedia",
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
  ab=>"http://ab.wikipedia.org Abkhazian [0.125,AS]",
  ace=>"http://ace.wikipedia.org Acehnese [3,AS]",
  af=>"http://af.wikipedia.org Afrikaans [13,AF]",
  ak=>"http://ak.wikipedia.org Akan [19,AF]",
  als=>"http://als.wikipedia.org Alemannic [10,EU]", # was Elsatian
  am=>"http://am.wikipedia.org Amharic [25,AF]",
  an=>"http://an.wikipedia.org Aragonese [0.01,EU]",
  ang=>"http://ang.wikipedia.org Anglo-Saxon [,EU]",
  ar=>"http://ar.wikipedia.org Arabic [530,AF,AS]",
  arc=>"http://arc.wikipedia.org Aramaic [2.2,AS]",
  arz=>"http://arz.wikipedia.org Egyptian Arabic [76,AF]",
  as=>"http://as.wikipedia.org Assamese [13,AS,I]",
  ast=>"http://ast.wikipedia.org Asturian [0.275,EU]",
  av=>"http://av.wikipedia.org Avar [0.06,EU]",
  ay=>"http://ay.wikipedia.org Aymara [2.2,SA]",
  az=>"http://az.wikipedia.org Azeri [27,AS]",
  ba=>"http://ba.wikipedia.org Bashkir [1.9,AS]",
  bar=>"http://bar.wikipedia.org Bavarian [12,EU]",
  bat_smg=>"http://bat-smg.wikipedia.org Samogitian [0.5,EU]",
  "bat-smg"=>"http://bat-smg.wikipedia.org Samogitian",
  bcl=>"http://bcl.wikipedia.org Central Bicolano [2.5,AS]",
  be=>"http://be.wikipedia.org Belarusian [6.5,EU]",
  "be-x-old"=>"http://be-x-old.wikipedia.org Belarusian (Tarakievica) [6.5,EU]",
  be_x_old=>"http://be-x-old.wikipedia.org Belarusian (Tarakievica) [6.5,EU]",
  bg=>"http://bg.wikipedia.org Bulgarian [12,EU]",
  bh=>"http://bh.wikipedia.org Bihari [,AS,I]",
  bi=>"http://bi.wikipedia.org Bislama [0.2,OC]",
  bjn=>"http://bjn.wikipedia.org Banjar [3.5,AS]",
  bm=>"http://bm.wikipedia.org Bambara [6,AF]",
  bn=>"http://bn.wikipedia.org Bengali [230,AS,I]",
  bo=>"http://bo.wikipedia.org Tibetan [7,AS]",
  bpy=>"http://bpy.wikipedia.org Bishnupriya Manipuri [0.45,AS,I]",
  br=>"http://br.wikipedia.org Breton [0.25,EU]",
  bs=>"http://bs.wikipedia.org Bosnian [2.7,EU]",
  bug=>"http://bug.wikipedia.org Buginese [4,AS]",
  bxr=>"http://bxr.wikipedia.org Buryat [0.4,AS]",
  ca=>"http://ca.wikipedia.org Catalan [9,EU]",
  cbk_zam=>"http://cbk-zam.wikipedia.org Chavacano [0.607,AS]",
  "cbk-zam"=>"http://cbk-zam.wikipedia.org Chavacano",
  cdo=>"http://cdo.wikipedia.org Min Dong [9.1,AS,C]",
  ce=>"http://ce.wikipedia.org Chechen [1.33,EU]",
  ceb=>"http://ceb.wikipedia.org Cebuano [20,AS]",
  ch=>"http://ch.wikipedia.org Chamorro [0.06,OC]",
  cho=>"http://cho.wikipedia.org Choctaw [0.0179,NA]", # was Chotaw
  chr=>"http://chr.wikipedia.org Cherokee [0.018,NA]",
  chy=>"http://chy.wikipedia.org Cheyenne [0.000712,NA]",
  ckb=>"http://ckb.wikipedia.org Sorani [4,AS]",
  co=>"http://co.wikipedia.org Corsican [0.25,EU]",
  cr=>"http://cr.wikipedia.org Cree [0.117,NA]",
  crh=>"http://crh.wikipedia.org Crimean Tatar [0.456,EU,AS]",
  cs=>"http://cs.wikipedia.org Czech [12,EU]",
  csb=>"http://csb.wikipedia.org Cassubian [0.05,EU]",
  cu=>"http://cv.wikipedia.org Old Church Slavonic [,EU]",
  cv=>"http://cv.wikipedia.org Chuvash [1.3,AS]",
  cy=>"http://cy.wikipedia.org Welsh [0.75,EU]",
  da=>"http://da.wikipedia.org Danish [6,EU]",
  de=>"http://de.wikipedia.org German [185,EU]",
  diq=>"http://diq.wikipedia.org Zazaki [2,AS]",
  dk=>"http://dk.wikipedia.org Danish [6]",
  dsb=>"http://dsb.wikipedia.org Lower Sorbian [0.014,EU]",
  dv=>"http://dv.wikipedia.org Divehi [0.3,AS,I]",
  dz=>"http://dz.wikipedia.org Dzongkha [0.6,AS,I]",
  ee=>"http://ee.wikipedia.org Ewe [3.5,AF]",
  el=>"http://el.wikipedia.org Greek [15,EU]",
  eml=>"http://eml.wikipedia.org Emilian-Romagnol [2,EU]",
  en=>"http://en.wikipedia.org English [1500,EU,NA,OC,AS,AF]",
  eo=>"http://eo.wikipedia.org Esperanto [1.1,AL]",
  es=>"http://es.wikipedia.org Spanish [500,EU,NA,SA,AS,AF]",
  et=>"http://et.wikipedia.org Estonian [1.25,EU]",
  eu=>"http://eu.wikipedia.org Basque [1.06,EU]",
  ext=>"http://ext.wikipedia.org Extremaduran [0.5,EU]",
  fa=>"http://fa.wikipedia.org Persian [107,AS]",
  ff=>"http://ff.wikipedia.org Fulfulde [13,AF]",
  fi=>"http://fi.wikipedia.org Finnish [6,EU]",
  "fiu-vro"=>"http://fiu-vro.wikipedia.org Voro [0.07,EU]",
  fiu_vro=>"http://fiu-vro.wikipedia.org Voro [0.07,EU]",
  fj=>"http://fj.wikipedia.org Fijian [0.55,OC]",
  fo=>"http://fo.wikipedia.org Faroese [0.07,EU]", # was Faeroese
  fr=>"http://fr.wikipedia.org French [200,EU,NA,AF,OC]",
  frp=>"http://frp.wikipedia.org Arpitan [0.113,EU]",
  frr=>"http://frr.wikipedia.org North Frisian [0.01,EU]",
  fur=>"http://fur.wikipedia.org Friulian [0.794,EU]",
  fy=>"http://fy.wikipedia.org Frisian [0.65,EU]",
  ga=>"http://ga.wikipedia.org Irish [0.53,EU]",
  gan=>"http://gan.wikipedia.org Gan [35,AS,C]",
  gay=>"http://gay.wikipedia.org Gayo",
  gd=>"http://gdi.wikipedia.org Scots Gaelic [0.07,EU]", # was Scottish Gaelic
  gl=>"http://gl.wikipedia.org Galician [3.5,EU]", # was Galego
  glk=>"http://glk.wikipedia.org Gilaki [3.3,AS]",
  gn=>"http://gn.wikipedia.org Guarani [7,SA]",
  got=>"http://got.wikipedia.org Gothic [,EU]",
  gu=>"http://gu.wikipedia.org Gujarati [46,AS,I]",
  gv=>"http://gv.wikipedia.org Manx [0.0017,EU]", # was Manx Gaelic
  ha=>"http://ha.wikipedia.org Hausa [39,AF]",
  hak=>"http://hak.wikipedia.org Hakka [34,AS,C]",
  haw=>"http://haw.wikipedia.org Hawai'ian [0.027,OC]", # was Hawaiian
  he=>"http://he.wikipedia.org Hebrew [10,AS]",
  hi=>"http://hi.wikipedia.org Hindi [550,AS]",
  hif=>"http://hif.wikipedia.org Fiji Hindi [0.46,OC]",
  ho=>"http://ho.wikipedia.org Hiri Motu",
  hr=>"http://hr.wikipedia.org Croatian [6.2,EU]",
  hsb=>"http://hsb.wikipedia.org Upper Sorbian [0.04,EU]",
  ht=>"http://ht.wikipedia.org Haitian [12,NA]",
  hu=>"http://hu.wikipedia.org Hungarian [15,EU]",
  hy=>"http://hy.wikipedia.org Armenian [5.5,AS]",
  hz=>"http://hz.wikipedia.org Herero [0.13,AF]",
  ia=>"http://ia.wikipedia.org Interlingua [,AL]",
  iba=>"http://iba.wikipedia.org Iban",
  id=>"http://id.wikipedia.org Indonesian [250,AS]",
  ie=>"http://ie.wikipedia.org Interlingue [,AL]",
  ig=>"http://ig.wikipedia.org Igbo [22.5,AF]",
  ii=>"http://ii.wikipedia.org Yi [2,AS,C]",
  ik=>"http://ik.wikipedia.org Inupiak [0.0021,NA]",
  ilo=>"http://ilo.wikipedia.org Ilokano [10,AS]",
  io=>"http://io.wikipedia.org Ido [,AL]",
  is=>"http://is.wikipedia.org Icelandic [0.32,EU]",
  it=>"http://it.wikipedia.org Italian [70,EU]",
  iu=>"http://iu.wikipedia.org Inuktitut [0.03,NA]",
  ja=>"http://ja.wikipedia.org Japanese [132,AS]",
  jbo=>"http://jbo.wikipedia.org Lojban [,AL]",
  jv=>"http://jv.wikipedia.org Javanese [80,AS]",
  ka=>"http://ka.wikipedia.org Georgian [4.2,EU]",
  kaa=>"http://kaa.wikipedia.org Karakalpak [0.41,AS]",
  kab=>"http://ka.wikipedia.org Kabyle [8,AF]",
  kaw=>"http://kaw.wikipedia.org Kawi",
  kg=>"http://kg.wikipedia.org Kongo [7,AF]",
  ki=>"http://ki.wikipedia.org Kikuyu [5.4,AF]",
  kj=>"http://kj.wikipedia.org Kuanyama",
  kk=>"http://kk.wikipedia.org Kazakh [12,AS]",
  kl=>"http://kl.wikipedia.org Greenlandic [0.05,NA]",
  km=>"http://km.wikipedia.org Khmer [18.5,AS]", # was Cambodian
  kn=>"http://kn.wikipedia.org Kannada [47,AS,I]",
  ko=>"http://ko.wikipedia.org Korean [78,AS]",
  koi=>"http://koi.wikipedia.org Komi-Permyak [0.094,EU]",
  kr=>"http://kr.wikipedia.org Kanuri [4,AF]",
  ks=>"http://ks.wikipedia.org Kashmiri [4.6,AS,I]",
  ksh=>"http://ksh.wikipedia.org Ripuarian [0.25,EU]",
  ku=>"http://ku.wikipedia.org Kurdish [26,AS]",
  kv=>"http://kv.wikipedia.org Komi [0.293,EU]",
  kw=>"http://kw.wikipedia.org Cornish [0.000245,EU]", # was Kornish
  ky=>"http://ky.wikipedia.org Kirghiz [5,AS]",
  la=>"http://la.wikipedia.org Latin [,W]",
  lad=>"http://lad.wikipedia.org Ladino [0.109,AS]",
  lb=>"http://lb.wikipedia.org Luxembourgish [0.39,EU]", # was Letzeburgesch
  lbe=>"http://lbe.wikipedia.org Lak [0.12,AS]",
  lg=>"http://lg.wikipedia.org Ganda [10,AF]",
  li=>"http://li.wikipedia.org Limburgish [1.6,EU]",
  lij=>"http://lij.wikipedia.org Ligurian [1.9,EU]",
  lmo=>"http://lmo.wikipedia.org Lombard [3,EU]",
  ln=>"http://ln.wikipedia.org Lingala [25,AF]",
  lo=>"http://lo.wikipedia.org Laotian [5.2,AS]",
  ls=>"http://ls.wikipedia.org Latino Sine Flexione",
  lt=>"http://lt.wikipedia.org Lithuanian [3.5,EU]",
  lv=>"http://lv.wikipedia.org Latvian [1.6,EU]",
  mad=>"http://mad.wikipedia.org Madurese [14]",
  mak=>"http://mak.wikipedia.org Makasar [2]",
  map_bms=>"http://map-bms.wikipedia.org Banyumasan [13.5,AS]",
  "map-bms"=>"http://map-bms.wikipedia.org Banyumasan",
  mdf=>"http://mdf.wikipedia.org Moksha [0.5,EU]",
  mg=>"http://mg.wikipedia.org Malagasy [20,AF]",
  mh=>"http://mh.wikipedia.org Marshallese [0.0439,OC]",
  mhr=>"http://mhr.wikipedia.org Eastern Mari [0.3,EU]",
  mi=>"http://mi.wikipedia.org Maori [0.157,OC]",
  min=>"http://min.wikipedia.org Minangkabau [6.5]",
  minnan=>"http://minnan.wikipedia.org Minnan",
  mk=>"http://mk.wikipedia.org Macedonian [2.7,EU]",
  ml=>"http://ml.wikipedia.org Malayalam [37,AS,I]",
  mn=>"http://mn.wikipedia.org Mongolian [5.2,AS]",
  mo=>"http://mo.wikipedia.org Moldavian [,EU]",
  mr=>"http://mr.wikipedia.org Marathi [90,AS,I]",
  mrj=>"http://mrj.wikipedia.org Western Mari [0.3,A]",
  ms=>"http://ms.wikipedia.org Malay [300,AS]",
  mt=>"http://mt.wikipedia.org Maltese [0.37,EU]",
  mus=>"http://mus.wikipedia.org Muskogee [0.006,NA]",
  mwl=>"http://mwl.wikipedia.org Mirandese [0.015,EU]",
  my=>"http://my.wikipedia.org Burmese [52,AS]",
  myv=>"http://myv.wikipedia.org Erzya [0.5,AS]",
  mzn=>"http://mzn.wikipedia.org Mazandarani [3.7,AS]",
  na=>"http://na.wikipedia.org Nauruan [0.006,OC]", # was Nauru
  nah=>"http://nah.wikipedia.org Nahuatl [1.45,NA]",
  nap=>"http://nap.wikipedia.org Neapolitan [7.5,EU]",
  nds=>"http://nds.wikipedia.org Low Saxon [10,EU]",
  nds_nl=>"http://nds-nl.wikipedia.org Dutch Low Saxon [10,EU]",
  "nds-nl"=>"http://nds-nl.wikipedia.org Dutch Low Saxon [10,EU]",
  ne=>"http://ne.wikipedia.org Nepali [30,AS,I]",
  new=>"http://new.wikipedia.org Nepal Bhasa [0.8,AS,I]",
  ng=>"http://ng.wikipedia.org Ndonga [0.690,AF]",
  nl=>"http://nl.wikipedia.org Dutch [27,EU,SA]",
  nov=>"http://nov.wikipedia.org Novial [,AL]",
  nrm=>"http://nrm.wikipedia.org Norman [,EU]",
  nn=>"http://nn.wikipedia.org Nynorsk [4.7,EU]", # was Neo-Norwegian
  no=>"http://no.wikipedia.org Norwegian [4.7,EU]",
  nv=>"http://nv.wikipedia.org Navajo [0.178,NA]",
  ny=>"http://ny.wikipedia.org Chichewa [9.3,AF]",
  oc=>"http://oc.wikipedia.org Occitan [1.9,EU]",
  om=>"http://om.wikipedia.org Oromo [25.5,AF]",
  or=>"http://or.wikipedia.org Oriya [31,AS,I]",
  os=>"http://os.wikipedia.org Ossetic [0.52,AS]",
  pa=>"http://pa.wikipedia.org Punjabi [104,AS,I]",
  pag=>"http://pag.wikipedia.org Pangasinan [1.5,AS]",
  pam=>"http://pam.wikipedia.org Kapampangan [2.9,AS]",
  pap=>"http://pap.wikipedia.org Papiamentu [0.329,SA]",
  pcd=>"http://pcd.wikipedia.org Picard [,EU]",
  pdc=>"http://pdc.wikipedia.org Pennsylvania German [0.250,NA]",
  pi=>"http://pi.wikipedia.org Pali [,AS]",
  pih=>"http://pih.wikipedia.org Norfolk [0.0006,OC]",
  pl=>"http://pl.wikipedia.org Polish [43,EU]",
  pms=>"http://pms.wikipedia.org Piedmontese [2,EU]",
  pnb=>"http://pnb.wikipedia.org Western Panjabi [60,AS]",
  pnt=>"http://pnt.wikipedia.org Pontic [0.325,EU]",
  ps=>"http://ps.wikipedia.org Pashto [26,AS]",
  pt=>"http://pt.wikipedia.org Portuguese [290,EU,SA,AF,AS]",
  qu=>"http://qu.wikipedia.org Quechua [10.4,SA]",
  rm=>"http://rm.wikipedia.org Romansh [0.035,EU]", # was Rhaeto-Romance
  rmy=>"http://rmy.wikipedia.org Romani [2.5,EU]",
  rn=>"http://rn.wikipedia.org Kirundi [4.6,AF]",
  ro=>"http://ro.wikipedia.org Romanian [28,EU]",
  roa_rup=>"http://roa-rup.wikipedia.org Aromanian [0.3,EU]",
  "roa-rup"=>"http://roa-rup.wikipedia.org Aromanian [0.5]",
  roa_tara=>"http://roa-tara.wikipedia.org Tarantino [0.9,EU]",
  "roa-tara"=>"http://roa-tara.wikipedia.org Tarantino",
  ru=>"http://ru.wikipedia.org Russian [278,EU,AS]",
  ru_sib=>"http://ru-sib.wikipedia.org Siberian",
  "ru-sib"=>"http://ru-sib.wikipedia.org Siberian",
  rw=>"http://rw.wikipedia.org Kinyarwanda [12,AF]",
  sa=>"http://sa.wikipedia.org Sanskrit [0.05,AS,I]",
  sah=>"http://sah.wikipedia.org Sakha [0.456,AS]",
  sc=>"http://sc.wikipedia.org Sardinian [1.85,EU]",
  scn=>"http://scn.wikipedia.org Sicilian [8,EU]",
  sco=>"http://sco.wikipedia.org Scots [1.5,EU]",
  sd=>"http://sd.wikipedia.org Sindhi [41,AS,I]",
  se=>"http://se.wikipedia.org Northern Sami [0.02,EU]",
  sg=>"http://sg.wikipedia.org Sangro [3,AF]",
  sh=>"http://sh.wikipedia.org Serbo-Croatian [23,EU]",
  si=>"http://si.wikipedia.org Sinhala [19,AS]",
  simple=>"http://simple.wikipedia.org Simple English [1500,EU,NA,OC,AS,AF]",
  sk=>"http://sk.wikipedia.org Slovak [7,EU]",
  sl=>"http://sl.wikipedia.org Slovene [2.4,EU]",
  sm=>"http://sm.wikipedia.org Samoan [0.370,OC]",
  sn=>"http://sn.wikipedia.org Shona [7,AF]",
  so=>"http://so.wikipedia.org Somali [13.5,AF]",
  sq=>"http://sq.wikipedia.org Albanian [6,EU]",
  sr=>"http://sr.wikipedia.org Serbian [12,EU]",
  srn=>"http://srn.wikipedia.org Sranan [0.3,SA]",
  ss=>"http://ss.wikipedia.org Siswati [3,AF]",
  st=>"http://st.wikipedia.org Sesotho [4.9,AF]",
  stq=>"http://stq.wikipedia.org Saterland Frisian [0.002,EU]",
  su=>"http://su.wikipedia.org Sundanese [27,AS]",
  sv=>"http://sv.wikipedia.org Swedish [10,EU]",
  sw=>"http://sw.wikipedia.org Swahili [50,AF]",
  szl=>"http://szl.wikipedia.org Silesian [0.056,EU]",
  ta=>"http://ta.wikipedia.org Tamil [66,AS,I]",
  te=>"http://te.wikipedia.org Telugu [80,AS,I]",
  test=>"http://test.wikipedia.org Test",
  tet=>"http://tet.wikipedia.org Tetum [0.8,AS]",
  tg=>"http://tg.wikipedia.org Tajik [4.4,AS]",
  th=>"http://th.wikipedia.org Thai [73,AS]",
  ti=>"http://ti.wikipedia.org Tigrinya [6.7,AF]",
  tk=>"http://tk.wikipedia.org Turkmen [9,AS]",
  tl=>"http://tl.wikipedia.org Tagalog [90,AS]",
  tlh=>"http://tlh.wikipedia.org Klingon", # was Klignon
  tn=>"http://tn.wikipedia.org Setswana [4.4,AF]",
  to=>"http://to.wikipedia.org Tongan [0.105,OC]",
  tokipona=>"http://tokipona.wikipedia.org Tokipona",
  tpi=>"http://tpi.wikipedia.org Tok Pisin [5.5,AS]",
  tr=>"http://tr.wikipedia.org Turkish [70,EU,AS]",
  ts=>"http://ts.wikipedia.org Tsonga [3.3,AF]",
  tt=>"http://tt.wikipedia.org Tatar [8,AS]",
  tum=>"http://tum.wikipedia.org Tumbuka [2,AF]",
  turn=>"http://turn.wikipedia.org Turnbuka",
  tw=>"http://tw.wikipedia.org Twi [14.8,AF]",
  ty=>"http://ty.wikipedia.org Tahitian [0.120,OC]",
  udm=>"http://udm.wikipedia.org Udmurt [0.550,AS]",
  ug=>"http://ug.wikipedia.org Uyghur [10,AS,C]",
  uk=>"http://uk.wikipedia.org Ukrainian [45,EU]",
  ur=>"http://ur.wikipedia.org Urdu [60,AS,I]",
  uz=>"http://uz.wikipedia.org Uzbek [23.5,AS]",
  ve=>"http://ve.wikipedia.org Venda [0.875,AF]",
  vec=>"http://vec.wikipedia.org Venetian [2.3,EU]",
  vi=>"http://vi.wikipedia.org Vietnamese [80,AS]",
  vls=>"http://vls.wikipedia.org West Flemish [1.06,EU]",
  vo=>"http://vo.wikipedia.org Volap&uuml;k [0.000010,AL]",
  wa=>"http://wa.wikipedia.org Walloon [0.6,EU]",
  war=>"http://war.wikipedia.org Waray-Waray [3.1,AS]",
  wo=>"http://wo.wikipedia.org Wolof [3.6,AF]",
  wuu=>"http://wuu.wikipedia.org Wu [77,AS,C]",
  xal=>"http://xal.wikipedia.org Kalmyk [0.174,EU]",
  xh=>"http://xh.wikipedia.org Xhosa [7.9,AF]",
  yi=>"http://yi.wikipedia.org Yiddish [3.2,W]",
  yo=>"http://yo.wikipedia.org Yoruba [25,AF]",
  za=>"http://za.wikipedia.org Zhuang [14,AS,C]",
  zea=>"http://zea.wikipedia.org Zealandic [0.220,EU]",
  zh=>"http://zh.wikipedia.org Chinese [1300,AS]",
  zh_min_nan=>"http://zh-min-nan.wikipedia.org Min Nan [49,AS,C]",
  "zh-min-nan"=>"http://zh-min-nan.wikipedia.org Min Nan [60]",
  zh_classical=>"http://zh-classical.wikipedia.org Classical Chinese [,AS,C]",
  "zh-classical"=>"http://zh-classical.wikipedia.org Classical Chinese [,AS,C]",
  zh_yue=>"http://zh-yue.wikipedia.org Cantonese [71,AS,C]",
  "zh-yue"=>"http://zh-yue.wikipedia.org Cantonese [71,AS,C]",
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
  "ArticlesGt500Bytes",
  "ArticlesGt1500Bytes",
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

# language specific part of user page url
  $out_userpages     {"ar"} = "User" ;
  $out_userpages     {"ast"} = "User" ;
  $out_userpages     {"bg"} = "User" ;
  $out_userpages     {"br"} = "User" ;
  $out_userpages     {"bs"} = "User" ;
  $out_userpages     {"cs"} = "Wikipedista" ;
  $out_userpages     {"cy"} = "User" ;
  $out_userpages     {"da"} = "Bruger" ;
  $out_userpages     {"de"} = "Benutzer" ;
  $out_userpages     {"el"} = "User" ;
  $out_userpages     {"en"} = "User" ;
  $out_userpages     {"eo"} = "Vikipediisto" ;
  $out_userpages     {"es"} = "Usuario" ;
  $out_userpages     {"fr"} = "Utilisateur" ;
  $out_userpages     {"he"} = "%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9" ;
  $out_userpages     {"hi"} = "%E0%A4%B8%E0%A4%A6%E0%A4%B8%E0%A5%8D%E0%A4%AF_" ;
  $out_userpages     {"hr"} = "User" ;
  $out_userpages     {"hu"} = "User" ;
  $out_userpages     {"id"} = "Pengguna" ;
  $out_userpages     {"it"} = "Utente" ;
  $out_userpages     {"ja"} = "%E5%88%A9%E7%94%A8%E8%80%85" ;
  $out_userpages     {"ml"} = "User" ;
  $out_userpages     {"ms"} = "User" ;
  $out_userpages     {"nah"}= "User" ;
  $out_userpages     {"nl"} = "Gebruiker" ;
  $out_userpages     {"nn"} = "Bruker" ;
  $out_userpages     {"ko"} = "%EC%82%AC%EC%9A%A9%EC%9E%90" ;
  $out_userpages     {"pl"} = "Wikipedysta" ;
  $out_userpages     {"pt"} = "Usu&aacute;rio" ;
  $out_userpages     {"ro"} = "Utilizator" ;
  $out_userpages     {"sh"} = "User" ;
  $out_userpages     {"sk"} = "User" ;
  $out_userpages     {"sl"} = "User" ;
  $out_userpages     {"sr"} = "User" ;
  $out_userpages     {"ru"} = "%D0%A3%D1%87%D0%B0%D1%81%D1%82%D0%BD%D0%B8%D0%BA" ;
  $out_userpages     {"sv"} = "Anv%E4ndare" ;
  $out_userpages     {"tr"} = "User" ;
  $out_userpages     {"wa"} = "Uzeu" ;
  $out_userpages     {"zh"} = "User" ;

  if ($mode_wn)
  {
    $out_userpages   {"pl"} = "Wikireporter" ;
  }

  if ($mode_ws)
  {
    $out_userpages   {"cs"} = "U%C5%BEivatel" ;
    $out_userpages   {"pl"} = "Wikiskryba" ;
  }

  $out_none          = "" ;
  $out_html_doc      = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" " .
                       "\"http://www.w3.org/TR/html4/loose.dtd\">\n";

  # no unicode support
  $out_meta_8859     = "<meta http-equiv=\"Content-type\" content=\"text/html; charset=iso-8859-1\">\n" ;
  $out_meta_utf8     = "<meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\">\n" ;
  $out_meta_robots   = "<meta name=\"robots\" content=\"index,follow\">\n" ;

  $out_scriptfile    = "<script language=\"javascript\" type=\"text/javascript\" src=\"..\/WikipediaStatistics14.js\"></script>\n" ;

  $out_html_language = $language ; # default only, override when needed
  $out_web_address   = "http://" . $wp . ".wikipedia.org" ; # default only
  $out_mainpage      = "http://" . $wp . ".wikipedia.org" ;
  $out_wikipage      = "/wiki/" ;

# ten thousand two hundred three + 4/10 = 10,203.4
  $out_thousands_separator = "," ;
  $out_decimal_separator   = "." ;

  if (defined ($wikipedias {$language}))
  { ($out_webaddress, $out_language_long) = split (" ", $wikipedias {$language}) ; }

  $out_no_wikimedia = "This script has been developed for <a href='http://www.wikimedia.org'>Wikimedia</a>.<br>" .
                      "Results on other sites running Mediawiki software may vary.<br>" .
                      "For comparison: <a href='http://en.wikipedia.org/wikistats/EN/Sitemap.htm'>Wikipedia statistics</a>." ;

  $out_webalizer_note = "Note: Webalizer data are not consistently available. Low figures for Dec 2003 are result of major server outage." ;
  $out_svg_firefox  = "<br><a href='http://magnusmanske.de/wikimaps/index.php/How_to_SVG-enable_Firefox'>How to enable SVG in Firefox for Windows</a>" ;

  # used for category reports, for now only in English
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

  $out_documentation = "For documentation see <a href='http://meta.wikipedia.org/wiki/Wikistats'>meta</a>" ; #new
}

1;
