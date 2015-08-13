package CDD::Play::Pair;
use Carp qw/confess/;
use Moo;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    return $group->sort_by('val', 'desc', 0) if $group->is_pair;
    confess "Not a valid pair";
}

1;
