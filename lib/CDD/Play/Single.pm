package CDD::Play::Single;
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    return $group->cards if $group->is_single;
    confess "Not a valid single";
}

1;
