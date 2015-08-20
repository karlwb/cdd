package CDD::DB::Populator;
use Modern::Perl;
use Mojo::SQLite;
use Carp qw/confess/;
use CDD::Card;

my $VERBOSE = 1;  # 0 say nothing, 1 just overview, 2 data

# used many times when generating database:
my $GROUPID; 
my $VALUE;  
my $SQL_CARD = q/insert into card (id, rank,suit_id,value) values (?,?,?,?)/;
my $SQL_GRP  = q/insert into grp (id, numcards, grptype_id, value) values (?,?,?,?)/;
my $SQL_GRPCARD = q/insert into grpcard (grp_id, card_id) values (?,?)/;
my $SQL_GRPAVAIL = q/insert into grpavail (grp_id, available) values (?,1)/;

use Moo;
has sql  => (is => 'ro');

sub generate {
    my $self  = shift;
    $self->_generate_database($self->sql);
    return $self;
}

sub _generate_database {
    my $self = shift;
    my $db = $self->sql->db;
    eval {
        my $tx = $db->begin;
        _create_schema($db);
        say "populating tables..." if $VERBOSE;
        _populate_suits($db);
        _populate_grptype($db);
        _populate_cards($db);
        say "generating plays and populating groups..." if $VERBOSE;
        $GROUPID = 1;
        $VALUE = 1; # singles have their own values
        my $singles = _populate_singles($db);

        $VALUE = 1; # pairs have their own values
        my $pairs   = _populate_pairs($db);

        $VALUE = 1; # triples have their own values
        my $triples = _populate_triples($db);

        $VALUE = 1; # 5 carders have their own values
        my ($straights, $straight_flushes) = _populate_straights($db);
        my $flushes   = _populate_flushes($db);
        my $full_houses = _populate_full_houses($db, $pairs, $triples);
        #my $quads   = _populate_quads($db, $singles);
        #my $straight_flushes = _populate_straight_flushes($db);

        $tx->commit;
    };
    confess $@ if $@;
}

sub _create_schema {
    my $db = shift;
    say "creating tables..." if $VERBOSE;
    my $create = {
        card => q/create table card (id text not null primary key, rank integer not null, suit_id  text not null, value integer not null)/,
        grp  => q/create table grp (id integer not null primary key, numcards integer not null, grptype_id integer not null, value integer not null ); /,
        grpavail => q/create table grpavail ( grp_id integer not null primary key, available integer not null )/,
        grpcard  => q/create table grpcard ( card_id integer not null, grp_id integer not null, primary key (card_id, grp_id))/,
        grptype  => q/create table grptype ( id integer not null primary key, name text not null )/,
        suit     => q/create table suit ( id text not null primary key, name text not null, rank integer not null )/,
    };

    foreach my $table (qw/card grp grpavail grpcard grptype suit/) {
        say "  * $table" if $VERBOSE;
        $db->query("drop table if exists $table");
        $db->query($create->{$table});
    }
}

sub _populate_suits {
    my $db = shift;
    say "  * suits" if $VERBOSE;
    my @suit_data = (['D', 'diamonds', 1], ['C', 'clubs', 2], ['H', 'hearts', 3], ['S', 'spades', 4],);
    foreach my $x (@suit_data) {
        $db->query('insert into suit (id, name, rank) values (?, ?, ?)', @{$x});
    }
}

sub _populate_grptype {
    my $db = shift;
    say "  * grptype" if $VERBOSE;
    my @grptype_data = ([1, 'single'], [2, 'pair'], [3, 'triple'], [4, 'straight'],
                        [5, 'flush'], [6, 'full house'], [7, 'quad+1'], [8, 'straight flush']);
    foreach my $x (@grptype_data) {
        $db->query('insert into grptype (id, name) values (?, ?)', @{$x});
    }
}

sub _populate_cards {
    my $db = shift;
    say "  * cards" if $VERBOSE;
    my $val = 1;
    for my $r (@CDD::Card::RANKS) {
        for my $s (@CDD::Card::SUITS) {
            $db->query('insert into card (id, rank, suit_id, value) values(?, ?, ?, ?)', "$r$s", $r, $s, $val++);
        }
    }
}

sub _populate_singles {
    my $db = shift;
    my @singles = ();
    say "  * singles (groupid: $GROUPID, value: $VALUE)" if $VERBOSE;
    foreach my $r (@CDD::Card::RANKS) {
        foreach my $s (@CDD::Card::SUITS) {
            my $c = "$r$s";
            $db->query($SQL_GRP, $GROUPID, 1, 1, $VALUE);
            $db->query($SQL_GRPAVAIL, $GROUPID);
            $db->query($SQL_GRPCARD, $GROUPID, $c);
            push @singles, [$c];
            say "single: $c val:$VALUE, group: $GROUPID" if $VERBOSE > 1;
            $VALUE++;
            $GROUPID++;
        }
    }
    say "    --> [populated " . scalar(@singles) . ' singles]' if $VERBOSE;
    return \@singles;
}

