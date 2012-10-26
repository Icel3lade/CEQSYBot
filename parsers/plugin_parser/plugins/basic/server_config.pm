if ($command eq '005') {
    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>$message");

    ## REFERENCE: http://www.irc.org/tech_docs/005.html
    ## Sample 005 lines.
    #10:02:00 [UTwente] -!- RFC2812 PREFIX=(ov)@+ CHANTYPES=#&!+ MODES=3 CHANLIMIT=#&!+:41 NICKLEN=15 TOPICLEN=255 KICKLEN=255 MAXLIST=beIR:64 CHANNELLEN=50 IDCHAN=!:5 CHANMODES=beIR,k,l,imnpstaqr are supported by this server                  
    #10:02:00 [UTwente] -!- PENALTY FNC EXCEPTS=e INVEX=I CASEMAPPING=ascii NETWORK=IRCnet are supported by this server 
    #10:02:00 [Freenode] -!- CHANTYPES=# EXCEPTS INVEX CHANMODES=eIbq,k,flj,CFLMPQcgimnprstz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode KNOCK STATUSMSG=@+ CALLERID=g are supported by this server                    
    #10:02:00 [Freenode] -!- CASEMAPPING=rfc1459 CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 ETRACE CPRIVMSG CNOTICE DEAF=D MONITOR=100 FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: are supported by this server                                                                                                                                                                                                            
    #10:02:00 [Freenode] -!- EXTBAN=$,arx WHOX CLIENTVER=3.0 SAFELIST ELIST=CTU are supported by this server
    #10:02:01 [Rizon] -!- CALLERID CASEMAPPING=rfc1459 DEAF=D KICKLEN=160 MODES=4 NICKLEN=30 TOPICLEN=390 PREFIX=(qaohv)~&@%+ STATUSMSG=~&@%+ NETWORK=Rizon MAXLIST=beI:100 TARGMAX=ACCEPT:,KICK:1,LIST:1,NAMES:1,NOTICE:4,PRIVMSG:4,WHOIS:1 CHANTYPES=# are supported by this server                                                                                                                           
    #10:02:01 [Rizon] -!- CHANLIMIT=#:75 CHANNELLEN=50 CHANMODES=beI,k,l,BMNORScimnpstz AWAYLEN=160 FNC KNOCK ELIST=CMNTU SAFELIST NAMESX UHNAMES EXCEPTS=e INVEX=I are supported by this server
    #10:02:10 [Security] -!- CHANTYPES=&# CHANMODES=b,k,l,imnpstS CHANLIMIT=&#:5 PREFIX=(ov)@+ MAXLIST=b:250 MODES=4 NETWORK=Certified STATUSMSG=@+ CALLERID=g SAFELIST ELIST=U CASEMAPPING=rfc1459 are supported by this server                   
    #10:02:10 [Security] -!- CHARSET=ascii NICKLEN=9 CHANNELLEN=50 TOPICLEN=160 ETRACE CPRIVMSG CNOTICE DEAF=D MONITOR=100 FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: are supported by this server
    #12:16:20 [Gewis] -!- CALLERID CASEMAPPING=rfc1459 DEAF=D KICKLEN=160 MODES=4 NICKLEN=15 PREFIX=(ohv)@%+ STATUSMSG=@%+ TOPICLEN=350 NETWORK=gewis MAXLIST=beI:25 MAXTARGETS=4 CHANTYPES=#& are supported by this server                        
    #12:16:20 [Gewis] -!- CHANLIMIT=#&:15 CHANNELLEN=50 EXCEPTS=e INVEX=I CHANMODES=eIb,k,l,imnpst AWAYLEN=160 KNOCK ELIST=CMNTU SAFELIST are supported by this server
    
    my @getvalue = ("CHANTYPES","MAXLIST","MODES","NETWORK","STATUSMSG","CALLERID","CHANMODES","PREFIX","CHARSET","CASEMAPPING","NICKLEN","CHANNELLEN","TOPICLEN","TARGMAX","AWAYLEN","CHANLIMIT","INVEX","EXCEPTS");
    
    foreach my $getme(@getvalue) {
        my $parseme = $message;
        #DEBUG:
        #ACT('LITERAL',undef,"log>COOKIES>$message CONTAINS: $getme");
        if ($parseme =~ /^(.*)\s($getme=?([^\s]+)?)(.*)$/gi) {
            if ($3) {
                #DEBUG:
                #ACT('LITERAL',undef,"log>COOKIES>CONTAINS_3: $getme=$3");
                ACT('LITERAL',undef,"set_config_value>Server_$getme>$3");
            }
            elsif ($2) {
                # For example if we only get "CHANTYPES=# INVEX CHANMODES=eIbq..."
                # instead of "CHANTYPES=# INVEX=I CHANMODES=eIbq..."
                # We want to store the value $config{'Server_INVEX'}="INVEX"; where it would be "I" otherwise.
                #DEBUG:
                #ACT('LITERAL',undef,"log>COOKIES>CONTAINS_2: $getme=$2");
                ACT('LITERAL',undef,"set_config_value>Server_$getme>$2");
            }
        }
    }
    #DEBUG:
    #ACT('LITERAL',undef,"log>COOKIES>Done parsing 005-line");
    return 1;
}

return 0;
