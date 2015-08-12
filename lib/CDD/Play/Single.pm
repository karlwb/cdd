package CDD::Play::Single;
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

sub validate {
    my ($class, $group) = @_;
    my $cards = $group->cards;
    if ( @{$cards} == 1) {
        return $cards
    }
    confess "Not a valid single";
}

sub valuate {
    my ($class, $group) = @_;
    return -1; # todo
}

sub _3way_compare {
    shift->cards->[0]->val <=> shift->cards->[0]->val;
}

use overload '<=>' => '_3way_compare';
use overload 'cmp' => '_3way_compare';

1;
