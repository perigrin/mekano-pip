package Pip::Games::BarJoke;
use Moose;
extends qw(Adam::Plugin);

use Acme::LOLCAT;
use POE::Component::IRC::Plugin qw(PCI_EAT_ALL PCI_EAT_NONE);
use XML::RSS::LibXML;
use LWP::Simple;
use Regexp::Common qw(pattern);

pattern
  name   => [qw[COMMAND barjoke]],
  create => q[^(?:tell me a )?bar\s*joke],
  ;

has '+events' => ( default => sub { [qw(msg bot_addressed)] }, );

has rss_parser => (
    isa     => 'XML::RSS::LibXML',
    is      => 'ro',
    default => sub { XML::RSS::LibXML->new() },
    handles => [qw(parse)],
);

has feed_url => (
    isa     => 'Str',
    is      => 'ro',
    default => sub { 'http://downlode.org/Code/Perl/RSS/barjoke.cgi' },
);

sub get_joke {
    my $raw  = get( $_[0]->feed_url );
    my $item = $_[0]->parse($raw)->items->[0];
    my $joke = $item->{title};
    return translate($joke);
}

sub S_msg {
    my ( $self, $irc, $nickstring, $to, $message ) = @_;
    $message = $$message;
    my ($nick) = split /!/, $nickstring;
    if ( $message =~ $RE{COMMAND}{barjoke}{-i} ) {
        $self->privmsg( $nick => $self->get_joke );
        return PCI_EAT_ALL;
    }
    return PCI_EAT_NONE;
}

sub S_bot_addressed {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    $message = $$message;
    my @channels = @{$$channels};
    if ( $message =~ $RE{COMMAND}{barjoke}{-i} ) {
        my $joke = $self->get_joke;
        $self->privmsg( $_ => $self->get_joke ) for @channels;
        return PCI_EAT_ALL;
    }
    return PCI_EAT_NONE;
}

sub S_public { shift->S_bot_addressed(@_) }

no Moose;
1;
