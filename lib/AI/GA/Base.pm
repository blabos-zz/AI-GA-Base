package AI::GA::Base;

use warnings;
use strict;
use Carp;

use Data::Dumper;

=head1 NAME

AI::GA::Base - Base class for AI::GA algorithms.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SELECTORS

Selectors available.

=cut

our %selectors = ( 'uniform' => \&uniform_selection );

=head1 SYNOPSIS

The AIGA Base is a basic framework that can be used to easily implement
genetic algorithms.

It is based on a pair of modules, one that implements a genome data structure
with its respective genetic operators and another module that implements the
algorithm itself.

The module AI::GA::Genome::Base as its name says provides a base class for
genome data structures. See perldoc AI::GA::Genome::Base for more details.

On other hand the module AI::GA::Base is the base class that must to be
extended to implement the particularities that you may need.

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=head2 new

Constructs a AI::GA object.

=cut

sub new {
    my $class = shift;
    my $args  = shift;
    my $atts  = {
        '_termination_function' => $args->{'term_func'},
        '_selector'             => $selectors{'uniform'},
        '_operators'            => {},
        '_pop'                  => [],
        '_statistics'           => [],
        '_cur_gen'              => 0,
        '_fitness_function'     => undef,
        '_max_gen'              => undef,
        '_pop_size'             => undef,
        '_ordering'             => undef
    };

    # Genome code
    croak 'You must provide a valid AI::GA::Genome class'
      unless exists $args->{'genome'}
      && $args->{'genome'}->isa('AI::GA::Genome::Base');

    $atts->{'_genome'} = $args->{'genome'};

    foreach my $op ( keys %AI::GA::Genome::Base::operators ) {
        if ( ref $AI::GA::Genome::Base::operators{$op} eq 'CODE' ) {
            $atts->{'_operators'}->{$op}->{'code'} =
              $AI::GA::Genome::Base::operators{$op};
        }
        else {
            croak 'Invalid Genome Operator';
        }
    }

    # Genetic operators rates
    croak 'You must provide genetic operator rates'
      unless keys %{ $args->{'operators'} };

    foreach my $op ( keys %{ $args->{'operators'} } ) {
        $atts->{'_operators'}->{$op}->{'rate'} = $args->{'operators'}->{$op};
    }

    # Selector
    if ( defined $args->{'selector'} ) {
        if ( ref $args->{'selector'} eq 'CODE' ) {
            $atts->{'_selector'} = $args->{'selector'};
        }
        elsif ( exists $selectors{ $args->{'selector'} } ) {
            $atts->{'_selector'} = $selectors{ $args->{'selector'} };
        }
    }

    # Fitness Function
    croak 'You must provide a fitness function'
      unless defined $args->{'fitness'}
      && ref $args->{'fitness'} eq 'CODE';

    $atts->{'_fitness_function'} = $args->{'fitness'};

    # Limits and ordering
    $atts->{'_max_gen'} =
      defined $args->{'max_gen'}
      && $args->{'max_gen'} > 0
      ? $args->{'max_gen'}
      : 100;

    $atts->{'_pop_size'} =
      defined $args->{'pop_size'}
      && $args->{'pop_size'} > 0
      ? $args->{'pop_size'}
      : 500;

    $atts->{'_ordering'} =
      defined $args->{'ordering'}
      && $args->{'ordering'} =~ /(a|de)sc/
      ? $args->{'ordering'}
      : 'desc';

    # Blessing this evolutionist object
    my $instance = bless $atts, $class;

    # Initializing population
    $instance->init();

    return $instance;
}

=head2 init

Initializes the population. This method is automatically called during object
construction.

=cut

sub init {
    my $self = shift;
    for my $i ( 0 .. $self->pop_size() - 1 ) {
        $self->{'_pop'}->[$i] = $self->{'_genome'}->new();
        $self->{'_pop'}->[$i]->init;
    }

    $self->evaluate();
}

=head2 terminate

Terminates execution of the algorithm when reach the maximum number of
generations or if the termination function returns true.

=cut

sub terminate {
    my $self = shift;

    my $term_func = $self->termination_function();

    return $self->cur_gen() >= $self->max_gen()
      || ( defined $term_func && $term_func->($self) );
}

=head2 evolve

This method starts the process of evolution of the population, using the
methods of evaluation, selection and genetic operators chosen.

=cut

sub evolve {
    my $self = shift;

    while ( !$self->terminate() ) {
        $self->set_population( [ $self->next_generation() ] );
        $self->inc_gen();
        $self->evaluate();
    }
}

=head2

Applies the fitness function to all members of current population.

=cut

