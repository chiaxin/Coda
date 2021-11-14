use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use MovToMp4;

my $Input = $ARGV[0];

if (exists $ARGV[0] && -d $ARGV[0]) {
    my $Converter = MovToMp4->new($ARGV[0]);
    $Convert->do_it();
}

