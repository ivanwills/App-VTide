package App::VTide::Command::History;

# Created on: 2016-03-22 15:42:06
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use English qw/ -no_match_vars /;
use YAML::Syck;

extends 'App::VTide::Command::Run';

our $VERSION = version->new('0.1.17');
our $NAME    = 'history';
our $OPTIONS = [
    'number|n=i',
    'uniq|u',
    'verbose|v+',
];
sub details_sub { return ( $NAME, $OPTIONS )};

sub run {
    my ($self) = @_;
    my @history;
    my %uniq;
    my $max = $self->defaults->{number} || 10;

    my $fh = $self->config->history_file->openr;
    while (my $line = <$fh>) {
        my ($date, $command) = $line =~ /^\[([^\]]+)\]\s+(.*?)\s+$/;
        next if !$command;

        if ($self->defaults->{uniq}) {
            if (defined $uniq{$command}) {
                my $size = @history;
                @history = (
                    @history[0 .. ($uniq{$command} - 1)],
                    @history[($uniq{$command} + 1) .. $#history]
                );
                if (@history != $size - 1) {
                    warn 'No change in history';
                }
            }
            $uniq{$command} = scalar @history;
            push @history, [$date, $command];
        }
        else {
            push @history, [$date, $command];
        }
    }

    @history = ((reverse @history)[ 0 .. $max - 1]);
    for my $item (reverse @history) {
        next if !$item;
        printf "%-25s %s\n", @$item;
    }

    return;
}

sub auto_complete {
    my ($self) = @_;
}

1;

__END__

=head1 NAME

App::VTide::Command::History - Tells you about the terminal you are in

=head1 VERSION

This documentation refers to App::VTide::Command::History version 0.1.17

=head1 SYNOPSIS

    vtide history [-f|--force]

    OPTIONS
     -n (int)       The maximum number of history sessions to show (Default 10)
     -u --uniq      Show only uniq results
     -v --verbose   Show more detailed output
        --help      Show this help
        --man       Show the full man page

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<run ()>

Run the command

=head2 C<auto_complete ()>

Auto completes sub-commands that can have help shown

=head2 C<details_sub ()>

Returns the commands details

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
