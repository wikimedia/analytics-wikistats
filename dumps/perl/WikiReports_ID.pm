#!/usr/bin/perl

# please specify all accented characters as utf-8 or as html codes (like &agrave; or $#224;)
# for a list of html codes see http://evolt.org/article/ala/17/21234/

sub SetLiterals_ID
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Statistik Wikipedia" ;
$out_charts       = "Grafik Wikipedia" ;
$out_btn_tables   = "Tabel" ;
$out_btn_table    = "Tabel" ;
$out_btn_charts   = "Grafik" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipedia" ;
$out_wikipedians   = "wikipediawan" ; # new

$out_wiktionary   = "Wiktionary" ;
$out_wiktionaries = "Wiktionary" ;
$out_wiktionarians   = "wiktionarians" ; # new

$out_wikibook        = "Wikibook" ;  # new
$out_wikibooks       = "Wikibook" ; # new
$out_wikibookies     = "Pengarang Wikibook" ; # new

$out_wikiquote       = "Wikiquote" ;  # new
$out_wikiquotes      = "Wikiquote" ; # new
$out_wikiquotarians  = "Wikiquotarians" ; # new

$out_wikinews        = "Wikinews" ;  # new
$out_wikinewssites   = "Situs Wikinews" ; # new
$out_wikireporters   = "WartawanWiki" ; # new

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisource" ; # new
$out_wikilibrarians  = "PustakawanWiki" ; # new

$out_wikispecial     = "Wikispecial" ;  # new
$out_wikispecials    = "Situs Wikispecial" ; # new
$out_wikispecialists = "Pengarang" ; # new

$out_wikimedia       = "Wikimedia" ;       # new
$out_wikimedia_sites = "Situs Wikimedia" ; # new

$out_comparisons  = "Perbandingan" ;

$out_creation_history = "Sejarah pembuatan" ; # new
$out_accomplishments  = "Pencapaian" ; # new
$out_created          = "Dibuat" ; # new
$average_increase     = "Peningkatan rata-rata per bulan" ; # new

$out_explanation_categories = "Di setiap kategori, Anda menemukan jumlah artikel yang termasuk dalam kategori tersebut" ; # new
$out_follow_links           = "Kiat: untuk menghindari pemuatan ulang seluruh halaman, gunakan Shift+Mouseclick untuk mengikuti suatu pranala" ; # new
$out_categories_templates   = "Tag kategori yang disisipkan melalui suatu suatu templat <b>belum</b> dikenali." ; # new
$out_categories_redirects   = "Tinjauan ini juga dapat mencantumkan halaman-halaman kategori yang hanya mengandung tag pengalihan." ;

$out_license      = "Semua data dan gambar pada halaman ini adalah domain publik." ; # new
$out_generated    = "Dihasilkan pada " ;
$out_sqlfiles     = "dari berkas dump SQL dari " ;
$out_version      = "Versi skrip:" ;
$out_author       = "Penulis" ;
$out_mail         = "Surel" ;
$out_site         = "Situs web" ;
$out_home         = "Beranda" ;
$out_sitemap      = "Peta situs";
$out_rendered     = "Grafik dihasilkan dengan " ;
$out_generated2   = "Jika dihasilkan:" ;       # new
$out_easytimeline = "Indeks ke grafik EasyTimeline per Wikipedia" ; # new
$out_categories   = "Tinjauan Kategori per Wikipedia" ; # new
$out_botactivity  = "Aktivitas bot" ;     # new
$out_stats_for    = "Statistik untuk " ; # new
$out_stats_per    = "Statistik pada " ; # new

$out_gigabytes    = "GB" ;
$out_megabytes    = "MB" ;
$out_kilobytes    = "kB" ;
$out_bytes        = "B" ;
$out_million      = "M" ;
$out_thousand     = "k" ;

$out_date         = "Tanggal" ;
$out_year         = "tahun" ;
$out_month        = "bulan" ;
$out_mean         = "Rerata" ;
$out_growth       = "Pertumbuhan" ;
$out_total        = "Total" ;
$out_bars         = "Batang" ;
$out_words        = "kata" ;
$out_zoom         = "Sorot" ;
$out_scripts      = "Skrip" ; # new

