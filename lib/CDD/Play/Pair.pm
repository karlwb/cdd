package CDD::Play::Pair;
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $group->sort_by('val', 'desc')->cards;
    if ( @{$cards} == 2) {
        if ($cards->[0]->rank eq $cards->[1]->rank and 
            $cards->[0]->suit ne $cards->[1]->suit
           ){
            return $cards;
        }
    }
    confess "Not a valid pair";
}

sub _valuate {
    my ($class, $group) = @_;
    return -1; # todo
}

sub _highest {
    my ($class, $group) = @_;
    return $group->sort_by('val', 'desc')->cards->[0];
}

sub _3way_compare {
    shift->highest->val <=> shift->highest->val
}

use overload '<=>' => '_3way_compare';
use overload 'cmp' => '_3way_compare';

1;

1;
