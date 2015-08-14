package CDD::Play::FiveCard;
use Carp qw/confess/;
use List::MoreUtils qw/uniq/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

our %TYPE_VAL = ( 'CDD::Play::Straight'      => 1,
                  'CDD::Play::Flush'         => 2,
                  'CDD::Play::FullHouse'     => 3,
                  'CDD::Play::QuadPlusOne'   => 4,
                  'CDD::Play::StraightFlush' => 5,
               );


sub _validate {
    my ($class, $group) = @_;
    my $cards = $group->sort_by('val', 'desc', 0);
    return $cards if ( exists $TYPE_VAL{$class} and @{$cards} == 5 and scalar(uniq map{$_->val} @{$cards}) == 5 );
    confess "Not a valid 5-card group";
}


sub _3way_compare {
    my ($a, $b) = @_;
    $TYPE_VAL{ref($a)} <=> $TYPE_VAL{ref($b)}
        or $a->highest->val <=> $b->highest->val;
}

1;