$out_new          = "baru" ; # new
$out_all          = "semua" ; # new  (people)
$out_all2         = "semua" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " konversi (semi-)otomatis telah dilakukan." ;

$out_phaseIII     = "Hanya Wikipedia yang menggunakan perangkat lunak <a href='http://www.mediawiki.org'>MediaWiki</a> yang dimasukkan." ;

$out_svg_viewer   = "Untuk melihat isi halaman ini Anda perlu suatu " .
                    "penampil SVG, mis. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "untuk MS Explorer Win/Mac (bebas)" ;
$out_rendering    = "Mengolah.... Mohon tunggu" ;

$out_sort_order   = "Wikipedia berurut sesuai jumlah pranala internal (kecuali pengalihan)<br>" .
                    "Tampaknya ini adalah dasar yang lebih adil untuk membandingkan upaya keseluruhan dibandingkan penggunaan jumlah artikel maupun ukuran basis data:<br>" .
                    "Jumlah artikel tidak terlalu bermakna karena fakta bahwa beberapa Wikipedia terutama hanya terdiri dari artikel pendek,<br>" .
                    "atau bahkan banyak artikel otomatis, sedangkan Wikipedia lain memiliki artikel yang lebih sedikit tapi lebih panjang, ditulis sendiri.<br>" .
                    "Ukuran basis data tergantung pada sistem kode (karakter unicode memiliki beberapa bita) dan<br>" .
                    "pada berapa banyak makna tersampaikan dengan satu karakter (mis. Karakter Cina adalah seluruh huruf).<br>" ;

$out_webalizer_note = "Catatan: Data Webalizer tidak selalu tersedia. Jumlah yang kecil pada Des 2003 disebabkan ketaktersediaan server besar-besaran." ;
$out_not_included = "Tidak termasuk" ; #new

$out_average_1    = "jumlah rerata sepanjang bulan yang ditampilkan" ;
$out_growth_1     = "jumlah rerata pertumbuhan bulanan sepanjang bulan yang ditampilkan" ;
$out_formula      = "rumus" ;
$out_value        = "nilai" ;
$out_monthes      = "bulan" ;
$out_skip_values  = "(Wikipedia dengan nilai < 10 diabaikan)" ;

$out_history      = "Catatan: jumlah pada bulan pertama terlalu kecil. " .
                    "Riwayat revisi tidak selalu disimpan pada masa-masa awal." ;

$out_unique_users = "Pengguna unik" ; # new
$out_archived     = "Diarsipkan" ; # new
$out_reg          = "Terdaft." ;   # new (Reg. = Registered)
$out_unreg        = "Anon." ; # new (Unreg. = Unregistered)

$out_reg_users_edited = "suntingan peng. terdaft." ; # new
$out_reg_user_edited  = "suntingan peng. terdaft." ;  # new

$out_index        = "Indeks" ;    # new
$out_complete     = "Lengkap" ; # new
$out_concise      = "Ringkas" ;  # new

$out_categories_complete = "Lengkap" ; # new
$out_categories_concise  = "Ringkas" ;  # new
$out_categories_main     = "Utama" ;     # new
$out_category_trees      = "Tinjauan Kategori Wikipedia" ; # new
$out_category_tree       = "Tinjauan Kategori Wikipedia" ;  # new

$out_license      = "Semua data dan gambar di halaman ini adalah domain publik." ; # new

$out_tbl1_intro   = "[[2]] wikipediawan aktif belakangan, " .
                    "berurut sesuai jumlah kontribusi:" ;
$out_tbl1_intro2  = "hanya suntingan artikel yang dihitung, bukan suntingan pada halaman diskusi, dll" ;
$out_tbl1_intro3  = "&Delta; = perubahan peringkat dalam 30 hari terakhir" ;

$out_tbl1_hdr1    = "Pengguna" ;
$out_tbl1_hdr2    = "Suntingan" ;
$out_tbl1_hdr3    = "Suntingan pertama" ;
$out_tbl1_hdr4    = "Suntingan terakhir" ;
$out_tbl1_hdr5    = "tanggal" ;
$out_tbl1_hdr6    = "hari<br>lalu" ;
$out_tbl1_hdr7    = "total" ;
$out_tbl1_hdr8    = "30 hari<br>terakhir" ;
$out_tbl1_hdr9    = "peringkat" ;
$out_tbl1_hdr10   = "sekarang" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Artikel" ;
$out_tbl1_hdr13   = "Lainnya" ;

