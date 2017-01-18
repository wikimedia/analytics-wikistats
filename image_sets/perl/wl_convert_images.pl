#!/usr/bin/perl

# TO DO
# gebruik downloaded image indien aanwezig, anders download image (of convert rechtsstreeks van url?)
# introduceer option $cache_images
# later: genereer extra column in wl_winners.pl

# -----------------------------------------------------------------------------------------------

# use case:
# offline slide shows (there is a great online slide show tool already)
# with image resized, for perfect fit to target platform (and thus greatly reduced file size)

# requires csv input with file data (images and url) and meta data (title, author, liense)
# convert and annotate images into several sets (depending on target resolution)
# annotations are: left: context (e.g. contest name) & context2 (e.g. country), center: title, right: photograph/author & license

# developed and tested on Windows 10

# required (in path or same directory as perl script):
# ImageMagick tool convert.exe: https://www.imagemagick.org/script/binary-releases.php (I used curl-7.46.0-win64.exe)
# ImageMagick xml config files
# font file

  use URI::Escape;
  use Time::Local ;
  use Encode;

  our $true  = 1 ;
  our $false = 0 ;
  our $verbose = 1 ;
  our $cache_originals = $true ; # (recommended:$true) use less disk space, at the expense of multiple downloads, one for each pass of ConvertImages
  our $skip_earlier_converted_images = $true ; # (recommended:$true)
  our $unescaped = $true ;
  our $escaped = $false ;

  our $font = 'Arialuni.ttf' ;

  our $color_text_background = '#FF000000' ;
  our $color_text_undercolor = '#444444FF' ;
  our $color_text_fill       = '#AAAAAA' ;
  our $color_text_stroke     = 'transparent' ;
  our $colors_text = "-background $color_text_background -undercolor $color_text_undercolor -fill $color_text_fill -stroke $color_text_stroke" ;

  our $file_size_minimum = 1024 ; # files less than so many bytes are failed downloads (in WL context) -> remove

  binmode(STDOUT, ":utf8");

  if ((! -e 'curl') && (! -e 'curl.exe'))
  { die "Add curl[.exe] executable to same folder as this script" ; }
  if ((! -e 'curl') && (! -e 'convert.exe'))
  { die "Add convert[.exe] executable to same folder as this script" ; }

  our $project_name = 'Wiki Loves Monuments' ;
# our $project_name = 'Wiki Loves Earth' ;
  our $project_code = $project_name ;
  $project_code =~ s/[^A-Z]//g ;
  if ($project_code !~ /^WLM|WLE$/)
  { die "Unsupported project: '$project_code'" ; }
  $project_code_lc = lc ($project_code) ;

  $folder_data   = "data/" ;

  our $folder = "images_${project_code_lc}" ;
  our $country_code = '' ;

  $file_data = $folder_data . "${project_code_lc}_data.csv" ;
  die "Input file not found: '$file_data'" if ! -e $file_data ;

  $file_log  = $folder_data . "${project_code_lc}_log.txt" ;
  open LOG, '>', $file_log || die "Log file '$file_log' could not be opened for write." ;

  &ReadDataFile (! $verbose) ;

# either convert from local image (downloaded earlier) or from url
  if ($cache_originals)
  { &DownloadImagesIfMissing  ; }

# ref https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
  &ConvertImages (2560,1600,24,14) ;
  &ConvertImages (1920,1080,20,12) ; # full HD TV, iPhone 6+/6s+/7+ plus
  &ConvertImages (1334,750,16,12) ; # iPhone 6/6s/7
  &ConvertImages (1136,640,14,10) ; # iPhone 5/5s
  close LOG ;

  &Log ("\n\nReady\n\n") ;
  exit ;

sub ReadDataFile
{
  my $verbose = shift ;

  &Log ("ReadDataFile\n\n") ;

  open CSV_IN, '<', $file_data ;
  binmode CSV_IN ;

  my $lines = 0 ;
  my $line ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ; # skip header/comment line(s)

    chomp $line ;
    $lines++ ;

    &Log ("$lines: $line\n") if $verbose ;

    my ($filedata, $metadata,$timestamp) = &GetFileAndMetaData ($line) ;

    &Log ("File data: $filedata\n") if $verbose ;
    &Log ("Metadata: $metadata\n")  if $verbose  ;

    $metadata2 = $metadata ;
    $metadata =~ s/^\d+[\.\:]?\s*// ;

    my ($file_out) = split (',', $filedata) ;

    $filedata  {$file_out} = $filedata ;
    $metadata  {$file_out} = $metadata ;
    $timestamp {$file_out} = $timestamp ;
  }
  close CSV_IN ;

  &Log ("ReadDataFile complete: " . ($lines+0) . " lines read from image data file\n\n") ;
}

