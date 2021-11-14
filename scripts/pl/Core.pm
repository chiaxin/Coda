package Core;
use strict;
use warnings;
use File::Spec;
use File::Basename;
use FindBin;

my $ProgramDirectory = File::Spec->catfile(
    dirname(dirname($FindBin::Bin)), "bin"
);

(my $FFmpegProgram = File::Spec->catfile($ProgramDirectory, "ffmpeg.exe")
) =~ s/(\\|\/)+/\//;

my %MovieFormats = (
    mov => [
        '-pattern_type', 'glob', '-vcodec', 'qtrle', '-pix_fmt', 'yuv420p'
    ],
    mp4 => [
        '-pattern_type', 'glob', '-vcodec', 'libx264', '-pix_fmt', 'yuv420p'
    ],
);

sub check_ffmpeg_exists
{
    return -f $FFmpegProgram;
}

sub get_ffmpeg
{
    return $FFmpegProgram;
}

sub get_movie_format_map
{
    return %MovieFormats;
}

1;
