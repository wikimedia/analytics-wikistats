#!/usr/bin/perl

# collect images and meta data for all Wiki Loves Monuments Winners (national or world-wide) for 2010-2016
# convert and annotate images into several sets (depending on target resolution) (add new resolution at PhaseConvertImages)

# use case:
# offline slide shows (there is great online slide show tool already)
# with selected images only (tweaked file names makes that a no brainer)
# with image resized for perfect fit to target platform (and thus greatly reduced file size)

# meta data are collected from the winners pages, and complemented (if needed) from the image upload page
# annotations are: left: contest name & country, center: title, right: photograph/author & license
# a csv file is generated with the following fields
#    contest,download timestamp,author,license,file (on disk),url,title
# this file is re-used for conversion phase (some manual tweaking , e.g. of too long titles, can be done between download and conversion phases)

# to do: make this script more widely usable,
# - first for Wiki Loves Earth (should be easy as it WLE follows same pattern for winners pages)
# hopefully for other contests (Wiki Loves Africa?)
# a tweaked version could read a random list of image urls from Commons from text file, for maimum applicability

# developed and tested on Windows 7

# required (in same directory as perl script):
# ImageMagick tool convert.exe: https://www.imagemagick.org/script/binary-releases.php (I used curl-7.46.0-win64.exe)
# curl.exe: https://curl.haxx.se/download.html

# note: this script is on purpose not meant to be run on Wikimedia servers (which would have been somewhat easier to develop)
# this way reuse of the script in any context is best

  use URI::Escape;
  use Time::Local ;
  use Encode;

  binmode(STDOUT, ":utf8");

  $true  = 1 ;
  $false = 0 ;

  $unescaped = 0 ;
  $escaped   = 1 ;
  $silent    = 1 ;

  $file_size_minimum = 1024 ; # files less than so many bytes are failed downloads (in WLM context) -> remove

  $skip_until_contest = '' ; # for speed up of debug session

  $width =  390 ;
  $width = 1920 ;

# $skip_until_content = "WLM_2011_FR" ; # debug only

  our $prize = 0 ; # number from 1 onwards for best in year
  our $image_data_stored = 0 ;
  our $year ;
  our $folder = 'images' ;
  our $country_code = '' ;

  $file_image_data     = 'image_data.csv' ;
  $file_image_data_new = 'image_data_new.csv' ;
  $file_image_errors   = 'image_data_errors.csv' ;
  $file_image_log      = 'image_data_log.txt' ;
  $file_image_sections = 'image_data_sections.csv' ;

  open LOG, '>', $file_image_log ;
  open CSV_SECTIONS, '>', $file_image_sections ;
  binmode CSV_SECTIONS ;

  unlink ($file_image_errors) ;

# &CollectCountryCodesFromCommonsConfigPage ; # one time only, read 'Commons page Module_WL data - Wikimedia Commons.html' (maintain manually)
  &ReadCountryCodesFromFile ;
  &ReadDataFromFile ($silent) ;

  # &PhaseCollectImages ;
  &PhaseConvertImages ;
  &Log ("\n\nReady\n\n") ;
  exit ;

sub PhaseCollectImages
{


# &DownloadHtmlPagesWlmWinners ;
  &CollectImageAndMetaDataForAllYears ;

  &WriteDataToFile ;
  &PrintLicenseCounts ;
}

sub PhaseConvertImages
{
# ref https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
  &ConvertImages (2560,1600,24,14) ; # full HD TV, iPhone 6+/6s+/7+ plus
# &ConvertImages (1920,1080,20,12) ; # full HD TV, iPhone 6+/6s+/7+ plus
# &ConvertImages (1334,750,16,12) ; # iPhone 6/6s/7
# &ConvertImages (1136,640,14,10) ; # iPhone 5/5s
}

# one time only: download and save html pages with contest winners
sub DownloadHtmlPagesWlmWinners
{
  &DownloadHtmlPageWinnersForOneYear ('2010') ;
  &DownloadHtmlPageWinnersForOneYear ('2011') ;
  &DownloadHtmlPageWinnersForOneYear ('2012') ;
  &DownloadHtmlPageWinnersForOneYear ('2013') ;
  &DownloadHtmlPageWinnersForOneYear ('2014') ;
  &DownloadHtmlPageWinnersForOneYear ('2015') ;
  &DownloadHtmlPageWinnersForOneYear ('2016') ;
}

