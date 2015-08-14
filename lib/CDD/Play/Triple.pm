package CDD::Play::Triple;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    return $group->cards if exists $CDD::Val::TRIPLE_VAL->{$group->key};
    confess "Not a valid triple";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::TRIPLE_VAL->{$group->key};
}

1;
