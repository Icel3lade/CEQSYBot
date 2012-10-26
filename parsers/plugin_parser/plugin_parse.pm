use strict;
use warnings;
use Data::Dumper;
#use Time::HiRes;
use permissions; # include the permissions.pm file

my $have_output = 0;

my $events = {
  'server_ping' => \&on_ping,
  'private_message' => \&on_private_message,
  'public_message' => \&on_public_message,
  'private_notice' => \&on_private_notice,
  'public_notice' => \&on_public_notice,
  'join' => \&on_join,
  'part' => \&on_part,
  'quit' => \&on_quit,
  'mode' => \&on_mode,
  'nick' => \&on_nick,
  'kick' => \&on_kick,
  'server_message' => \&on_server_message,
  'error' => \&on_error
};

sub startup_variables {
  my $pipe_id = <STDIN>;
  my $bot_name = <STDIN>;
  my $incoming_message = <STDIN>;
  $pipe_id =~ s/[\r\n\s\t]+$//;
  $bot_name =~ s/[\r\n\s\t]+$//;
  $incoming_message =~ s/[\r\n\s\t]+$//;
  return ($pipe_id, $bot_name, $incoming_message);
}

sub fetch_server_variables {
    ACT('LITERAL',undef,'get_config_value>Server_PREFIX');
    my $server_prefix = <STDIN>;
    $server_prefix =~ s/[\r\n\t\s]+$//;
    
    ACT('LITERAL',undef,'get_config_value>Server_MODES');
    my $server_modes = <STDIN>;
    $server_modes =~ s/[\r\n\t\s]+$//;
    
    ACT('LITERAL',undef,'get_config_value>Server_CHANTYPES');
    my $server_chantype = <STDIN>;
    $server_chantype =~ s/[\r\n\t\s]+$//;

    ACT('LITERAL',undef,'get_config_value>Server_NETWORK');
    my $server_network = <STDIN>;
    $server_network =~ s/[\r\n\t\s]+$//;

    # Set defaults if servers variables aren't known yet.
    $server_prefix = "(ov)@+" if(!$server_prefix);
    $server_modes = "4" if(!$server_modes);
    $server_chantype = "#" if(!$server_chantype);
    $server_network = "freenode" if(!$server_network);
    
    return ($server_chantype, $server_prefix, $server_modes, $server_network);
}

