package PageViews::Model::Sequential;
use strict;
use warnings;
use File::Basename qw/basename/;
use Data::Dumper;
use PageViews::BotDetector;
use Time::Piece;


=head1 NAME

PageViews::Model::Sequential - Processing squid log lines one file at a time

=cut



my $MINIMUM_EXPECTED_FIELDS = 9;
# seconds in a day
our $ONE_DAY = 86_400;

# a list of all wikiprojects
my @accept_lang_array = (
  'en', 'de', 'fr', 'nl', 'it', 'pl', 'es', 'ru', 'ja', 'pt', 'sv', 'zh', 'uk', 'ca', 
  'no', 'fi', 'cs', 'hu', 'tr', 'ro', 'ko', 'vi', 'da', 'ar', 'eo', 'sr', 'id', 'lt', 
  'vo', 'sk', 'he', 'fa', 'bg', 'sl', 'eu', 'war', 'lmo', 'et', 'hr', 'new', 'te',
  'nn', 'th', 'gl', 'el', 'ceb', 'simple', 'ms', 'ht', 'bs', 'bpy', 'lb', 'ka', 'is',
  'sq', 'la', 'br', 'hi', 'az', 'bn', 'mk', 'mr', 'sh', 'tl', 'cy', 'io', 'pms',
  'lv', 'ta', 'su', 'oc', 'jv', 'nap', 'nds', 'scn', 'be', 'ast', 'ku', 'wa', 'af',
  'be-x-old', 'an', 'ksh', 'szl', 'fy', 'frr', 'yue', 'ur', 'ia', 'ga', 'yi', 'sw', 'als',
  'hy', 'am', 'roa-rup', 'map-bms', 'bh', 'co', 'cv', 'dv', 'nds-nl', 'fo', 'fur', 'glk', 'gu',
  'ilo', 'kn', 'pam', 'csb', 'kk', 'km', 'lij', 'li', 'ml', 'gv', 'mi', 'mt', 'nah',
  'ne', 'nrm', 'se', 'nov', 'qu', 'os', 'pi', 'pag', 'ps', 'pdc', 'rm', 'bat-smg', 'sa',
  'gd', 'sco', 'sc', 'si', 'tg', 'roa-tara', 'tt', 'to', 'tk', 'hsb', 'uz', 'vec', 'fiu-vro',
  'wuu', 'vls', 'yo', 'diq', 'zh-min-nan', 'zh-classical', 'frp', 'lad', 'bar', 'bcl', 'kw', 'mn', 'haw',
  'ang', 'ln', 'ie', 'wo', 'tpi', 'ty', 'crh', 'jbo', 'ay', 'zea', 'eml', 'ky', 'ig',
  'or', 'mg', 'cbk-zam', 'kg', 'arc', 'rmy', 'gn', 'closed', 'so', 'kab', 'ks', 'stq', 'ce',
  'udm', 'mzn', 'pap', 'cu', 'sah', 'tet', 'sd', 'lo', 'ba', 'pnb', 'iu', 'na', 'got',
  'bo', 'dsb', 'chr', 'cdo', 'hak', 'om', 'my', 'sm', 'ee', 'pcd', 'ug', 'as', 'ti',
  'av', 'bm', 'zu', 'pnt', 'nv', 'cr', 'pih', 'ss', 've', 'bi', 'rw', 'ch', 'arz',
  'xh', 'kl', 'ik', 'bug', 'dz', 'ts', 'tn', 'kv', 'tum', 'xal', 'st', 'tw', 'bxr',
  'ak', 'ab', 'ny', 'fj', 'lbe', 'ki', 'za', 'ff', 'lg', 'sn', 'ha', 'sg', 'ii',
  'cho', 'rn', 'mh', 'chy', 'ng', 'kj', 'ho', 'mus', 'kr', 'hz', 'mwl', 'pa', 'xmf', 'lez'
);

# a list of accepted suffixes for the domain
my @accept_domain_suffixes = (
  'wikibooks',
  'wikidata',
  'wikinews',
  'wikipedia',
  'wikiquote',
  'wikisource',
  'wikiversity',
  'wikivoyage',
  'wikimedia',
  'mediawiki',
  'wikimediafoundation',
  'wiktionary',
);

# a list of accepted prefixes for the url path
my @accept_path_fragments = (
  "wiki[/\\?]",
  "w/index.php",
  "w/api.php\\?.*action=(?:mobile)?view"
);


