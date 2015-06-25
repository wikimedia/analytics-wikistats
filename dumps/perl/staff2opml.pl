#!/usr/bin/perl#
# shortener http://is.gd/create.php?format=simple&url=http://infodisiac.com/blog
  use Getopt::Std ;
  getopt ("io", \%options) ;
  my $file_in  = $options {'i'} ;
  my $file_out = $options {'o'} ;
  die "Specify input html as -i file" if $file_in  eq '' ;
  die "Specify output html as -o file" if $file_out eq '' ;
  
  print "Input '$file_in'\n" ;
  print "Output '$file_out\n" ;

  die "File not found: '$file_in'" if ! -e $file_in ;

  &ParseFile ;

  print "Ready\n\n" ;
  exit ;

sub ParseFile
{
  open IN,  '<', $file_in ;	
  open OUT, '>', $file_out ;	

  print OUT "<?xml version='1.0' encoding='ISO-8859-1'?>\n" ;
  print OUT "<opml version='1.0'>\n" ;
  print OUT "<head>\n</head>\n<body>\n" ;
  print OUT "<outline text=\"WMF Staff\">\n" ; 
  
  while ($line = <IN>)
  {
    # print OUT $line ;	  
    chomp $line ; 
    if ($line =~ /mw-headline/)
    {
      ($hx = $line) =~ s/^.*?(<h\d>).*$/$1/ ;	    
      $hx =~ s/[<>]//g ;
      $line =~ s/<[^>]*>//g ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;

      next if $line =~ /Contents/ ; 
      next if $line =~ /Navigation/ ; 

      if ($hx eq 'h2') { while ($level > 0) { print OUT "</outline>\n" ; $level -- ; }}      
      if ($hx eq 'h4') { while ($level > 1) { print OUT "</outline>\n" ; $level -- ; }}      
      if ($hx eq 'h5') { while ($level > 2) { print OUT "</outline>\n" ; $level -- ; }}      
      if ($hx eq 'h6') { while ($level > 3) { print OUT "</outline>\n" ; $level -- ; }}      
      if ($hx eq 'h7') { while ($level > 4) { print OUT "</outline>\n" ; $level -- ; }}      
      $level ++ ;
    # print OUT "<outline text='$level [$hx] $line'>\n" ;      
      print OUT "<outline text='$level $line'>\n" ;      

    }

    if ($line =~ /<div style="width: 145px;/)
    {
      if ($line =~ /font-weight:\s*bold/)
      {
        $line =~ s/"//g ;
        $line =~ s/'/\'/g ;
        $name = &striphtml ($line) ;
      }
      else
      {
	$note = '' ;      
	if ($image ne '')
	{ $note = "_note=\"image $image\"" ; }
	$image = '' ;

        $role = &striphtml ($line) ;
        $roles {$role} ++ ;
	$names {$role} .= "$name / " ;

	print "<outline text=\"$name / $role\" />\n" ;
      # print OUT "<outline text=\"&lt;b&gt;$name&lt;/b&gt; / $role\" $note/>\n" ;
        $line = "<outline text=\"&lt;b&gt;$name&lt;/b&gt; / $role\" $note/>\n" ;
	if ($line =~ /llt/)
	{ print "XXX $line\n" ; }
	$line =~ s/\&llt;/\&lt;/ ;
	$line =~ s/\&ggt;/\&gt;/ ;
        print OUT $line ;
      }
    }

    if ($line =~ /<img /)
    {
      $line =~ s/^.*?src="// ;
      $line =~ s/".*$// ;
      $image = $line ;    
    }  
    
    if ($line =~ /div style="margin-bottom: 4px;/)
    {
    
    }
  }

  print OUT "</outline>\n" ;       

  print OUT "<outline text=\"Roles\">\n" ; 
# foreach $role (sort {$roles {$b} <=> $roles {$a}} keys %roles)
  foreach $role (sort keys %roles)
  { 
    $names = $names {$role} ;
    $names =~ s/ \/ $// ;
  # print OUT "<outline text=\"$role (${roles{$role}})\" _note=\"$names\" />\n" ; 
    $count = $roles {$role} ;
    if ($count == 1)  
    { print OUT "<outline text=\"&lt;b&gt;$role &lt;/b&gt;: $names\" />\n" ; }
    else    
    { print OUT "<outline text=\"&lt;b&gt;$role (${roles{$role}})&lt;/b&gt;: $names\" />\n" ; }
  }  
  print OUT "</outline>\n" ;       

  print OUT "</outline>\n" ;       
  print OUT "</body>\n</opml>\n" ;

  close IN ;
  close OUT ;
}

sub striphtml
{
  my $line = shift ;	
  $line =~ s/<[^>]*>//g ;
  $line =~ s/^\s*// ;
  $line =~ s/\s*$// ;
  return $line ;
}
