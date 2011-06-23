#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Plack::Test;
use SuperAwesomeCool;

test_psgi
  app    => SuperAwesomeCool->new->to_app(),
  client => sub {
    my $cb   = shift;
    my $req  = HTTP::Request->new( GET => "http://localhost/" );
    my $resp = $cb->($req);
    is( $resp->code, 200 );
    like( $resp->content, qr/Hello World/ );
  };

done_testing;
