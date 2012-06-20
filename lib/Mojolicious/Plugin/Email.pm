package Mojolicious::Plugin::Email;
use Mojo::Base 'Mojolicious::Plugin';

use strict;
use warnings;

use Email::MIME;
use Email::Sender::Simple;
use Email::Sender::Transport::Test;

our $VERSION = '0.05';


sub register {
  my ($self, $app, $conf) = @_;

  $app->helper(
    email => sub {
      my $self = shift;
      my $args = @_ ? { @_ } : return;


      my @data  = @{ $args->{data} };

      my @parts = Email::MIME->create(
                    body => $self->render_partial(
                                        @data,
                                        format => $args->{format}
                                                ? $args->{format}
                                                : 'email'
                                  )
                  );

      my $transport = defined $args->{transport} || $conf->{transport}
                            ? $args->{transport} || $conf->{transport}
                            : undef;

      my $header = { @{ $args->{header} } };

      $header->{From}    ||= $conf->{from};
      $header->{Subject} ||= $self->stash('title');

      my $email = Email::MIME->create(
                                  header => [ %{$header} ],
                                  parts  => [ @parts ],
                              );

      $email->charset_set     ( $args->{charset}      ? $args->{charset}      : 'utf8'      );
      $email->encoding_set    ( $args->{encoding}     ? $args->{encoding}     : 'base64'    );
      $email->content_type_set( $args->{content_type} ? $args->{content_type} : 'text/html' );

      return Email::Sender::Simple->try_to_send( $email, { transport => $transport } ) if $transport;

      my $emailer = Email::Sender::Transport::Test->new;
      $emailer->send_email(
                  $email,
                  {
                    to   => [ $header->{To} ],
                    from =>   $header->{From}
                  }
                );
      return unless $emailer->{deliveries}->[0]->{successes}->[0];

    }
  );

}

1;

__END__