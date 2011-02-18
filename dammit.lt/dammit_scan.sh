i='/a/dammit.lt/pagecounts'       # input dir
o='/home/ezachte/wikistats/scans' # output dir
f=20090424 # from date
t=20091110 # till date
#="swine.*flu\nswine.*influenza\nflu.*outbreak\ninfluenza.*outbreak\ngripe.*porcina\npandem\n"
p=".*influensa\n.*H1N1.*\npandemi\n"
#p="#$o/pattern_influenza_en.txt" # file name
#p="#$o/pattern_pandemic_shortlist.txt" # file name
#p=html
perl /a/dammit.lt/DammitScanCompactedFiles.pl -i $i -o $o -f $f -t $t -p $p
