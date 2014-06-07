#!/bin/bash

wikistats=/a/wikistats_git
dumps=$wikistats/dumps                     # folder for scripts and output
csv=$dumps/csv
file=StatisticsLog.csv

date                             >  $csv/csv_mw/DumpsLatestInputFull.csv
echo wb                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wb/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo wk                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wk/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo wn                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wn/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo wo                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wo/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo wp                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wp/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo wq                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wq/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo ws                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_ws/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo wv                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wv/$file >> $csv/csv_mw/DumpsLatestInputFull.csv
echo wx                          >> $csv/csv_mw/DumpsLatestInputFull.csv
grep full_dump $csv/csv_wx/$file >> $csv/csv_mw/DumpsLatestInputFull.csv

date                              >  $csv/csv_mw/DumpsLatestInputStub.csv
echo wb                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wb/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo wk                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wk/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo wn                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wn/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo wo                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wo/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo wp                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wp/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo wq                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wq/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo ws                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_ws/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo wv                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wv/$file >> $csv/csv_mw/DumpsLatestInputStub.csv
echo wx                           >> $csv/csv_mw/DumpsLatestInputStub.csv
grep edits_only $csv/csv_wx/$file >> $csv/csv_mw/DumpsLatestInputStub.csv

clear
head -n 50 $csv/csv_mw/DumpsLatestInputFull.csv
