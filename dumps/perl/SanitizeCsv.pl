#!/usr/bin/perl

# ScanFolders ("D:\\Wikipedia\\\@xml\\wb\\csv","") ;
  ScanFolders ("/home/wikipedia/wikistats","") ;
  exit ;

sub ScanFolders
{
   my $dir  = shift ;
   my $dirs = shift ;
   my ($file, $stats, $size, $age) ;

   if (!-e $dir)
   {
     print "dir $dir no found\n" ;
     return ;
   }

   if ($dirs eq "")
   { $dirs = $dir ; }
   else
   { $dirs .= "/" . $dir ; }

   chdir ($dir) || die "Cannot chdir to $dir\n";
   local (*DIR);
   opendir (DIR, ".");
   while ($file = readdir (DIR))
   {
      if ($file eq "." || $file eq "..")
      { next ; }

      if (-d $file)
      {
        $dircnt++ ;
        &ScanFolders ($file,$dirs);
      }
      else
      {
        if ($file !~ /\.csv$/) { next ; }
        $filecnt++ ;

        @stats = stat ($file) ;
        if ($#stats < 0) { next ; }

        $size = $stats [7] ;
        $time = $stats [9] ;

        open (FILE_IN, "<", "$dirs/$file") || die ("File $dirs/$file could not be opened.") ;
        undef @lines ;
        undef @skiplines ;
        $skipped = 0 ;
        while ($line = <FILE_IN>)
        {
          
          if ($line =~ /^[^\,]*mania(?:team|200)/i)
          {
            if ($skipped < 10)
            { push @skiplines, $line ; }
            $skipped ++ ;
          }
          else
          { push @lines, $line ; }
        }
        close FILE_IN ;
        if ($skipped > 0)
        {
          #open (FILE_OUT, ">", "$dirs/$file") || die ("File $dirs/$file could not be opened.") ;
          #foreach $line (@lines)
          #{ print FILE_OUT $line ; } 
          #close FILE_OUT ;
        } 
        print sprintf ("%7d", $#lines) . " lines " . sprintf ("%7.1f", $size/1024) . " Kb $dirs/$file\n" ;
        if ($skipped > 0)
        {
          print sprintf ("%6d", $skipped) . " skipped\n\n" ;
          print @skiplines ;
          print "\n\n" ;
        }
      }
   }

   closedir(DIR);
   chdir("..");
}


