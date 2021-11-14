use strict;
use warnings;

package MovToMp4;
use utf8;
use FindBin;
use lib $FindBin::Bin;
use Core;
use File::Spec;
use File::Basename;
use File::Path qw/make_path/;

my $FFmpegProgram = Core::get_ffmpeg();

our $IsTest = 0;

binmode(STDOUT, ":encoding(Big5)");

sub new
{
    my $class = shift;
    my $self = {
        source => shift
    };
    $self->{destination} = File::Spec->catfile(
        $self->{source}, "Converted"
    );
    $self->{movies} = [];
    bless $self, $class;
    return $self;
}

sub create_directory
{
    my $self = shift;
    if (!-d $self->{destination}) {
        make_path($self->{destination});
    }
    return $self->{destination};
}

sub get_mov
{
    my $self = shift;
    my $directory = $self->{source};
    @{$self->{movies}} = <"$directory\\*.mov">;
    return scalar @{$self->{movies}};
}

sub number
{
    my $self = shift;
    return scalar @{$self->{movies}};
}

sub quote
{
    return "\"$_[0]\"";
}

sub catfile
{
    return File::Spec->catfile(@_);
}

sub space
{
    return " ";
}

sub convert
{
    my $self = shift;
    my $flags= shift;
    my $rename_function = shift;
    my @commands = ();
    $self->get_mov();
    if ($self->number()) {
        my $destination = $self->create_directory();
        foreach my $video (@{$self->{movies}}) {
            my $converted = basename $video;
            if ($rename_function
            && (ref $rename_function) eq 'CODE') {
                $rename_function->($converted);
            }
            my $full_path = catfile($destination, $converted);
            my @cmd_buffer = (
                quote($FFmpegProgram), "-i", quote($video), $flags, quote($full_path)
            );
            push @commands, join &space, @cmd_buffer;
        }
    } else {
        print "No any *.mov found.\n";
    }
    if ($IsTest) {
        print $_ . "\n" foreach @commands;
    } else {
        system($_) foreach @commands;
    }
}

1;
