package CDD::Play::Pair;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play';


sub _validate {
    my ($class, $group) = @_;
    return $group->cards if exists $CDD::Val::PAIR_VAL->{$group->key};
    confess "Not a valid pair";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::PAIR_VAL->{$group->key};
}

1;
