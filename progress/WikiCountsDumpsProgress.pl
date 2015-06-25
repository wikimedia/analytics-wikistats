#!/usr/bin/perl

# use lib "/home/ezachte/lib" ;
# use EzLib ;
# $trace_on_exit = $true ;
# ez_lib_version (4) ;

  use CGI qw(:all);
  use Time::Local ;
  use Getopt::Std ;

  $| = 1; # flush screen output

  $path_dumps_root = "/mnt/data/xmldatadumps/public" ; # Q&D hard coded, to be externalized
  $file_folders    = "/a/wikistats_git/dumps/csv/csv_mw/DumpFolders.csv" ;
  $file_dump_files = "/a/wikistats_git/dumps/csv/csv_mw/DumpFiles.csv" ;

  $regexp_timestamp = "\\d{4}\\-\\d{2}\\-\\d{2}\\s\\d{2}\\:\\d{2}\\:\\d{2}" ;

# test runs
# $file_dump_files = "DumpFiles.csv" ;
# &ParseIndexFile ("fiwiki_20150205_index.html","xxx","yyy") ;
# &ParseIndexFile ("fiwiki_20150127_index.html","xxx","yyy") ;
# &ParseIndexFile ("enwiki_20150205_index.html","enwiki","20150205") ;
# exit ;

  open FOLDERS, '<', $file_folders ;
  while ($line = <FOLDERS>)
  {
    next if $line =~ /^#/ ;
    next if $line =~ /^\s*$/ ;

    chomp $line ;
    $folders {$line} ++ ;
  }
  close FOLDERS ;

  chdir $path_dumps_root ;

  @files = <*>;
  foreach $file (@files)
  {
    next if ! -d $file ;
# print "$file\n" ;
    push @folders, $file ;
  }

  $index_folders = 0 ;
  foreach $folder (@folders)
  {
    # last if $folders_scanned ++ >= 20 ;

    $index_folders++ ;
    print "$index_folders $path_dumps_root/$folder\n" ;
    chdir "$path_dumps_root/$folder" ;

    @files2 = <*>;
    foreach $file2 (@files2)
    {
      next if $file2 !~ /^\d\d\d\d\d\d\d\d$/ ;
      $folder2 = $file2 ;

      if (defined $folders {"$folder/$folder2"})
      {
      # print "$folder/$folder2 already added\n" ; 
        next ;
      }

      next if ! -d $file2 ;

      $file_index = "$folder2/index.html" ;
      if (! -e $file_index)
      {
        print "$folder/$file_index not found!!!\n" ;
        next ;
      }

      ($completed,$file_timestamps) = &ParseIndexFile ($file_index,$folder,$folder2) ;
     
      if ($completed)
      {     
        print "add $folder/$folder2 to completed jobs\n\n" ;
    # last if $folders_written ++ >= 5 ;
        $folders {"$folder/$folder2"} ++ ;
 #     print "$file_index\n" ;
      }
      else
      {
        print "defer adding $folder/$folder2 to completed jobs: job marked as 'running' and still activity in last hour\n\n" ;
      }
    }
  }

  open FOLDERS, '>', $file_folders ;
  foreach $folder (sort keys %folders)
  { print FOLDERS "$folder\n" ; }
  close FOLDERS ;

  print "\nNew data files to be found in /a/wikistats_git/dumps/csv/csv_mw/" ; # Q&D hard coded, to be externalized
  print "\nFields:wiki,job start date,file timestamp,job duration hh:mm:ss, job duration secs,step status,step duration,file size,file name,file desc\n" ;

  print "\n\nReady\n\n" ;
  exit ;

