package CDD::Play::Triple;
use Carp qw/confess/;
use Moo;
extends 'CDD::Play';

sub _validate {
    my ($class, $group) = @_;
    return $group->sort_by('val', 'desc', 0) if $group->is_triple;
    confess "Not a valid triple";
}

1;
