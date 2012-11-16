#!/usr/bin/perl

sub CollectCategories
{
  my $namespace = shift ;
  my $text = "" ;
  my $cat  = "" ;
  my $article2 = $article ;
  my $length = length ($article) ;
  $cat = $title ;

  $cat =~ s/_/ /g ;
  $cat =~ s/\"/\'/g ;
  $cat =~ s/\&quot;/\'/g ;
  $cat =~ s/^\s+// ;
  $cat =~ s/\s+$// ;
  $cat =~ s^\@\#\*\$^'^g ; # restore quotes
  $cat = ucfirst ($cat) ;

  if ($cat eq "")
  { return ; }

  undef %CategoryCnt ;
  undef @CategoryList ;

  $article2 =~ s/\[\[$categorytag\:([^\"\`\\\|\]]*)[^\]]*\]\]/&CollectCategory($1,$cat)/giex ;
  if ($categorytag !~ /category/i)
  { $article2 =~ s/\[\[category\:([^\"\`\\\|\]]*)[^\]]*\]\]/&CollectCategory($1,$cat)/giex ; }

  $cat     =~ s/\|/&pipe;/g ;
  $cat     =~ s/\,/&comma;/g ;
  $catlist = join ('|', @CategoryList) ;
  print FILE_CATEGORIES "$namespace,$length,$cat,$catlist\n" ;
}

sub CollectCategory
{
  my $cat  = shift ;

  if ($cat =~ /[\[\]]/) # ignore [[$cat x [[$cat y]]]] error
  { return ("") ; }

  my $cat0 = shift ;
  $cat =~ s/_/ /g ;
  $cat =~ s/\"/\'/g ;
  $cat =~ s/\&quot;/\'/g ;
  $cat =~ s/^\s+// ;
  $cat =~ s/\s+$// ;
  $cat =~ s^\@\#\*\$^'^g ;

  if ($cat eq "")
  { return ; }

  if ($namespace == 14)
  {
    if (lc($cat) eq lc($cat0)) # self referring category
    { return ("") ; }
  }

  $CategoryCnt {uc($cat)} ++ ;
  if ($CategoryCnt {uc($cat)} == 1)
  {
    $cat =~ s/\|/&pipe;/g ;
    $cat =~ s/\,/&comma;/g ;
    push @CategoryList, ucfirst ($cat) ;
  }
  return ("") ;
}

1;