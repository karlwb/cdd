package CDD::Play::Flush;
use List::MoreUtils qw/all/;
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $group->sort_by('val', 'desc')->cards;
    if ( @{$cards} == 5) {
        if ($cards->[0]->val != $cards->[1]->val and
            $cards->[1]->val != $cards->[2]->val and
            $cards->[2]->val != $cards->[3]->val and
            $cards->[3]->val != $cards->[4]->val and
            not( $CDD::Card::RANK_VAL{$cards->[0]->rank} == $CDD::Card::RANK_VAL{$cards->[1]->rank}+1 and
                 $CDD::Card::RANK_VAL{$cards->[1]->rank} == $CDD::Card::RANK_VAL{$cards->[2]->rank}+1 and
                 $CDD::Card::RANK_VAL{$cards->[2]->rank} == $CDD::Card::RANK_VAL{$cards->[3]->rank}+1 and
                 $CDD::Card::RANK_VAL{$cards->[3]->rank} == $CDD::Card::RANK_VAL{$cards->[4]->rank}+1)
            and all {$_->suit eq $cards->[0]->suit} @{$cards}
           ) {
            return $cards;
        }
    }
    confess "Not a valid flush";
}

1;
