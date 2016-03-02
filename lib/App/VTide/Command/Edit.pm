package App::VTide::Command::Edit;

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

extends 'App::VTide::Command::Run';

our $VERSION = version->new('0.0.1');

sub run {
    my ($self) = @_;

    my ( $name ) = $self->env;
    my $cmd = $self->options->files->[0];
    print "Running $name - $cmd\n";

    my $params = $self->params( $cmd );
    $params->{edit} = $self->options->files;
    my @cmd    = $self->command( $params );

    if ( $params->{env} && ref $params->{env} eq 'HASH' ) {
        for my $env ( keys %{ $params->{env} } ) {
            my $orig = $ENV{$env};
            $ENV{$env} = $params->{env}{$env};
            $ENV{$env} =~ s/[\$]$env/$orig/;
        }
    }

    $self->load_env( $params->{env} );
    $self->runit( @cmd );

    return;
}

sub auto_complete {
    my ($self) = @_;

    my $env = $self->options->files->[-1];
    my @files = sort keys %{ $self->config->get->{editor}{files} };

    print join ' ', grep { $env ne 'edit' ? /^$env/ : 1 } @files;

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Edit - Run an edit command (like Run but without a terminal

=head1 VERSION

This documentation refers to App::VTide::Command::Edit version 0.0.1

=head1 SYNOPSIS

    vtide run
    vtide run [--help|--man]

  OPTIONS:
       --help       Show this help
       --man        Show full documentation

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
