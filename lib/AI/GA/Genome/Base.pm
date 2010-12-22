package AI::GA::Genome::Base;

use warnings;
use strict;

use Carp;

=head1 NAME

AI::GA::Genome::Base - Base class for AI::GA Genomes.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 OPERATORS

Operators available

=cut

our %operators = (); 


=head1 SYNOPSIS

This module is a base class for AI::GA Genomes. You must extend it to provide
a genome to be used with other AI::GA modules.

You MUST provide the methods new (constructor) and init (initializer).

You MUST export your genetic operators using the hash %operators. These
operators are allowed to receive and return any data since, you will call them
later using your other AI::GA specialized classes.

You MAY provide aditional methods for convenience.

This module implements the method fitness, which provides a way to update and
retrieve the fitness measure.

    package AI::GA::Genome::MyGenome;
    
    %operators(
        'crossover' => \&my_crossover,
        'mutation'  => \&my_mutation,
        'foobar'    => \&my_foobar,
    );
    
    sub new {
        # Create genome data structures
    }
    
    sub init {
        # Provide a way to initialize it
    }
    
    sub my_crossover {
        # Makes a crossover operation
    }
    
    sub my_mutation {
        # Makes a mutation operation
    }
    
    sub my_foobar {
        # Makes a foobar operation
    }
    
    42;


=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

Dummy implementation.

=cut

sub new {
    Carp::croak('You must specialize this method');
}

=head2 init

Dummy implementation.

=cut

sub init {
    Carp::croak('You must specialize this method');
}


=head2 fitness

Sets and gets the fitness value.

=cut

sub fitness {
    my ( $self, $fitness ) = @_;

    $self->{'_fitness'} = $fitness if defined $fitness;

    return $self->{'_fitness'};
}

=head1 AUTHOR

Blabos de Blebe, C<< <blabos at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-ai-ga-base at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AI-GA-Base>. I will be
notified, and then you'll automatically be notified of progress on your bug
as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AI::GA::Base
    perldoc AI::GA::Genome::Base


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=AI-GA-Base>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/AI-GA-Base>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/AI-GA-Base>

=item * Search CPAN

L<http://search.cpan.org/dist/AI-GA-Base/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Blabos de Blebe.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

return 42; # End of AI::GA::Genome::Base
