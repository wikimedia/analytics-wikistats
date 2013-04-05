package PageViews::View::JSON;
use strict;
use warnings;
use JSON::XS;

sub new {
  my ($class) = @_;

  return bless {},$class;
}


=head2 get_data_from_model($self,$model)

Gets as parameter a model and collects what data is needed from it in order to produce the
json.

=cut

sub get_data_from_model {
  my ($self,$model) = @_;

  $self->{$_} = $model->{$_}
  for 
    qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_referer     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
    __config
    /;

};

=head2 render($self)

This method renders the pageview counts in JSON format.
It also includes the config.json with which the run was made. It stores that in the __config key inside data.json
There is also a git-sha1-for-this-run key to the json which shows the commit in the git history of the code
that produced this json.

=cut


sub render {
  my ($self,$params) = @_;
  my $data = {};
  $data->{$_} = $self->{$_} 
  for
  qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_referer     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
    __config
  /;

  my $output_path = $params->{"output-path"}."/data.json";
  open my $fh,">",$output_path;

  $data->{"git-sha1-for-this-run"} = `git rev-parse --verify HEAD`;
  chomp $data->{"git-sha1-for-this-run"};


  print $fh JSON::XS
            ->new
            ->canonical(1)
            ->pretty(1)
            ->encode($data);

  close $fh;
}

1;
