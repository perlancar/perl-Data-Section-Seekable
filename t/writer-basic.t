#!perl

use 5.010;
use strict;
use warnings;

use Test::Exception;
use Test::More 0.98;

use Data::Section::Seekable::Writer;

{
    my $writer = Data::Section::Seekable::Writer->new;
    $writer->add_part(part1 => "This is part1\n");
    $writer->add_part(part2 => "This is part\ntwo\n");

    dies_ok { $writer->add_part('' => "foo") } "part name must not be empty";
    dies_ok { $writer->add_part('a,b' => "foo") } "part name must not contain comma";

    is($writer->as_string, <<'_');
Data::Section::Seekable v1
part1,0,14
part2,14,17

This is part1
This is part
two
_
}

{
    my $writer = Data::Section::Seekable::Writer->new(separator=>"==\n");
    is($writer->separator, "==\n", "separator 1");
    $writer->add_part(b => "This is part1\n");
    $writer->add_part(a => "This is part\ntwo\n", "extra");
    $writer->separator(">>\n");
    is($writer->separator, ">>\n", "separator 2");
    $writer->add_part(c => "");
    dies_ok { $writer->add_part("c" => "") } "add duplicate name -> dies";
    dies_ok { $writer->add_part("d\n" => "") } "part name cannot contain newline";
    dies_ok { $writer->add_part(e => "", "extra\n") } "extra cannot contain newline";

    is($writer->as_string, <<'_');
Data::Section::Seekable v1
b,0,14
a,17,17,extra
c,37,0

This is part1
==
This is part
two
>>
_
}

done_testing;
