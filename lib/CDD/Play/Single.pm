package CDD::Play::Single;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    return $group->cards if exists $CDD::Val::SINGLE_VAL->{$group->key};
    confess "Not a valid single";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::SINGLE_VAL->{$group->key};
}


1;
