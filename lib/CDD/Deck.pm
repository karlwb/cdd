package CDD::Deck;
use Moo;
use CDD::Card;

with 'CDD::Group';

sub _build_cards {
    my @cards = ();
    my $val   = 1;
    for my $rank (qw/3 4 5 6 7 8 9 10 J Q K A 2/) {
        for my $suit (qw/D C H S/) {
            push @cards, CDD::Card->new(rank => $rank, suit => $suit, val => $val++);
        }
    }
    return \@cards;
}

1;
