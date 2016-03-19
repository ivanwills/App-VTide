package App::VTide::Command::Help;

# Created on: 2016-02-05 10:11:54
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use English qw/ -no_match_vars /;
use Pod::Usage;

extends 'App::VTide::Command::Run';

our $VERSION = version->new('0.0.1');
our $NAME    = 'help';
our $OPTIONS = [
    'test|T!',
    'verbose|v+',
];
sub _sub {( $NAME, $OPTIONS )};

sub run {
    my ($self) = @_;
    my $command = shift @ARGV;

    my $sub = $self->vtide->_generate_sub_command;

    if ($command) {
        # show the help for the command
    }
    else {
        # show the list of commands and their descriptions
        for my $cmd (sort keys %$sub) {
            my $title  = ucfirst $cmd;
            my $module = 'App/VTide/Command/' . $title . '.pm';
            require Tie::Handle::Scalar;
            my $out = '';
            tie *FH, 'Tie::Handle::Scalar', \$out;

            pod2usage(
                -verbose  => 99,
                -input    => $INC{$module},
                -exitval  => 'NOEXIT',
                -output   => \*FH,
                -sections => [qw/ NAME /],
            );

            $out =~ s/Name.*?$title/$cmd/xms;
            $out =~ s/\s\s+/ /gxms;
            print "$out\n";
        }
    }

    return;
}

sub auto_complete {
    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Help - Run an edit command (like Run but without a terminal

=head1 VERSION

This documentation refers to App::VTide::Command::Help version 0.0.1

=head1 SYNOPSIS

    vtide run (glob ...)
    vtide run [--help|--man]

  OPTIONS:
   -T --test        Test the running of the terminal (shows the commands
                    that would be executed)
   -v --verbose     Show more verbose output.
      --help        Show this help
      --man         Show full documentation

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Run an editor command with passed in file globs

=head2 C<auto_complete ()>

Auto completes editor file groups

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
