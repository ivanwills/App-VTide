#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

my $module = 'App::VTide::Command::Run';
use_ok( $module );

globable();

done_testing();

sub globable {
    my @globs = App::VTide::Command::Run->globable('a/b');
    is $globs[0], 'a/b', 'Plain file just gets returned';

    @globs = App::VTide::Command::Run->globable('a/b*');
    is $globs[0], 'a/b*', 'Plain glob just gets returned';

    @globs = App::VTide::Command::Run->globable('a/**/b');
    is_deeply \@globs, [qw{a/b a/*/b a/*/*/b a/*/*/*/b}], 'simple ** is expanded'
        or diag explain \@globs;

    @globs = App::VTide::Command::Run->globable('a/**/b/**/c');
    is_deeply \@globs, [qw{
        a/b/c a/b/*/c a/b/*/*/c a/b/*/*/*/c
        a/*/b/c a/*/b/*/c a/*/b/*/*/c a/*/b/*/*/*/c
        a/*/*/b/c a/*/*/b/*/c a/*/*/b/*/*/c a/*/*/b/*/*/*/c
        a/*/*/*/b/c a/*/*/*/b/*/c a/*/*/*/b/*/*/c a/*/*/*/b/*/*/*/c
    }], 'deep ** is expanded'
        or diag explain \@globs;
}