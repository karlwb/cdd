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

1;
