# This module parses both server_messages and mode_messages!

#DEBUG: Causes flooding!
#ACT('MESSAGE',"#ceqsy","EVENT: $event, SENDER: $sender, ACCOUNT: $account, HOSTNAME: $hostname, COMMAND: $command, TARGET: $target, MESSAGE: $message");
#ACT('LITERAL',undef,"log>COOKIES>EVENT: $event, SENDER: $sender, ACCOUNT: $account, HOSTNAME: $hostname, COMMAND: $command, TARGET: $target, MESSAGE: $message");

# It uses MODE messages to update the bot's current permissions, and if it senses a possible conflict, uses WHOIS data to use the server's setting.
if ($event eq 'mode') { 
    if ($message =~ /^((?:[+-][opsitnbv]+)+)((?:\s+(?:[$valid_nick_characters]+))+)$/i) {
        my $modestr = $1;
        my $nickstr = $2;
        $target = (lc $target);
        #DEBUG:
        #ACT('MESSAGE',"#ceqsy","DEBUG: 1:$1, 2:$2, 3:$3, 4:$4, 5:$5, 6:$6, 7:$7, 8:$8, 9:$9, 10:$10, 11:$11, 12:$12");
        
        my $prefixchars = $server_prefix;
        $prefixchars =~ s/[\r\n\t\s]+$//;
        
        my $modecount = $server_modes;
        $modecount =~ s/[\r\n\t\s]+$//;
        
        my (%prefixes, @modetokens, @modetokenperms, @nicklist);
        
        if ($prefixchars =~ /^\((.+)\)(.+)$/i) { #ex. "(ov)@+"
            for(my $i = 0; $i < length($1); $i++) {
                my $mchar = substr($1,$i-1,1);
                my $msymb = substr($2,$i-1,1);
                if ($msymb =~ /[\[\\\^\$\.\|\?\*\+\(\)\{\}]/i ) {
                    #DEBUG:
                    #ACT('LITERAL',undef,"log>COOKIES>padding: $msymb");
                    $msymb = "\\".$msymb;
                    #DEBUG:
                    #ACT('LITERAL',undef,"log>COOKIES>padded: $msymb");
                }
                $prefixes{$mchar} = $msymb;
            }
        }
        #DEBUG:
        #ACT('MESSAGE','#ceqsy','o:'.$prefixes{'o'}.'  v:'.$prefixes{'v'}.'  h:'.$prefixes{'h'});
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>o:$prefixes{'o'} v:$prefixes{'v'} h:$prefixes{'h'}");

        while( $modestr =~ /(([\+-])([opsitnbv]+))/gi ) {
            #DEBUG:
            #ACT('MESSAGE',"#ceqsy","perms found: $1,$2,$3");
            #DEBUG:
            #ACT('LITERAL',undef,"log>COOKIES>perms found: $1,$2,$3");
        my $tchar = $2;
            foreach my $perm (split(//, $3)) {
                if($perm =~ /[ohv]/i) { #ignore other characters as psitn and b don't affect nicknames.
                    #DEBUG:
                    #ACT('MESSAGE',"#ceqsy","$tchar.$perm");
                    #DEBUG:
                    #ACT('LITERAL',undef,"log>COOKIES>$tchar.$perm");
                    push(@modetokens,"$tchar");
                    push(@modetokenperms,"$perm");
                }
            }
        }
        #DEBUG:
        #ACT('MESSAGE',"#ceqsy","$modetokens[0]$modetokenperms[0], $modetokens[1]$modetokenperms[1], $modetokens[2]$modetokenperms[2], $modetokens[3]$modetokenperms[3], $modetokens[4]$modetokenperms[4]");        
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>$modetokens[0]$modetokenperms[0], $modetokens[1]$modetokenperms[1], $modetokens[2]$modetokenperms[2], $modetokens[3]$modetokenperms[3], $modetokens[4]$modetokenperms[4]");
        
        while( $nickstr =~ /(?:\s*([$valid_nick_characters]+))/gi ) {
            #DEBUG:
            #ACT('MESSAGE',"#ceqsy","nick found: $1");
            #DEBUG:
            #ACT('LITERAL',undef,"log>COOKIES>Nick found $1");
            push(@nicklist,"$1");
        }
        #DEBUG:
        #ACT('MESSAGE',"#ceqsy","Nicklist: 0:$nicklist[0], 1:$nicklist[1], 2:$nicklist[2], 3:$nicklist[3]");
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>Nicklist: 0:$nicklist[0], 1:$nicklist[1], 2:$nicklist[2], 3:$nicklist[3]");
        
        #Disallow any other mode lines to change the value for the bot while we're still working on it.
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>LOCK Semaphore");
        open (SEMAMODEWHOIS, "> $home_folder/plugins/basic/modewhois.sem") or die ("Can't open semaphore $!\n");
        flock SEMAMODEWHOIS, LOCK_EX or die ("Can't lock semaphore $!\n");
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>Semaphore LOCKED");
        
        for(my $i = 0; $i < $modecount; $i++) {
            if ($nicklist[$i] && ($nicklist[$i] eq $self)) {
                #check to see if mode wasn't changed just now (w.r.t random order of mode messages if mode is set for > Server_MODES people at the same time)
                ACT('LITERAL',undef,'get_variable_value>mode_'.$target.'_lastmodechange');
                my $timeresult = <STDIN>;
                $timeresult =~ s/[\r\n\t\s]+$//;
                
                if ($timeresult && ((time - $timeresult) <= 3)) { # if bot's mode changed in last 3 seconds then:
                    DoWhois($self,"force");
                    #DEBUG:
                    #Whois_print_all($self);

                    my $whois_channels = Whois_get('channels',$self);                    
                    if ($whois_channels && (($whois_channels." ") =~ /\s*([$prefixes{'o'}.$prefixes{'v'}]*)$target\s/i)) {
                        # trailing space after $whois_channels to eliminate false postives
                        # (ie matching "#channel" when looking for "#chan" thus require space directly after $target )
                        my $whoisperms = $1;
                        if($whoisperms =~ /($prefixes{'o'})/gi) {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_op>true');
                        } else {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_op>false');
                        }
                        if($whoisperms =~ /($prefixes{'v'})/gi) {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_voice>true');
                        } else {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_voice>false');
                        }
                    }
                }
                else { # if mode wasn't changed recently, we just use whatever mode is sent by the server.
                    if ($modetokenperms[$i] eq "o") {
                        if ($modetokens[$i] eq "+") {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_op>true');
                        } else {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_op>false');
                        }
                    }
                    elsif ($modetokenperms[$i] eq "v") {
                        if ($modetokens[$i] eq "+") {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_voice>true');
                        } else {
                            ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_voice>false');
                        }
                    }
                }
                ACT('LITERAL',undef,'set_variable_value>mode_'.$target.'_lastmodechange>'.time); # Update latest time
            }
        }
        
        # Unlock semaphore
        #ACT('LITERAL',undef,"log>COOKIES>UNLOCK Semaphore");
        flock SEMAMODEWHOIS, LOCK_UN;
        close (SEMAMODEWHOIS);
    }
    return 1;
}



# ========================= <EXAMPLE> ==========================
#OUTGOING 16:13:07 whois ceqsy ceqsy
# gives:
#INCOMING 16:13:07 :wolfe.freenode.net 311 CEQSY CEQSY ircbot 541B99FC.cm-5-4c.dynamic.ziggo.nl * :CEQSY Bot
#INCOMING 16:13:07 :wolfe.freenode.net 319 CEQSY CEQSY :@#opchan @+#opvoicechan +#voicechan #somechan
#INCOMING 16:13:07 :wolfe.freenode.net 312 CEQSY CEQSY wolfe.freenode.net :Manchester, England
#INCOMING 16:13:07 :wolfe.freenode.net 378 CEQSY CEQSY :is connecting from *@541B99FC.cm-5-4c.dynamic.ziggo.nl 84.27.153.252
#INCOMING 16:13:07 :wolfe.freenode.net 317 CEQSY CEQSY 1383 1332591524 :seconds idle, signon time
#INCOMING 16:13:07 :wolfe.freenode.net 671 CEQSY CEQSY :is using a secure connection
#INCOMING 16:13:07 :wolfe.freenode.net 330 CEQSY CEQSY CEQSY :is logged in as
#INCOMING 16:13:07 :wolfe.freenode.net 318 CEQSY CEQSY :End of /WHOIS list.
# or:
#INCOMING 16:13:07 :wolfe.freenode.net 401 CEQSY CEQSY :No such nick/channel
#INCOMING 16:13:07 :wolfe.freenode.net 318 CEQSY ceqsy :End of /WHOIS list.
# or:
#INCOMING 16:13:07 :wolfe.freenode.net 402 CEQSY CEQSY :No such server
#INCOMING 00:23:11 :irc.snt.utwente.nl 001 CEQSY :Welcome to the Internet Relay Network CEQSY!ircbot@541B99FC.cm-5-4c.dynamic.ziggo.nl
# ========================= </EXAMPLE> =========================

if ($command eq '001') {    #INCOMING 00:23:11 :irc.snt.utwente.nl 001 CEQSY :Welcome to the Internet Relay Network CEQSY!ircbot@541B99FC.cm-5-4c.dynamic.ziggo.nl
    if($message =~ /^(.+):Welcome to the Internet Relay Network ([$valid_nick_characters]+)!(.+)@(.+)$/i) {
        ACT('LITERAL',undef,'set_variable_value>bot_nick>'.(lc $2));
        ACT('LITERAL',undef,'set_variable_value>bot_user>'.(lc $3));
        ACT('LITERAL',undef,'set_variable_value>bot_host>'.(lc $4));
    }
    return 1;
}

if ($command eq '311') {    #INCOMING 16:13:07 :wolfe.freenode.net 311 CEQSY CEQSY ircbot 541B99FC.cm-5-4c.dynamic.ziggo.nl * :CEQSY Bot
    if($message =~ /^([$valid_nick_characters]+)\s+(.+)\s+(.+)\s+(.+)\s+:(.+)$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_ident>'.(lc $2));
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_hostmask>'.(lc $3));
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_realname>'.(lc $5));
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_status>'.$command);
    }
    return 1;
}

if ($command eq '312') {    #INCOMING 16:13:07 :wolfe.freenode.net 312 CEQSY CEQSY wolfe.freenode.net :Manchester, England
    if($message =~ /^([$valid_nick_characters]+)\s+(.+)$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_server>'.(lc $2));
    }
    return 1;
}

if ($command eq '330') {    #INCOMING 16:13:07 :wolfe.freenode.net 330 CEQSY CEQSY CEQSY :is logged in as
    if($message =~ /^([$valid_nick_characters]+)\s+(.+)\s+:is logged in as$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_account>'.(lc $2));
    }
    return 1;
}

if ($command eq '378') {    #INCOMING 16:13:07 :wolfe.freenode.net 378 CEQSY CEQSY :is connecting from *@541B99FC.cm-5-4c.dynamic.ziggo.nl 84.27.153.252
    if($message =~ /^([$valid_nick_characters]+)\s+:is connecting from (.+)(?:\s+(.+))?$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_hostip>'.(lc $2)."@@@@".(lc $3));
    }
    return 1;
}

if ($command eq '317') {    #INCOMING 16:13:07 :wolfe.freenode.net 317 CEQSY CEQSY 1383 1332591524 :seconds idle, signon time
    if($message =~ /^([$valid_nick_characters]+)\s+(.+)\s+(.+)\s+:seconds idle, signon time$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_idletime>'.(lc $2));
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_signon>'.(lc $3));
    }
    return 1;
}

if ($command eq '318') {    #INCOMING 16:13:07 :wolfe.freenode.net 318 CEQSY CEQSY :End of /WHOIS list.
    if($message =~ /^([$valid_nick_characters]+)\s+:End of \/*WHOIS list.$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_time>'.time); # Update latest time
    }
    return 1;
}

if ($command eq '319') {    #INCOMING 16:13:07 :wolfe.freenode.net 319 CEQSY CEQSY :@#opchan @+#opvoicechan +#voicechan #somechan
    if($message =~ /^([$valid_nick_characters]+)\s+:(.+)$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_channels>'.(lc $2)); # Update channel list info
    }
    return 1;
}

if ($command eq '671') {    #INCOMING 16:13:07 :wolfe.freenode.net 671 CEQSY CEQSY :is using a secure connection
    if($message =~ /^([$valid_nick_characters]+)\s+:is using a secure connection$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_secure>true');
    }
    return 1;
}

if ($command eq '353') {    #INCOMING 00:04:39 :irc.snt.utwente.nl 353 CEQSY @ #kerckhoffs :CEQSY gomp atum Robbert @phedny mrngm aczid VeXocide Ice_Blade namnatulco niels thelamb MacGyverNL Sjors @Amrod @Sakartu @Onmarag @efjboss @BasilFX @ralphje @Dutchy @ius @{myst} @Sagi
    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>EVENT: $event, SENDER: $sender, ACCOUNT: $account, HOSTNAME: $hostname, COMMAND: $command, TARGET: $target, MESSAGE: $message");

    my $prefixchars = $server_prefix;
    $prefixchars =~ s/[\r\n\t\s]+$//;
      
    my (%prefixes, @modetokens, @modetokenperms, @nicklist);
    
    if ($prefixchars =~ /^\((.+)\)(.+)$/i) { #ex. "(ov)@+"
        for(my $i = 0; $i < length($1); $i++) {
            my $mchar = substr($1,$i-1,1);
            my $msymb = substr($2,$i-1,1);
            if ($msymb =~ /[\[\\\^\$\.\|\?\*\+\(\)\{\}]/i ) {
                $msymb = "\\".$msymb;
            }
            $prefixes{$mchar} = $msymb;
        }
    }
    #DEBUG:
    #if($prefixes{'o'}) { ACT('LITERAL',undef,"log>COOKIES>o:$prefixes{'o'}"); }
    #if($prefixes{'v'}) { ACT('LITERAL',undef,"log>COOKIES>v:$prefixes{'v'}"); }
    #if($prefixes{'h'}) { ACT('LITERAL',undef,"log>COOKIES>h:$prefixes{'h'}"); }


    #MESSAGE: = #CEQSY :CEQSY @Ice_Blade
    #MESSAGE: = #jwz :@CEQSY
    if($prefixes{'o'} && $message =~ /^(.+)\s([$valid_chan_characters]+)\s+:([$prefixes{'o'}]+)([$target]+)/i) {
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>Found op for $target in channel $2");
        ACT('LITERAL',undef,'set_variable_value>mode_'.(lc $2).'_op>true');
    }
    if($prefixes{'v'} && $message =~ /^(.+)\s([$valid_chan_characters]+)\s+:([$prefixes{'v'}]+)([$target]+)/i) {
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>Found voice for $target in channel $2");
        ACT('LITERAL',undef,'set_variable_value>mode_'.(lc $2).'_voice>true');
    }
    if($prefixes{'h'} && $message =~ /^(.+)\s([$valid_chan_characters]+)\s+:([$prefixes{'h'}]+)([$target]+)/i) {
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>Found halfop for $target in channel $2");
        ACT('LITERAL',undef,'set_variable_value>mode_'.(lc $2).'_halfop>true');
    }
    return 1;
}

if (($command eq '401') ||  #INCOMING 16:13:07 :wolfe.freenode.net 401 CEQSY CEQSY :No such nick/channel
    ($command eq '402')) {  #INCOMING 16:13:07 :wolfe.freenode.net 402 CEQSY CEQSY :No such server
    if($message =~ /^([$valid_nick_characters]+)\s+:No such (nick\/channel|server)$/i) {
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_time>'.time);
        ACT('LITERAL',undef,'set_variable_value>whois_'.(lc $1).'_status>'.$command);
        
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_ident');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_hostmask');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_realname');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_server');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_account');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_hostip');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_idletime');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_signon');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_channels');
        ACT('LITERAL',undef,'clear_variable_value>whois_'.(lc $1).'_secure');
    }
    return 1;
}

return 0;
