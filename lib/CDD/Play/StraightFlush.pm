package CDD::Play::StraightFlush;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $class->SUPER::_validate($group);
    return $cards if exists $CDD::Val::STRAIGHTFLUSH_VAL->{$group->key};
    confess "Not a valid straight flush";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::STRAIGHTFLUSH_VAL->{$group->key};
}

1;
