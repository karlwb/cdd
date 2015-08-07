package CDD::Deck;
use Moo;
use CDD::Card;

has cards => (is => 'rwp',
              builder => \&_build_deck,
             );

sub _build_deck {
    my $self = shift;
    my @cards = ();
    my $val = 1;
    for my $rank (qw/3 4 5 6 7 8 9 10 J Q K A 2/){
        for my $suit (qw/D C H S/) {
            push @cards, CDD::Card->new(rank=>$rank, suit=>$suit, val=>$val++);
        }
    }
    return \@cards;
}

sub as_string {
    my $self = shift;
    return join(', ', map{ $_->as_string } @{$self->cards});
}

sub shuffle {
    my $self = shift;
    my $cards = $self->cards;
    for (my $i = @{$cards}; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @{$cards}[$i,$j] = @{$cards}[$j,$i];
    }
    $self->_set_cards($cards);
    return $self;
}

1;
