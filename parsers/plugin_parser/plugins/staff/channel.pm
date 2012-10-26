push(@modules,"channel");

if ($message =~ /^${sl}${cm}topic(\s+([#&][$valid_chan_characters]+))?(\s+(.*))?$/i) {
    my ($chanstr, $topicstr);
    if(!$4) {
        $chanstr = $target;
    }
    else {
        $chanstr = $4;
    }
    if(!$6) {
        $topicstr = "";
    }
    else {
        $topicstr = $6;
    }
    if(CheckPerm($sender, "topic", $chanstr, $target)) {
        if(CheckOps($chanstr)) {
            ACT('TOPIC',$chanstr,$topicstr);
        } else {
            ACT('MESSAGE','chanserv',"op $chanstr $self");
            sleep 4;
            ACT('TOPIC',$chanstr,$topicstr);
            sleep 2;
            ACT('MESSAGE','chanserv',"deop $chanstr $self");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}join\s+([$valid_chan_characters]+)$/i) {
    if(CheckPerm($sender, "join", $3, $target)) {
        ACT('JOIN',$3);
    }
    return 1;
}

if ($message =~ /^${sl}${cm}invite\s+([$valid_nick_characters]+)(\s+([#&][$valid_chan_characters]+))?$/i) {
    my ($chanstr, $nickstr);
    if(!$5) {
        $chanstr = $target;
    }
    else {
        $chanstr = $5;
    }
    $nickstr = $3;
    if(CheckPerm($sender, "invite", $chanstr, $target)) {
        if(CheckOps($chanstr)) {
            ACT('INVITE',$nickstr,$chanstr);
        } else {
            ACT('MESSAGE','chanserv',"op $chanstr $self");
            sleep 4;
            ACT('INVITE',$nickstr,$chanstr);
            sleep 2;
            ACT('MESSAGE','chanserv',"deop $chanstr $self");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}part(\s+([$valid_chan_characters]+))?(\s+(.*))?$/i) {
    my ($chanstr, $msgstr);
    if(!$4) {
        $chanstr = $target;
    }
    else {
        $chanstr = $4;
    }
    if(!$6) {
        $msgstr = "Parted at ${receiver}'s request.";
    }
    else {
        $msgstr = $6;
    }
    if(CheckPerm($sender, "part", $chanstr, $target)) {
        ACT('PART',$chanstr,$msgstr);
    }
    return 1;
}

if ($message =~ /^${sl}${cm}kick(\s+([#&][$valid_chan_characters]+))?\s+([$valid_nick_characters]+)(\s+(.*))?$/i) {
    my ($chanstr, $nickstr, $reasonstr);
    if(!$4) {
        $chanstr = $target;
    }
    else {
        $chanstr = $4;
    }
    if(!$5) {
        $nickstr = "";
    }
    else {
        $nickstr = $5;
    }
    if(!$7) {
        $reasonstr = "Kicked at ${receiver}'s request.";
    }
    else {
        $reasonstr = $7;
    }
    if(CheckPerm($sender, "kick", $chanstr, $target)) {
        if(CheckOps($chanstr)) {
            ACT('KICK',$chanstr,$nickstr,$reasonstr);
        } else {
            ACT('MESSAGE','chanserv',"op $chanstr $self");
            sleep 4;
            ACT('KICK',$chanstr,$nickstr,$reasonstr);
            sleep 2;
            ACT('MESSAGE','chanserv',"deop $chanstr $self");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}ban(\s+([#&][$valid_chan_characters]+))?\s+([$valid_nick_characters]+)?([^\s]+)?$/i) {
    my ($chanstr, $nickstr, $hostmask);
    if(!$4) {
        $chanstr = $target;
    }
    else {
        $chanstr = $4;
    }
    if(!$5) {
        $nickstr = "*";
    }
    else {
        $nickstr = $5;
    }
    if(!$6) {
        $hostmask = "!*@*";
    }
    else {
        $hostmask = $6;
    }
    if(CheckPerm($sender, "ban", $chanstr, $target)) {
        if(CheckOps($chanstr)) {
            ACT('MODE',$chanstr,"+b","$nickstr$hostmask");
        } else {
            ACT('MESSAGE','chanserv',"op $chanstr $self");
            sleep 4;
            ACT('MODE',$chanstr,"+b","$nickstr$hostmask");
            sleep 2;
            ACT('MESSAGE','chanserv',"deop $chanstr $self");
        }
    }

    return 1;
}

if ($message =~ /^${sl}${cm}unban(\s+([#&][$valid_chan_characters]+))?\s+([$valid_nick_characters]+)?([^\s]+)?$/i) {
    my ($chanstr, $nickstr, $hostmask);
    if(!$4) {
        $chanstr = $target;
    }
    else {
        $chanstr = $4;
    }
    if(!$5) {
        $nickstr = "*";
    }
    else {
        $nickstr = $5;
    }
    if(!$6) {
        $hostmask = "!*@*";
    }
    else {
        $hostmask = $6;
    }
    if(CheckPerm($sender, "unban", $chanstr, $target)) {
        if(CheckOps($chanstr)) {
            ACT('MODE',$chanstr,"-b","$nickstr$hostmask");
        } else {
            ACT('MESSAGE','chanserv',"op $chanstr $self");
            sleep 4;
            ACT('MODE',$chanstr,"-b","$nickstr$hostmask");
            sleep 2;
            ACT('MESSAGE','chanserv',"deop $chanstr $self");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}kickban(\s+([#&][$valid_chan_characters]+))?\s+([$valid_nick_characters]+)?([^\s]+)?(?:\s+(.*))?$/i) {
    my ($chanstr, $nickstr, $hostmask, $reasonstr);
    if(!$4) {
        $chanstr = $target;
    }
    else {
        $chanstr = $4;
    }
    if(!$5) {
        $nickstr = "*";
    }
    else {
        $nickstr = $5;
    }
    if(!$6) {
        $hostmask = "!*@*";
    }
    else {
        $hostmask = $6;
    }
    if(!$7) {
        $reasonstr = "Kicked at ${receiver}'s request.";
    }
    else {
        $reasonstr = $7;
    }
    if(CheckPerm($sender, "kick", $chanstr, $target) && CheckPerm($sender, "ban", $chanstr, $target)) {
        if(CheckOps($chanstr)) {
            ACT('MODE',$chanstr,"+b","$nickstr$hostmask");
            ACT('KICK',$chanstr,$nickstr,$reasonstr);
        } else {
            ACT('MESSAGE','chanserv',"op $chanstr $self");
            sleep 4;
            ACT('MODE',$chanstr,"+b","$nickstr$hostmask");
            sleep 2;
            ACT('KICK',$chanstr,$nickstr,$reasonstr);
            sleep 2;
            ACT('MESSAGE','chanserv',"deop $chanstr $self");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+channel$/i) {
    ACT('MESSAGE',$receiver,"The channel module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !join CHANNEL                             - Causes $self to join CHANNEL.");
    ACT('MESSAGE',$receiver,"    !invite NICK [CHANNEL]                    - Invites NICK to the current [or CHANNEL] channel.");
    ACT('MESSAGE',$receiver,"    !topic [CHANNEL] [STRING]                 - Changes the topic of the current [or CHANNEL] channel to nothing [or STRING].");
    ACT('MESSAGE',$receiver,"    !part [CHANNEL] [STRING]                  - Causes $self to leave the current [or CHANNEL] channel [with parting message STRING].");
    ACT('MESSAGE',$receiver,"    !kick [CHANNEL] NICK [STRING]             - Kicks NICK from the current [or CHANNEL] channel [with STRING as reason].");
    ACT('MESSAGE',$receiver,"    !ban [CHANNEL] [NICK][HOST]               - Bans *!*@* or [NICK][HOST] from the current [or CHANNEL] channel.");
    ACT('MESSAGE',$receiver,"    !unban [CHANNEL] [NICK][HOST]             - Unbans *!*@* or [NICK][HOST] from the current [or CHANNEL] channel.");
    ACT('MESSAGE',$receiver,"    !kickban [CHANNEL] [NICK][HOST] [STRING]  - Kicks and bans *!*@* or [NICK][HOST] from the current [or CHANNEL] channel [with STRING as reason].");
    return 1;
}

return 0;
