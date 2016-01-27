#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

BEGIN {
    use_ok( 'App::VTide' );
}

diag( "Testing App::VTide $App::VTide::VERSION, Perl $], $^X" );
done_testing();
