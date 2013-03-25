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
  $model->process_files($config);
  print "[DBG] web rendering\n";
  my $model_processed_data = $model->get_data_view_web();
  #print Dumper $model_processed_data;

  my $json_path = $config->{"output-path"}."/out.json";
  print "[DBG] json_path = $json_path\n";
  open my $json_fh,">",$json_path;
    print   $json_fh JSON::XS->new
      ->pretty(1)
      ->canonical(1)
      ->encode($model_processed_data);
  close   $json_fh;

  $view->set_data($model_processed_data);
  $view->render($config);
} elsif( $config->{"output-format"} eq "wikireport") {
  $model->process_files($config);
  my $model_processed_data = $model->get_data_view_wikireport();
  $view = PageViews::View::WikiReport->new();
  $view->set_data($model_processed_data);
  $view->render($config);
} elsif( $config->{"output-format"} eq "limn") {
  $view = PageViews::View::Limn->new();
} else {
  confess "[ERROR] Something's wrong";
};

