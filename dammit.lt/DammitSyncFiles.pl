#!/usr/bin/perl

# 27 April 2010 renamed from WikiStatsDammitSync.pl

  use Time::Local ;
  use Archive::Tar;

  $tar = Archive::Tar->new;

  $| = 1; # flush screen output

  $maxdaysago = 40; # do not download files more than this ago

  if (-e "a_dammit.lt_index.html") # test
  { $file_html = "a_dammit.lt_index.html" ; }
  else
  {
    open LOG, '>>', "/a/dammit.lt/WikiStatsDammitSync.log" ;

    $file_html = "/a/dammit.lt/index.html" ;
    unlink $file_html ;
    $cmd = "wget -O $file_html http://dammit.lt/wikistats/" ;
    $result = `$cmd` ;
    if ($result == 0)
    { $result = "OK" ; }
    &Log ("Cmd '$cmd' -> $result \n\n") ;

    if (! -e $file_html)    { &Abort ("File $file_html not found") ; }
    if (-s $file_html == 0) { &Abort ("File $file_html empty") ; }
  }

  $timestart = time ;

  chdir "/a/dammit.lt/projectcounts" ;
  $cmd = `pwd` ;
  &Log ("Cmd '$cmd'\n") ;
  $result = `$cmd` ;
  print "$result\n" ;

  open HTML,'<',$file_html ;
  while ($line = <HTML>)
  {
    if ($line =~ /<title>/)
    {
      $subdir = "" ;
      if ($line =~ /archive/)
      {
        $line =~ s/^.*?\/wikistats\/// ;
        $line =~ s/<.*$// ;
        chomp $line ;
        $subdir = $line ;
      }
      &Log ("Subdir = '$subdir'\n") ;
      next ;
    }

    if ($line !~ /application\/octet-stream/) { next ; }

    ($file = $line) =~ s/^.*?a href=\"([^"]+)\".*$/$1/s ;
    ($date = $line) =~ s/^.*?class=\"m\">([^<]+)<.*$/$1/s ;
    ($date,$time) = split (' ', $date) ;

    if ($file =~ /^pagecounts/)
    {
      $yy = substr ($file,11,4) ;
      $mm = substr ($file,15,2) ;
      $dd = substr ($file,17,2) ;
      $daysago = int ((time - timegm(0,0,0,$dd,$mm-1,$yy-1900)) / (24 * 60 * 60)) ;

      print "$file: $daysago days ago\n" ;
      if ($daysago > $maxdaysago) { next ; }

      # $path_7z = "/a/dammit.lt/pagecounts/$yy\-$mm/pagecounts\-$yy$mm$dd\_fdt.7z" ;
      # if (-e $path_7z) { print "exists\n" ; next ; }

      $path = "/a/dammit.lt/pagecounts/$yy\-$mm/pagecounts\-$yy$mm$dd\_h" ;
      if ((-e "$path.7z") || (-e "$path.zip") || (-e "$path.bz2") || (-e "$path.gz"))
      { print "$path.[7z|zip|bz2|gz] exists\n" ; next ; }
      else
      { print "$path.[7z|zip|bz2|gz] new -> download\n" ; }
    }

    # if ($file =~ /^projectcounts/)
    # {
    #  $yy = substr ($file,14,4) ;
    #  $mm = substr ($file,18,2) ;
    #  $dd = substr ($file,20,2) ;
    #  $daysago = int ((time - timegm(0,0,0,$dd,$mm-1,$yy-1900)) / (24 * 60 * 60)) ;
    #  if ($daysago > $maxdaysago) { next ; }
    # }


    $yy = substr ($date,0,4) ;
    $mm = substr ($date,5,3) ;
    $dd = substr ($date,9,2) ;
    $hh = substr ($time,0,2) ;
    $nn = substr ($time,3,2) ;
    $ss = substr ($time,6,2) ;

       if ($mm eq 'Jan') { $mm =  1 ; }
    elsif ($mm eq 'Feb') { $mm =  2 ; }
    elsif ($mm eq 'Mar') { $mm =  3 ; }
    elsif ($mm eq 'Apr') { $mm =  4 ; }
    elsif ($mm eq 'May') { $mm =  5 ; }
    elsif ($mm eq 'Jun') { $mm =  6 ; }
    elsif ($mm eq 'Jul') { $mm =  7 ; }
    elsif ($mm eq 'Aug') { $mm =  8 ; }
    elsif ($mm eq 'Sep') { $mm =  9 ; }
    elsif ($mm eq 'Oct') { $mm = 10 ; }
    elsif ($mm eq 'Nov') { $mm = 11 ; }
    elsif ($mm eq 'Dec') { $mm = 12 ; }
    else                 { &Abort ("Invalid month '$mm' in file date $date $time") ; }

    $date2 = sprintf ("%02d%02d%02d%02d%02d.%02d", ($yy-2000), $mm, $dd, $hh, $nn, $ss) ;

    if ($file =~ /^(?:page|project)counts-2/)
    {

      if ($file =~ /^pagecounts/)
      { $path = "/a/dammit.lt/pagecounts/$file" ; }
      else
      { $path = "/a/dammit.lt/projectcounts/$file" ; }

      if (-e $path)
      {
        &Log ("File $path exists\n") ;
        if (-s $path == 0)
        {
          &Log ("File $path empty -> overwrite\n") ;
          unlink $path ;
        }
        else { next ; }
      }

      if ($file =~ /^projectcounts/)
      {
        $tar_file = "/a/dammit.lt/projectcounts/projectcounts-$yy.tar" ;
        if (-e $tar_file)
        {
          if ($tar_file ne $tar_file_prev)
          {
            &Log ("\nRead tar file $tar_file\n") ;
            $tar->read($tar_file);
            $tar_file_prev = $tar_file ;
          }
          if ($tar->contains_file ($file))
          {
            &Log ("File $file exists in tar file $tar_file\n") ;
            next ;
          }
        }
        else
        { &Log ("Tar file $tar_file not found\n") ; }
      }

      &Log ("Write file $path, set date $date2\n") ;

      $cmd = "wget -a /a/dammit.lt/wget.log -O $path http://mituzas.lt/wikistats/$subdir$file" ;
      $result = `$cmd` ;
      if ($result == 0)
      { $result = "OK" ; }
      &Log ("Cmd '$cmd' -> $result \n\n") ;

      `touch $path -t $date2` ;

      if ($file =~ /^projectcounts/)
      {
        $cmd = "tar --append --file=$tar_file $file" ;
        &Log ("Cmd '$cmd'\n") ;
        $result = `$cmd` ;
        print "$result\n" ;
        unlink $path ;
      }
    }
  }

  &Log ("Ready in " . (time - $timestart) . " sec.\n") ;
  close HTML ;
  close LOG ;
  exit ;

sub Log
{
  $msg = shift ;
  my ($ss, $nn, $hh) = (localtime(time))[0,1,2] ;
  my $time  = sprintf ("%02d:%02d:%02d", $hh, $nn, $ss) ;
  $msg = "$time $msg" ;
  print $msg ;
  print LOG $msg ;
}

sub Abort
{
  $msg = shift ;
  &Log ($msg) ;
  exit ;
}
