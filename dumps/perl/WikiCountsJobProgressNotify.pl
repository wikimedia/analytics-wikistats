#!/usr/bin/perl

# no command line parameters (trivial script)

use LWP::UserAgent;

$file = "/a/wikistats_git/dumps/out/out_wm/WikiCountsJobProgressDaily.txt" ;

die "File '$file' not found" if ! -e $file ;

@lines = `tail -n 22$file` ;

$msg = join ("\n", @lines) ;

$result = LWP::UserAgent->new()->post(
  "https://api.pushover.net/1/messages.json", [
  "token" => "MvqD8yZuJGbNfZ4KXxnK2cGrndwu4x",
  "user" => "zzQycwrc5cYdwUc5KUoUWpQpqfWZpk",
  "message" => "$msg",
]);

print "Ready" ;
exit ;
