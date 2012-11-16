#!/usr/bin/perl

use lib "/home/ezachte/lib" ;

use EzLib ;

%plank = (1=>'aap', 2=>'noot', 3=>'mies', 4=>'wim', 5=>'jet') ;

#@plank= sort {$plank{$a} cmp $plank {$b}} keys %plank ;
#print @plank ;

# @plank= &sort_by_value_alpha_asc (\%plank) ;
@plank = hash_values_alpha_asc (%plank) ;
print "PLANK [@plank]" ;



