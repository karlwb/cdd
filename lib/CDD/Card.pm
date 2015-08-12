package CDD::Card;
use Carp qw/confess/;
use Moo;

has rank => (is => 'ro', 
             required => 1,
             isa => sub{ confess "invalid rank $_[0]" unless $_[0] =~ m/^[2-9JQKA]|10$/i },
             coerce => sub { uc $_[0] },
            );
has suit => (is => 'ro', 
             required=>1,
             isa => sub{ confess "invalid suit $_[0]" unless $_[0] =~ m/^[DCHS]$/i },
             coerce => sub { uc $_[0] },
            );
has val  => (is => 'ro', 
             required=>1,
             isa => sub { confess "val must be a number got $_[0]" if $_[0] !~ m/^\d+$/; 
                          confess "val must be positive got $_[0]" if $_[0] < 1;
                          confess "val must be <= 52 got $_[0]" if $_[0] > 52; 
                      },
            );

our %CARD_VAL = ( '3D'  => 1,  '3C'  => 2,  '3H'  => 3,  '3S'  => 4,
                  '4D'  => 5,  '4C'  => 6,  '4H'  => 7,  '4S'  => 8,
                  '5D'  => 9,  '5C'  => 10, '5H'  => 11, '5S'  => 12,
                  '6D'  => 13, '6C'  => 14, '6H'  => 15, '6S'  => 16,
                  '7D'  => 17, '7C'  => 18, '7H'  => 19, '7S'  => 20,
                  '8D'  => 21, '8C'  => 22, '8H'  => 23, '8S'  => 24,
                  '9D'  => 25, '9C'  => 26, '9H'  => 27, '9S'  => 28,
                  '10D' => 29, '10C' => 30, '10H' => 31, '10S' => 32, 
                  'JD'  => 33, 'JC'  => 34, 'JH'  => 35, 'JS'  => 36, 
                  'QD'  => 37, 'QC'  => 38, 'QH'  => 39, 'QS'  => 40, 
                  'KD'  => 41, 'KC'  => 42, 'KH'  => 43, 'KS'  => 44, 
                  'AD'  => 45, 'AC'  => 46, 'AH'  => 47, 'AS'  => 48, 
                  '2D'  => 49, '2C'  => 50, '2H'  => 51, '2S'  => 52,
            );
our %RANK_VAL = ( '3' => 1, '4' => 2, '5' => 3, '6' => 4, '7' => 5,
                  '8' => 6, '9' => 7, '10' => 8, 'J' => 9, 'Q' => 10,
                  'K' => 11, 'A' => 12, '2' => 13);
our %SUIT_VAL = ( 'D' => 1, 'C' => 2, 'H' => 3, 'S' => 4);
our %UNICODE = ( D => '♢', C => '♧', H => '♡', S => '♤' );

sub BUILDARGS {
    my ($class, @args) = @_;
    confess "Must supply args" if not defined $args[0];
    if (ref($args[0]) eq '') {
        if ($args[0] =~ m/^(.*)([DCHS])$/i) {
            my $rank = uc $1;
            my $suit = uc $2;
              return {rank=>$rank, suit=>$suit, val=>$CARD_VAL{$rank.$suit}};
        }
    }
    elsif (ref($args[0] eq 'HASH')) {
        return $args[0];
    }
    return { @args };
}

sub as_string{ 
    $_[0]->rank . ($_[1] ? $UNICODE{$_[0]->suit} : $_[0]->suit);
};

sub as_unicode {
    shift->as_string(1);
}

sub _3way_compare { 
    shift->val <=> shift->val;
}

use overload '""' => 'as_string';
use overload '<=>' => '_3way_compare';
use overload 'cmp' => '_3way_compare'; 

1;

