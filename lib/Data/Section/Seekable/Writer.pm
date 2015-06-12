package Data::Section::Seekable::Writer;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use overload
    '""'  => 'as_string',
    ;

sub new {
    my $class = shift;

    my $self = bless {@_}, $class;
    $self->{_parts} = {};
    $self->{separator} //= '';
    $self;
}

sub add_part {
    my ($self, $name, $part_content, $extra) = @_;
    die "Name cannot be empty" unless length($name);
    die "Name cannot contain comma" if $name =~ /,/;
    die "Extra cannot contain newline" if defined($extra) && $extra =~ /\R/;
    $self->{_parts}{$name} = [$part_content, $extra];
}

sub as_string {
    my $self = shift;

    my @names = sort keys %{$self->{_parts}};
    my @toc;
    my $content;
    my $offset = 0;
    for my $name (@names) {
        if (@toc && length($self->{separator})) {
            $content .= $self->{separator};
            $offset += length($self->{separator});
        }
        my ($part_content, $extra) = @{ $self->{_parts}{$name} };
        push @toc, "$name,$offset," . length($part_content) .
            (defined($extra) ? ",$extra" : "") . "\n";
        $content .= $part_content;
        $offset += length($part_content);
    }

    join(
        "",
        "Data::Section::Seekable v1\n",
        @toc,
        "\n",
        $content,
    );
}

1;
# ABSTRACT: Generate data section with multiple parts

=head1 SYNOPSIS

In your script:

 use Data::Section::Seekable::Writer;

 my $writer = Data::Section::Seekable::Writer->new;

 $writer->add_part(part1 => "This is part1\n");
 $writer->add_part(part2 => This is part\ntwo\n");
 print "__DATA__\n", $writer;

will print:

 __DATA__
 Data::Section::Seekable v1
 part1,0,14
 part2,14,17

 This is part1
 This is part
 two


=head1 DESCRIPTION

This class lets you generate data section which can contain multiple part in the
format described by L<Data::Section::Seekable>.


=head1 METHODS

=head2 new(%attrs) => obj

Constructor. Attributes:

=over

=item * separator => str (default: '')

=back

=head2 $writer->add_part($name => $content)

=head2 $writer->as_string => str


=head1 SEE ALSO

L<Data::Section::Seekable> for the description of the data format.

L<Data::Section::Seekable::Reader> for the reader class.
