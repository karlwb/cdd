use Modern::Perl;
use Test::More;
use CDD::Card;
use List::MoreUtils qw/any all/;
use lib 't';
use TestGroup; # couldn't inline this package in the t file...Moo thing?

my $g = TestGroup->new;
is_deeply $g->cards, [], "empty group";

$g = TestGroup->new('6d', '3d', '5c', '7d', '4h',);
is "$g", '[6D, 3D, 5C, 7D, 4H]', 'group as strings';
is $g->sort->as_string, '[3D, 4H, 5C, 6D, 7D]', 'sort';
is $g->sort_by('rank', 'desc')->as_string, '[7D, 6D, 5C, 4H, 3D]', 'sort_by rank desc';
is $g->sort_by('rank', 'asc')->as_string, '[3D, 4H, 5C, 6D, 7D]', 'sort_by rank asc';
is $g->sort_by('suit', 'desc')->as_string, '[4H, 5C, 7D, 6D, 3D]', 'sort_by suit desc';
is $g->sort_by('suit', 'asc')->as_string, '[3D, 6D, 7D, 5C, 4H]', 'sort_by suit asc';
is $g->sort_by('val', 'desc')->as_string, '[7D, 6D, 5C, 4H, 3D]', 'sort_by val desc';
is $g->sort_by('val', 'asc')->as_string, '[3D, 4H, 5C, 6D, 7D]', 'sort_by val asc';
my $str = $g->as_string;
is "$g", $str, "overloaded string";
my $x = any { $g->shuffle->as_string ne $str } (1..5); #hopefully 
is $x, 1, 'shuffle';

done_testing;

