package CDD::Group;
use Moo::Role;
use List::MoreUtils qw/all uniq/;
use Carp qw/confess/;

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

# shuffle cards in place, return self
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

# are there more than 2 cards in the group and when sorted by rank are they sequential?
sub is_run {
    my $self = shift;
    my $cards = $self->sort_by('rank', 'asc', 0);
    my $len = @{$cards};
    return '' if $len < 2;
    for (my $i=0; $i<$len-1; $i++) {
        return '' if $CDD::Card::RANK_VAL{$cards->[$i]->rank} != $CDD::Card::RANK_VAL{$cards->[$i+1]->rank} - 1;
    }
    return 1;
}

# do all cards in the group have the same suit?
sub is_same_suit {
    my $self = shift;
    return scalar(uniq map{$_->suit} @{$self->cards}) == 1;
}

# does a group look like a full house? If so, return [[triple],[pair]]
sub is_full_house {
    my $self = shift;
    my $cards = $self->sort_by('rank', 'asc', 0);
    return '' if @{$cards} != 5;
    return [[@{$cards}[0..2]], [@{$cards}[3,4]]]
        if ($cards->[2]->rank ne $cards->[3]->rank and
            $cards->[3]->rank eq $cards->[4]->rank and
            all {$_->rank eq $cards->[0]->rank} @{$cards}[1,2]);
    return [[@{$cards}[2..4]], [@{$cards}[0,1]]]
        if ($cards->[1]->rank ne $cards->[2]->rank and
            $cards->[0]->rank eq $cards->[1]->rank and
            all {$_->rank eq $cards->[2]->rank} @{$cards}[3,4]);
    return '';
}

# does a group look like a quad + 1? If so, return [[quad], [one]]
sub is_quad_plus_one {
    my $self = shift;
    my $cards = $self->sort_by('rank', 'asc', 0);
    return '' if @{$cards} != 5;
    return [[@{$cards}[0..3]], [$cards->[4]]]
        if ($cards->[3]->rank ne $cards->[4]->rank and
            all {$_->rank eq $cards->[0]->rank} @{$cards}[1,2,3]);
    return [[@{$cards}[1..4]], [$cards->[0]]]
        if ($cards->[0]->rank ne $cards->[1]->rank and
            all {$_->rank eq $cards->[1]->rank} @{$cards}[2,3,4]);
    return '';
}

# is a group a single
sub is_single {
    @{shift->cards} == 1;
}

# is a group a pair
sub is_pair {
    my $self = shift;
    my $cards = $self->cards;
    return '' if @{$cards} != 2;
    return ($cards->[0]->rank eq $cards->[1]->rank and 
            $cards->[0]->val ne $cards->[1]->val);
}

# is a group a triple?
sub is_triple {
    my $self = shift;
    my $cards = $self->cards;
    return '' if @{$cards} != 3;
    return (all {$_->rank eq $cards->[0]->rank} @{$cards}[1,2] and
            scalar(uniq map{$_->val} @{$cards}) == 3);
}

# sort cards using $code, or if omitted ascending by val, returning arrayref (i.e. not in place)
sub sort_cards {
    my ($self, $code) = @_;
    ref($code) eq 'CODE' ? [sort $code @{$self->cards}] : [sort {$a->val <=> $b->val} @{$self->cards}];
}

# sort cards in-place using $code, or if omitted ascending by val
sub sort {
    my ($self, $code) = @_;
    $self->_set_cards($self->sort_cards($code));
    return $self;
}

# convenience function for sorting by $attr, in $order, in-place or not
sub sort_by {
    my $self  = shift;
    my $attr  = shift;   # 'rank', 'suit', 'val'
    my $order = shift // 'asc';    # 'asc', 'desc'
    my $in_place = shift // 1;   # sort cards in place and return self, or return aref of sorted cards
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
    return $in_place ? $self->sort($sub->{$order}{$attr}) : $self->sort_cards($sub->{$order}{$attr});
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

has key => ( is => 'ro',
             builder => sub{ '[' . join(',', @{shift->sort->cards}) . ']' }, 
           );
             
1;
