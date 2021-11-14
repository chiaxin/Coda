use strict;
use warnings;
use Term::ANSIColor;
use FindBin;
use lib $FindBin::Bin;
use File::Temp qw/tempfile tempdir/;
use ImageCollect;
use Core;

my $FrameRate   = 24;
my $MovieFormat = 'mp4';
my $ImageFormat = 'jpg';
my @Tmp_ARGV = @ARGV;
my $SourceDirectory = pop @Tmp_ARGV;
my %Argv = @Tmp_ARGV;
my $Information = "";

if (exists $Argv{rate}) {
    my $user_frame_rate = $Argv{rate};
    if ($user_frame_rate =~ /\d+/) {
        $FrameRate = $user_frame_rate + 0;
    } else {
        print "Invalid frame rate : $user_frame_rate\n";
        exit(-1);
    }
}
if (exists $Argv{image}) {
    my $user_image_format = $Argv{image};
    my %kAcceptImageFormats = ( jpg => 1, tif => 1, exr => 1 );
    if (exists $kAcceptImageFormats{$user_image_format}) {
        $ImageFormat = $user_image_format;
    } else {
        print "Invalid movie format : $user_image_format\n";
        exit(-2);
    }
}
if (exists $Argv{format}) {
    my %kAcceptFormats = ( mov => 1, mp4 => 1);
    my $user_format = $Argv{format};
    if (exists $kAcceptFormats{$user_format}) {
        $MovieFormat = $user_format;
    } else {
        print "Invalid movie format : $user_format\n";
        exit(-3);
    }
}


my $FFmpeg = Core::get_ffmpeg();

if (!Core::check_ffmpeg_exists()) {
    print "$FFmpeg is not exists!\n";
    exit(-4);
}

my %Formats = Core::get_movie_format_map();
my $Source = $SourceDirectory;
my $Collect = ImageCollect->new($Source, $ImageFormat, $MovieFormat);
my $name_map = $Collect->get_name_map();
my @batch_commands = ();
my @batch_files = ();

foreach my $object (keys %{$name_map}) {
    my $source = $object;
    (my $source_pattern = $source) =~ s/%%04d/####/;
    my $output = $name_map->{$object}->{output};
    my $directory = $Source;
    my @command_parts = ('@ECHO off', "\n");
    push @command_parts, ('pushd', '%CD%', "\n");
    push @command_parts, ('cd', '/d', ${directory}, "\n");
    push @command_parts, (
        "\"${FFmpeg}\"", "-framerate", ${FrameRate}, "-i", "\"${source}\"",
        "-start_number", $name_map->{$object}->{start},
        @{ $Formats{$MovieFormat} }, ${output}, "\n"
    );
    push @command_parts, ('popd', "\n");
    push @batch_commands, join ' ', @command_parts;
    $Information .= "  [== Convert ==] " . 
        colored($output, "yellow") . " from " .
        colored($source_pattern, "cyan") . "\n";
}

sub run
{
    foreach my $command (@batch_commands) {
        my $temp_file = File::Temp->new(
            PREFIX => '_FFmpeg_Convert_', SUFFIX => '.bat'
        );
        open my $file_handle, '>', $temp_file
            or die "Failed to open file : $temp_file - $!";
        print $file_handle $command;
        close $file_handle;
        push @batch_files, $temp_file;
    }

    system $_ foreach @batch_files;
}

print "\n************ ************ ************\n";
print "[*] Search Directory : " . colored($SourceDirectory, "magenta") . "\n";
print "[*] Ready convert movie(s) below :\n";
print $Information;
print "************ ************ ************\n";

my $user_input = "";

while (!$user_input) {
    print colored("[?] Convert movie(s), yes or no? (y|n) :", "green");
    $user_input = <STDIN>;
    chomp $user_input;
    $user_input = lc $user_input;
    if ($user_input eq "y") {
        &run;
        last;
    } elsif ($user_input eq "n") {
        print "OK, bye!\n";
        last;
    } else {
        $user_input = "";
        next;
    }
}