=head2 build_accepted_url_regex1()

=begin html

This is not a method. It is just a function. It creates a (rather big) regex that has 5 captures.

This regex matches the url decision step <a href="https://raw.github.com/wikimedia/metrics/master/pageviews/new_mobile_pageviews_report/pageview_definition.png"> described in this document</a> (you can see it in the appendix).

=end html

=cut



sub build_accepted_url_regex1 {
  my $g1 = "(http|https)";
  my $g2 = "(www\.|)";
  my $g3 = "(".
            (join("|",@accept_lang_array))
            .")";
  my $g4 = "(".
            join("|",@accept_domain_suffixes)
            .")";
  my $g5 = "(".
            join("|",(@accept_path_fragments))
            .")";

  my $re = "^$g1://$g2$g3\.m\.$g4\.org/$g5";
  return qr{$re};
}


#
# Generate all possible valid urls for mobile pages and make a hash with those as keys.
# The values will indicate what kind of url it is.
#

sub build_accepted_url_regex2 {
  my $ra = Regexp::Assemble->new();
  for my $p1 ("http","https") {
    for my $p2 ("","www.") {
      for my $l(@accept_lang_array) {
        for my $d (@accept_domain_suffixes) {
          $ra->add("$p1://$p2$l.m.$d.org/wiki/");
          $ra->add("$p1://$p2$l.m.$d.org/w/index.php");
          $ra->add("$p1://$p2$l.m.$d.org/w/api.php\?action=mobile");
          $ra->add("$p1://$p2$l.m.$d.org/w/api.php\?action=mobileview");
        };
      };
    };
  };
  return $ra->re();
}


sub new {
  my ($class) = @_;

  my $raw_obj = {
    current_file_processed      => undef,
    # counts is  counts_wiki_basic + counts_wiki_index + counts_api
    counts                      => {},

    # count for /wiki/
    counts_wiki_basic           => {},
    # count for /w/index.php
    counts_wiki_index           => {},
    # count for /w/api.php
    counts_api                  => {},


    last_ymd                    => undef,
    fh_dbg_accepted             => undef,
    fh_dbg_discarded            => undef,

    counts_discarded_bots       => {},
    counts_discarded_url        => {},
    counts_discarded_referer    => {},
    counts_discarded_time       => {},
    counts_discarded_fields     => {},
    counts_discarded_status     => {},
    counts_discarded_mimetype   => {},

    counts_mimetype             => {},
    bdetector                   => PageViews::BotDetector->new(),
  };
  $raw_obj->{accept_re} = build_accepted_url_regex1(),
  $raw_obj->{bdetector}->load_ip_ranges();
  $raw_obj->{bdetector}->load_useragent_regex();

  my $obj     = bless $raw_obj,$class;

  return $obj;
};


sub accept_rule_time {
  my ($self,$tp) = @_;
  if(!$tp) {
    return 1;
  };
  if(defined($tp) && ($tp >= $self->{tp_start} && $tp < $self->{tp_end})) {
    #print {$self->{fh_dbg_discarded}} $line;
    return 1;
  };

  if($self->{last_ymd}) {
    $self->{counts_discarded_time}->{$self->{last_ymd}}++;
  };
  return 0;
}

sub accept_rule_bot_ua {
  my ($self,$ua) = @_;
  my $bdetector = $self->{bdetector};
  if( defined($ua) && $bdetector->match_ua($ua) ) {
    #print "[DBG] bot_ua_discard\n";
    #print { $self->{fh_dbg_bots} } $line;
    $self->{counts_discarded_bots}->{$self->{last_ymd}}++;
    return 0;
  };

  return 1;
}

sub accept_rule_status_code {
  my ($self,$req_status) = @_;
  #302 304 and 20x
  if(defined($req_status) && $req_status =~ m{20\d|30[24]}) {
    #print "[DBG] reqstatus_discarded\n";
    #print { $self->{fh_dbg_status} } $line;
    return 1;
  };
  $self->{counts_discarded_status}->{$self->{last_ymd}}++;
  return 0;
}

sub accept_rule_bot_ip {
  my ($self,$ip) = @_;
  my $bdetector = $self->{bdetector};
  my $label_ip = $bdetector->match_ip($ip);

  if( $label_ip ) {
    $self->{counts_discarded_bots}->{$self->{last_ymd}}++;
    return 0;
  };
  return 1;
}

