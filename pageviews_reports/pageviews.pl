#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use PageViews::ParallelModel;
use PageViews::Model;
use PageViews::View;
use Data::Dumper;
use JSON::XS;
use Carp;
use Getopt::Long;

if(@ARGV < 2) {
  confess "[ERROR] you need to pass a config json as argument";
};

confess "[ERROR] config file does not exist"
  unless -f $ARGV[1];

my $config = decode_json(`cat $ARGV[1]`);


confess "[ERROR] mode is supposed to be parallel or sequential"
  unless $config->{mode} eq "sequential" || $config->{mode} eq "parallel";

confess "[ERROR] input-path argument is not a valid path"
  unless -d $config->{"input-path"};

confess "[ERROR] output-path argument is not a valid path"
  unless -d $config->{"output-path"};

confess "[ERROR] max-children argument is not a valid integer"
  unless $config->{"max-children"} =~ /^\d+$/;

`
mkdir -p $config->{"output-path"}
mkdir -p $config->{"output-path"}/map
rm    -f $config->{"output-path"}/map/*.json
rm    -f $config->{"output-path"}/map/*.err
`;


my $model;

if(     $config->{mode} eq "sequential") {
  $model = PageViews::Model->new();
} elsif($config->{mode} eq "parallel") {
  $model = PageViews::ParallelModel->new();
};


if($config->{mode} eq "parallel") {
  if(!$config->{"children-output-path"}) {
      confess "[ERROR] mode set to parallel but children-output-path not present";
  } else {
    if(!-d $config->{"children-output-path"}) {
      confess "[ERROR] mode set to parallel but children-output-path doesn't exist";
    };
  };
};

$model->process_files($config);
my $d = $model->get_data();

open my $json_fh,">",$config->{"output-path"}."/out.json";
print   $json_fh JSON::XS->new
                         ->pretty(1)
                         ->canonical(1)
                         ->encode($d);
close   $json_fh;

my $v = PageViews::View->new($d);
$v->render($config);
