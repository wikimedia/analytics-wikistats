#!/bin/sh

for x in AST BG BR CA CS DA DE EN EO ES FR HE HU IT JA NL NN PL PT RO RU SL SV WA ZH;
do
   echo $x
   echo 'before'
   ls /home/wikipedia/htdocs/wikipedia.org/wikistats/wikispecial/$x/*COMCOM*
   rm /home/wikipedia/htdocs/wikipedia.org/wikistats/wikispecial/$x/*COMCOM*
   echo 'after'
   ls /home/wikipedia/htdocs/wikipedia.org/wikistats/wikispecial/$x/*COMCOM*
done;
