package CDD::Deck;
use Moo;
use CDD::Card;

with 'CDD::Group';

sub _build_cards {
    my @cards = ();
    my $val   = 1;
    for my $rank (@CDD::Card::RANKS) {
        for my $suit (@CDD::Card::SUITS) {
            push @cards, CDD::Card->new(rank => $rank, suit => $suit, val => $val++);
        }
    }
    return \@cards;
}

1;
