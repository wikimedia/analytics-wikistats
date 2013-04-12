package PageViews::Model::Sequential;
use strict;
use warnings;
use File::Basename qw/basename/;
use Data::Dumper;
use PageViews::BotDetector;
use Time::Piece;
use Carp;


=head1 NAME

PageViews::Model::Sequential - Processing squid log lines one file at a time

=head1 METHODS

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
  #'wikibooks',
  #'wikidata',
  #'wikinews',
  'wikipedia',
  #'wikiquote',
  #'wikisource',
  #'wikiversity',
  #'wikivoyage',
  #'wikimedia',
  #'mediawiki',
  #'wikimediafoundation',
  #'wiktionary',
);

# a list of accepted prefixes for the url path
my @accept_path_fragments = (
  "wiki[/\\?](.*)\$", # wiki/ or wiki?
  "w/index.php[/\\?](.*)\$", # w/index.php
  "w/api.php\\?(.*)\$",
);


=head2 build_accepted_url_regex1()

This is not a method. It is just a function. It creates a (rather big) regex that has 8 captures.

=begin html

<img src="accept-regex-example.png" width="100%" />

=end html

=cut


sub build_accepted_url_regex1 {
  my $g1 = "(http|https)";
  my $g2 = "(www\.|)";
  my $g3 = "(".join("|",@accept_lang_array)     .")";
  my $g4 = "(".join("|",@accept_domain_suffixes).")";
  my $g5 = "(".join("|",@accept_path_fragments) .")";

  # we have 6 captures
  my $re = "^$g1://($g2$g3\.m\.$g4\.org)/$g5";
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

sub accept_rule_url {
  my ($self,$url) = @_;
  my $re = $self->{accept_re};
  #captures
  my (@c)  = $url =~ $re;
  #print "AAAA=>".Dumper(\@c);
  if(@c == 9) {
    my $retval        = {
      "language"      => $c[3],
      "project"       => $c[4],
      "domain"        => $c[1],
      "pageview-type" => "",
      "action"        => $c[7],
      "title"         => "",
    };
    my $language      = $c[3];
    my $path_fragment = $c[5];
    my $pageview_type        ;
    if(     index($path_fragment,"wiki/"       ,0)!=-1) {
      $retval->{"title"}         = $c[6];
      $retval->{"pageview-type"} = "wiki_basic";
    }elsif( index($path_fragment,"w/index.php" ,0)!=-1) {
      $retval->{"pageview-type"} = "wiki_index";
    }elsif( index($path_fragment,"w/api.php"   ,0)!=-1) {
      my $url_params    = { split(/&|=/,$c[8]) };
      $retval->{"pageview-type"} = "api";
      $retval->{action}  = $url_params->{action};
      $retval->{"title"} = $url_params->{page}  || 
                           $url_params->{title} ||
                           $url_params->{titles} ;
      $retval->{"title"} =~ s/\+/_/g;
      return undef
        unless $url_params->{action} ~~ ["view","mobileview","query"];
    } else {
      return undef;
    };

    return $retval;
  };

  $self->{counts_discarded_url}->{$self->{last_ymd}}++;
  return undef;
};

=head2 accept_case1($self,$u,$r)

This method takes B<url_info> and B<referer_info> in the format returned by B<accept_rule_url>.

It treats the case where both the url and the referer have the same title, in which case it discards.

Otherwise it accepts because this means the request was not caused by the same page as the url.

=cut

sub accept_case1 {
  my ($self,$u,$r) = @_;
  if($u->{"pageview-type"} eq "api"          &&
     $r->{"pageview-type"} eq "api"          &&
     $r->{"action"}        =~ "view"         &&
     $u->{"action"}        =~ "view"         &&
     $u->{"domain"}        eq $r->{"domain"} &&
     $u->{"title"}         eq $r->{"title"} 
   ) {
     return 0;
  };
  return 1;
};

=head2 accept_case2($self,$u,$r)

This method takes B<url_info> and B<referer_info> in the format returned by B<accept_rule_url>.

This is a case which stemmed from feedback with the Mobile Team.

It treats the case where the title should be different although the referer and url are /wiki/ and /w/api.php links.

=cut

sub accept_case2 {
  my ($self,$u,$r) = @_;

  #print Dumper $u;
  #print Dumper $r;
  if($u->{"pageview-type"} eq "api"          &&
     $r->{"pageview-type"} eq "wiki_basic"   &&
     $u->{"domain"}        eq $r->{"domain"} &&
     $u->{"title"}         eq $r->{"title"} 
   ) {

     return 0;

   };

   return 1;
}


=head2 accept_rule_url_and_referer

This is one of the main parts of the logic in the pageview definition.

It uses accept_case1 and accept_case2 to deal with some of the cases.

All other edge-cases will be put in methods with the name B<accept_caseX> where X will be a number.

So we are currently treating cases where the url and referer are api urls, and also the case where the url is a wiki url and the referer is a wiki url.

=cut

sub accept_rule_url_and_referer {
  my ($self,$url_info,$referer_info,$referer) = @_;
  return 1 if $referer eq '-';
  return 0 if !$self->accept_case1($url_info,$referer_info);
  return 0 if !$self->accept_case2($url_info,$referer_info);
  return 1;
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
  <li>accept_rule_url_and_referer
</ul>

=end html

=cut

sub process_line {
  my ($self,$line) = @_;
  # after 2013-02-01 the logs changed to tab-separated fields instead of space separated
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

  # language, type of pageview (wiki_basic,wiki_index,api) , title
  return if !(my $url_info     = $self->accept_rule_url($url));
  # language, type of pageview (wiki_basic,wiki_index,api) , title
  my $referer_info = $self->accept_rule_url($referer);
  return if !($self->accept_rule_url_and_referer($url_info,$referer_info,$referer));

  #print "$url\n";
  # counts
  $self->{"counts"}->{$ymd}->{$url_info->{language}}++;
  # counts separated /w/index.php , /w/api.php , /wiki/
  $self->{"counts_".$url_info->{"pageview-type"}}->{$ymd}->{$url_info->{language}}++;
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
  my ($self,$filename,$restrictions) = @_;
  $self->{current_file_processed} = $filename;
  $self->open_dbg_fh;

  my $cmd = "unpigz -c $filename ";
  if($restrictions) {
    if(exists $restrictions->{"days-of-each-month"}) {
      my $days_to_process = $restrictions->{"days-of-each-month"};
      my ($y,$m,$d) = $filename =~ /(\d{4})(\d{2})(\d{2})\.gz$/;
      if(!($d ~~ $days_to_process)) {
        $self->close_dbg_fh;
        return;
      };
    };
    if(exists $restrictions->{"lines-for-each-day"}) {
      my $L = $restrictions->{"lines-for-each-day"};
      $cmd .= " | head -$L";
    };
  };

  print "[DBG] process_file => $filename\n";
  # zcat
  open IN, "-|", $cmd;
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
  my $tp_end        = Time::Piece->strptime($params->{end}->{year}."-".
                                            $params->{end}->{month}."-".$lday."T00:00:00",
                                            "%Y-%m-%dT%H:%M:%S");
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
  $self->{__config} = $params;
  my $restrictions = $params->{restrictions};
  for my $gz_logfile ($self->get_files_in_interval($params)) {
    $self->process_file($gz_logfile,$restrictions);
  };
};

1;
