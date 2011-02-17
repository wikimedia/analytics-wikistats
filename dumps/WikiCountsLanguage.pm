#!/usr/bin/perl

sub ReadLanguageSettings
{
  &LogT ("Read Langage Settings") ;
  # http://svn.wikimedia.org/viewvc/mediawiki/trunk/phase3/languages/messages/
  # code probably needs update
  # these files have no been parsed for quite some time
  # previous results are reused from LanguageCodes.csv
  if ($path_php eq "")
  { &LogT ("\n\nNo path specified for language specific php scripts. Specify as: -s path\n") ; }
  else
  {
    if (! -e $path_php)
    { &LogT ("\n\nPath for language specific php scripts not found:\n'$path_php'\n") ; }
    else
    {
      $path_php =~ s/[\\\/]*$/\// ;                 # was $language_ (underscore) upd OK ?
    # $file_php = $path_php . "classes/Language" . ucfirst (lc ($language)) . ".php" ;
      $file_php = $path_php . "messages/Messages" . ucfirst (lc ($language)) . ".php" ;
      $file_php =~ s/Zh\.php/Zh_tw.php/ ; # not sure if this will do in the future
      &LogT ("\n\nLanguage specific php script: '$file_php'\n") ;
    }
  }

  # actually $imagetag would now be better named $filetag, since namespace tag IMAGE: became alias for FILE: (don't change though)
  ($encoding, $categorytag, $imagetag, $usertag, $redirtag) = &GetLanguageSettings ;
  if ($categorytag !~ /x/) # /^[a-zA-Z0-9]*^/)
  {
     if ($language eq "sr") # still applicable ?
     { substr ($redirtag,2,1) = chr (159) ; }

     $prt_encoding = "'$encoding'" ;
     $prt_encoding = sprintf ("%-20s", $prt_encoding) ;
     $prt_categorytag = "'$categorytag'" ;
     $prt_categorytag = sprintf ("%-20s", $prt_categorytag) ;
     $prt_imagetag = "'$imagetag'" ;
     $prt_imagetag = sprintf ("%-20s", $prt_imagetag) ;
     $prt_usertag = "'$usertag'" ;
     $prt_usertag = sprintf ("%-20s", $prt_usertag) ;
     $prt_redirtag = "'$redirtag'" ;
     $prt_redirtag = sprintf ("%-20s", $prt_redirtag) ;
  }

  &LogT ("\nLanguage settings:\n" .
         "Encoding $prt_encoding\n" .
         "Category $prt_categorytag\n" .
         "Image    $prt_imagetag\n" .
         "User     $prt_usertag\n" .
         "Redirect $prt_redirtag\n") ;

  &LogT (&OptimizeRegExpKeyword ('image',    $imagetag)) ;
  &LogT (&OptimizeRegExpKeyword ('redirect', $redirtag)) ;

  $input_unicoded = $false ;
  if ($encoding eq "utf-8")
  { $input_unicoded = $true ; }
  &Log ("\n") ;
}


