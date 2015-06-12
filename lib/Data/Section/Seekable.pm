package Data::Section::Seekable;

# DATE
# VERSION

1;
# ABSTRACT: Read and write parts from data section

=head1 DESCRIPTION

This module defines a simple format to let you store and read parts from data
section. The distribution also comes with a reader (see
L<Data::Section::Seekable::Reader>) and a writer/generator (see
L<Data::Section::Seekable::Writer>).

Like L<Data::Section>, the format allows you to store multiple parts in data
section. This module's format is different from Data::Section's and is meant to
allow seeking to any random content part just by reading the index/"table of
content" part of the data section.


=head1 FORMAT

First line of data section is the header line and must be:

 Data::Section::Seekable v1

After the header line, comes one or more TOC ("table of content") lines. Each
TOC line must match:

 ([^,]+),(\d+),(\d+)

The first field is the name, the second field is the offset, the third field is
the length. Offset starts from 0 and the zero is counted from after the blank
line after the last TOC line.

After the last TOC line is a blank line. And after that is content.

Example:

 Data::Section::Seekable v1
 part1,0,14
 part2,14,17

 This is part1
 This is part
 two


=head1 SEE ALSO

L<Data::Section>
