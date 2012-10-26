#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket;

sub create_socket_connection {
  my ($server, $port, $nick, $pass) = @_;
  &event_output('I am attempting to connect.');

  my $sock = new IO::Socket::INET(
    PeerAddr => $server,
    PeerPort => $port,
    Proto => 'tcp',
    timeout => 1)
    or die "Error while connecting to $server:$port";

  &event_output('I am attempting to login.');
  print $sock "PASS $nick:$pass\015\012" if($pass);
  print $sock "NICK $nick\015\012";
  print $sock "USER CEQSY 8 * :CEQSY\015\012";

  return $sock;
}

1;
