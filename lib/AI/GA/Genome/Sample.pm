package AI::GA::Genome::Sample;

use warnings;
use strict;

use Data::Dumper;

use parent 'AI::GA::Genome::Base';

=head1 NAME

AI::GA::Genome::Sample - A sample AI::GA genome.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 OPERATORS

Operators Available: crossover and mutation.

=cut

$AI::GA::Genome::Base::operators{'crossover'} = \&my_crossover;
$AI::GA::Genome::Base::operators{'mutation'}  = \&my_mutation;

=head1 SYNOPSIS

This module extends AI::GA::Genome::Base, implementing a bit vector with seven
bits and providing crossover and mutation operators.

=head1 SUBROUTINES/METHODS

=head2 new

Constructs a new individual or a copy of a existing one.

    # A new individual
    my $individual = AI::GA::Genome::Sample->new();
    
    # A copy individual
    my $copy = AI::GA::Genome::Sample->new({
        'genes' => [1, 0, 0, 1, 0, 0 , 1]
    });

=cut

sub new {
    my $class = shift;
    my $args  = shift;
    my $atts  = {
        '_fitness'     => 0,
        '_chromossome' => $args->{'genes'} || [],
        '_bits'        => 7,
    };

    return bless $atts, $class;
}

=head2 init

Provides a way to initialize a recently created individual.

=cut

sub init {
    my $self = shift;
    
    my $last_bit = $self->bits() - 1;

    $self->{'_chromossome'}->[$_] = int( rand(2) ) foreach ( 0 .. $last_bit );
}

=head2 as_string

Provides a textual format of internal data.

=cut

sub as_string {
    my $self = shift;

    my $str = join ', ', reverse @{ $self->{'_chromossome'} };

    return "[$str]($self->{'_fitness'})";
}

=head2 my_crossover

Makes a one point corssover.

=cut

sub my_crossover {
    my ( $mom, $dad ) = @_;
    
    my $last_bit = $mom->bits() - 1;
    my $point = 1 + int rand $last_bit;

    return (
        AI::GA::Genome::Sample->new(
            {
                'genes' => [
                    @{ $mom->{'_chromossome'} }[ 0 .. $point ],
                    @{ $dad->{'_chromossome'} }[ $point + 1 .. $last_bit]
                ]
            }
        ),
        AI::GA::Genome::Sample->new(
            {
                'genes' => [
                    @{ $dad->{'_chromossome'} }[ 0 .. $point ],
                    @{ $mom->{'_chromossome'} }[ $point + 1 .. $last_bit ]
                ]
            }
        )
    );
}

sub bits {
    my $self = shift;

    return $self->{'_bits'};
}

=head2 my_mutation

Makes a single flib bit mutation.

=cut

sub my_mutation {
    my $individual = shift;

    my $pos = int rand $individual->bits();

    $individual->{'_chromossome'}->[$pos] =
      1 - $individual->{'_chromossome'}->[$pos];

    return $individual;
}

=head1 AUTHOR

Blabos de Blebe, C<< <blabos at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ai-ga-base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AI-GA-Base>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AI::GA::Genome::Sample


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

return 42;    # End of AI::GA::Genome::Sample
