use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::Email',
  VERSION_FROM => 'lib/Mojolicious/Plugin/Email.pm',
  AUTHOR       => 'Raul Matei  <raulmatei@cpan.org>',
  PREREQ_PM    => {
     'Mojolicious' => '2.60',
     'Email::MIME' => '1.910',
     'Email::Sender::Simple' => '0.110005',
     'Email::Sender::Transport::Test' => '0.110005',
  },
  test         => {TESTS => 't/*.t'}
);
