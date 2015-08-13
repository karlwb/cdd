use Modern::Perl;
use Test::More;
use CDD::Card;
use List::MoreUtils qw/any all/;

require_ok 'CDD::SimpleGroup';
use_ok 'CDD::SimpleGroup';

my $g = CDD::SimpleGroup->new;
is_deeply $g->cards, [], "empty group";

$g = CDD::SimpleGroup->new('6d', '3d', '5c', '7d', '4h',);
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

$g = CDD::SimpleGroup->new('3d');
is $g->is_single, 1, 'single is_single';
is $g->is_pair, '', 'single not is_pair';
is $g->is_triple, '', 'single not is_triple';
is $g->is_run, '', 'single not is_run';
is $g->is_same_suit, 1, 'single is_same_suit';
is $g->is_full_house, '', 'single not is_full_house';
is $g->is_quad_plus_one, '', 'single not is_quad_plus_one';

$g = CDD::SimpleGroup->new('3d', '3c');
is $g->is_single, '', 'pair not is_single';
is $g->is_pair, 1, 'pair  is_pair';
is $g->is_triple, '', 'pair not is_triple';
is $g->is_run, '', 'pair not is_run';
is $g->is_same_suit, '', 'pair not is_same_suit';
is $g->is_full_house, '', 'pair not is_full_house';
is $g->is_quad_plus_one, '', 'pair not is_quad_plus_one';

$g = CDD::SimpleGroup->new('3d', '3c', '3h');
is $g->is_single, '', 'triple not is_single';
is $g->is_pair, '', 'triple  is_pair';
is $g->is_triple, 1, 'triple not is_triple';
is $g->is_run, '', 'triple not is_run';
is $g->is_same_suit, '', 'triple not is_same_suit';
is $g->is_full_house, '', 'triple not is_full_house';
is $g->is_quad_plus_one, '', 'triple not is_quad_plus_one';


$g = CDD::SimpleGroup->new('3d', '4d', '5d', '6d', '7d');
is $g->is_single, '', 'straight flush not is_single';
is $g->is_pair, '', 'straight flush not is_pair';
is $g->is_triple, '', 'straight flush not is_triple';
is $g->is_run, 1, 'straight flush is_run';
is $g->is_same_suit, 1, 'straight flush is_same_suit';
is $g->is_full_house, '', 'straight flush not is_full_house';
is $g->is_quad_plus_one, '', 'straight flush not is_quad_plus_one';

$g = CDD::SimpleGroup->new('3d', '3c', '3h', '4d', '4c');
is $g->is_single, '', 'fullhouse not is_single';
is $g->is_pair, '', 'fullhouse not is_pair';
is $g->is_triple, '', 'fullhouse not is_triple';
is $g->is_run, '', 'fullhouse not is_run';
is $g->is_same_suit, '', 'fullhouse not is_same_suit';
is_deeply $g->is_full_house, [[CDD::Card->new('3d'),
                               CDD::Card->new('3c'),
                               CDD::Card->new('3h')], 
                              [CDD::Card->new('4d'),
                               CDD::Card->new('4c')]
                             ], 'fullhouse is_full_house';
is $g->is_quad_plus_one, '', 'fullhouse not is_quad_plus_one';

$g = CDD::SimpleGroup->new('3d', '3c', '3h', '3s', '4c');
is $g->is_single, '', 'quad+1 not is_single';
is $g->is_pair, '', 'quad+1 not is_pair';
is $g->is_triple, '', 'quad+1 not is_triple';
is $g->is_run, '', 'quad+1 not is_run';
is $g->is_same_suit, '', 'quad+1 not is_same_suit';
is $g->is_full_house, '', 'quad+1 not is_full_house';
is_deeply $g->is_quad_plus_one, [[CDD::Card->new('3d'),
                                  CDD::Card->new('3c'),
                                  CDD::Card->new('3h'),
                                  CDD::Card->new('3s')],
                                 [CDD::Card->new('4c')]
                                ], 'quad+1 is_quad_plus_one';

done_testing;

