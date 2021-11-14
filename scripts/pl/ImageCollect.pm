package ImageCollect;
use strict;
use warnings;
use FindBin;
use File::Basename;
use File::Spec;
use Data::Dumper;

sub new
{
    my $class = shift;
    my $self = {
        directory => shift,
        format    => shift || 'jpg',
        output    => shift || 'mov',
        name_map  => { }
    };
    bless $self, $class;
    $self->_search();
    return $self;
}

sub setup_format
{
    my $self = shift;
    my $format = shift;
    if ($format) {
        $self->{format} = $format;
    }
}

sub get_name_map
{
    my $self = shift;
    return $self->{name_map};
}

sub _search
{
    my $self = shift;
    my $ext  = $self->{format};
    my $directory = $self->{directory};
    my $name_map = {};
    if (!-d $directory) {
        warn "Directory is not exists : $directory";
        return 0;
    }
    my @images = map { s/(\\|\/)+/\//r } <${directory}//*.${ext}>;
    foreach my $image (@images) {
        my ($name, $dir, $ext) = fileparse($image);
        if ($name =~ m/\d{4}/p) {
            my $title = ${^PREMATCH} . '%%04d' . ${^POSTMATCH};
            if (exists $name_map->{$title}->{sequence}) {
                push @{$name_map->{$title}->{sequence}}, ${^MATCH} + 0;
            } else {
                $name_map->{$title}->{sequence} = [];
                $name_map->{$title}->{output} = ${^PREMATCH} . $self->{output};
            }
        }
    }
    foreach my $name (keys %{$name_map}) {
        @{ $name_map->{$name}->{sequence} } = sort {
            $a <=> $b 
        } @{$name_map->{$name}->{sequence}};
        $name_map->{$name}->{start} = $name_map->{$name}->{sequence}->[ 0];
        $name_map->{$name}->{end}   = $name_map->{$name}->{sequence}->[-1];
    }
    $self->{name_map} = $name_map;
    return scalar (keys %{$self->{name_map}});
}

1;
