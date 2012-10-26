push(@modules,"quiet");

if ($message =~ /^${sl}${cm}quiet(\s+([#&][$valid_chan_characters]+))?(\s+([$valid_nick_characters]+))?$/i) {
    my ($chanstr, $nickstr);
    if(!$4) { $chanstr = $target; } else { $chanstr = $4; }
    if(!$6) { $nickstr = $receiver; } else { $nickstr = $6; }
    if(CheckPerm($sender, "quiet", $chanstr, $target)) {
        ACT('MESSAGE','chanserv',"quiet $chanstr $nickstr");
    }
    return 1;
}
if ($message =~ /^${sl}${cm}(un|de)quiet(\s+([#&][$valid_chan_characters]+))?(\s+([$valid_nick_characters]+))?$/i) {
    my ($chanstr, $nickstr);
    if(!$4) { $chanstr = $target; } else { $chanstr = $4; }
    if(!$6) { $nickstr = $receiver; } else { $nickstr = $6; }
    if(CheckPerm($sender, "quiet", $chanstr, $target)) {
        ACT('MESSAGE','chanserv',"unquiet $chanstr $nickstr")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}quietbot$/i) {
    if(CheckPerm($sender, "quiet", $target, $target)) {
        ACT('MESSAGE','chanserv',"quiet $target $self")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}(un|de)quietbot$/i) {
    if(CheckPerm($sender, "quiet", $target, $target)) {
        ACT('MESSAGE','chanserv',"unquiet $target $self")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+quiet$/i) {
    ACT('MESSAGE',$receiver,"The quiet module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !quiet [CHANNEL] [NICK]                   - Gives quiet restriction to the user [NICK] on the channel [CHANNEL].");
    ACT('MESSAGE',$receiver,"    !unquiet [CHANNEL] [NICK]                 - Removes quiet restriction from the user [NICK] on the channel [CHANNEL].");
    ACT('MESSAGE',$receiver,"    !dequiet [CHANNEL] [NICK]                 - Removes quiet restriction from the user [NICK] on the channel [CHANNEL].");
    ACT('MESSAGE',$receiver,"    !quietbot                                 - Gives quiet restriction to $self.");
    ACT('MESSAGE',$receiver,"    !unquietbot                               - Removes quiet restriction from $self.");
    ACT('MESSAGE',$receiver,"    !dequietbot                               - Removes quiet restriction from $self.");
    return 1;
}

return 0;
