package CDD::Play::Triple;
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $group->sort_by('val', 'desc')->cards;
    if ( @{$cards} == 3) {
        if ($cards->[0]->rank eq $cards->[1]->rank and
            $cards->[1]->rank eq $cards->[2]->rank and
            $cards->[0]->suit ne $cards->[1]->suit and
            $cards->[1]->suit ne $cards->[2]->suit
           ){
            return $cards;
        }
    }
    confess "Not a valid triple";
}

1;