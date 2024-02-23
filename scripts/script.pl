#!/usr/bin/perl

use Net::DNS;
use Data::Dumper;
use HTTP::Request;
use LWP::UserAgent;

# Get X-Candidate-Id from TXT DNS record
my $subdomain = "candiharvest.infomanihack.ch";
my $resolver = Net::DNS::Resolver->new;
my $txt_record = $resolver->query($subdomain, "TXT");
my $x_candidate_id = substr(Dumper(((($txt_record->answer)[0])->txtdata)[0]), 9, -3);

# Get and print content result
my $header   = ['X-Candidate-Id' => $x_candidate_id ];
my $request  = HTTP::Request->new('GET', 'https://'.$subdomain, $header);
my $usragent = LWP::UserAgent->new;
print  $usragent->request($request)->as_string

