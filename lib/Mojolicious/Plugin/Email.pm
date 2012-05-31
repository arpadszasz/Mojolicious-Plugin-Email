package Mojolicious::Plugin::Email;
use Mojo::Base 'Mojolicious::Plugin';

use strict;
use warnings;

use Email::MIME;
use Email::Sender::Simple;
use Email::Sender::Transport::Sendmail;


our $VERSION = '0.03';


sub register {
    my ($self, $app, $conf) = @_;

    $app->helper(
        email => sub {
            my $self = shift;
            my $args = @_ ? { @_ } : return;

            my $sendmail = $args->{sendmail} ? $args->{sendmail} : '/usr/sbin/sendmail';

            my @data   = @{ $args->{data} };

            my @parts = Email::MIME->create(
                            body => $self->render_partial(
                                                    @data,
                                                    format => $args->{format}
                                                            ? $args->{format}
                                                            : 'email'
                                    ),
                        );

            my $transport = defined $args->{transport}
                            ? $args->{transport}
                            : Email::Sender::Transport::Sendmail->new({ sendmail => $sendmail });

            my $header = { @{ $args->{header} } };

            $header->{From}    ||= $conf->{from};
            $header->{Subject} ||= $self->stash('title');

            my @header = %{$header};

            my $email = Email::MIME->create(
                            header => \@header,
                            parts  => \@parts,
                        );

            $email->charset_set     ( $args->{charset}      ? $args->{charset}      : 'utf8'      );
            $email->encoding_set    ( $args->{encoding}     ? $args->{encoding}     : 'base64'    );
            $email->content_type_set( $args->{content_type} ? $args->{content_type} : 'text/html' );

            my $emailer = Email::Sender::Simple->try_to_send( $email, { transport => $transport } );

            # If message is sent successfully it will return a true value,
            # if an error ocurred it will return an Email::Sender::Failure object.
            return $emailer; 
        }
    );
}

1;

__END__