sub GetFileAndMetaData
{
  my $line = shift ;
  my ($sortkey,$context,$context2,$timestamp,$photographer,$license,$file,$url,$title) = split (',', $line) ;
  my $filedata = "$file,$url" ;
  my $metadata = "$context,$context2,$title,$photographer,$license" ;

  # nomalize timestamp as yyyy-mm-dd, for easy sort (may have been changed by manual curation in Excel)
  if ($timestamp =~ /\//)
  {
    ($date,$time) = split (' ', $timestamp) ;
    ($mm,$dd,$yyyy) = split ('\/', $date) ;
    $timestamp = sprintf ("%04d-%02d-%02d", $yyyy, $mm, $dd) . " $time" ;
  }

  return ($filedata, $metadata, $timestamp) ;
}

sub DownloadImagesIfMissing
{
  foreach my $file_out (sort keys %filedata)
  {
    my $filedata = $filedata {$file_out} ;
    my ($file,$url) = split (',', $filedata) ;
    next if &FileExists ($file) ;

    $downloads ++ ;
    print "$downloads:\n" ;
    &DownloadImage  ($file, $url, $escaped) ;
  }
}

sub FileExists
{
  my $file = shift ;
  $file2 = "$folder/$file" ;
  my $file_exists = -e $file2 ;

  if ($file_exists)
  {
    if (-s $file2 < $file_size_minimum)
    {
      &Log ("Remove '$file2': size less than $file_size_minimum bytes, can't be legit (in WL context) -> remove\n") ;
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

# use curl (instead of wget)
# for reference, wget command would have been:
# $result = `wget --no-check-certificate --restrict-file-names=nocontrol -P $folder $url` ;
sub DownloadImage
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
    $success = &DownloadImage ($file, $url2, $unescaped) ; # try again with changed url
  }

  return $success ;
}


sub ConvertImages
{
  my ($width,$height,$fontsize_large,$fontsize_small) = @_ ;

  die "Invalid width '$width'"                    if $width          !~ /^\d\d\d+$/ ;
  die "Invalid height '$height'"                  if $height         !~ /^\d\d\d+$/ ;
  die "Invalid large font size '$fontsize_large'" if $fontsize_large !~ /^\d+$/ ;
  die "Invalid small font size '$fontsize_small'" if $fontsize_small !~ /^\d+$/ ;

  my $folder_resized = "$folder/${width}x${height}" ;
  if (! -d "$folder_resized")
  {
    mkdir "$folder_resized" ;
    die "Folder could not be created '$folder_resized'" if ! -d $folder_resized ;
  }

  my $conversions = 0 ;
  foreach my $file_out (sort keys %filedata)
  {
    $conversions ++ ;
    print "$conversions:\n" ;
    &ConvertImage ($width, $height, $fontsize_large, $fontsize_small, $filedata {$file_out}, $metadata {$file_out}) ;

  # return if $conversions >= 3 ; # tests
  }
}

sub ConvertImage
{
  my ($width, $height, $fontsize_large, $fontsize_small, $filedata, $metadata) = @_ ;

  my $file_temp ;

  my ($file_out,$url) = split (',', $filedata) ;
  my ($context,$context2,$title,$photographer,$license) = split (',', $metadata) ;

  my $file_downloaded = "$folder/$file_out" ;
  my $file_resized    = "$folder/${width}x${height}/$file_out" ;

  if ($cache_originals && $skip_earlier_converted_images && -e $file_resized)
  {
    if ($verbose)
    { print "File already exists: '$file_resized' -> skip conversion\n" ; }
    return ;
  }

  if (! $cache_originals)
  {
    ($file_ext = $file_out) =~ s/^[^\.]+\.// ;
    $file_temp = "image_to_convert.$file_ext" ;
    if (! &DownloadImage ($file_temp, $url, $unescaped)) # convert can accept url directly, but this step gives extra checks
    {
      &Log ("ConvertImage: image download failed for file '$file_out', url '$url\n") ;
      return ;
    }
  }

  # use this indirect method to supply unicode strings to convert (couldn't get direct method, in command line, to work)
  open LABEL, '>', 'text1a.utf8.txt' ;   print LABEL uri_unescape (" $context ") ;       close LABEL ;
  open LABEL, '>', 'text1b.utf8.txt' ;   print LABEL uri_unescape (" $context2 ") ;      close LABEL ;
  open LABEL, '>', 'text2.utf8.txt' ;    print LABEL uri_unescape (" $title ") ;         close LABEL ;
  open LABEL, '>', 'text3a.utf8.txt' ;   print LABEL uri_unescape (" $photographer ") ;  close LABEL ;
  open LABEL, '>', 'text3b.utf8.txt' ;   print LABEL uri_unescape (" $license ") ;       close LABEL ;

  $offset_top_label = 20 ;

  my ($text1a,$text1b,$text2,$text3a,$text3b) ;

  $text1a = "-gravity SouthWest $colors_text -pointsize $fontsize_small -annotate +0+3  \@text1a.utf8.txt"                if $context      !~ /^\s*$/ ;
  $text1b = "-gravity SouthWest $colors_text -pointsize $fontsize_small -annotate +0+$offset_top_label \@text1b.utf8.txt" if $context2     !~ /^\s*$/ ;
  $text2  = "-gravity South     $colors_text -pointsize $fontsize_large -annotate +0+3  \@text2.utf8.txt"                 if $title        !~ /^\s*$/ ;
  $text3a = "-gravity SouthEast $colors_text -pointsize $fontsize_small -annotate +0+$offset_top_label \@text3a.utf8.txt" if $photographer !~ /^\s*$/ ;
  $text3b = "-gravity SouthEast $colors_text -pointsize $fontsize_small -annotate +0+3  \@text3b.utf8.txt"                if $license      !~ /^\s*$/ ;

  $cmd = "convert $file_downloaded -auto-orient -resize ${width}x${height} -font $font $text1a $text1b $text2 $text3a $text3b $file_resized" ; # 1920x1080
  $result = `$cmd` ;
  if ($result eq '')
  { $result = 'OK' ; }
  $cmd =~ s/-gravity/\n-gravity/g ;
  $cmd =~ s/$folder/\n$folder/g ;
  &Log ("cmd $cmd ->\n-> $result\n\n") ;

  if (! $cache_originals)
  { unlink ($file_temp) ; }
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


