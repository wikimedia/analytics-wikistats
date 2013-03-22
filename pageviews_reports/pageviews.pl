#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use PageViews::Model::Sequential;
use PageViews::Model::Parallel;
use PageViews::View::WikiReport;
use PageViews::View::Web;
use PageViews::View::Limn;
use Data::Dumper;
use JSON::XS;
use Carp;
use Getopt::Long;

if(@ARGV < 1) {
  confess "[ERROR] you need to pass a config json as argument";
};

confess "[ERROR] config file does not exist"
  unless -f $ARGV[0];

my $config = decode_json(`cat $ARGV[0]`);

confess "[ERROR] invalid mode"
  unless $config->{mode} ~~ ["sequential","parallel"];

confess "[ERROR] invalid output-format"
  unless $config->{"output-format"} ~~ ["web","wikireport","limn"];

confess "[ERROR] input-path argument is not a valid path"
  unless -d $config->{"input-path"};

confess "[ERROR] max-children argument is not a valid integer"
  unless $config->{"max-children"} =~ /^\d+$/;


if($config->{mode} eq "parallel") {
  if(!$config->{"children-output-path"}) {
      confess "[ERROR] mode set to parallel but children-output-path not present";
  };
  `
  mkdir -p $config->{"output-path"}/map
  rm    -f $config->{"output-path"}/map/*.json
  rm    -f $config->{"output-path"}/map/*.err
  `
};


`mkdir -p $config->{"output-path"}`;

my $model;
my $view ;

if(     $config->{mode} eq "sequential") {
  $model = PageViews::Model::Sequential->new();
} elsif($config->{mode} eq "parallel") {
  $model = PageViews::Model::Parallel->new();
};

if(      $config->{"output-format"} eq "web") {
  $view = PageViews::View::Web->new();
} elsif( $config->{"output-format"} eq "wikireport") {
  $view = PageViews::View::WikiReport->new();
} elsif( $config->{"output-format"} eq "limn") {
  $view = PageViews::View::Limn->new();
};

$model->process_files($config);

my $model_processed_data = $model->get_data();

open my $json_fh,">",$config->{"output-path"}."/out.json";
print   $json_fh JSON::XS->new
                         ->pretty(1)
                         ->canonical(1)
                         ->encode($model_processed_data);
close   $json_fh;

$view->set_data($model_processed_data);
$view->render($config);