sub accept_rule_referer {
  my ($self,$referer) = @_;
  my $re = $self->{accept_re};
  my @c  = $referer =~ $re;
  if(@c == 5) {
    my $wikiproject   = $c[2];
    my $path_fragment = $c[4];
    return [$wikiproject,
            $path_fragment];
  };

  $self->{counts_discarded_referer}->{$self->{last_ymd}}++;
  return undef;
}


sub accept_rule_url {
  my ($self,$url) = @_;
  my $re = $self->{accept_re};
  my (@c)  = $url =~ $re;
  if(@c == 5) {
    my $wikiproject   = $c[2];
    my $path_fragment = $c[4];
    my $pageview_type        ;
    if(     index($path_fragment,"wiki"        ,0)==0) {
      $pageview_type = "wiki_basic";
    }elsif( index($path_fragment,"w/index.php" ,0)==0) {
      $pageview_type = "wiki_index";
    }elsif( index($path_fragment,"w/api.php"   ,0)==0) {
      $pageview_type = "api";
    };
    return [$wikiproject,
            $pageview_type];
  };

  $self->{counts_discarded_url}->{$self->{last_ymd}}++;
  return undef;
};


sub accept_rule_method {
  my ($self,$method) = @_;
  if( $method =~ /GET/i ) {
    return 1;
  };

  return 0;
}

sub accept_rule_mimetype {
  my ($self,$mime_type) = @_;
  ## text/html mime types only
  ## (mimetype filtering only occurs for regular pageviews, not for the API ones) 
  if( $mime_type =~ m{text/html|text/vnd\.wap\.wml|application/json}i ) {
    #print "[DBG] mime_discard\n";
    #print { $self->{fh_dbg_mimetype} } $line;
    return 1;
  };
  $self->{counts_discarded_mimetype}->{$self->{last_ymd}}++;
  return 0;
}

=head2 process_line($self,$line)

=begin html

This method takes a log line as argument. It splits it by space and tab into fields.

Afterwards a series of filters are applied for each filter.

These filters are:

<ul>
  <li>minimum field count constraint
  <li>accept_rule_time
  <li>accept_rule_status_code
  <li>accept_rule_method
  <li>accept_rule_mimetype
  <li>accept_rule_url
  <li>accept_rule_referer
</ul>

=end html

=cut

sub process_line {
  my ($self,$line) = @_;
  # after 2013-02-01 the logs changed to having tab-separated fields instead of space separated
  my @fields = split(/\s|\t/,$line);

  if(@fields < $MINIMUM_EXPECTED_FIELDS) {
    #print {$self->{fh_dbg_discarded}} $line;
    #print { $self->{fh_dbg_fields} } $line;
    $self->{counts_discarded_fields}->{$self->{last_ymd}}++;
    return;
  };
   
  # get time in format YYYY-MM-DDTHH:MM:SS (without milliseconds)  
  my $time       = substr($fields[2],0,19) ;
  my $method     = $fields[7] ;
  my $url        = $fields[8] ;
  my $ip         = $fields[4] ;
  my $ua         = $fields[13];
  my $req_status = $fields[5] ;
  my $mime_type  = $fields[10];
  my $referer    = $fields[12];

  my $tp = Time::Piece->strptime($time,"%Y-%m-%dT%H:%M:%S");


  my $ymd = $tp->year."-".$tp->mon.'-'.$tp->mday; 
  $self->{last_ymd} = $ymd;


  return if !($self->accept_rule_time($tp));
  return if !($self->accept_rule_status_code($req_status));
 #return if !($self->accept_rule_bot_ip($ip));
 #return if !($self->accept_rule_bot_ua($ua));
  return if !($self->accept_rule_method($method));
  return if !($self->accept_rule_mimetype($mime_type));
  return if !(my $url_info     = $self->accept_rule_url($url));
  return if !(my $referer_info = $self->accept_rule_referer($referer));

  #print "$url\n";
  # counts
  $self->{"counts"             }->{$ymd}->{$url_info->[0]}++;
  # counts separated /w/index.php , /w/api.php , /wiki/
  $self->{"counts_$url_info->[1]"}->{$ymd}->{$url_info->[0]}++;
};

