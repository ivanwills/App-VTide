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

our $VERSION = version->new('0.1.10');
our $NAME    = 'history';
our $OPTIONS = [
    'max|m=i',
    'verbose|v+',
];
sub details_sub { return ( $NAME, $OPTIONS )};

sub run {
    my ($self) = @_;

    my $fh = $self->config->history_file->openr;
    {
        local $/;
        print <$fh>;
    };

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

This documentation refers to App::VTide::Command::History version 0.1.10

=head1 SYNOPSIS

    vtide history [-f|--force]

    OPTIONS
     -m --max[=]int The maximum number of history sessions to show (Default 10)
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