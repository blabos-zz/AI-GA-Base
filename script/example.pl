#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use AI::GA::Genome::Sample;
use AI::GA::Sample;

my $ga = AI::GA::Sample->new({
    'genome' => 'AI::GA::Genome::Sample',
    'operators' => {
        'crossover' => 0.9,
        'mutation' => 0.01,
    },
    'fitness' => \&my_fitness,
    'pop_size' => 10,
    'max_gen' => 25,
    'selector' => 'roulette',
    'preserve' => 1
});

$ga->evolve;

my $statistics = $ga->statistics();
foreach (@$statistics) {
    say sprintf("%3.2f;%3.2f;%3.2f", $_->{'min'}, $_->{'avg'}, $_->{'max'});
}

say $ga->fittest()->as_string;


sub my_fitness {
    my $self = shift;
    my $individual = shift;
    my $fit = 0;
    
    my $last_bit = $individual->bits() - 1;
    
    for (0 .. $last_bit) {
        $fit += ($individual->{'_chromossome'}->[$_] * (2 ** $_));
    }
    
    return ($fit)/2 ** $individual->bits();
}