sub open_dbg_fh {
  my ($self) = @_;
  print "[DBG] OPEN_DBG_FH\n";
  print "[DBG] $self->{current_file_processed} \n";
  my $path = "/tmp/discarded/".basename($self->{current_file_processed});
  print "[DBG] $path\n";
  `mkdir /tmp/discarded` if(! -d "/tmp/discarded");

  my $path_accepted   = $path;
  my $path_discarded  = $path;

  $path_accepted             =~ s/\.gz$/.accepted/;
  $path_discarded            =~ s/\.gz$/.discarded/;

  open my $fh_dbg_accepted   , ">$path_accepted" ;
  open my $fh_dbg_discarded  , ">$path_discarded";

  $self->{fh_dbg_accepted}   = $fh_dbg_accepted  ;
  $self->{fh_dbg_discarded}  = $fh_dbg_discarded ;
};

sub close_dbg_fh {
  my ($self) = @_;
  for my $key (%$self) {
    next unless $key =~ /^fh_dbg_/;
    close($self->{$key});
  };
};

sub process_file {
  my ($self,$filename) = @_;
  $self->{current_file_processed} = $filename;
  $self->open_dbg_fh;

  print "[DBG] process_file => $filename\n";
  open IN, "-|", "unpigz -c $filename";
  #open IN, "-|", "gzip -dc $filename";
  while( my $line = <IN>) {
    $self->process_line($line);
  };
  close IN;
  $self->close_dbg_fh;
};

=head2 get_files_in_interval($self,$params)

This method reads from the hash it is being passed(the configuration file parsed from json=>perl data structures).

It reads the start and end date, it then selects the files which are in the B<input-path> and match the B<logs-prefix>,
it sorts them and returns them as a list.

=cut

sub get_files_in_interval {
  my ($self,$params) = @_;
  my @retval = ();
  my $squid_logs_path   = $params->{"input-path"};
  my $squid_logs_prefix = $params->{"logs-prefix"};

  $params->{start}->{month} = sprintf("%02d",$params->{start}->{month});
  $params->{end}->{month}   = sprintf("%02d",$params->{end}->{month});

  my $time_start    = $params->{start}->{year}."-".$params->{start}->{month}."-01T00:00:00";
  my $time_end      = $params->{end}->{year}."-"  .$params->{end}->{month}."-01T00:00:00";
  my $tp_start      = Time::Piece->strptime($time_start,"%Y-%m-%dT%H:%M:%S"); 
  my $tp_end1       = Time::Piece->strptime(  $time_end,"%Y-%m-%dT%H:%M:%S");
  my $lday          = $tp_end1->month_last_day;
  my $tp_end        = Time::Piece->strptime($params->{end}->{year}."-".$params->{end}->{month}."-".$lday."T00:00:00","%Y-%m-%dT%H:%M:%S");
  $tp_end          += $ONE_DAY;

  $self->{tp_start} = $tp_start;
  $self->{tp_end}   = $tp_end;


  #print "start=>$tp_start\n";
  #print "  end=>$tp_end\n";
  my @all_squid_files =
  sort {
    ($a=~/(\d{8})/)[0] <=>
    ($b=~/(\d{8})/)[0]
  } <$squid_logs_path/$squid_logs_prefix*.gz>;
  for my $log_filename (@all_squid_files) {
    if(my ($y,$m,$d) = $log_filename =~ /(\d{4})(\d{2})(\d{2})\.gz$/) {
      my  $tp_log  =  Time::Piece->strptime( "$y-$m-$d"."T00:00:00" ,"%Y-%m-%dT%H:%M:%S"); 
      if( $tp_log >= $tp_start && $tp_log < $tp_end ) {
        #print "fn=>$log_filename\n";
        push @retval,$log_filename;
      };
    };
  };

  #warn Dumper \@retval;
  #exit 0;
  return @retval;
};


=head2 process_files($params)

The files which need to be processed are determined through B<get_files_in_interval> and then processing
commences, one file at a time.

=cut

sub process_files  {
  my ($self, $params) = @_;
  for my $gz_logfile ($self->get_files_in_interval($params)) {
    $self->process_file($gz_logfile);
  };
};

=head1 APPENDIX

=begin html

<img width="640" height="800" src="https://raw.github.com/wikimedia/metrics/master/pageviews/new_mobile_pageviews_report/pageview_definition.png"/>

=end html

=cut

1;
