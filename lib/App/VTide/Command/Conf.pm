package App::VTide::Command::Conf;

# Created on: 2016-02-08 10:42:09
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use English qw/ -no_match_vars /;
use YAML::Syck qw/ Dump /;
use Array::Utils qw/intersect/;

extends 'App::VTide::Command';

our $VERSION = version->new('0.0.1');

sub _alphanum {
    my $A = $a;
    my $B = $b;
    $A =~ s/(\d+)/sprintf "%05i", $1/egxms;
    $B =~ s/(\d+)/sprintf "%05i", $1/egxms;
    $A cmp $B;
}

sub run {
    my ($self) = @_;

    if ( $self->defaults->{env} ) {
        for my $env (sort keys %ENV ) {
            next if $env !~ /VTIDE/;
            printf "%-12s : %s\n", $env, $ENV{$env};
        }
        print "\n";
    }

    if ( $self->defaults->{which} ) {
        return $self->which( $self->defaults->{which} );
    }

    my $data  = $self->defaults->{terms}
        ? $self->config->get->{terminals}
        : $self->config->get->{editor}{files};
    my @files = sort _alphanum keys %{ $data };

    if ( $self->defaults->{verbose} ) {
        for my $file (@files) {
            print $file, Dump( $data->{$file} ), "\n";
        }
    }
    else {
        print join "\n", @files, '';
    }

    return;
}

sub which {
    my ( $self, $which ) = @_;
    my $term = $self->config->get->{terminals};
    my $file = $self->config->get->{editor}{files};
    my (%files, %groups, %terms);

    for my $group (keys %$file) {
        my @found = grep {/$which/}
            @{ $file->{$group} },
            map { $self->_dglob($_) } @{ $file->{$group} };
        next if !@found;

        for my $found (@found) {
            $files{$found}++;
        }
        $groups{$group}++;
    }

    my @files  = sort keys %files;
    my @groups = sort keys %groups;
    my @terms;
    for my $terminal (sort keys %$term) {
        my $edit = !$term->{$terminal}{edit} ? []
            : ! ref $term->{$terminal}{edit} ? [ $term->{$terminal}{edit} ]
            :                                  $term->{$terminal}{edit};

        my @found = (
            ( intersect @files , @$edit ),
            ( intersect @groups, @$edit ),
        );
        next if !@found;
        push @terms, $terminal;
    }

    if (@files) {
        print "Files:     " . ( join ', ', @files )  . "\n";
        print "Groups:    " . ( join ', ', @groups ) . "\n";
        print "Terminals: " . ( join ', ', @terms )  . "\n" if @terms;
    }
    else {
        print "Not found\n";
    }

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Conf - Show the current configuration and environment

=head1 VERSION

This documentation refers to App::VTide::Command::Conf version 0.0.1

=head1 SYNOPSIS

    vtide conf [-v|--verbose]

    OPTIONS
     -e --env       Show the current VTIide environment
     -t --terms     Show the terminal configurations
     -w --which[=]glob-name
                    Show the files found by "glob-name"
     -v --verbose   Show environment as well as config

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Show's the current files configuration

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2016 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
