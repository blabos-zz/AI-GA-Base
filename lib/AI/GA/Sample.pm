package AI::GA::Sample;

use warnings;
use strict;

use parent 'AI::GA::Base';
use Data::Dumper;

=head1 NAME

AI::GA::Sample - A sample AI::GA implementation.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SELECTORS

Selectors Available: uniform (inherited) and roulette.

=cut

$AI::GA::Base::selectors{'roulette'} = \&roulette_selection;

=head1 SYNOPSIS

This module extends AI::GA::Base, implementing a elitist population.

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my $class = shift;
    my $args  = shift;
    my $atts  = $class->SUPER::new($args);

    $atts->{'_preserve'} = $args->{'preserve'} || 0;

    return bless $atts, $class;
}

sub next_generation {
    my $self = shift;

    my @new_pop = $self->SUPER::next_generation();
    my $old_pop = $self->population();

    if (   $self->{'_preserve'} > 0
        && $self->{'_preserve'} <= $self->pop_size() )
    {
        push @new_pop, @{$old_pop}[ 0 .. $self->{'_preserve'} - 1 ];
    }
    return @new_pop;
}

=head2 roulette_selector

Selects an individual using a roulette wheel algorithm. Uses a closure for
better performance.

=cut

sub roulette_selection {
    my $self       = shift;
    my $population = $self->population();
    my $sum        = $self->statistics()->[ $self->cur_gen() ]->{'sum'};
    my $lim        = $sum * rand();

    my ( $i, $aux ) = ( 0, 0 );

    for ( $i = 0 ; ( $i < scalar @{$population} ) && ( $aux < $lim ) ; ++$i )
    {
        $aux += $population->[$i]->fitness();
    }

    $i--;

    return $population->[$i];
}

=head2 as_string

Provides a textual format of internal data.

=cut

sub as_string {
    my $self = shift;

    my $str = '';

    $str .= $_->as_string . $/ foreach ( @{ $self->{'_pop'} } );

    return $str;
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
