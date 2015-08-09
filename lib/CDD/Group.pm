package CDD::Group;
use Moo::Role;
use List::MoreUtils qw/all/;
use Carp qw/confess/;

requires qw/shuffle sort sort_by as_string as_unicode _build_cards/;

sub BUILDARGS {
    my ($class, @args) = @_;
    if ( ref($args[0]) eq 'ARRAY' and ref($args[0]->[0]) eq 'CDD::Card') {
        # arrayref of cards
        return {'cards' => $args[0]};
    }
    elsif ( ref($args[0]) eq 'CDD::Card' ) {
        # args are cards
        return {'cards' => \@args};
    }
    elsif ( defined($args[0]) and ref($args[0]) eq '' ) {
        # args are strings 
        return {cards => [ map{CDD::Card->new($_)} @args ]};
    }
    else {
        return { @args };
    }
}

sub _build_cards {
    [];
}

sub shuffle {
    my $self  = shift;
    my $cards = $self->cards;
    for (my $i = @{$cards} ; --$i ;) {
        my $j = int rand($i + 1);
        next if $i == $j;
        @{$cards}[$i, $j] = @{$cards}[$j, $i];
    }
    $self->_set_cards($cards);
    return $self;
}

sub sort {
    my $self = shift;
    my $code = shift;
    if (ref($code) eq 'CODE') {
        $self->_set_cards([sort $code @{$self->cards}]);
    }
    else {
        $self->_set_cards([sort {$a->val <=> $b->val} @{$self->cards}]);
    }
    return $self;
}

sub sort_by {
    my $self  = shift;
    my $attr  = shift;   # 'rank', 'suit', 'val'
    my $order = shift // 'asc';    # 'asc', 'desc'

    if    ($order =~ m/^a/i) {$order = 'asc'}
    elsif ($order =~ m/^d/i) {$order = 'desc'}
    else                     {die "unknown sort order: $order; try 'asc' or 'desc'";}

    my %suit_val;
    @suit_val{qw/D C H S/} = 1 .. 4;
    my %rank_val;
    @rank_val{qw/3 4 5 6 7 8 9 10 J Q K A 2/} = 1 .. 13;

    my $sub = {
        'asc' => {
            rank => sub {$rank_val{$a->rank} <=> $rank_val{$b->rank} or $a->val <=> $b->val},
            val  => sub {$a->val <=> $b->val},
            suit => sub {$suit_val{$a->suit} <=> $suit_val{$b->suit} or $a->val <=> $b->val},
        },
        'desc' => {
            rank => sub {$rank_val{$b->rank} <=> $rank_val{$a->rank} or $b->val <=> $a->val},
            val  => sub {$b->val <=> $a->val},
            suit => sub {$suit_val{$b->suit} <=> $suit_val{$a->suit} or $b->val <=> $a->val},
        },
    };
    return $self->sort($sub->{$order}{$attr});
}

use overload '""' => \&as_string;

sub as_string {
    '[' . join(', ', map {$_->as_string} @{shift->cards}) . ']';
}

sub as_unicode {
    '[' . join(', ', map {$_->as_unicode} @{shift->cards}) . ']';
}

has cards => (
    is  => 'rwp',
    isa => sub {
        (ref($_[0]) eq 'ARRAY' and all {ref($_) eq 'CDD::Card'} @{$_[0]})
            or confess "cards not valid";
    },
    builder => \&_build_cards,
);

1;