$out_tbl2_intro  = "[[3]] wikipediawan yang baru-baru ini menghilang, " .
                   "berurut sesuai jumlah kontribusi:" ;

$out_tbl3_intro   = "Pertumbuhan jumlah wikipediawan terdaftar yang aktif dan aktivitasnya" ;

$out_tbl3_hdr1a   = "Wikipediawan" ;
$out_tbl3_hdr1e   = "Artikel" ;
$out_tbl3_hdr1l   = "Basis data" ;
$out_tbl3_hdr1o   = "Pranala" ;
$out_tbl3_hdr1t   = "Penggunaan Harian" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(pengguna terdaftar)" ;
$out_tbl3_hdr1e2  = "(kec. pengalihan)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "baru" ;
$out_tbl3_hdr2c   = "suntingan" ;
$out_tbl3_hdr2e   = "jumlah" ;
$out_tbl3_hdr2f   = "baru<br>per&nbsp;hari" ;
$out_tbl3_hdr2h   = "rerata" ;
$out_tbl3_hdr2j   = "lebih&nbsp;dari" ;
$out_tbl3_hdr2l   = "suntinga" ;
$out_tbl3_hdr2m   = "besar" ;
$out_tbl3_hdr2n   = "kata" ;
$out_tbl3_hdr2o   = "internal" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "berkas" ;
$out_tbl3_hdr2r   = "eksternal" ;
$out_tbl3_hdr2s   = "pengalihan" ;
$out_tbl3_hdr2t   = "permintaan<br>halaman" ;
$out_tbl3_hdr2u   = "kunjungan" ;
$out_tbl3_hdr2s2  = "proyek" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "resmi" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "suntingan" ;
$out_tbl3_hdr3i   = "bita" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] pengguna anonim, berurut sesuai jumlah kontribusi" ;
$out_table6_footer = "Terdapat total %d suntingan oleh pengguna anonim, dari total %d suntingan (%.0f\%)" ;

$out_tbl5_intro   = "Statistik pengunjung (berdasarkan keluaran <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definisi</font></a>, " .
                    "<a href=''><font color='#000088'>grafik</font></a>)" ;
$out_tbl5_hdr1a   = "Rata-rata Harian" ;
$out_tbl5_hdr1e   = "Total Bulanan" ;
$out_tbl5_hdr2a   = "Tohokan" ;
$out_tbl5_hdr2b   = "Berkas" ;
$out_tbl5_hdr2c   = "Halaman" ;
$out_tbl5_hdr2d   = "Kunjungan" ;
$out_tbl5_hdr2e   = "Situs" ;
$out_tbl5_hdr2f   = "KBita" ;
$out_tbl5_hdr2g   = "Kunjungan" ;
$out_tbl5_hdr2h   = "Halaman" ;
$out_tbl5_hdr2i   = "Berkas" ;
$out_tbl5_hdr2j   = "Tohokan" ;

$out_tbl7_intro   = "Rekaman basis data per ruang nama / Artikel terkategori<p>" .
                    "<small>1) Kategori yang disisipkan melalui suatu templat tidak terdeteksi.</small>" ; # new
$out_tbl7_hdr_ns  = "Ruang nama" ; # new
$out_tbl7_hdr_ca  = "Artikel<br>terkategori <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribusi suntingan artikel pada wikipediawan"  ; # new

$out_tbl9_intro   = "[[5]] artikel terbanyak disunting (> 25 suntingan)"  ; # new

$out_tbl10_intro  = "[[3]] bot, berurut sesuai jumlah kontribusi" ; # new

@out_namespaces   = ("Artikel", "Pengguna", "Proyek", "Berkas", "MediaWiki", "Templat", "Bantuan", "Kategori") ;

