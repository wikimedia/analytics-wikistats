#!/usr/bin/perl

$| = 1; # flush screen output

chdir ("DammitPatchProjectcountsForServerOverload2011OctNovMobile/after") || die "Cannot chdir to DammitPatchProjectcountsForServerOverload2011OctNovMobile/after\n" ;

# Asher
# For October, cp1043 stopped logging on 10/15 at 23:24:23, so it wasn't counted for a tad >50% of the month.
# For November, cp1043 was logging for 35 hours, or was missing around 95% of the month.
# Actually figures rise again in 20111129-200000 (29 hours from end of month)
# patch range 20111016-000000 - 20111129-200000: mobile stats * 2

  @files = <*>;
  foreach $file (@files)
  {
    next if ! -e $file ;
    next if $file !~ /^projectcounts-\d{8}-\d{6}$/ ;
    &Patch ($file) ;
  }

print "\n\nReady\n\n" ;
exit ;

sub Patch
{
  my ($file) = @_ ;

  print     "Patch file $file\n" ;
  print LOG "Patch file $file\n" ;

  open PROJECTFILE, '<', $file || die "Could not open '$file'\n" ;

  undef @projectfile ;
  while ($line = <PROJECTFILE>)
  {
    chomp $line ;
    ($project,$dash,$count,$bytes) = split (' ', $line) ;

     if ($project =~ /\.mw/)
     {
       $count *= 2 ;
       $bytes *= 2 ;
       $line = "$project $dash $count $bytes" ;
     }
     push @projectfile, "$line\n" ;
  }

  close PROJECTFILE ;


  open  PROJECTFILE, '>', $file || die "Could not open '$file'\n" ;
  print PROJECTFILE @projectfile ;
  close PROJECTFILE ;
}

# before this patch:
# (records with bytes sent = 1 were already patched for server overload, this patch is cumulative)