sub OptimizeRegExpKeyword
{
  my $desc = shift ;
  my $tags = shift ;
  my $log = "" ;

  if ($tags =~ /|/)
  {
    my $allstartwithhash = $true ;
    my @tags2 = split ('\|', $tags) ;
    foreach $tag (@tags2)
    {
      if ($tag !~ /^\#/)
      { $allstartwithhash = $false ; }
    }
    $tags = "(?:$tags)" ;
    if ($allstartwithhash)
    {
      $tags =~ s/\:\#/\:/ ;
      $tags =~ s/\|\#/\|/g ;
      $tags = "\\#$tags" ;
    }
    $log = "\nUse for $desc regexp '$tags'\n" ;
  }
  return ($log) ;
}

sub GetLanguageSettings
{
  my ($found, $encoding, $category, $image, $user, $redirtag) = &ReadFilePhp ;

  # if php script not found or incomplete, reuse parameters from last session
  if (! $found)
  {
    &ReadFileCsvAll ($file_language_codes) ;
    foreach $line (@csv)
    {
      if ($line =~ /^$language,/)
      {
        ($language, $encoding, $category, $image, $user, $redirtag) = split (',', $line) ;
        if ($redirtag eq "")
        { $redirtag = "#redirect" ; }
        &LogT ("Reuse tags from last session\n") ;
        last ;
      }
    }
  }

  $category =~ s/,/&comma;/g ;
  $image    =~ s/,/&comma;/g ;
  $user     =~ s/,/&comma;/g ;
  $redirtag =~ s/,/&comma;/g ;

  &ReadFileCsv ($file_language_codes) ;
  push @csv, "$language,$encoding,$category,$image,$user,$redirtag" ;
  @csv = sort {$a cmp $b} @csv ;
  &WriteFileCsv ($file_language_codes) ;

  # remove brackets (signify that value was not found in php file, but was added as default)
  $encoding =~ s/\((.*)\)/$1/ ;
  $category =~ s/\((.*)\)/$1/ ;
  $image    =~ s/\((.*)\)/$1/ ;
  $user     =~ s/\((.*)\)/$1/ ;
  $redirtag =~ s/\((.*)\)/$1/ ;

  $category =~ s/&comma;/,/ ;
  $image    =~ s/&comma;/,/ ;
  $user     =~ s/&comma;/,/ ;
  $redirtag =~ s/&comma;/,/ ;

  return ($encoding, $category, $image, $user, $redirtag) ;
}

# look in php file for encoding (utf ?) and language specific tags
# write them to csv file
# use values from csv file if php file could not be found (
sub ReadFilePhp
{
  # store within brackets when default value, not found in php file
  my $found    = $false ;
  my $encoding = "(utf-8)" ;
  my $category = "(Category)" ;
  my $image    = "(Image)";
  my $user     = "(User)";
  my $redirtag = "(#Redirect)";

  $try_phpfile = $true ;
  parse_phpfile:
  while ($try_phpfile && (++$files_php_read <= 3))
  {
    &LogT ("Language specific php file: read '$file_php'\n") ;

    if (($file_php eq "") || (! (-e $file_php)))
    { &LogT ("Language specific php file not found\n") ; }
    else
    {
      $found = $true ;
      &LogT ("Language specific php file found\n\n") ;

      open "FILE_PHP", "<", $file_php ;
      @php = <FILE_PHP> ;
      close FILE_PHP;

      foreach $line (@php)
      {
        if ($line =~ /\$fallback\s*=\s*'.*'/)
        {
          chomp ($line) ;
          &LogT ("Language specific php file refers to fallback file '$line'\n") ;
          $line =~ s/^.*?fallback\s*=\s*'([^']*)'.*$/$1/ ;
          $line =~ s/-/_/g ;
          $file_php =~ s/[^\/]*$// ;
          $file_php .= "Messages" . ucfirst ($line) . ".php" ;
          next parse_phpfile ;
        }
      }
      $try_phpfile = $false ;

      $array_namespace = $false ;
      foreach $line (@php)
      {
        chomp $line ;

        $line =~ s/\\'/*quote;/g ;
        $line =~ s/\\"/*dquote;/g ;
        # no provision for commented lines with similar content
        if ($line =~ /\$wgInputEncoding\s*=/)
        {
          $line =~ s/^.*?\"([^\"]*)\".*$/$1/ ;
          $line =~ s/^.*?\'([^\']*)\'.*$/$1/ ;
          $encoding = $line ;
          &LogT ("Encoding: $encoding\n") ;
        }

        # no provision for commented lines with similar content
        if ($line =~ /'redirect'\s*=>/)
        {
          $line =~ s/^.*?\(// ;
          $line =~ s/\).*$// ;
          my ($dummy,@tags) = split (',', $line) ;
          my $tags = "" ;
          foreach my $tag (@tags)
          {
            $tag =~ s/\s*"([^"]*).*$/$1/ ;
            $tag =~ s/\s*'([^']*).*$/$1/ ;
            if (length ($tag) < 2)
            {
              &LogT ("Ignore empty or too short (suspect) redirect tag '$tag'\n") ;
              next ;
            }
            if ($tag !~ /^#/)
            { $allstartwithhash = $false ; }
            $tags .= "$tag|" ;
          }
          if ($tags !~ /\#redirect/i)
          { $tags .= "#REDIRECT" ; }
          $tags =~ s/\|\s*$// ;
          $redirtag = $tags ;
          # &LogT ("Redirtag(s): $redirtag\n") ;
        }

        if ($line =~ /\$namespaceNames.*=.*array/i)
        { $array_namespace = $true ; }
        if ($line =~ /\)/)
        { $array_namespace = $false ;        }

        if ($line =~ /\$namespaceAliases.*=.*array/i)
        { $array_namespace_aliases = $true ; }
        if ($line =~ /\)/)
        { $array_namespace_aliases = $false ;        }

        if ($array_namespace)
        {
          if (($line =~ /NS_USER\s*=>/) ||
              ($line =~ /\s2\s*=>/))
          {
            $line =~ s/^.*?\"([^\"]*)\".*$/$1/ ;
            $line =~ s/^.*?\'([^\']*)\'.*$/$1/ ;
            $user = $line ;
            # &LogT ("User: $user\n") ;
          }
          if (($line =~ /NS_MEDIA\s*=>/) || # old alias for IMAGE, now FILE (?)
              ($line =~ /NS_IMAGE\s*=>/) || # old keyword, now alias
              ($line =~ /NS_FILE\s*=>/) ||
              ($line =~ /\s6\s*=>/))
          {
            $line =~ s/^.*?\"([^\"]*)\".*$/$1/ ;
            $line =~ s/^.*?\'([^\']*)\'.*$/$1/ ;
            if ($image eq "(Image)")
            { $image = $line ; }
            else
            { $image .= "|$line" ; }
            # &LogT ("Image: $image\n") ;
          }
          if (($line =~ /NS_CATEGORY\s*=>/) ||
              ($line =~ /\s14\s*=>/))
          {
            $line2 = $line ;
            $line =~ s/^.*?\"([^\"]*)\".*$/$1/ ;
            $line =~ s/^.*?\'([^\']*)\'.*$/$1/ ;
            $category = $line ;
            &LogT ("Line: '$line2'\n") ;
            &LogT ("Category: '$category'\n") ;
          }
        }

        if ($array_namespace_aliases)
        {
          if ($line =~ /=>\s*NS_FILE[^_\w]/) # old keyword, now alias
          {
            $line =~ s/^.*?\"([^\"]*)\".*$/$1/ ;
            $line =~ s/^.*?\'([^\']*)\'.*$/$1/ ;
            $image .= "|$line" ;
            # &LogT ("Image alias: $line\n") ;
          }
        }
      }
    }
  }

  if ($image !~ /(?:^|\|)IMAGE(?:$|\|)/i)
  { $image .= "|Image" ; }
  if ($image !~ /(?:^|\|)FILE(?:$|\|)/i)
  { $image .= "|File" ; }

  $encoding =~ s/\*quote;/'/g ;
  $encoding =~ s/\*dquote;/"/g ;
  $category =~ s/\*quote;/'/g ;
  $category =~ s/\*dquote;/"/g ;
  $image    =~ s/\*quote;/'/g ;
  $image    =~ s/\*dquote;/"/g ;
  $user     =~ s/\*quote;/'/g ;
  $user     =~ s/\*dquote;/"/g ;
  $redirtag =~ s/\*quote;/'/g ;
  $redirtag =~ s/\*dquote;/"/g ;

  return ($found, $encoding, $category, $image, $user, $redirtag) ;
}

1;
