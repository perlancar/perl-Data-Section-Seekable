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
    $self->empty;
    $self->{separator} //= '';
    $self;
}

sub empty {
    my $self = shift;
    $self->{_toc} = [];
    $self->{_content} = '';
    $self->{_part_names} = {};
}

sub separator {
    my $self = shift;
    $self->{separator} = $_[0] if @_;
    $self->{separator};
}

sub add_part {
    my ($self, $name, $content, $extra) = @_;
    die "Name cannot be empty" unless length($name);
    die "Name cannot contain comma/newline" if $name =~ /,|\R/;
    die "Extra cannot contain newline" if defined($extra) && $extra =~ /\R/;

    die "Duplicate part name '$name'" if $self->{_part_names}{$name}++;

    if (keys(%{$self->{_part_names}}) > 1 && length($self->{separator})) {
        $self->{_content} .= $self->{separator};
    }
    push @{ $self->{_toc} }, [
        $name,
        length($self->{_content}),
        length($content),
        $extra,
    ];
    $self->{_content} .= $content;
}

sub as_string {
    my $self = shift;

    die "You must first add one or more parts" unless @{ $self->{_toc} };

    join(
        "",
        "Data::Section::Seekable v1\n",
        (map {"$_->[0],$_->[1],$_->[2]".(defined($_->[3]) ? ",$_->[3]":"")."\n"}
             @{ $self->{_toc} }),
        "\n",
        $self->{_content},
    );
}

1;
# ABSTRACT: Generate data section with multiple parts

=head1 SYNOPSIS

In your script:

 use Data::Section::Seekable::Writer;

 my $writer = Data::Section::Seekable::Writer->new;

 $writer->add_part(part1 => "This is part1\n");
 $writer->add_part(part2 => This is part\ntwo\n", "very,important");
 print "__DATA__\n", $writer;

will print:

 __DATA__
 Data::Section::Seekable v1
 part1,0,14
 part2,14,17,very,important

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

Get the final data section as string. You can also use the object as a string,
e.g.:

 print $writer;

because this method is used for stringification overloading.

=head2 $writer->separator([ $val ]) => str

Get/set separator.

=head2 $writer->empty

Empty content.


=head1 SEE ALSO

L<Data::Section::Seekable> for the description of the data format.

L<Data::Section::Seekable::Reader> for the reader class.
