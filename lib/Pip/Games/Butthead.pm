{

    package Acme::Butthead;
    use Moose;
    use Text::DoubleMetaphone qw(double_metaphone);

    has wordlist => (
        isa        => 'HashRef',
        is         => 'ro',
        lazy_build => 1,
    );

    my @words =
      qw( anus ass buttocks bugger breasts balls boobs dildo forskin vagina jism penis
      shit piss fuck cunt cocksucker motherfucker tits turd twat );

    sub _build_wordlist {
        my %list = ();
        for my $word (@words) {
            my $meta = double_metaphone($word);
            $list{$word} = qr/$meta/;
        }
        \%list;
    }

    sub check_list {
        my ( $self, $word ) = @_;
        return grep { double_metaphone($word) =~ $self->wordlist->{$_} }
          keys %{ $self->wordlist };
    }

    sub scan {
        my $self   = shift;
        my @return = ();
        for my $word ( map { split /\s+/ } @_ ) {
            push @return, $_ for $self->check_list($word);
        }
        return @return;
    }

    1;
}

package Pip::Games::Butthead;
use Moose;
extends qw(Adam::Plugin);

use Acme::LOLCAT;
use POE::Component::IRC::Plugin qw(PCI_EAT_ALL PCI_EAT_NONE);

has '+events' => ( default => sub { [qw(msg bot_addressed)] }, );

has butthead => (
    isa     => 'Acme::Butthead',
    is      => 'ro',
    default => sub { Acme::Butthead->new() },
    handles => [qw(scan)],
);

sub S_bot_addressed {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    $message = $$message;
    warn 'GOT HERE!';
    my @channels = @{$$channels};
    if ( my $word = $self->scan($message) ) {
        my $joke = $self->get_joke;
        $self->privmsg(
            $_ => translate("uh huh-huh-huh, huh-huh-huh, you said $_") )
          for @channels;
        return PCI_EAT_ALL;
    }
    return PCI_EAT_NONE;
}

sub S_public { shift->S_bot_addressed(@_) }

no Moose;
1;