sub ParseIndexFile
{
  my ($file,$folder,$folder2) = @_ ;
  my @lines ;

  $index_age = -M $file ;
  print "\nparse index file '$file' (" . sprintf ("%.0f", 60*24*$index_age) . " minutes old)\n" ;
  
  open INDEX, '<', $file || die "File '$file' can't be opened" ;

  my ($lines_out,@lines_out) ;
  my $file_timestamp_first = '' ;
  my $file_timestamp_oldest = '' ;

  @index_lines = <INDEX> ;

  my $html_complete ;

  foreach $line (@index_lines)
  {
    if ($line =~ /$regexp_timestamp/)
    {
      chomp $line ;
      ($file_timestamp_oldest = $line) =~ s/^.*?($regexp_timestamp).*$/$1/ ;
    }

    if ($line =~ /<\/html>/)
    { $html_complete = 1 ; }
  }

  if (! $html_complete)
  {
    open FILES, '>>', $file_dump_files ;
    print FILES "$folder,$folder2,,,,,corrupt index.html,-,-,Job status" ;
    close FILES ;
    return ;
  }

  $file_sec_oldest = Time2Sec ($file_timestamp_oldest) ;

  foreach $line (@index_lines)
  {
    $project = '' ;
    $private = $false ;

#    if ($line =~ /ETA \d\d\d\d-\d\d-\d\d/)
#    {
#      my ($eta,$yy,$mm,$dd,$hh,$nn,$togo,$left,$days,$hours,$time) ;
#      $time = time ;
#      ($eta = $line) =~ s/^.*?ETA (\d\d\d\d-\d\d-\d\d \d\d\:\d\d).*$/$1/ ;
#      $yy = substr ($eta,0,4) ;
#      $mm = substr ($eta,5,2) ;
#      $dd = substr ($eta,8,2) ;
#      $hh = substr ($eta,11,2) ;
#      $nn = substr ($eta,14,2) ;

#      $time_eta = timegm (0, $nn, $hh, $dd, $mm-1, $yy-1900) ; # - 8 * 60 * 60 ; # GMT -> PST
#      $togo = ($time_eta - $time) / (24*60*60) ;

#      $days  = int ($togo) ;
#      $hours = ($togo-$days) * 24 ;
#      $minutes = int (($hours - int ($hours)) * 60) ;
#      $hours  = int ($hours) ;

#      if ($days + $hours + $minutes > 0) # any of these non zero => 60 seconds or more
#      {
#        $left = "" ;
#        if ($days > 0)
#        { $left =  "$days days, " ; }
#        if ($hours > 0)
#        { $left .=  "$hours hrs" ; }
#        if ($minutes > 0)
#        { $left .=  ", $minutes min" ;            }
#        $left = "<b>($left to go)<\/b>" ;
#        if ($days > 0)
#        { $left = "<font color='#FF0000'>$left<\/font>" ; }
#        $line =~ s/(ETA \d\d\d\d-\d\d-\d\d \d\d\:\d\d\:\d\d)/$1 $left/ ;
#      }
#    }

    $line =~ s/<\/?bi?g?>//g ;

  # if ($line =~ /^\s*<li.*?$regexp_timestamp/)

    if ($line =~ /$regexp_timestamp/)
    {
      chomp $line ;
      ($file_timestamp = $line) =~ s/^.*?($regexp_timestamp).*$/$1/ ;

      if ($line !~ /<span class='status'>/)
      { $file_status = 'unknown' ; }
      else
      {
        ($file_status = $line) =~ s/^.*?<span class='status'>// ;
        $file_status =~ s/<.*$// ;
      }

      if ($line !~ /^.*?<span class='title'>/)
      { $file_desc = 'unknown' ; }
      else
      {
        ($file_desc = $line) =~ s/^.*?<span class='title'>// ;
        $file_desc =~ s/<.*$// ;
      }
      $file_desc =~ s/\"/\%22/g ;
      $file_desc = "\"$file_desc\"" ;
      $file_desc =~ s/(flagged \w+),.*$/$1\.\"/ ; # shorten too long msg

      $file_sec_prev = $file_sec ;
      $file_sec = Time2Sec ($file_timestamp) ;
      $step_duration = $file_sec_prev - $file_sec ;

      # now calc step length and job ltime passed for previous step
      $job_duration = $file_sec_prev - $file_sec_oldest ;
      $job_duration2 = $job_duration ;

      $job_duration_sec = $job_duration2 % 60 ;
      $job_duration2 -= $job_duration_sec ;
      $job_duration2 /= 60 ;
      $job_duration_min = $job_duration2 % 60 ;
      $job_duration2 -= $job_duration_min ;
      $job_duration_hrs = $job_duration2 / 60 ;
      $job_duration_hms = sprintf ("%d:%02d:%02d", $job_duration_hrs, $job_duration_min, $job_duration_sec) ;

      if ($file_timestamp_first eq '')
      {
        $file_timestamp_first   = $file_timestamp ;
        $job_duration_hms_first = 'JOB_DURATION_HMS' ; # $job_duration_hms ;
        $job_duration_first     = 'JOB_DURATION' ; # $job_duration ;

        $job_status = $file_status ;
        if ($job_status ne 'done')
        {
          if ($index_age < 1/24)
          { $job_status = 'running' ; }
          else
          { $job_status = 'failed' ; }
        }
      }
      else
      {
        if ($job_duration_first eq 'JOB_DURATION')
        {
          $job_duration_first     = $job_duration ;
          $job_duration_hms_first = $job_duration_hms ;
        }
      }

      $lines_out =~ s/FILE_DURATION/$job_duration_hms,$job_duration,$step_duration/g ;
#     print $file_details ;

#      if ($line =~ /private/)
#      {
#        $private = $true ;
#        ($project = $line) =~ s/^.*?(\w+)wiki.*$/$1/ ;
#        push @wikiprivate, "<font color='#808080'>$project</font>" ;
#        $line = '' ;
#        next ;
#      }
#      else
#      {
#        $href = $line ;
#        $href =~ s/^.*href=\"([^\"]+)\".*$/$1/ ;
#        if ($href eq $line)
#        { $href =~ s/^.*?([a-z_]+wiki).*$/$1/ ; }
#        if ($href eq $line)
#        { $href = 'n.a.' ; }

#        ($date = $line) =~ s/^.*\/(20\d{6}).*$/$1/ ;
#        if ($date =~ /\d{8,8}/)
#        {
#          $year  = substr ($date,0,4) ;
#          $month = substr ($date,4,2) ;
#          $day   = substr ($date,6,2) ;
#          $date = "$year$month$day" ;
#        }
#        else
#        { $date = "?" ; }

#        if ($test)
#        { ($project = $href) =~ s/http:\/\/download.wikimedia.org\/([^\/]+)\/.*$/$1/ ; }
#        else
#        { ($project = $href) =~ s/([^\/]+)\/.*$/$1/ ; }
#      }
#      next if $project =~ /labs/ ;

#      $projectcount++ ;
#      &Log ("\n=== $projectcount: Project $project ===\n\n") ;

#      $jobstatus = "" ;
#      if ($line =~ / failed/)   { $jobstatus  = "failed|" ; }
#      if ($line =~ / aborted/)  { $jobstatus .= "aborted|" ; }
#      if ($line =~ / \(new\)/)  { $jobstatus .= "new|" ; }
#      if ($line =~ / progress/) { $jobstatus .= "progress|" ;
#                                  $jobs_in_progress {$project} = $true ; }
#      $jobstatus =~ s/\|$// ;

#      $projectinfo_lastrun      = "$date,$project,$href,$jobstatus" ;
#      $projectinfo_lastrun_prev = $projectsinfo_lastrun {$project} ;

#      if ($projectinfo_lastrun_prev eq "")
#      {
#        $file_status = "new" ;
#        &Log ("\nNew project $project: -> $projectinfo_lastrun\n") ;
#      }
#      elsif ($projectinfo_lastrun_prev ne $projectinfo_lastrun)
#      {
#        $file_status = "changed" ;
#        &Log ("\nUpdated project $project: $projectinfo_lastrun_prev -> $projectinfo_lastrun\n") ;
#      }
#      else
#      {
#        $file_status = "unchanged" ;
#        &Log ("\nUnchanged project $project: $projectinfo_lastrun_prev -> $projectinfo_lastrun\n") ;
#      }

#      $projectsinfo_lastrun {$project} = $projectinfo_lastrun ;

#      &Log ("Status $file_status, last run $projectinfo_lastrun \n") ;

#      if (($file_status ne "unchanged") || ($jobstatus =~ /progress/))
#      { &UpdateProject ($projectinfo_lastrun) ; }

#      if (($line =~ /Dump complete/) && ($line !~ /item/))
#      { $line = '' ; }

#      if (($line =~ / failed/) && ($line !~ / progress/))
#      {
#        $line =~ s/<span[^>]*>(.*?)<\/span>/$1/ ;
#        $line =~ s/<\/a>(.*)/<\/a><font color='#800000'><b>$1<\/b><\/font>/ ;
#        push @lines_fail, $line ;
#        $line = '' ;
#      }
    }

    if ($line =~ /<li class='file'>/)
    {
      chomp $line ;
      $line_out = '' ;

      if ($line =~ m/href=/)
      {
        ($file = $line) =~ s/^.*href=\"// ;

        ($file_size = $file) =~ s/^.*?<\/a>\s*// ;
         $file_size =~ s/<.*$// ;
         $file_size = &FileSizeNormalize ($file_size) ;

        $file =~ s/\".*$// ;

        $file =~ s/^\/// ;
        ($file_wiki,$file_date,$file_name) = split ('\/', $file) ;

      # $line_out = "$file_wiki,$file_date,$file_timestamp,FILE_DURATION,$file_status,$file_size,$file_name,$file_desc\n" ;
        $line_out = "$folder,$folder2,$file_timestamp,FILE_DURATION,$file_status,$file_size,$file_name,$file_desc\n" ;
      }
      else
      {
        $line =~ s/^.*?<li class='file'>// ;
        $line =~ s/<.*$// ;
        ($file_name,$file_size) = split (' ', $line, 2) ;

        $file_size =~ s/\s*\(written\)\s*// ;
        $file_size = &FileSizeNormalize ($file_size) ;

      # $line_out = "$file_wiki,$file_date,$file_timestamp,FILE_DURATION,$file_status,$file_size,$file_name,$file_desc\n" ; # keep file wiki&date from previous step that did succeedda
        $line_out = "$folder,$folder2,$file_timestamp,FILE_DURATION,$file_status,$file_size,$file_name,$file_desc\n" ; # keep file wiki&date from previous step that did succeedda
      }

      $lines_out .= $line_out ;
    }

    elsif ($line =~ /<li class='waiting'>/)
    {
      chomp $line ;
      $line_out = '' ;

      if ($line !~ /^.*?<span class='title'>/)
      { $file_desc = 'unknown' ; }
      else
      {
        ($file_desc = $line) =~ s/^.*?<span class='title'>// ;
        $file_desc =~ s/<.*$// ;
      }
      $file_desc =~ s/\"/\%22/g ;
      $file_desc = "\"$file_desc\"" ;
      $file_desc =~ s/(flagged \w+),.*$/$1\.\"/ ; # shorten too long msg

      if ($line =~ /<li class='missing'>/)
      {
        ($file_name = $line) =~ s/^.*?<li class='missing'>// ;
        $file_name =~ s/<.*$// ;
        $line = '' ;
      }

      if ($file_timestamp ne '')
      { $line_out = "$folder,$folder2,$file_timestamp,-,-,-,waiting,-,$file_name,$file_desc\n" ; }
      else
      { $line_out = "$folder,$folder2,NO_FILE_TIMESTAMP,waiting,-,$file_name,$file_desc\n" ; }

      $lines_out .= $line_out ;
    }

    elsif ($line =~ /<li class='failed'>/)
    {
      chomp $line ;
      $line_out = '' ;

      $line =~ s/^.*?<li class='failed'>// ;
      $line =~ s/<.*$// ;
      $file_name = $line ;

      if ($file_timestamp ne '')
      { $line_out = "$folder,$folder2,$file_timestamp,-,-,-,failed,-,$file_name,$file_desc\n" ; }
      else
      { $line_out = "$folder,$folder2,NO_FILE_TIMESTAMP,failed,-,$file_name,$file_desc\n" ; }

      $lines_out .= $line_out ;
    }

    elsif ($line =~ /<li class='missing'>/)
    {
      chomp $line ;
      $line_out = '' ;

      $line =~ s/^.*?<li class='missing'>// ;
      $line =~ s/<.*$// ;
      $file_name = $line ;

      if ($file_timestamp ne '')
      { $line_out = "$folder,$folder2,$file_timestamp,-,-,-,missing,-,$file_name,$file_desc\n" ; }
      else
      { $line_out = "$folder,$folder2,NO_FILE_TIMESTAMP,missing,-,$file_name,$file_desc\n" ; }

      $lines_out .= $line_out ;
    }

    elsif ($line =~ /\(private\)/)
    {
      chomp $line ;
      $line_out = '' ;

      $file_name = '' ;
      $line_out = "$folder,$folder2,$file_timestamp,FILE_DURATION,$file_status,-,private,$file_desc\n" ;
      $lines_out .= $line_out ;
    }

#    if ($line =~ /in.progress/)
#    {
#      $line =~ s/(<li[^>]*>)(.*?)(<\/li>)/$1<small>$2<\/small>$3/ ;
#      $line =~ s/(<ul><li[^>]*>)(.*?)(<\/div>)/$1<small>$2<\/small>$3/ ;
#    }
#    $line =~ s/<\/?big>//g ;
    # $line =~ s/.in-progress/.in-progress {font-size:12px;/ ;
  }

  print "purge older data for '$folder,$folder2' from $file_dump_files\n" ;

  open FILES,  '<', $file_dump_files ;
  $lines_files_written = 0 ;
  $lines_files_skipped = 0 ;
  @lines_files = <FILES> ;
  close FILES ;
  open FILES,  '>', $file_dump_files ;
  foreach $line (@lines_files)
  {
    if ($line !~ /^$folder,$folder2,/)
    { 
      $lines_files_written ++ ;
      print FILES $line ;
    }
    else 
    { $lines_files_skipped ++ ; }
  }
  close FILES ;
  print "$lines_files_written lines written, $lines_files_skipped lines skipped\n" ;
  
  $lines_out =~ s/FILE_DURATION/0:00:00,0,0/g ;
  $lines_out =~ s/JOB_DURATION_FIRST/$job_duration_hms_first/g ;
  $lines_out =~ s/JOB_DURATION/$job_duration_first/g ;

  open FILES, '>>', $file_dump_files ;
  @lines_out = split ("\n", $lines_out) ;

# set job data to first timestamp
  $line = "$folder,$folder2,$file_timestamp_first,$job_duration_hms_first,$job_duration_first,-,$job_status,-,-,Job status" ;
  unshift @lines_out, ($line) ;

  foreach $line (@lines_out)
  {
    $line =~ s/NO_FILE_TIMESTAMP/$file_timestamp_first,-,-,-/ ;
    $line =~ s/^,/$file_timestamp_first,/ ;
    # print "$line\n" ;
    print FILES "$line\n" ;
  }
  close FILES ;

  $completed = 1 ;
  if ($job_status eq 'running')
  { $completed = 0 ; }

  return ($completed, @lines) ;
  close INDEX ;
}

