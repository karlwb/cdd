package CDD::Play::Quad; # not really a playable group per se
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $group->sort_by('val', 'desc')->cards;
    if ( @{$cards} == 4) {
        if ($cards->[0]->rank eq $cards->[1]->rank and
            $cards->[1]->rank eq $cards->[2]->rank and
            $cards->[2]->rank eq $cards->[3]->rank and
            $cards->[0]->suit ne $cards->[1]->suit and
            $cards->[1]->suit ne $cards->[2]->suit and
            $cards->[2]->suit ne $cards->[3]->suit
           ){
            return $cards;
        }
    }
    confess "Not a valid quad";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Card::RANK_VAL{$group->cards->[0]->rank};
}

1;