sub CollectImageAndMetaDataForAllYears
{
 &CollectFileDataAndMetaDataPerYear  ('2010') ;
 &CollectFileDataAndMetaDataPerYear  ('2011') ;
 &CollectFileDataAndMetaDataPerYear  ('2012') ;
 &CollectFileDataAndMetaDataPerYear  ('2013') ;
 &CollectFileDataAndMetaDataPerYear  ('2014') ;
 &CollectFileDataAndMetaDataPerYear  ('2015') ;
 &CollectFileDataAndMetaDataPerYear  ('2016') ;
}

sub ConvertImages
{
  my ($width,$height,$fontsize_large,$fontsize_small) = @_ ;
  die "Invalid width '$width'" if $width !~ /^\d\d\d+$/ ;
  die "Invalid height '$height'" if $height !~ /^\d\d\d+$/ ;

  my $folder_resized = "$folder/${width}x${height}" ;
  if (! -d "$folder_resized")
  {
    mkdir "$folder_resized" ;
    die "Folder could not be created '$folder_resized'" if ! -d $folder_resized ;
  }

  my $conversions = 0 ;
  foreach $file_out (sort keys %filedata)
  {
    $conversions ++ ;
    print "$conversions:\n" ;
    &ConvertImage ($width, $height, $fontsize_large, $fontsize_small, $filedata {$file_out}, $metadata {$file_out}) ;

  # exit if $conversions >= 10 ; # tests
  }
}

sub GetFileAndMetaData
{
  my $line = shift ;
  my ($contest,$timestamp,$photographer,$license,$file,$url,$title) = split (',', $line) ;
  my $filedata = "$file,$url" ;
  my $metadata = "$title,$photographer,$license" ;
# &Log ("File data $filedata\n") ;
# &Log ("Meta data $metadata\n") ;
  return ($filedata, $metadata, $timestamp) ;
}

sub ReadDataFromFile
{
  my $silent = shift ;

  &Log ("ReadDataFromFile\n\n") ;

# die "Input file not found: '$file_image_data'" if ! -e $file_image_data ;

  open CSV_IN, '<', $file_image_data ;
  binmode CSV_IN ;

  my $lines = 0 ;
  my $line ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    $lines++ ;

    &Log ("$lines: $line\n") if ! $silent ;

    next if $line =~ /^contest,/ ; # skip header line

# next if $line !~ /Vijzelstraat/ ; # test first record

    my ($filedata, $metadata,$timestamp) = &GetFileAndMetaData ($line) ;

    print "filedata: $filedata\n" if ! $silent ;
    print "metadata: $metadata\n" if ! $silent  ;

    $metadata2 = $metadata ;
    $metadata =~ s/^\d+[\.\:]?\s*// ;

  # if ($metadata ne $metadata2)
  # { print "\n\n$metadata <- \n $metadata2\n\n" ; exit ; }

  # next if $metadata =~ /user|by/i ;
  # next if $metadata =~ /unknown/i ;

    my ($file_out) = split (',', $filedata) ;

  # &Log ("\n\nfile_out: $line\n") ;
    if (! &FileExists ($file_out)) # if file exists, and less than minimum size, make it missing!
    {
      &Log ("File not found: $file_out\n") if ! $silent  ;
      $image_issues {$file_out} = $line ;
      &LogError ("Incomplete or missing file: do not store metadata: '$line'") ;
      next ;
    }
    # do not store incomplete lines, instead collect again from html page(s)
    if (&CheckDataComplete ($filedata,$metadata,$timestamp))
    {
      $filedata  {$file_out} = $filedata ;
      $metadata  {$file_out} = $metadata ;
      $timestamp {$file_out} = $timestamp ;
    # &Log ("Timestamp $file_out: $timestamp\n") ;

      $image_data_found ++ ;
    }
    else
    {
      $image_issues {$file_out} = $line ;
      &LogError ("Incomplete data: do not store metadata: '$line'\n") if ! $silent ;
      next ;
    }
  }
  close CSV_IN ;

  &Log ("ReadDataFromFile complete: " . ($lines+0) . " lines read from image data file\n\n") ;
}

# check file existence + remove failed download (file size < $file_size_minimum)
sub FileExists
{
  my $file = shift ;
  $file2 = "$folder/$file" ;
  my $file_exists = -e $file2 ;

  if ($file_exists)
  {
    if (-s $file2 < $file_size_minimum)
    {
      &Log ("Remove '$file2': size less than $file_size_minimum bytes, can't be legit (in WLM context) -> remove\n") ;
      unlink $file2 ;
      $file_exists = $false ;
    }
    else
    {
      my $age = time - 24 * 3600 * (-M $file2) ;
      $timestamp {$file} = &SecondsToTimestamp ($age) ;
    }
  }

  return $file_exists ;
}

