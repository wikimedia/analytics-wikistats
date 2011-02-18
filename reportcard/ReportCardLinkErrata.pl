#!/usr/local/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

  &PatchFiles ("W:/@ Report Card/Extended") ;
  &PatchFiles ("W:/@ Report Card/Public") ;

  print "\n\nReady\n\n" ;
  exit ;

sub PatchFiles
{
  my $dir = shift ;
  $prevdir = getcwd ;
  print "prevdir $prevdir\n" ;
  chdir ($dir) || die "Cannot chdir to $dir\n";
  $dir = getcwd ;
  print "currdir $dir\n" ;

  print "\nErrata files:\n\n" ;

  local (*DIR);
  opendir (DIR, ".");

  my %errata ;
  while ($file = readdir (DIR))
  {
     if ($file eq "." || $file eq "..")
     { next ; }

     next if $file !~ /^RC_\d\d\d\d_\d\d_errata\.html$/ ;

     print "File $file\n" ;
     $file =~ s/_errata.*$// ;
     $errata {$file} ++ ;
  }

  closedir(DIR);

  print "\nPatch files:\n\n" ;

  opendir (DIR, ".");
  while ($file = readdir (DIR))
  {
     if ($file eq "." || $file eq "..")
     { next ; }

     next if $file !~ /^RC_\d\d\d\d_\d\d_(?:synopsis|columns|detailed|summary)\.html$/ ;

     ($file2 = $file) =~ s/_[a-z]+\.html$// ;
     next if $errata {$file2} == 0 ;

     # print "Check file $file\n" ;

     $add_errata = $false ;
     open  FILE, '<', $file ;
     @lines = <FILE> ;
     close FILE ;

     foreach $line (@lines)
     {
       if ($line =~ /RC_\d\d\d\d_\d\d_\w+\.html.*?RC_\d\d\d\d_\d\d_\w+\.html.*?RC_\d\d\d\d_\d\d_\w+\.html/i)
       {
         if ($line !~ /errata/i)
         {
           $add_errata = $true ;
           # print "\nBefore:$line\n" ;
           $line =~ s/<\/small>/&nbsp;&nbsp;&nbsp;&nbsp; &rArr; <a href='${file2}_errata.html'><font color=#A00000>Errata<\/font><\/a><\/small>/ ;
           # print "\nAfter:$line\n" ;
           last ;
         }
       }
     }

     if ($add_errata)
     {
       print "Patch file $file\n" ;
       open  FILE, '>', $file ;
       print FILE @lines ;
       close FILE ;
     }
  }
  closedir(DIR);

  chdir($prevdir);
  $dir = getcwd ;
  print "\ncurrdir $dir\n" ;
}