@out_tbl3_legend  = (
"Wikipediawan yang menyunting lebih dari 10 kali sejak terdaftar",
"Peningkatan wikipediawan dengan paling tidak 10 suntingan sejak terdaftar",
"Wikipediawan yang berkontribusi 5 kali atau lebih bulan ini",
"Wikipediawan yang berkontribusi 100 kali atau lebih bulan ini",
"Artikel yang mengandung paling tidak satu pranala internal",
"Artikel yang mengandung paling tidak satu pranala internal dan 200 karakter teks terbaca, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mengecualikan kode wiki- dan html, pranala tersembunyi, dll.; juga tak menghitung judul<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(kolom lain berdasarkan metode penghitungan resmi)",
"Artikel baru per hari pada bulan terakhir",
"Jumlah rata-rata revisi per artikel",
"Besar rata-rata artikel dalam bita",
"Persentase artikel dengan paling tidak 0,5 Kb teks terbaca (lihat F)",
"Persentase artikel dengan paling tidak 2 Kb teks terbaca (lihat F)",
"Suntingan pada bulan terakhir (termasuk pengalihan, termasuk kontributor anonim)",
"Besar gabungan seluruh artikel (termasuk pengalihan)",
"Jumlah total kata (kecuali pengalihan, kode html/wiki codes, dan pranala tersembunyi)",
"Jumlah total pranala internal (kecuali pengalihan, rintisan, dan daftar pranala)",
"Jumlah total pranala ke Wikipedia lain",
"Jumlah total berkas yang ditampilkan",
"Jumlah total pranala ke situs lain",
"Jumlah total pengalihan",
"Permintaan halaman per hari (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definisi</font></a>, berdasarkan keluaran <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Visits per day (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definisi</font></a>, berdasarkan keluaran <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Data bulan lalu"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipediawan yang telah berkontribusi 5 kali atau lebih dalam seminggu",
"Wikipediawan yang telah berkontribusi 25 kali atau lebih dalam seminggu"
) ;

$out_legend_daily_edits = "Suntingan per hari (termasuk pengalihan, termasuk kontributor anonim)" ;
$out_report_description_daily_edits = "Suntingan per hari" ;
$out_report_description_edits       = "Suntingan per bulan/hari" ;
$out_report_description_current_status = "Status sekarang" ; # new

@out_report_descriptions = (
"Kontributor",
"Wikipediawan baru",
"Wikipediawan aktif",
"Wikipediawan sangat aktif",
"Jumlah artikel (resmi)",
"Jumlah artikel (alternatif)",
"Artikel baru per hari",
"Suntingan per artikel",
"Bita per artikel",
"Artikel yang melebihi 0,5 Kb",
"Artikel yang melebihi 2 Kb",
"Suntingan per bulan",
"Besar basis data",
"Kata",
"Pranala internal",
"Pranala ke Wikipedia lain",
"Berkas",
"Pranala web",
"Pengalihan",
"Permintaan halaman per hari",
"Kunjungan per hari",
"Tinjauan"
) ;

# if you don't know all translation please mark untranslated ones