sub Time2Sec
{
  my $timestamp = shift ;

  my $yyyy = substr ($timestamp,0,4) - 1900 ;
  my $mm   = substr ($timestamp,5,2) - 1 ;
  my $dd   = substr ($timestamp,8,2) ;
  my $hh   = substr ($timestamp,11,2) ;
  my $nn   = substr ($timestamp,14,2) ;
  my $ss   = substr ($timestamp,17,2) ;

  return (timegm ($ss,$nn,$hh,$dd,$mm,$yyyy)) ;
}

sub FileSizeNormalize
{
  my $file_size = shift ;

  $file_size =~ s/\sbytes// ;
  $file_size =~ s/,// ;

  $file_size =~ s/^(\d+) KB/"$1"."000"/e ;
  $file_size =~ s/^(\d+)\.(\d) KB/"$1$2"."00"/e ;
  $file_size =~ s/^(\d+) MB/"$1"."000000"/e ;
  $file_size =~ s/^(\d+)\.(\d) MB/"$1$2"."00000"/e ;
  $file_size =~ s/^(\d+) GB/"$1"."000000000"/e ;
  $file_size =~ s/^(\d+)\.(\d) GB/"$1$2"."00000000"/e ;

  return ($file_size) ;
}

#sub NormalizeTimestamp
#{
#  my $timestamp = shift ;
#  if ($timestamp =~ /\d+\-\d+\d \d+\:\d+/)
#  { return ($timestamp) ; }
#  my ($dd,$mm,$yyyy,$hh,$nn) =~ m/(\d+)\/(\d+)\/(\d+)\s+(\d+)\:(\d+)/ ;
#  $timestamp = sprintf ("%04d-%02d-%02d %02d\:%02d", $yyyy, $mm, $ss, $hh,$nn) ;
#  return ($timestamp) ;
#}

sub Log
{
  print shift ;
}