sub StoreData # store new or updated data
{
  my ($filedata,$metadata,$timestamp) = @_ ;

  my ($file_out,$url) = split (',', $filedata) ;
  my ($title,$photographer,$license) = split (',', $metadata) ;
  my ($contest) ;

  ($contest = substr ($file_out,0,11)) =~ s/ /_/g ;
  $licenses {"$contest $license"}++ ;

  if (! &CheckDataComplete ($filedata,$metadata,$timestamp))
  {
    $line = "$contest,$timestamp,$photographer,$license,$file_out,$url,$title" ;
    &LogError ("\nIncomplete image data: do not store: '$line'\n") ;
    return ;
  }

  my $data_changed = $false ;

# $file_out =~ s/^.*?${contest}_// ;
# data are complete now, check for changes, if found, report and add or update

  ($file_out = $filedata) =~ s/,.*$// ;
  if ($filedata ne $filedata {$file_out})
  {
    $data_changed = $true ;
    &Log ("  File data '$filedata' <- '${filedata {$file_out}}'\n") ;
    $filedata {$file_out} = $filedata ;
  }

  if ($metadata ne $metadata {$file_out})
  {
    $data_changed = $true ;
    &Log ("  Meta data '$metadata' <- '${metadata {$file_out}}'\n") ;
    $metadata {$file_out} = $metadata ;
  }

  if ($timestamp ne $timestamp {$file_out})
  {
    $data_changed = $true ;
    &Log ("  Timestamp '$timestamp' <- '${timestamp {$file_out}}'\n") ;
    $timestamp {$file_out} = $timestamp ;
  }

  if ($data_changed)
  {
    if (++$image_data_stored % 1 == 0)
    { &WriteDataToFile ; }
  }
}

sub CheckDataComplete
{
  my ($filedata,$metadata,$timestamp) = @_ ;

  if (($filedata =~ /^.+\,.+$/) && ($metadata =~ /^.+\,.+\,.+$/) && ($timestamp ne ''))
  { return ($true) ; }
  else
  {
    &Log ("Data not complete: [$filedata], [$metadata], [$timestamp]\n") ;
    return ($false) ;
  }
}

sub WriteDataToFile
{
  my $lines = 0 ;

  open CSV_OUT, '>', $file_image_data_new ;
  binmode CSV_OUT ;
  print CSV_OUT "contest,download time,author,license,file,url,title\n" ;

  foreach $key (sort {$filedata {$a} cmp $filedata {$b}} keys %filedata)
  {
    $lines++ ;

   my ($file_out,$url)                = split (',', $filedata {$key}) ;
   my ($title,$photographer,$license) = split (',', $metadata {$key}) ;
   my $timestamp                     = $timestamp {$key} ;
   my $contest = substr ($file_out,0,11) ;

    print CSV_OUT "$contest,$timestamp,$photographer,$license,$file_out,$url,$title\n" ;
  }

  close CSV_OUT ;

  &Log ("\n\nWriteDataToFile: " . ($image_data_found+0) . " lines read from data file, " .
                ($images_found_in_contest_pages+0) . " images found in contest pages, " .
                 ($upload_pages_downloaded+0) . " upload pages (= image description files) downloaded, " . ($lines+0) . " lines written to data file\n") ;

# exit if $checksdatacomplete++ > 10 ;
}

sub LogError
{
  my $msg = shift ;
  return if $msg =~ /^.*$/ ;

  &Log ($msg) ;

  open ERR_OUT, '>>', $file_image_errors ;
  print ERR_OUT $msg ;
  close ERR_OUT ;
}

sub PrintLicenseCounts
{
  foreach $license (sort keys %licenses)
  {
    $license2 = substr ($license,12) ;
    &Log ($licenses {$license} . ":$license\n") ;
    $licenses2 {$license2} += $licenses {$license} ;
  }

  &Log ("\n\n") ;
  foreach $license2 (sort keys %licenses2)
  { &Log ($licenses2 {$license2} . ":$license2\n") ; }
}