sub _populate_pairs {
    my $db = shift;
    my @pairs = ();
    say "  * pairs (groupid: $GROUPID, value: $VALUE)" if $VERBOSE;
    my $valsuits = {
        0 => [[qw/D C/],],                         # club high
        1 => [[qw/D H/], [qw/C H/]],               # heart high
        2 => [[qw/D S/], [qw/C S/], [qw/H S/]],    # spade high
    };
    my $newval = 0;
    for my $r (@CDD::Card::RANKS) {
        foreach my $val (sort keys %{$valsuits}) {
            $newval = $val;
            for my $group (@{$valsuits->{$newval}}) {
                my $realval = $VALUE + $newval;
                my ($s1, $s2) = @{$group};
                my ($c1, $c2) = ("$r$s1", "$r$s2");

                # db inserts
                $db->query($SQL_GRP, $GROUPID, 2, 2, $realval);
                $db->query($SQL_GRPAVAIL, $GROUPID);
                $db->query($SQL_GRPCARD, $GROUPID, $c1);
                $db->query($SQL_GRPCARD, $GROUPID, $c2);
                push @pairs, [$c1, $c2];
                say "pair: $c1,$c2 val:$realval, group:$GROUPID" if $VERBOSE > 1;
                $GROUPID++;
            }
        }
        $VALUE = $VALUE + $newval + 1;
    }
    say "    --> [populated " . scalar(@pairs) . ' pairs]' if $VERBOSE;
    return \@pairs;
}

sub _populate_triples {
    my $db = shift;
    say "  * triples (groupid: $GROUPID, value: $VALUE)" if $VERBOSE;
    my @triples = ();
    my $valsuits = {0 => [[qw/D C H/], [qw/D C S/], [qw/D H S/], [qw/C H S/]],};

    my $newval = 0;
    for my $r (@CDD::Card::RANKS) {
        for my $val (sort keys %{$valsuits}) {
            $newval = $val;
            for my $group (@{$valsuits->{$newval}}) {
                my $realval = $VALUE + $newval;
                my ($s1, $s2, $s3) = @{$group};
                my ($c1, $c2, $c3) = ("$r$s1", "$r$s2", "$r$s3");
                push @triples, [$c1, $c2, $c3];
                say "triple: $c1,$c2,$c3 val:$realval, group:$GROUPID" if $VERBOSE > 1;
                $db->query($SQL_GRP, $GROUPID, 3, 3, $realval);
                $db->query($SQL_GRPAVAIL, $GROUPID);
                $db->query($SQL_GRPCARD, $GROUPID, $c1);
                $db->query($SQL_GRPCARD, $GROUPID, $c2);
                $db->query($SQL_GRPCARD, $GROUPID, $c3);
                $GROUPID++;
            }
        }
        $VALUE = $VALUE + $newval + 1;
    }
    say "    --> [populated " . scalar(@triples) . ' triples]' if $VERBOSE;
    return \@triples;
}

sub _populate_straights {
    my $db = shift;
    say "  * straights (groupid: $GROUPID, value: $VALUE)" if $VERBOSE;
    my @straight_flushes;
    my @straights;

    for (my $i = 4 ; $i < 13 ; $i++) {    # highcard rank index:  5's up to 2's
        for my $s5 (@CDD::Card::SUITS) {             # 5th in group, highest ranking card's suit
            for my $s4 (@CDD::Card::SUITS) {
                for my $s3 (@CDD::Card::SUITS) {
                    for my $s2 (@CDD::Card::SUITS) {
                        for my $s1 (@CDD::Card::SUITS) {    # 1st in group, lowest ranking card's suit
                            # ranks in group
                            my $start = $i - 4;
                            my $stop  = $i;
                            my ($r1, $r2, $r3, $r4, $r5) = @CDD::Card::RANKS[$start .. $stop];
                            my ($c1, $c2, $c3, $c4, $c5) = ("$r1$s1", "$r2$s2", "$r3$s3", "$r4$s4", "$r5$s5");

                            # straight flushes...
                            if (($s1 eq $s2) and ($s2 eq $s3) and ($s3 eq $s4) and ($s4 eq $s5)) {
                                push @straight_flushes, [$c1, $c2, $c3, $c4, $c5];
                                next;
                            }

                            push @straights, [$c1, $c2, $c3, $c4, $c5];
                            say"straight: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID" if $VERBOSE > 1;
                            $db->query($SQL_GRP, $GROUPID, 3, 4, $VALUE);
                            $db->query($SQL_GRPAVAIL, $GROUPID);
                            $db->query($SQL_GRPCARD, $GROUPID, $c1);
                            $db->query($SQL_GRPCARD, $GROUPID, $c2);
                            $db->query($SQL_GRPCARD, $GROUPID, $c3);
                            $db->query($SQL_GRPCARD, $GROUPID, $c4);
                            $db->query($SQL_GRPCARD, $GROUPID, $c5);
                            $GROUPID++;
                        }
                    }
                }
            }

            # value increases when highcard suit changes
            $VALUE++;
        }
    }
    $VALUE--; # off by one otherwise...
    say "    --> [populated " . scalar(@straights) . ' straights]' if $VERBOSE;
    return \@straights, \@straight_flushes;
}

