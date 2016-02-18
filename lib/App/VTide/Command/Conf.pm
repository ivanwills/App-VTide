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

extends 'App::VTide::Command';

our $VERSION = version->new('0.0.1');

sub run {
    my ($self) = @_;

    if ( $self->defaults->{verbose} ) {
        for my $env (sort keys %ENV ) {
            next if $env !~ /VTIDE/;
            printf "%-12s : %s\n", $env, $ENV{$env};
        }
        print "\n";
    }

    my @files = sort keys %{ $self->config->get->{editor}{files} };

    print join "\n", @files, '';

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Conf - Show the current configuration

=head1 VERSION

This documentation refers to App::VTide::Command::Conf version 0.0.1


=head1 SYNOPSIS

   use App::VTide::Command::Conf;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


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
