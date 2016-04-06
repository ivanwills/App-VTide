#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

my $module = 'App::VTide::Command';
use_ok( $module );

my $vtide = App::VTide::Command->new;

env();

done_testing();

sub env {
    my $cmd = $module->new(
        vtide => $vtide,
    );
    ok $cmd, 'Create new cmd';

    $cmd->env('name', 'dir', 'config');
    is $ENV{VTIDE_NAME}, 'name', 'Environment variable name set correctly';
    is $ENV{VTIDE_DIR}, 'dir', 'Environment variable dir set correctly';
    is $ENV{VTIDE_CONFIG}, 'config', 'Environment variable config set correctly';
}
