package CDD::Play::Single;
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $group->cards;
    if ( @{$cards} == 1) {
        return $cards
    }
    confess "Not a valid single";
}

1;
