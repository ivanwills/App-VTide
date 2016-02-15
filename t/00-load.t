#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

BEGIN {
    use_ok( 'App::VTide' );
    use_ok( 'App::VTide::Config' );
    use_ok( 'App::VTide::Command' );
    use_ok( 'App::VTide::Command::Conf' );
    use_ok( 'App::VTide::Command::Edit' );
    use_ok( 'App::VTide::Command::Init' );
    use_ok( 'App::VTide::Command::Run' );
    use_ok( 'App::VTide::Command::Save' );
    use_ok( 'App::VTide::Command::Start' );
}

diag( "Testing App::VTide $App::VTide::VERSION, Perl $], $^X" );
done_testing();