#projectcounts-20111015-000000:en.mw - 1118333 20883413293
#projectcounts-20111015-010000:en.mw - 1153653 1
#projectcounts-20111015-020000:en.mw - 1235714 1
#projectcounts-20111015-030000:en.mw - 1277073 1
#projectcounts-20111015-040000:en.mw - 1255903 1
#projectcounts-20111015-050000:en.mw - 1114711 20581295139
#projectcounts-20111015-060000:en.mw - 971278 17586940145
#projectcounts-20111015-070000:en.mw - 840539 15153901986
#projectcounts-20111015-080001:en.mw - 758891 13668939122
#projectcounts-20111015-090000:en.mw - 712797 12765642068
#projectcounts-20111015-100000:en.mw - 668190 1
#projectcounts-20111015-110000:en.mw - 660336 11974415378
#projectcounts-20111015-120000:en.mw - 724907 1
#projectcounts-20111015-130000:en.mw - 809809 15129177894
#projectcounts-20111015-140000:en.mw - 925587 17153050656
#projectcounts-20111015-150000:en.mw - 1305923 1
#projectcounts-20111015-160000:en.mw - 1094837 1
#projectcounts-20111015-170000:en.mw - 1222474 1
#projectcounts-20111015-180001:en.mw - 1020931 18588682396
#projectcounts-20111015-190000:en.mw - 1330412 1
#projectcounts-20111015-200000:en.mw - 1343696 1
#projectcounts-20111015-210000:en.mw - 1384105 1
#projectcounts-20111015-220000:en.mw - 1374371 1
#projectcounts-20111015-230000:en.mw - 1299587 1
#projectcounts-20111016-000000:en.mw - 885108 1
#projectcounts-20111016-010000:en.mw - 649719 1
#projectcounts-20111016-020000:en.mw - 677924 1
#projectcounts-20111016-030000:en.mw - 719230 1
#projectcounts-20111016-040001:en.mw - 651389 12344532099
#projectcounts-20111016-050000:en.mw - 637134 1
#projectcounts-20111016-060000:en.mw - 571744 1
#projectcounts-20111016-070000:en.mw - 516809 1
#projectcounts-20111016-080000:en.mw - 440191 1
#projectcounts-20111016-090000:en.mw - 410063 1
#projectcounts-20111016-100000:en.mw - 380565 1
#projectcounts-20111016-110000:en.mw - 369823 1
#projectcounts-20111016-120000:en.mw - 386359 1
#projectcounts-20111016-130000:en.mw - 429909 1
#projectcounts-20111016-140000:en.mw - 493544 1
#projectcounts-20111016-150001:en.mw - 368162 6839158094
#projectcounts-20111016-160000:en.mw - 405009 1
#projectcounts-20111016-170000:en.mw - 464366 1
#projectcounts-20111016-180000:en.mw - 496096 1
#projectcounts-20111016-190000:en.mw - 466511 1
#projectcounts-20111016-200000:en.mw - 491923 1
#projectcounts-20111016-210000:en.mw - 619640 1
#projectcounts-20111016-220000:en.mw - 790755 1
#projectcounts-20111016-230000:en.mw - 773944 14908567555
#projectcounts-20111129-000000:en.mw - 658202 12963090181
#projectcounts-20111129-010000:en.mw - 663817 13152898167
#projectcounts-20111129-020000:en.mw - 711947 14058285981
#projectcounts-20111129-030000:en.mw - 803127 16551028434
#projectcounts-20111129-040000:en.mw - 799227 16050235809
#projectcounts-20111129-050000:en.mw - 746361 14902470928
#projectcounts-20111129-060000:en.mw - 624624 12117890156
#projectcounts-20111129-070000:en.mw - 521375 9862760692
#projectcounts-20111129-080000:en.mw - 441473 8323325077
#projectcounts-20111129-090001:en.mw - 379646 7126963252
#projectcounts-20111129-100000:en.mw - 339564 6339545174
#projectcounts-20111129-110000:en.mw - 324300 6080216942
#projectcounts-20111129-120000:en.mw - 334918 6286356570
#projectcounts-20111129-130000:en.mw - 370602 6970996093
#projectcounts-20111129-140000:en.mw - 401666 7560271772
#projectcounts-20111129-150000:en.mw - 420291 7889228670
#projectcounts-20111129-160000:en.mw - 466071 8771078927
#projectcounts-20111129-170000:en.mw - 465044 8786923839
#projectcounts-20111129-180000:en.mw - 460876 8807419664
#projectcounts-20111129-190000:en.mw - 536584 10232880511
#projectcounts-20111129-200000:en.mw - 766271 14638516623
#projectcounts-20111129-210001:en.mw - 1135531 21930878519
#projectcounts-20111129-220000:en.mw - 1301065 25059905220
#projectcounts-20111129-230000:en.mw - 1340507 25822559729
#projectcounts-20111130-000000:en.mw - 1330214 25918201051
#projectcounts-20111130-010000:en.mw - 1364502 26513997839
#projectcounts-20111130-020000:en.mw - 1448165 28857827009
#projectcounts-20111130-030000:en.mw - 1517979 29939164418
#projectcounts-20111130-040000:en.mw - 1634592 32208418808
#projectcounts-20111130-050000:en.mw - 1495205 29165795286
#projectcounts-20111130-060000:en.mw - 1263647 24310380494
#projectcounts-20111130-070000:en.mw - 1062462 20309814130
#projectcounts-20111130-080001:en.mw - 886558 16882782806
#projectcounts-20111130-090000:en.mw - 761288 14436310033
#projectcounts-20111130-100000:en.mw - 684702 12872911393
#projectcounts-20111130-110000:en.mw - 655848 12370104095
#projectcounts-20111130-120000:en.mw - 686010 13107748725
#projectcounts-20111130-130000:en.mw - 784738 14662045771
#projectcounts-20111130-140000:en.mw - 873031 16315042117
#projectcounts-20111130-150000:en.mw - 875939 16646388651
#projectcounts-20111130-160000:en.mw - 800983 15222836300
#projectcounts-20111130-170000:en.mw - 784713 14913634953
#projectcounts-20111130-180000:en.mw - 1031183 19879047403
#projectcounts-20111130-190000:en.mw - 909035 17613714868
#projectcounts-20111130-200001:en.mw - 1010585 19438308049
#projectcounts-20111130-210000:en.mw - 1243257 24115504214
#projectcounts-20111130-220000:en.mw - 1327612 25904007706
#projectcounts-20111130-230000:en.mw - 1355736 26490617282