#$out_languages {"aa"} = "Afar" ;
#$out_languages {"ab"} = "Abkhazian" ;
#$out_languages {"af"} = "Afrikaans" ;
#$out_languages {"ak"} = "Akana" ;
#$out_languages {"als"} = "Elsatian" ;
#$out_languages {"am"} = "Amharic" ;
#$out_languages {"an"} = "Aragonese" ;
#$out_languages {"ang"} = "Anglo-Saxon" ;
#$out_languages {"ar"} = "Arabic" ;
#$out_languages {"as"} = "Assamese" ;
#$out_languages {"ast"} = "Asturian" ;
#$out_languages {"av"} = "Avienan" ;
#$out_languages {"ay"} = "Aymara" ;
#$out_languages {"az"} = "Azerbaijani" ;
#$out_languages {"ba"} = "Bashkir" ;
#$out_languages {"be"} = "Belarussian" ;
#$out_languages {"bg"} = "Bulgarian" ;
#$out_languages {"bh"} = "Bihari" ;
#$out_languages {"bi"} = "Bislama" ;
#$out_languages {"bn"} = "Bengali" ;
#$out_languages {"bo"} = "Tibetan" ;
#$out_languages {"br"} = "Breton" ;
#$out_languages {"bs"} = "Bosnian" ;
#$out_languages {"bug"} = "Buginese" ;
#$out_languages {"ca"} = "Catalan" ;
#$out_languages {"ch"} = "Chamoru" ;
#$out_languages {"cho"} = "Chotaw" ;
#$out_languages {"co"} = "Corsican" ;
#$out_languages {"cr"} = "Cree" ;
#$out_languages {"cs"} = "Czech" ;
#$out_languages {"cy"} = "Welsh" ;
#$out_languages {"da"} = "Danish" ;
#$out_languages {"de"} = "German" ;
#$out_languages {"dv"} = "Divehi" ;
#$out_languages {"dz"} = "Dzongkha" ;
#$out_languages {"ee"} = "Ewe" ;
#$out_languages {"el"} = "Greek" ;
#$out_languages {"en"} = "English" ;
#$out_languages {"eo"} = "Esperanto" ;
#$out_languages {"es"} = "Spanish" ;
#$out_languages {"et"} = "Estonian" ;
#$out_languages {"eu"} = "Basque" ;
#$out_languages {"fa"} = "Persian" ;
#$out_languages {"fi"} = "Finnish" ;
#$out_languages {"fj"} = "Fijian" ;
#$out_languages {"fo"} = "Faeroese" ;
#$out_languages {"fr"} = "French" ;
#$out_languages {"fy"} = "Frisian" ;
#$out_languages {"ga"} = "Irish" ;
#$out_languages {"gay"} = "Gayo" ;
#$out_languages {"gd"} = "Scottish Gaelic" ;
#$out_languages {"gl"} = "Galego" ;
#$out_languages {"gn"} = "Guarani" ;
#$out_languages {"got"} = "Gothic" ;
#$out_languages {"gu"} = "Gujarati" ;
#$out_languages {"gv"} = "Manx Gaelic" ;
#$out_languages {"ha"} = "Hausa" ;
#$out_languages {"haw"} = "Hawaiian" ;
#$out_languages {"he"} = "Hebrew" ;
#$out_languages {"hi"} = "Hindi" ;
#$out_languages {"hr"} = "Croatian" ;
#$out_languages {"ht"} = "Haitian" ;
#$out_languages {"hu"} = "Hungarian" ;
#$out_languages {"hy"} = "Armenian" ;
#$out_languages {"ia"} = "Interlingua" ;
#$out_languages {"iba"} = "Iban" ;
#$out_languages {"id"} = "Indonesian" ;
#$out_languages {"ik"} = "Inupiak" ;
#$out_languages {"io"} = "Ido" ;
#$out_languages {"is"} = "Icelandic" ;
#$out_languages {"it"} = "Italian" ;
#$out_languages {"iu"} = "Inuktitut" ;
#$out_languages {"ja"} = "Japanese" ;
#$out_languages {"jv"} = "Javanese" ;
#$out_languages {"ka"} = "Georgian" ;
#$out_languages {"kaw"} = "Kawi" ;
#$out_languages {"kk"} = "Kazakh" ;
#$out_languages {"kl"} = "Greenlandic" ;
#$out_languages {"km"} = "Cambodian" ;
#$out_languages {"kn"} = "Kannada" ;
#$out_languages {"ko"} = "Korean" ;
#$out_languages {"ks"} = "Kashmiri" ;
#$out_languages {"ku"} = "Kurdish" ;
#$out_languages {"ky"} = "Kirghiz" ;
#$out_languages {"la"} = "Latin" ;
#$out_languages {"lb"} = "Letzeburgesch" ;
#$out_languages {"li"} = "Limburguish" ;
#$out_languages {"ln"} = "Lingala" ;
#$out_languages {"lo"} = "Laotian" ;
#$out_languages {"ls"} = "Latino Sine Flexione" ;
#$out_languages {"lt"} = "Lithuanian" ;
#$out_languages {"lv"} = "Latvian" ;
#$out_languages {"mad"} = "Madurese" ;
#$out_languages {"mak"} = "Makasar" ;
#$out_languages {"mg"} = "Malagasy" ;
#$out_languages {"mi"} = "Maori" ;
#$out_languages {"mk"} = "Macedonian" ;
#$out_languages {"ml"} = "Malayalam" ;
#$out_languages {"mn"} = "Mongolian" ;
#$out_languages {"mo"} = "Moldavian" ;
#$out_languages {"mr"} = "Marathi" ;
#$out_languages {"ms"} = "Malay" ;
#$out_languages {"mt"} = "Maltese" ;
#$out_languages {"mus"} = "Muskogee" ;
#$out_languages {"my"} = "Burmese" ;
#$out_languages {"na"} = "Nauru" ;
#$out_languages {"nah"} = "Nahuatl" ;
#$out_languages {"nds"} = "Low Saxon" ;
#$out_languages {"ne"} = "Nepali" ;
#$out_languages {"nl"} = "Dutch" ;
#$out_languages {"nn"} = "Norwegian (Nynorsk)" ;
#$out_languages {"no"} = "Norwegian" ;
#$out_languages {"nv"} = "Navayo" ;
#$out_languages {"oc"} = "Occitan" ;
#$out_languages {"om"} = "Oromo" ;
#$out_languages {"or"} = "Oriya" ;
#$out_languages {"pa"} = "Punjabi" ;
#$out_languages {"pl"} = "Polish" ;
#$out_languages {"ps"} = "Pashto" ;
#$out_languages {"pt"} = "Portuguese" ;
#$out_languages {"qu"} = "Quechua" ;
#$out_languages {"rm"} = "Rhaeto-Romance" ;
#$out_languages {"rn"} = "Kirundi" ;
#$out_languages {"ro"} = "Romanian" ;
#$out_languages {"roa_rup"} = "Aromanian" ;
#$out_languages {"ru"} = "Russian" ;
#$out_languages {"rw"} = "Kinyarwanda" ;
#$out_languages {"sa"} = "Sanskrit" ;
#$out_languages {"sc"} = "Sardinian" ;
#$out_languages {"scn"} = "Sicilian" ;
#$out_languages {"sd"} = "Sindhi" ;
#$out_languages {"se"} = "Northern Sami" ;
#$out_languages {"sg"} = "Sangro" ;
#$out_languages {"sh"} = "Serbo-Croatian" ;
#$out_languages {"si"} = "Singhalese" ;
#$out_languages {"simple"} = "Simple&nbsp;English" ;
#$out_languages {"sk"} = "Slovak" ;
#$out_languages {"sl"} = "Slovene" ;
#$out_languages {"sm"} = "Samoan" ;
#$out_languages {"sn"} = "Shona" ;
#$out_languages {"so"} = "Somalian" ;
#$out_languages {"sq"} = "Albanian" ;
#$out_languages {"sr"} = "Serbian" ;
#$out_languages {"ss"} = "Siswati" ;
#$out_languages {"st"} = "Seshoto" ;
#$out_languages {"su"} = "Sundanese" ;
#$out_languages {"sv"} = "Swedish" ;
#$out_languages {"sw"} = "Swahili" ;
#$out_languages {"ta"} = "Tamil" ;
#$out_languages {"te"} = "Telugu" ;
#$out_languages {"tg"} = "Tajik" ;
#$out_languages {"th"} = "Thai" ;
#$out_languages {"ti"} = "Tigrinya" ;
#$out_languages {"tk"} = "Turkmen" ;
#$out_languages {"tl"} = "Tagalog" ;
#$out_languages {"tn"} = "Setswana" ;
#$out_languages {"to"} = "Tonga" ;
#$out_languages {"tr"} = "Turkish" ;
#$out_languages {"ts"} = "Tsonga" ;
#$out_languages {"tt"} = "Tatar" ;
#$out_languages {"tw"} = "Twi" ;
#$out_languages {"ty"} = "Tahitian" ;
#$out_languages {"ug"} = "Uighur" ;
#$out_languages {"uk"} = "Ukrainian" ;
#$out_languages {"ur"} = "Urdu" ;
#$out_languages {"uz"} = "Uzbek" ;
#$out_languages {"vi"} = "Vietnamese" ;
#$out_languages {"vo"} = "Volap&uuml;k" ;
#$out_languages {"wa"} = "Walloon" ;
#$out_languages {"wo"} = "Wolof" ;
#$out_languages {"yi"} = "Yiddish" ;
#$out_languages {"yo"} = "Yoruba" ;
#$out_languages {"za"} = "Zhuang" ;
#$out_languages {"zh"} = "Chinese" ;
#$out_languages {"zh_min_nan"} = "Minnan" ;
#$out_languages {"zu"} = "Zulu" ;
#$out_languages {"zz"} = "All&nbsp;languages" ;
}

# end of file marker, do not remove:
1;

