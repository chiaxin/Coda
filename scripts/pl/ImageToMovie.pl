use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use File::Spec;
use QA;

=head1 do_it()

    Run "ConvertImageToMovie.pl" with arguments.

=cut

sub do_it
{
    my $ConvertScript = File::Spec->catfile(
        $FindBin::Bin, 'ConvertImageToMovie.pl'
    );
    local @ARGV = @_;
    # system("perl \"$ConvertScript\" " . join " ", @_);
    if (-f $ConvertScript) {
        do $ConvertScript;
    } else {
        die "$ConvertScript is not exsits!\n";
    }
}

=head1 user_interactive()

    Asking user about convert infomation,
    and collect them to run convert script.

    no arguments.

=cut

sub user_interactive
{
    my $_QA = QA->new();
    $_QA->add_quest(
        "Please paste your source directory here",
        [], "string", sub { -d $_[0] }, "Please enter exists directory"
    );
    $_QA->add_quest(
        "Please input frame rate",
        [], "string", sub { $_[0] > 0 && $_[0] <= 60 },
        "Please enter frame rate from 1 ~ 60"
    );

    $_QA->add_quest(
        "Which image format you want to conver?",
        ['jpg', 'tif', 'exr'], 'optional'
    );
    $_QA->add_quest(
        "Which movie format you want to output?",
        ['mp4', 'mov'], 'optional'
    );
    my @receive = $_QA->ask();
    if (-d $receive[0]) {
        if ($receive[1] =~ /^\d+$/) {
            &do_it(
                'rate', $receive[1],
                'image', $receive[2],
                'format', $receive[3],
                $receive[0],
            );
        } else {
            print "[Error] Frame rate not is numbers : " . $receive[1] . "\n";
        }
    } else {
        print "[Error] Directory is not exists : " . $receive[0] . "\n";
    }
}

sub main
{
    user_interactive();
}

main();
