#!/usr/bin/perl

use strict;
use warnings;

my %back_buffers;

sub pipe_status {
  my $pipe = shift;
  fcntl($pipe, F_SETFL(), O_NONBLOCK());
  my $bytes_read = sysread($pipe,my $buffer,1,0);
  if (defined $bytes_read) {
    if ($bytes_read == 0) {
      return 'dead';
    }
    else { return $buffer; }
  }
  else {
    return 'later';
  }
}

sub read_lines {
  my ($pipe, $buffer) = @_;
  fcntl($pipe, F_SETFL(), O_NONBLOCK());

  if($back_buffers{$pipe}) {
    $buffer = $back_buffers{$pipe} . $buffer;
  }

  while(my $bytes_read = sysread($pipe,$buffer,1024,length($buffer))) { 1; }
  my @lines = split(/[\r\n]+/,$buffer);

  if($buffer !~ /[\r\n]+$/) { $back_buffers{$pipe} = pop(@lines); }
  else { delete $back_buffers{$pipe}; }

  return @lines;
}



sub generate_timestamps {
  my ($sec,$min,$hour,$mday,$mon,$year,undef,undef,undef) = localtime(time);
  $mon += 1;
  $year += 1900;
  $hour = sprintf("%02d", $hour);
  $min = sprintf("%02d", $min);
  $sec = sprintf("%02d", $sec);
  my $datestamp = "$year-$mon-$mday";
  my $timestamp = "$hour:$min:$sec";
  return $datestamp, $timestamp;
}

sub log_output {
  my ($prefix, $datestamp, $timestamp, $message) = @_;

  unless (&get_core_value('unlogged')) {
    my $filename = &get_config_value('log_directory') . '/' . &get_config_value('base_nick') . "-$datestamp.txt";
    open my $logfile, '>>' . $filename
      or print 'Unable to open logfile "' . $filename . "\".\n" . "Does that directory structure exist?\n";
    print $logfile "$prefix $timestamp $message\015\012";
    close $logfile;
  }
}

sub stdout_output {
  my ($prefix, $timestamp, $message) = @_;
  print "$prefix $timestamp $message\n";
}


#Always logged and displayed
sub error_output {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  log_output('BOTERROR',$datestamp,$timestamp,$message);
  stdout_output('BOTERROR',$timestamp,$message);
}

#Always logged and displayed
sub event_output {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  log_output('BOTEVENT',$datestamp,$timestamp,$message);
  stdout_output('BOTEVENT',$timestamp,$message);
}

#Always logged, but only displayed if --verbose
sub normal_output {
  my ($prefix,$message) = @_;
  my ($datestamp, $timestamp) = &generate_timestamps();
  log_output($prefix,$datestamp,$timestamp,$message);
  if (&get_core_value('verbose')) {
    stdout_output($prefix,$timestamp,$message);
  }
}

#Logged if --debug. Displayed if --verbose and --debug
sub debug_output {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  if (&get_core_value('debug')) {
    log_output('BOTDEBUG',$datestamp,$timestamp,$message);
    if(&get_core_value('verbose')) {
      stdout_output('BOTDEBUG',$timestamp,$message);
    }
  }
}

1;