# one time only, read 'Commons page Module_WL data - Wikimedia Commons.html' (maintain list manually thereafter)
sub CollectCountryCodesFromCommonsConfigPage
{
  $file_in  = "Module_WL data - Wikimedia Commons.html" ;
  $file_codes = "country-codes.csv" ;

  open HTML_IN, '<', $file_in || die "File not found '$file_in'" ;
  open CSV_OUT, '>', $file_codes ;

  $start = $false ;
  while ($line = <HTML_IN>)
  {
    if ($line =~ /prefixes/)
    { $start = $true ; }
    next if ! $start ;

    last if $line =~ /defaultUTC/ ;

    $line =~ s/<[^>]*>//g ;
    next if $line !~ /=/ ;
    $line =~ s/\&quot;/"/g ;
    next if $line !~ /\[\".*\"\]/ ;
    chomp $line ;
    ($code,$name) = split ('=', $line) ;

    $code =~ s/^\s*\[\"// ;
    $code =~ s/\"\]\s*// ;
    $name =~ s/^\s*\"// ;
    $name =~ s/\s*\",// ;

    print CSV_OUT "$name,$code\n" ;
  }

  close HTML_IN ;
  close CSV_OUT ;
}

sub ReadCountryCodesFromFile
{
  $file_in = "country-codes.csv" ;
  open CSV_IN,  '<', $file_in || die "File not found '$file_in'" ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    ($country_name,$country_code) = split (',', $line) ;
    $country_codes {$country_name} = $country_code ;
    $country_names {uc ($country_code)} = $country_name ;
  }
  close CSV_IN ;
}

# parse html page with winners for one year
# find country in h3 tag
# find start of winner/finalists in h2 tag
# find image url and (from that) file name to be written fromline line with proper url: https://upload.wikimedia.org/wikipedia/commons/thumb/
# only if metadata for this image isn't complete (if it is, that imples image has been downloaded already)
# find metadata ($contest,$title,$photographer,$license) after <div class="gallerytext">

sub CollectFileDataAndMetaDataPerYear
{
  $year = shift ; # global

  my $page = "Wiki_Loves_Monuments_${year}_winners.html" ;
  &Log ("\nCollectFileDataAndMetaDataPerYear $year\n\n") ;
  $country_code = '' ;

  if ($year eq '2010')
  {
    $country_code = 'NL' ;
    $country_name = 'Netherlands' ;
  }

  $prize = 1; # auto number images without country code as prizes, ranked first prize first

  my $line_prev = '' ;
  my ($filedata,$metadata,$timestamp) ;
  my ($file_out,$url,$contest) ;

  $beyond_h2_winners_finalists = $false ;
  open IN_HTML, '<', $page ;
  while ($line = <IN_HTML>)
  {
    $line_prev = $line_as_read ;
    $line_as_read = $line ;
    # print $line ;

    chomp $line ;
    if ($line =~ /<h3/)
    {
      $line =~ s/<[^>]*>//g ;
      next if $line !~ /edit/ ;

      $country_code = &FindCountryCode ($line) ;
    }

    if (($line =~ /<h2/) && ($line =~ /Winners|Finalists/))
    { $beyond_h2_winners_finalists = $true ; }

    if ($line =~ /https\:\/\/upload.wikimedia.org\/wikipedia\/commons\/thumb\//)
    {
      next if ! $beyond_h2_winners_finalists  ;

      $filedata = '' ;

      # prefix for file_out not yet known, but handy to show in log file, so construct here as well
      $contest = "WLM_${year}_" . substr (uc ($country_code).'??', 0,2) ;

      next if $contest lt $skip_until_contest ;

      &Log ("\n\n$contest " . '=' x 80 . "\n\n")  ;

      $images_found_in_contest_pages ++ ;

    # ($file_out,$url) = &CollectFilenameUrl ($line) ;
      $filedata = &CollectFiledata ($line) ;
      ($file_out,$url) = split (',', $filedata) ;
      next if &RejectedUrl ($url) ;

      if (! &ImageDownloaded ($filedata))
      { &DownloadImage ($filedata) ; } # register success by storing timestamp of output file
      else
      { &Log ("File already downloaded\n") ; }

      $timestamp = $timestamp {$file_out} ;
    }

    if ($line =~ /<div class="gallerytext">|overflow-y/)
    {
      next if &RejectedUrl ($url) ;
      $metadata = $metadata {$file_out} ;
    # if ($image_issues {$file_out})
    # {
    &Log ("GalleryText\n") ;
      if (! &CheckDataComplete ($filedata, $metadata, $timestamp))
      {
        &Log ("CollectFileDataAndMetaDataPerYear: data for \$file_out '$file_out' not complete:\n -> Parse section from contest page \$section\n\n") ;

        $section = &ReadSectionGalleryText ($line) ; # read multiple lines
        $metadata = &GetMetadataFromContestWinnersPage ($contest,$section) ;

        if (! &MetadataComplete ($metadata))
        { $metadata = &CompleteMetadataFromUploadPage ($filedata, $metadata) ; }

        &StoreData ($filedata,$metadata,$timestamp) ;
      # &PrintImageData ($filedata,$metadata,$timestamp) ;

        $filedata = $metadata = $timestamp = '' ;
      }
      else
      { &Log ("Data already complete\n") ; }
      # last if $converts++ > 6 ;
    }
  }
  close IN_HTML ;
}

sub FiledataComplete
{
  my $filedata = shift ;
  my ($file,$url) = split (',', $filedata) ;
  if (($file ne '') && ($url ne ''))
  { return $true ; }
  else
  { return $false ; }
}

sub MetadataComplete
{
  my $metadata = shift ;
  my ($title,$photographer,$license) = split (',', $metadata) ;
  if (($title ne '') && ($photographer ne '') && ($license ne ''))
  { return $true ; }
  else
  { return $false ; }
}

sub ImageDataComplete
{
  my $file = shift ;

  if (&FiledataComplete ($filedata {$file}) &&
      &MetadataComplete ($metadata {$file}) &&
      $timestamp {$file} ne '')
  { return $true ; }
  else
  { return $false ; }
}

sub PrintImageData
{
  my ($filedata,$metadata,$timestamp) = @_ ;
  &Log ("New data: File data $filedata\nMeta data $metadata\nTimestamp $timestamp\n") ;
}

sub ReadSectionGalleryText
{
  my $section = shift ;
  chomp $section ;

  my $lines= 1 ;

# print "$lines: '$section'\n" ;
  my $line ;
  while ($line = <IN_HTML>)
  {
    chomp $line ;
    $lines++ ;
  # print "$lines: '$line'\n" ;
    $section .= $line ;
    if ($line =~ /<\/div>/)
    { last ; }
  }
  &Log ("ReadSectionGalleryText: '$section'\n") ;
  return $section ;
}

sub RejectedUrl
{
  my $url = shift ;
  if (($url !~ /\.(?:jpg|png|tiff?)/i) || ($url =~ /turquoise.png/i))
  {
    &Log ("Rejected url: '$url'\n") ;
    return $true ;
  }
  else
  { return $false ; }
}

sub DownloadImage
{
  my $filedata = shift ;
  my ($file_out,$url) = split (',', $filedata) ;

  $file_out2 = "$folder/$file_out" ;
  $file_out  =~ s/\"/\%22/g ; # \" (double quote) invalid in Windows file
  $file_out2 =~ s/\"/\%22/g ;

  my $success = &DownloadImageWithCurl ($file_out2, $url, $escaped) ;

  if ($success)
  {
    ($timestamp) = &SecondsToTimestamp (time - 24 * 3600 * (-M $file_out2)) ;
     $timestamp {$file_out} = $timestamp ;
    &Log ("Image downloaded: '$file_out', at $timestamp\n\n") ;
  }

  return ($success) ;
}

# use curl (instead of wget)
# for reference, wget command would have been:
# $result = `wget --no-check-certificate --restrict-file-names=nocontrol -P $folder $url` ;
sub DownloadImageWithCurl
{
  my ($file, $url, $mode) = @_ ;
  my $success = $false ;

  &Log ("\nDownload file '$file' <- '$url' ($mode)\n") ;
  my $cmd = "curl -sS -k \"$url\" --output $file" ; # -sS = silent
  `$cmd` ;
  $size = -s $file ;
  &Log ("\n$cmd -> " . ($size+0) . " bytes\n\n") ;

  if ($size == 0)
  { &Log ("\n1 Download failed. No file written\n'$file' <-\n '$url'\n") ; }
  elsif ($size < $file_size_minimum)
  { &Log ("\n1 Download failed, file too small ($size < 1k bytes)\n'$file' <-\n '$url'\n") ; }
  else
  {
  # &Log ("\n1 Download done (file is $size bytes)\n'$file' <-\n '$url'\n") ;
    $success = $true ;
  }

  if ((! $success) && ($mode == $escaped)) # retry with unescaped url?
  {
    $url2 = uri_unescape $url ;
    $url2 =~ s/,/\%2C/g ;
    $url2 =~ s/"/\%22/g ;
    $success = &DownloadImageWithCurl ($file, $url2, $unescaped) ; # try again with changed url
  }

  return $success ;
}

sub ImageDownloaded
{
  my $filedata = shift ;
  (my $file = $filedata) =~ s/,.*$// ;
  %a = %timestamp ;
  return ($timestamp {$file} ne '') ; # use this instead of actual file check, timestamp filled means image download was vetted
}

# sub CollectFilenameUrl
sub CollectFiledata
{
  my $line = shift ;
  chomp $line ;

  my $url = $line ;
  $url =~ s/^.*?\ssrc=\"// ;
  $url =~ s/\".*$// ;
  $url =~ s/(\/[0-9a-f]\/[0-9a-f]{2}\/[^\/]+)\/.*$/$1/i ;
  $url =~ s/thumb\/// ;

  my $file = $url ;
  $file =~ s/^.*?\/[0-9a-f]\/[0-9a-f]{2,2}\/// ; # keep filename, discard path

  my $file_code = $country_code ;
  if ($file_code eq '')
  { $file_code = sprintf ("%02d", $prize++) ; }

  my $file_out = $url ;
  $file_out =~ s/^.*\/// ;
  $file_out = uri_unescape $file_out ;
  $file_out =~ s/,/\%2C/g ;
  $file_out =~ s/"/\%22/g ;

  # ($file_out = $file) =~ s/(\.\w{3,4}$)/lc($1)/e ; # make extension lower case

  $file_out = "WLM_${year}_" . substr (uc ($file_code).'??',0,2) . "_$file_out" ;

  &Log ("CollectFiledata: $file_out\n") ;

  if ($file_out =~ /WLM_2011_06/)
  { $a = 1 ; }

  return ("$file_out,$url") ;
}

sub FindCountryCode
{
  my ($line) = @_ ;
  $line =~ s/\[edit\]//g ;
    # &Log ("h3: $line") ;
  if ($year > 2010)
  {
    $country_code = '' ;
    foreach $country_name (keys %country_codes)
    {
      if ($line =~ $country_name)
      {
        $country_code = $country_codes {$country_name} ;
        &Log ("Country '$country_name' -> code '$country_code'\n") ;
        last ;
      }
    }
    if ($country_code eq '')
    {
      $country_code = 'XX' ;
      &Log ("No country code found for h3 section '$line'\n") ;
    }
  }

  return ($country_code) ;
}

sub GetMetadataFromContestWinnersPage
{
  my ($contest,$section) = @_ ;
  my $title2 ;
# $section =~ s/^(\^+[^\^+]\^)/($a = $1, $a=~s/,/%2C/g, $a)/ge ;

# if ($year eq '2010')
#  { $section =~ s/<small>/Photograph:/ ; } # add a word that is always there from 2011 onwards
  $section =~ s/<small>/Photograph:/ ;

  $section =~ s/,/%2C/g ;
  $section2 = $section ;
  $section =~ s/User:/>User:</ ; # bring outside html tag: needed for detection below
  $section =~ s/<[^>]*>/^/g ;
  $section3 = $section ;

  # encode commas except in last part (which is author)
  if ($year ne '2010')
  {
    my @sections = split ('\^', $section) ;

    if ($#sections == -1)
    {
      &Log ("GetMetadataFromContestWinnersPage: \$\#section == -1\n") ;
      $title2 = 'Title unknown' ;
    }
    else
    {
    #  print ($#sections+0) . " sections\n" ;
    #  $sections [$#sections] = '' ;
    #  $section = join ('^', @sections) ;
    #  $section =~ s/,/\%2C/g ;
    }
  }

  &Log ("Section (with html tags removed) from contest winners page: '$section'\n") ;

  $license = '' ;
  if ($section =~ /CC-/)
  {
    ($license = $section) =~ s/^.*?(CC-)/$1/ ;
     $license =~ s/\^.*$// ;
     $license =~ s/^\s+// ;
     $license =~ s/\s+$// ;

     $section =~ s/CC.*$// ;
  }

  $photographer = '' ;
  if ($section =~ /photograph|author|user\:|by:/i)
  {
    ($photographer = $section) =~ s/^.*?photograph(er)?\://i ;
     $photographer =~ s/^.*?Author\://i ;
     $photographer =~ s/^.*?User\://i ;
     $photographer =~ s/^.*?By\://i ;
     $photographer =~ s/\^([^\^]+)\^.*$/$1/ ;
     $photographer =~ s/^\s+// ;
     $photographer =~ s/\s+$// ;
     $photographer =~ s/\s*\(talk\)//i ;
     $photographer =~ s/\^//g ;

     if ($photographer !~ /^\s*$/)
     { $section =~ s/$photographer.*$// ; }

     $section =~ s/(?:photograph|author|user\:|by\:).*$//i ;
  }

  ($title = $section) ;
  $title =~ s/photograph.*$//i ;
  $title =~ s/author.*$//i ;
  $title =~ s/\^//g ;
  $title =~ s/^\s+// ;
  $title =~ s/\s+$// ;
  $title =~ s/^\d+[\.\:]?\s*// ;

  if ($title =~ /^\s*$/)
  { $title = 'Title unknown' ; }

  print CSV_SECTIONS "$contest,$section3,$section2,$license,$photographer,$title\n" ; # for debugging
  return ("$title,$photographer,$license") ;
}

sub ConvertImage # ccc (for quick search in IDE)
{
  my ($width, $height, $fontsize_large, $fontsize_small, $filedata, $metadata) = @_ ;
  my ($file_out,$url) = split (',', $filedata) ;
  my ($title,$photographer,$license) = split (',', $metadata) ;
  my $contest = substr ($file_out,0,11) ;
  $contest =~ s/_/ /g ;

  $title =~ s/\.\s*$// ;
  $title =~ s/\&amp;/&/g ;
  if ($title =~ /Title unknown/i) # do not show this after all
  { $title = '' ; }
  else
  { $title = " $title " ; }
  $photographer = " $photographer " ;
  $license = "$license" ;

  my ($text,$text2,$text2b,$text3) ;

  my $colors = "-background #FF000000 -undercolor #444444FF -fill #AAAAAA -stroke transparent" ;

  my $year = substr ($contest,4,4) ;
  my $code = substr ($contest,9,2) ;
  $code =~ s/^0// ;
  if ($code =~ /^\d\d?$/)
  { $where_or_why = "Finalist, $code" . ($code == 1? "st" : $code == 2 ? "nd" : "th") . " place" ; }
  else
  {
    $where_or_why = $country_names {$code} ;
    if ($where_or_why eq '')
    { $where_or_why = "Country unknown" ; }
  }
  print "Code $code -> where or why: $where_or_why\n" ;

  open LABEL, '>', 'title.utf8.txt' ;
  print LABEL uri_unescape ($title) ;
  close LABEL ;
  open LABEL, '>', 'author.utf8.txt' ;
  print LABEL uri_unescape ($photographer) ;
  close LABEL ;

  my $contest_name = 'Wiki Loves Monuments' ;

  if ($width < 1700)
  { $contest_name = 'WLM' ; }

  $offset_top_label = 20 ;

  $text1a = "-gravity SouthWest $colors -pointsize $fontsize_small -annotate +0+3 \"\\  $where_or_why\\ \""  ;
  $text1b = "-gravity SouthWest $colors -pointsize $fontsize_small -annotate +0+$offset_top_label \"\\  $contest_name $year\\ \""  ;

  $text2 = '' ;
  if ($title ne '')
  { $text2  = "-gravity South $colors -pointsize $fontsize_large -annotate +0+3 \@title.utf8.txt" ; }

  if (($photographer ne '') || ($license ne ''))
  {
  # if ($photographer eq '--')
    if ($photographer eq '')
    { $photographer = '...' ; }

  # $text3 = "-gravity SouthEast $colors -pointsize 12 -annotate +0+3 \"\\   \@$photographer ($license)\\ \" " ;
    $text3a = "-gravity SouthEast $colors -pointsize $fontsize_small -annotate +0+$offset_top_label \@author.utf8.txt" ;
    $text3b = "-gravity SouthEast $colors -pointsize $fontsize_small -annotate +0+3 \"\\   $license\\ \" " ;
  }

  my $file_downloaded = "$folder/$file_out" ;
  my $file_resized = "$folder/${width}x${height}/$file_out" ;

  $cmd = "convert $file_downloaded -auto-orient -resize ${width}x${height} -font Arialuni.ttf $text1a $text1b $text2 $text3a $text3b $file_resized" ; # 1920x1080
  print "title: $title\n" ;
  $result = `$cmd` ;
  if ($result eq '')
  { $result = 'OK' ; }
  &Log ("cmd $cmd -> $result\n\n") ;
}

sub DownloadHtmlPageWinnersForOneYear
{
  $page = "Wiki_Loves_Monuments_${year}_winners" ;
  &DownloadHtmlPage ("${page}.html", "https://commons.wikimedia.org/wiki/$page") ;
}

sub DownloadHtmlPage
{
  my ($file, $url) = @_ ;

  my ($success, $content) = &GetPage ($url) ;
  if ($success)
  { &WriteHtmlPage ($file, $content) ; }
}

sub WriteHtmlPage
{
  my ($file, $content) = @_ ;
  &Log ("Write file '$file'\n") ;
  open FILE, '>', $file || die "Could not open file $file" ;
  print FILE $content ;
  close FILE ;
}

sub CompleteMetadataFromUploadPage
{
  my ($filedata, $metadata) = @_ ;
  my ($title,$photographer,$license) = split (',', $metadata) ;

  (my $file_out = $filedata) =~ s/,.*$// ;

# return if $file_out !~ /RU/ ;

  $file_out =~ s/^.*?WLM_\d\d\d\d\_\w\w\_// ; # minus contest prefix

  if (($photographer ne '') && ($license ne ''))
  {
    $license = &FormatLicense ($license) ;
    &Log ("CompleteMetadataFromUploadPage photographer and license already in image data\n") ;
    return ($metadata) ;
  }

  &Log ("\nCompleteMetadataFromUploadPage download: $file_out\n") ;
  $upload_pages_downloaded ++ ;

  my ($success, $content) = &GetPage ("http://commons.wikimedia.org/wiki/File:$file_out") ;

  $photographer2 = '' ;
  $photographer  = '' ;
  $license       = '' ;

  my @lines = split ("\n", $content) ;
  foreach $line (@lines)
  {
    if ($line_prev =~ /fileinfotpl_aut/)
    {
      $photographer2 = $line ;
      $photographer2 =~ s/<[^>]*>//g ; # remove html
    }

    if ($line_prev =~ />Author</)
    {
      $photographer = $line ;
      $photographer =~ s/<[^>]*>//g ; # remove html
    }

    if ($line =~ /This photo.*was taken by/)
    {
      $photographer = $line ;
      $photographer =~ s/<[^>]*>//g ; # remove html
      $photographer =~ s/\.\s*$// ;   # remove end of sentence
      $photographer =~ s/This photo was taken by // ;
    }

    if ($line =~ /This file is licensed under the/) # license comes after author in upload page, so we're done
    {
     ($license = $line) =~ s/<[^>]*>//g ;  # remove html
      $license = &FormatLicense ($license) ;
      last ;
    }

    if ($line =~ /Public domain/)
    {
      $license = 'Public domain' ;
      last ;
    }
    $line_prev = $line ;
  }

  if ($photographer eq '')
  { $photographer = $photographer2 ; }

  $photographer =~ s/^\s+// ;         # remove leading blanks
  $photographer =~ s/\s+$// ;         # remove trailing blanks
  $photographer =~ s/\s*\(talk\)//i ; # remove ref to talk page
# return ('--','--') ;
  $metadata = "$title,$photographer,$license" ;
  return ($metadata) ;
}

sub FormatLicense
{
  my $license = shift ;

  $license =~ s/\s*\.\s*$// ;
  $license =~ s/This file is licensed under the //i ;
  $license =~ s/ license\s*$//i ;
  $license =~ s/Creative Commons /CC-/i ;
  $license =~ s/Attribution.Share.?Alike/BY-SA/i ;
  $license =~ s/International//i ;
  $license =~ s/Generic//i ;
  $license =~ s/Unported.*$//i ;
  $license =~ s/Attribution/BY/i ;
  $license =~ s/^\s+// ;
  $license =~ s/\s+$// ;

  $license2 = $license ;

  if ($license =~ /at/) # test
  {$a = 1 ; }

  $license =~ s/\-([a-z][a-z])/' '.uc($1)/e ;
  foreach $country_name (keys %country_codes)
  {
    my $country_code = uc ($country_codes {$country_name}) ;
    $license =~ s/$country_name/$country_code/ ;
  }
  if ($license ne $license2)
  { &Log ("\n  License edited from '$license2' to '$license'\n") ; }

  return ($license) ;
}


sub GetPage
{
  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  my $raw_url = shift ;
  my $is_html = shift ;
  my ($success, $content, $attempts) ;
  my $file = $raw_url ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikimedia Perl job");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://wikimedia.org");

  $success = $false ;

  my $msg = "\nFetch '$file'" ;
  for ($attempts = 1 ; ($attempts <= 2) && (! $success) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { $msg .= " -> 404\n" ; }
      else
      { $msg .= " -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n" ; }

      &LogError ($msg) ;

      return ($false) ;
    }

    $content = $response->content();
    $success = $true ;
  }

  if (! $success)
  { &LogError ("Error: page not retrieved after " . (--$attempts) . " attempts !!\n\n") ; }

  return ($success,$content) ;
}

sub ReportFileExistsAlready
{
  my $file_out2 = shift ;
  my $age = -M $file_out2 ;
  my $time = time - $age * (24 * 3600) ;
  my $timestamp = &SecondsToTimestamp ($time) ;
  &Log ("File exists: '$file_out2', downloaded at $timestamp\n") ;
}

sub SecondsToTimestamp
{
  my $seconds = shift ;
  my ($ss,$nn,$hh,$dd,$mm,$yyyy) = localtime ($seconds);
  my $timestamp = sprintf ("%4d-%02d-%02d %02d:%02d", $yyyy+1900, $mm+1, $dd, $hh, $nn) ;
  return ($timestamp) ;
}

sub Log
{
  my $msg = shift ;
  print $msg ;
  print LOG $msg ;
}

#ApiGetLicense # test, not used
#{
#  my $file_out = shift ;
#  my $api_request = "http://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo&iiprop=extmetadata&titles=File%3a$file_out&format=xml" ;
#  my ($success, $content) = &GetPage ($api_request) ;

#  print $content ;
#  exit ;
#}


