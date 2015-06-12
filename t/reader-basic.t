#!perl

use 5.010;
use strict;
use warnings;

use Test::Exception;
use Test::More 0.98;

use Data::Section::Seekable::Reader;

my $reader = Data::Section::Seekable::Reader->new;
is($reader->read_part('part1'), "This is part1\n", "part1 content");
is($reader->read_part('part2'), "This is part\ntwo\n", "part2 content");
dies_ok { $reader->read_part('part3') } "attempt to read unknown part -> dies";

done_testing;

__DATA__
Data::Section::Seekable v1
part1,0,14
part2,14,17

This is part1
This is part
two
