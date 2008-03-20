package Pip::Time;
use Moose;
use base qw(Adam::Plugin);

use Acme::LOLCAT;
use DateTime;
use DateTime::Format::Human;
use POE::Component::IRC::Plugin qw(PCI_EAT_ALL PCI_EAT_NONE);
use Regexp::Common qw(pattern);

pattern
  name   => [qw[COMMAND what_time -keep]],
  create => qq[^what time is it(?: in (?k:\\w{3}))?],
  ;

has formatter => (
    isa     => 'DateTime::Format::Human',
    is      => 'ro',
    default => sub {
        DateTime::Format::Human->new(
            evening => 19,
            night   => 23,
        );
    },
    handles => [qw(format_datetime)],
);

sub get_time {
    my ( $self, $tz ) = @_;
    my $time = $_[0]->format_datetime(DateTime->now( time_zone => $tz ));
    translate( "it is $time " . ($tz ? "in $tz" : 'where I am' ));
}

sub S_bot_addressed {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    $message = $$message;
    my @channels = @{$$channels};
    if ( $message =~ $RE{COMMAND}{what_time}{-i}{-keep} ) {
        $self->privmsg( $_ => $self->get_time($1) ) for @channels;
        return PCI_EAT_ALL;
    }
    return PCI_EAT_NONE;
}

sub S_public { shift->S_bot_addressed(@_) }

no Moose;
1;