sub _populate_flushes {
    my $db = shift;
    say "  * flushes  (groupid: $GROUPID, value: $VALUE)" if $VERBOSE;
    my %flush   = ();
    my $valsuit = {
        D => 1,
        C => 9,
        H => 17,
        S => 25,
    };

    my @flushes = ();
    my $flushes     = {};
    my $start_value = $VALUE;

    foreach my $s (@CDD::Card::SUITS) {
        for my $ri1 (0 .. 12) {    # lowest rank index
            for my $ri2 (0 .. 12) {
                for my $ri3 (0 .. 12) {
                    for my $ri4 (0 .. 12) {
                        for my $ri5 (0 .. 12) {    # highest rank index
                            my @indices = sort {$a <=> $b} ($ri1, $ri2, $ri3, $ri4, $ri5);
                            my ($i1, $i2, $i3, $i4, $i5) = @indices;
                            if ($i1 == $i2 or $i2 == $i3 or $i3 == $i4 or $i4 == $i5) {
                                next; # impossible combo
                            }
                            if ($i2 == $i1 + 1 and $i3 == $i2 + 1 and $i4 == $i3 + 1 and $i5 == $i4 + 1) {
                                next; # straight flush
                            }
                            my $key = join('', @indices) . "$s";

                            if (exists $flush{$key}) {
                                next;  # already got this one
                            }
                            else {
                                $flush{$key}++;
                                my ($r1, $r2, $r3, $r4, $r5) = @CDD::Card::RANKS[@indices];

                                # there are only 32 cdd values, based on the highest card in a group of each
                                # suit. d,c,h,s; 8 to 2 (8 cards) for each of 4 suits (8*4=32)
                                my $val = ($i5 - 5) + $valsuit->{$s};
                                $VALUE = $start_value + $val;

                                my ($c1, $c2, $c3, $c4, $c5) = ("$r1$s", "$r2$s", "$r3$s", "$r4$s", "$r5$s");
                                push @{$flushes->{$val}}, [$c1, $c2, $c3, $c4, $c5];
                                say "flush: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID" if $VERBOSE > 1;
                                
                                $db->query($SQL_GRP, $GROUPID, 5, 5, $VALUE);
                                $db->query($SQL_GRPAVAIL, $GROUPID);
                                $db->query($SQL_GRPCARD, $GROUPID, $c1);
                                $db->query($SQL_GRPCARD, $GROUPID, $c2);
                                $db->query($SQL_GRPCARD, $GROUPID, $c3);
                                $db->query($SQL_GRPCARD, $GROUPID, $c4);
                                $db->query($SQL_GRPCARD, $GROUPID, $c5);
                                $GROUPID++;
                            }    #else
                        }    #ri1
                    }    #ri2
                }    #ri3
            }    # ri4
        }    #ri5
    }    # suits
    for my $v (1 .. 32) {
        foreach my $group (@{$flushes->{$v}}) {
            push @flushes, $group;
        }
    }
    say "    --> [populated " . scalar(@flushes) . ' flushes]' if $VERBOSE;
    return \@flushes;
}

sub _populate_full_houses {
    my $db = shift;
    my $pairs = shift;
    my $triples = shift;
    say "  * full houses (groupid: $GROUPID, value: $VALUE)" if $VERBOSE;

    my @full_houses = ();
    my $x = 0;
    foreach my $triple (@{$triples}) {
        my ($t1, $t2, $t3) = @{$triple};
        foreach my $pair (@{$pairs}) {
            my ($p1, $p2) = @{$pair};
            my ($tr, $ts, $t_extra) = split //, $t1;
            my ($pr, $ps, $p_extra) = split //, $p1;

            #10 is special case since it has 3 chars...not a 2 char rank/suit
            if ($tr eq '1' and $ts eq '0') {
                $tr = 10;
                $ts = $t_extra;
            }
            if ($pr eq '1' and $ps eq '0') {
                $pr = 10;
                $ps = $p_extra;
            }

            next if $pr eq $tr;
            if ($x ne $tr) {
                $VALUE++;    # value increases as triple changes, low to high
                $x = $tr;
            }
            my ($c1, $c2, $c3, $c4, $c5) = ($t1, $t2, $t3, $p1, $p2);
            push @full_houses, [$c1, $c2, $c3, $c4, $c5];
            say "full house: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID" if $VERBOSE > 1;
            
            $db->query($SQL_GRP, $GROUPID, 5, 6, $VALUE);
            $db->query($SQL_GRPAVAIL, $GROUPID);
            $db->query($SQL_GRPCARD, $GROUPID, $c1);
            $db->query($SQL_GRPCARD, $GROUPID, $c2);
            $db->query($SQL_GRPCARD, $GROUPID, $c3);
            $db->query($SQL_GRPCARD, $GROUPID, $c4);
            $db->query($SQL_GRPCARD, $GROUPID, $c5);
            $GROUPID++;
        }
    }
    say "    --> [populated " . scalar(@full_houses) . ' full houses]' if $VERBOSE;
    return \@full_houses;
}



1;
