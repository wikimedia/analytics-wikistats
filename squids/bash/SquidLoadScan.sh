#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
perl=$wikistats/perl
cd $perl

nice perl SquidLoadScan.pl