sub regex_escape {
    my $string = $_[0];
    $string =~ s/\\/\\\\/g; # escape \
    $string =~ s/\./\\\./g; # escape .
    $string =~ s/\[/\\\[/g; # escape [
    $string =~ s/\^/\\\^/g; # escape ^
    $string =~ s/\$/\\\$/g; # escape $
    $string =~ s/\|/\\\|/g; # escape |
    $string =~ s/\?/\\\?/g; # escape ?
    $string =~ s/\+/\\\+/g; # escape +
    $string =~ s/\*/\\\*/g; # escape *
    $string =~ s/\(/\\\(/g; # escape (
    $string =~ s/\)/\\\)/g; # escape )
    $string =~ s/\{/\\\{/g; # escape {
    $string =~ s/\}/\\\}/g; # escape }
    return $string;
}
sub CheckPerm {
    my ($nickname, $Nickname, $perm, $channame, $Channame, $target);
    $nickname = lc $_[0];
    $Nickname = $_[0]; # Original case
    $perm = lc $_[1];
    $channame = lc $_[2];
    $Channame = $_[2]; # Original case
    $target = lc $_[3];
    my $print = ($_[4]?1:0);
  
    my @useraccess = permissions::get_permissions();
    
    my $w_result = DoWhois($nickname,"force");
    #DEBUG:
    #Whois_print_all($nickname);
    
    my $w_status = ((Whois_get('status',$nickname) eq '311')?1:0);

    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>CheckPerm w_result: ".$w_result." and w_status: ".$w_status.".");

    
    if ($w_result && $w_status) {
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>Requested CheckPerm for ".$Nickname." in ".$Channame." with permissions ".$perm.".");
        
        my $ident = Whois_get('ident',$nickname);
        my $hostmask = Whois_get('hostmask',$nickname);
        my $account = Whois_get('account',$nickname);
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>Requested CheckPerm for user: ".$Nickname."!".$ident."@".$hostmask." with account: ".$account.".");
     
        for (my $i=0; $i < scalar(@useraccess); $i++) {
            my $userfound = 0;
            my (%uar, @w_accounts, @w_nicks, @w_idents, @w_hosts, %w_perms);
            %uar = %{$useraccess[$i]};
            @w_accounts = @{$uar{'account'}};
            @w_nicks = @{$uar{'nick'}};
            @w_idents = @{$uar{'ident'}};
            @w_hosts = @{$uar{'host'}};
            %w_perms = %{$uar{'perm'}};
                  
            foreach my $w_account (@w_accounts) {
                if((lc $w_account) eq $account) {
                    #DEBUG:
                    #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Found Account: $w_account");
                    $userfound = 1;
                }
            }
            if(!$userfound) {
                foreach my $w_nick (@w_nicks) {
                    $w_nick = regex_escape($w_nick);
                    $w_nick =~ s/\\\*/(.*)/g;
                    #DEBUG:
                    #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Trying Nick: ".$w_nick);
                    if($nickname =~ /^$w_nick$/i ) { #TODO convert to regex for wildcards ie "ceq*" matches "ceqsy" and "ceqcibot"
                        #DEBUG:
                        #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Found Nick: ".$w_nick);
                        foreach my $w_ident (@w_idents) {
                            $w_ident = regex_escape($w_ident);
                            $w_ident =~ s/\\\*/(.*)/g;
                            #DEBUG:
                            #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Trying Ident: ".$w_ident);
                            if($ident =~ /^~?$w_ident$/i ) { #TODO convert to regex for wildcards ie "ceqsy*" matches "ceqsy" and "ceqsybot"
                                #DEBUG:
                                #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Found Ident: ".$w_ident);
                                foreach my $w_host (@w_hosts) {
                                    #DEBUG:
                                    #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Trying Host: ".$w_host);
                                    $w_host = regex_escape($w_host);
                                    $w_host =~ s/\\\*/(.*)/g;
                                    #DEBUG:
                                    #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Trying Host: ".$w_host);
                                    if($hostmask =~ /^$w_host$/i ) { #TODO convert to regex for wildcards ie "*.dynamic.*.nl" matches both "541B99FC.cm-5-4c.dynamic.ziggo.nl" and "something.dynamic.somesite.nl"
                                        #DEBUG:
                                        #ACT('LITERAL',undef,"log>COOKIES>CheckPerm: Found Host: ".$w_host);
                                        $userfound = 1;
                                    }
                                    last if ($userfound); # break out of loop as we have a match
                                }
                            }
                            last if ($userfound); # break out of loop as we have a match
                        }
                    }
                    last if ($userfound); # break out of loop as we have a match
                }
            }
            if ($userfound) {
                my $permfound = 0;
                foreach my $w_chan ( keys %w_perms ) {
                    my $w_chan_reg = regex_escape($w_chan);
                    $w_chan_reg =~ s/\\\*/(.*)/g;
                    #DEBUG:
                    #ACT('MESSAGE',$target,"Trying Channel: ".$w_chan_reg);
                    if($channame =~ /^${w_chan_reg}$/i ) {
                        if($perm eq "list") {
                            ACT('MESSAGE',$target,"Permissions in $w_chan: @{$w_perms{$w_chan}}") if ($print);
                            $permfound = 1;
                        } else {
                            my %permshash = map { $_ => 1 } @{$w_perms{(lc $w_chan)}};
                            if((exists $permshash{$perm}) || (exists $permshash{'all'})) {
                                ACT('MESSAGE',$target,$Nickname." has '".$perm."' permissions in ".$w_chan.".") if ($print);
                                $permfound = 1;
                            }
                        }
                    }
                }
                if($permfound) {
                    return 1;
                }
            }
        }
        if($perm eq "list") {
            ACT('MESSAGE',$target,$Nickname." does not have permissions in ".$Channame.".");
        } else {
            ACT('MESSAGE',$target,$Nickname." does not have '".$perm."' permissions in ".$Channame.".");
        }
        return 0;
    } else {   
        # Whois failed, user data unavailable
        ACT('MESSAGE',$target,"Either ".$Nickname." is offline, the user does not exist, or the permission check failed.");
        return 0;
    }
}

sub CheckOps {
    my $chanstr = (lc $_[0]);
    ACT('LITERAL',undef,'get_variable_value>mode_'.$chanstr.'_op');
    my $resultmsg = <STDIN>;
    $resultmsg =~ s/[\r\n\t\s]+$//;
    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>CheckOps: Bot is OP of $chanstr? $resultmsg");
    return (($resultmsg eq "true")? 1 : 0);
}

sub CheckVoice {
    my $chanstr = (lc $_[0]);
    ACT('LITERAL',undef,'get_variable_value>mode_'.$chanstr.'_voice');
    my $resultmsg = <STDIN>;
    $resultmsg =~ s/[\r\n\t\s]+$//;
    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>CheckOps: Bot has VOICE in $chanstr? $resultmsg");
    return (($resultmsg eq "true")? 1 : 0);
}

sub DoWhois {
    my $nick = (lc $_[0]);
    my $forcewhois = (($_[1] && ($_[1] eq "force"))? 1 : 0);
    
    my $home_folder = $FindBin::RealBin;
    
    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>Whois requested for ".$nick);
    
    ACT('LITERAL',undef,'get_variable_value>whois_latesttime');
    my $whoislatesttimeresult = <STDIN>;
    $whoislatesttimeresult =~ s/[\r\n\t\s]+$//;

    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>Checking ifstatement ".$whoislatesttimeresult. "> ".(time - $whoislatesttimeresult)." >> ".$forcewhois. "<<");
    if (!$whoislatesttimeresult || ((time - $whoislatesttimeresult) > 5) || $forcewhois) { # if latest whois was done more than 5 seconds ago

        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>LOCK Semaphore");
        
        #Disallow any other lines to do a whois while the bot is still working on it.
        open (SEMADOWHOIS, "> $home_folder/whois.sem") or die ("Can't open semaphore $!\n");
        flock SEMADOWHOIS, LOCK_EX or die ("Can't lock semaphore $!\n");

        ACT('LITERAL',undef,'get_variable_value>whois_'.$nick.'_time');
        my $whoistimeresult = <STDIN>;
        $whoistimeresult =~ s/[\r\n\t\s]+$//;

        if (!$whoistimeresult || ((time - $whoistimeresult) > 5)) { # if whois was done more than 5 seconds ago
            #ACT('LITERAL',undef,'clear_variable_value>whois_'.$nick.'_time'); # clear lastwhois for $nick
            Whois_clear_all($nick);
            ACT('LITERAL',undef,'set_variable_value>whois_latesttime>'.time); # reset latest timestamp
            ACT('LITERAL',undef,"send_server_message>WHOIS $nick"); # fetch 'fresh' whois info for $nick
        }
        #DEBUG:
        #Whois_print_all($nick);
        ACT('LITERAL',undef,'get_variable_value>whois_'.$nick.'_time');
        $whoistimeresult = <STDIN>;
        $whoistimeresult =~ s/[\r\n\t\s]+$//;
        
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>$nick: Waiting for whois results... lastwhois: $whoistimeresult");
        
        my $k=0;
        while(!$whoistimeresult && $k<25) {
            
            ACT('LITERAL',undef,'get_variable_value>whois_'.$nick.'_time');
            $whoistimeresult = <STDIN>;
            $whoistimeresult =~ s/[\r\n\t\s]+$//;
            
            #DEBUG:
            #ACT('LITERAL',undef,"log>COOKIES>$nick: Waiting $k: $whoistimeresult");
            #DEBUG:
            #Whois_print_all($nick);
            
            $k++;
            #Time::HiRes::sleep(0.2); #0.2 seconds
            #while(defined select(undef,undef,undef,0.2)) {} #0.2 seconds
            select(undef,undef,undef,0.2)
        }
        # if we're out of the while loop, then we finally received a whoisresult that is up to date, or we waited for more than 5 seconds
        
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>$nick: End of loop: $k: $whoistimeresult");
                
        # Unlock semaphore
        flock SEMADOWHOIS, LOCK_UN;
        close (SEMADOWHOIS);
        
        if ($k >= 25) { # whois timed out
            #DEBUG:
            #ACT('LITERAL',undef,"log>COOKIES>Whois Timed out");
            return 0;
        } else {        # whois completed, results available in variables.
            #DEBUG:
            #ACT('LITERAL',undef,"log>COOKIES>Whois Completed");
            return 1;
        }
    } else { # latest whois was less than 5 seconds ago
        # DoWhois failed.
        return 0;
    }
}

sub Whois_clear_all {
    my $nickname = lc $_[0];
    
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_time');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_status');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_ident');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_hostmask');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_realname');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_server');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_account');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_hostip');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_idletime');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_signon');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_channels');
    ACT('LITERAL',undef,'clear_variable_value>whois_'.$nickname.'_secure');
}
sub Whois_print_all {
    my $nickname = lc $_[0];
       
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: $nickname");
    
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _ident: ".Whois_get('ident',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _hostmask: ".Whois_get('hostmask',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _realname: ".Whois_get('realname',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _server: ".Whois_get('server',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _secure: ".Whois_get('secure',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _account: ".Whois_get('account',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _hostip: ".Whois_get('hostip',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _idletime: ".Whois_get('idletime',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _signon: ".Whois_get('signon',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _time: ".Whois_get('time',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _channels: ".Whois_get('channels',$nickname));
    ACT('LITERAL',undef,"log>COOKIES>WHOIS_PRINT: _status: ".Whois_get('status',$nickname));
}    
    
sub Whois_get {
    my $value = lc $_[0];
    my $nickname = lc $_[1];
    ACT('LITERAL',undef,'get_variable_value>whois_'.$nickname.'_'.$value);
    my $resultmsg = <STDIN>;
    $resultmsg =~ s/[\r\n\t\s]+$//;
    return $resultmsg;
}

sub have_output {
  return $have_output;
}

sub ACT {
  my @unsafeargs = @_;
  my @args;
  foreach my $current_arg (@unsafeargs) {
    $current_arg =~ s/[\r\n]+/ / if ($current_arg);
    push (@args,$current_arg);
  }
  if ($_[0] eq 'MESSAGE')       { print "send_server_message>PRIVMSG ".(($args[1])?"$args[1] ":"").":".(($args[2])?"$args[2]":"")."\n"; }
  elsif ($_[0] eq 'ACTION')     { print "send_server_message>PRIVMSG ".(($args[1])?"$args[1] ":"").":ACTION ".(($args[2])?"$args[2]":"")."\n"; }
  elsif ($_[0] eq 'NOTICE')     { print "send_server_message>NOTICE ".(($args[1])?"$args[1] ":"").":".(($args[2])?"$args[2]":"")."\n"; }
  elsif ($_[0] eq 'PART')       { print "send_server_message>PART ".(($args[1])?"$args[1] ":"").":".(($args[2])?"$args[2]":"")."\n"; }
  elsif ($_[0] eq 'INVITE')     { print "send_server_message>INVITE ".(($args[1])?"$args[1] ":"").":".(($args[2])?"$args[2]":"")."\n"; }
  elsif ($_[0] eq 'JOIN')       { print "send_server_message>JOIN ".(($args[1])?"$args[1]":"")."\n"; }
  elsif ($_[0] eq 'MODE')       { print "send_server_message>MODE ".(($args[1])?"$args[1] ":"").(($args[2])?"$args[2] ":"").(($args[3])?"$args[3] ":"").(($args[4])?"$args[4] ":"").(($args[5])?"$args[5]":"")."\n"; }
  elsif ($_[0] eq 'TOPIC')      { print "send_server_message>TOPIC ".(($args[1])?"$args[1] ":"").":".(($args[2])?"$args[2]":"")."\n"; }
  elsif ($_[0] eq 'KICK')       { print "send_server_message>KICK ".(($args[1])?"$args[1] ":"").(($args[2])?"$args[2] ":"").":".(($args[3])?"$args[3]":"")."\n"; }
  elsif ($_[0] eq 'LITERAL')    { print "".(($args[2])?"$args[2]":"")."\n"; }
  $have_output = 1;
}

sub fire_event {
  my $event = shift;
  $events->{$event}->();
}

sub parse_message {
  my ($self, $incoming_message) = @_;
  
  #DEBUG:
  #ACT('LITERAL',undef,"log>COOKIES>PARSE_MESSAGE: $self «» $incoming_message");

  my $valid_nick_characters = 'A-Za-z0-9[\]\\`_^{}|-';
  my $valid_chan_characters = "#$valid_nick_characters";
  my $valid_human_sender_regex = "([.$valid_nick_characters]+)!~?([.$valid_nick_characters]+)@(.+?)";

  my ($sender, $ident, $hostname, $command, $target, $message);
  my $event;
  my $receiver;

  if ($incoming_message =~ /^PING(.*)$/i) {
    ACT('LITERAL',undef,"send_server_message>PONG$1");
    ($sender, $ident, $hostname, $command, $target, $message) = ('', '', '', '', '', '');
    $event = 'server_ping';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (PRIVMSG) ([$valid_chan_characters]+) :(.+)$/) {
    ($sender, $ident, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    if ($target eq $self) { $event = 'private_message'; $target = $sender; }
    else { $event = 'public_message'; }
    $receiver = $sender;
    if ($message =~ /@ ?([, $valid_nick_characters]+)$/) {
      $receiver = $1;
      $message =~ s/ ?@ ?([, $valid_nick_characters]+)$//;
    }
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (NOTICE) ([$valid_chan_characters]+) :(.+)$/) {
    ($sender, $ident, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    if ($target eq $self) { $event = 'private_notice'; $target = $sender; }
    else { $event = 'public_notice'; }
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (JOIN) :?([$valid_chan_characters]+)$/) {
    ($sender, $ident, $hostname, $command, $target) = ($1, $2, $3, $4, $5);
    $message = '';
    $event = 'join';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (PART) ([$valid_chan_characters]+) ?:?(.+)?$/) {
    ($sender, $ident, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    $message = '' unless $message;
    $event = 'part';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (QUIT) :(.+)?$/) {
    ($sender, $ident, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
    $target = '';
    $event = 'quit';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (MODE) ([$valid_chan_characters]+) (.+)$/) {
    ($sender, $ident, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    #ACT('LITERAL',undef,"log>APIERROR>$incoming_message");
    $event = 'mode';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (NICK) :(.+)$/) {
    ($sender, $ident, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
    $target = '';
    $event = 'nick';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (KICK) ([$valid_chan_characters]+) ?:?(.+)?$/) {
    ($sender, $ident, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    $message = '' unless $message;
    $event = 'kick';
  }

  elsif ($incoming_message =~ /^:(.+?) ([a-zA-Z0-9]+) (.+?) :?(.+)$/) {
    ($sender, $ident, $hostname, $command, $target, $message) = ($1, $1, $1, $2, $3, $4);
    #ACT('LITERAL',undef,"log>COOKIES>$incoming_message");
    $event = 'server_message';
  }

  elsif ($incoming_message =~ /^ERROR :(.+)$/) {
    ($sender, $ident, $hostname, $command, $target, $message) = ('','','','','',$1);
    $event = 'error';
  }

  else {
    ACT('LITERAL',undef,"log>APIERROR>Message did not match preparser.");
    ACT('LITERAL',undef,"log>APIERROR>$incoming_message");
    exit();
  }

  return ($event, $sender, $ident, $hostname, $command, $target, $message, $receiver);
}
