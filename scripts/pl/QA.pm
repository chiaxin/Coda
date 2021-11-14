package Question;
use strict;
use warnings;
use Data::Dumper;

sub new
{
    # Example :
    # Question->new("What is your ages?", [10, 20, 30], "optional");
    # Question->new("What is you sure?", [], "yesOrNo");
    # Question->new("What is your name?", [], "string");
    my $class = shift;
    my $self = {
        Ask =>     shift || "",
        Options => shift || [],
        typ =>     shift || "optional",
        condition => undef,
        help => undef
    };
    bless $self, $class;
    return $self;
}

sub add_condition
{
    my $self = shift;
    my $func = shift;
    $self->{condition} = $func if (ref $func) eq 'CODE';
}

sub add_help
{
    my $self = shift;
    $self->{help} = shift;
}

sub ask_yes_or_no
{
    my $self = shift;
    my $answer = "";
    while ($answer !~ /^(y|n)$/) {
        print $self->{Ask} . " (y/n/q): ";
        $answer = lc <STDIN>;
        chomp $answer;
        last if $answer eq 'q';
    }
    my %values = ( y => 1, n => 0, q => undef );
    return $values{ $answer };
}

sub ask_string
{
    my $self = shift;
    my $answer = "";
    while($answer eq "") {
        print $self->{Ask} . " : ";
        $answer = <STDIN>;
        chomp $answer;
        if (defined $self->{condition}) {
            if (!$self->{condition}->($answer)) {
                print "\n * " . $self->{help} . "\n" if $self->{help};
                $answer = "";
            }
        }
    }
    return $answer;
}

sub ask_options
{
    my $self = shift;
    my $answer = 0;
    my $size_of_options = scalar @{ $self->{Options} };
    while ($answer == 0 || $answer > $size_of_options) {
        print $self->{Ask} . " ";
        foreach my $idx (0 .. scalar @{$self->{Options}} - 1) {
            print "[" . ($idx + 1) . "]" . $self->{Options}->[$idx] . " ";
        }
        print "[q] EXIT : ";
        $answer = <STDIN>;
        chomp $answer;
        next if $answer eq '';
        last if $answer eq 'q';
        $answer = 0 if $answer !~ /^\d+$/;
        $answer += 0;
        print "[Error] The number must in 1 ~ " . $size_of_options . "\n"
            if $answer > $size_of_options;
    }
    return undef if $answer eq 'q';
    return $self->{Options}->[$answer - 1];
}

1;

package QA;
use strict;
use warnings;

sub new
{
    my $class = shift;
    my $self = {
        Questions => []
    };
    bless $self, $class;
    return $self;
}

sub add_quest
{
    my $self = shift;
    my %valid_types = (
        string   => 1,
        optional => 1,
        yesOrNo  => 1
    );
    my ($ask, $opt, $typ, $code, $help) = @_;
    if (exists $valid_types{ $typ }) {
        push @{$self->{Questions}}, Question->new($ask, $opt, $typ);
        $self->{Questions}->[-1]->add_condition($code) if (
            $code && (ref $code) eq 'CODE'
        );
        $self->{Questions}->[-1]->add_help($help) if $help;
    }
    return scalar @{$self->{Questions}};
}

sub get_last
{
    my $self = shift;
    return $self->{Questions}->[-1] if scalar @{$self->{Questions}};
}

sub ask
{
    my $self = shift;
    my @answers = ();

    my $behavior = sub {
        if (defined $_[0]) {
            push @answers, $_[0];
        } else {
            print "Process terminated.\n";
            exit(1);
        }
    };

    foreach my $quest (@{$self->{Questions}}) {
        if ($quest->{typ} eq 'string') {
            $behavior->($quest->ask_string());
        } elsif ($quest->{typ} eq 'optional') {
            $behavior->($quest->ask_options());
        } elsif ($quest->{typ} eq 'yesOrNo') {
            $behavior->($quest->ask_yes_or_no());
        } else {
            print "Unknown quest type : " . $quest->{typ} . "\n";
        }
        return () if !defined $answers[-1];
    }
    return @answers;
}

1;