sub evaluate {
    my $self       = shift;
    my $sum        = 0;
    my $population = $self->population();

    foreach my $individual ( @{$population} ) {
        $individual->fitness(
            $self->{'_fitness_function'}->( $self, $individual ) );
        $sum += $individual->fitness();
    }

    $self->{'_statistics'}->[ $self->cur_gen() ]->{'sum'} = $sum;

    $self->{'_statistics'}->[ $self->cur_gen() ]->{'avg'} =
      $sum / @{$population};

    if ( $self->{'_ordering'} eq 'asc' ) {
        @{$population} = sort { $a->fitness <=> $b->fitness } @{$population};
        $self->{'_statistics'}->[ $self->cur_gen() ]->{'min'} =
          $population->[0]->fitness;
        $self->{'_statistics'}->[ $self->cur_gen() ]->{'max'} =
          $population->[-1]->fitness;
    }
    else {
        @{$population} = sort { $b->fitness <=> $a->fitness } @{$population};
        $self->{'_statistics'}->[ $self->cur_gen() ]->{'min'} =
          $population->[-1]->fitness;
        $self->{'_statistics'}->[ $self->cur_gen() ]->{'max'} =
          $population->[0]->fitness;
    }
}

=head2 next_generation

Calculates the next generation. This method version apply only crossover and
mutation operators (if the provided genome has able).

To apply other operators you MUST overload this method, using the methods
select, can_apply and aply when necessary.

=cut

sub next_generation {
    my $self = shift;

    my @new_pop = ();

    while ( @new_pop < $self->pop_size() ) {

        my @children;

        # Crossover
        if ( $self->can_apply('crossover') ) {
            my $mom = $self->select();
            my $dad = $self->select();

            @children = $self->apply( 'crossover', $mom, $dad );
        }
        else {
            $children[0] = $self->select();
        }

        # Mutation
        for my $i ( 0 .. $#children ) {
            $self->apply( 'mutation', $children[$i] )
              if $self->can_apply('mutation');
        }

        push @new_pop, @children;
    }

    return @new_pop;
}

=head2 can_apply

Verifies if a genetic operator can be applied based on its percentual rate.
This method do not any verification about the validity of the code provided.

Expects receive as arguments the operator name registered into the %operators
hash.

=cut

sub can_apply {
    my ( $self, $op_name ) = @_;

    my $val = int( rand() < $self->{'_operators'}->{$op_name}->{'rate'} );

    return $val;
}

=head2 apply

Applies the genetic operator in individuals given as arguments. Returns a
list of new individuals.

=cut

sub apply {
    my ( $self, $op_name, @args ) = @_;

    my $op_ref = $self->{'_operators'}->{$op_name}->{'code'};

    return defined $op_ref ? $op_ref->(@args) : ();
}

=head2 fitness_function

Stores and returns a reference to the fitness function.

=cut

sub fitness_function {
    my ( $self, $code ) = @_;

    $self->{'_fitness_function'} = $code
      if ( defined $code && ref $code eq 'CODE' );

    return $self->{'_fitness_function'};
}

=head2 termination_function

Stores and returns a reference to the termination function.

=cut

sub termination_function {
    my ( $self, $code ) = @_;

    $self->{'_termination_function'} = $code
      if ( defined $code && ref $code eq 'CODE' );

    return $self->{'_termination_function'};
}

=head2 max_gen

Stores and returns the maximum number of generations.

=cut

sub max_gen {
    my ( $self, $value ) = @_;

    $self->{'_max_gen'} = $value if defined $value and $value > 0;

    return $self->{'_max_gen'};
}

=head2 cur_gen

Returns the current generation.

=cut

sub cur_gen {
    my $self = shift;

    return $self->{'_cur_gen'};
}

=head2 inc_gen

Increments the current generation.

=cut

sub inc_gen {
    my $self = shift;

    ++$self->{'_cur_gen'};
}

=head2 pop_size

Stores and returns the size of current population.

=cut

sub pop_size {
    my ( $self, $value ) = @_;

    $self->{'_pop_size'} = $value if defined $value && $value > 0;

    return $self->{'_pop_size'};
}

=head2 statistics

=cut

sub statistics {
    my $self = shift;

    return $self->{'_statistics'};
}

=head2 population

Returns a reference to the current population.

=cut

sub population {
    my $self = shift;

    return $self->{'_pop'};
}

=head2 fittest

Returns the fittest individual of this population.

=cut

sub fittest {
    my $self = shift;

    return $self->population()->[0];
}

=head2 population

Stores a reference to the current population. You MUST use this method to
make the swap between the old population and the population that you has just
calculated.

=cut

sub set_population {
    my ( $self, $new_pop ) = @_;

    if ( defined $new_pop && ref $new_pop eq 'ARRAY' ) {
        $self->{'_pop'} = $new_pop;
    }
}

=head2 ordering

Stores and returns the ordering of current population. The values available
are 'desc' (default), which means best fitness at first position and worst
fitness at last position, and 'asc', which means the inverse order.

=cut

sub ordering {
    my ( $self, $value ) = @_;

    $self->{'_ordering'} = $value if defined $value && $value =~ /(a|de)sc/i;

    return $self->{'_ordering'};
}

=head2 select

Selects and returns an individual based on the selector chosen.

=cut

sub select {
    my $self = shift;

    return $self->{'_selector'}->($self);
}

=head2 uniform_selection

Selects an individual using an uniform random choice.

=cut

sub uniform_selection {
    my $self = shift;

    return $self->{'_pop'}->[ int rand $self->pop_size ];
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

return 42;    # End of AI::GA::Base
