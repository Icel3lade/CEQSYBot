push(@modules,"voice");

if ($message =~ /^${sl}${cm}voice(\s+([#&][$valid_chan_characters]+))?(\s+([$valid_nick_characters]+))?$/i) {
    my ($chanstr, $nickstr);
    if(!$4) { $chanstr = $target; } else { $chanstr = $4; }
    if(!$6) { $nickstr = $receiver; } else { $nickstr = $6; }
    if(CheckPerm($sender, "voice", $chanstr, $target)) {
        CheckOps($chanstr) ? ACT('MODE',"$chanstr","+v","","$nickstr","") : ACT('MESSAGE','chanserv',"voice $chanstr $nickstr");
    }
    return 1;
}

if ($message =~ /^${sl}${cm}devoice(\s+([#&][$valid_chan_characters]+))?(\s+([$valid_nick_characters]+))?$/i) {
    my ($chanstr, $nickstr);
    if(!$4) { $chanstr = $target; } else { $chanstr = $4; }
    if(!$6) { $nickstr = $receiver; } else { $nickstr = $6; }
    if(CheckPerm($sender, "voice", $chanstr, $target)) {
        CheckOps($chanstr) ? ACT('MODE',"$chanstr","-v","","$nickstr","") : ACT('MESSAGE','chanserv',"devoice $chanstr $nickstr")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}voicebot$/i) {
    if(CheckPerm($sender, "voice", $target, $target)) {
        CheckOps($target) ? ACT('MODE',"$target","+v","","$self","") : ACT('MESSAGE','chanserv',"voice $target $self")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}devoicebot$/i) {
    if(CheckPerm($sender, "voice", $target, $target)) {
        CheckOps($target) ? ACT('MODE',"$target","-v","","$self","") : ACT('MESSAGE','chanserv',"devoice $target $self")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+voice$/i) {
    ACT('MESSAGE',$receiver,"The voice module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !voice [CHANNEL] [NICK]                   - Gives voice privileges to the user [NICK] on the channel [CHANNEL].");
    ACT('MESSAGE',$receiver,"    !devoice [CHANNEL] [NICK]                 - Removes voice privileges from the user [NICK] on the channel [CHANNEL].");
    ACT('MESSAGE',$receiver,"    !voicebot                                 - Gives voice privileges to $self.");
    ACT('MESSAGE',$receiver,"    !devoicebot                               - Removes voice privileges from $self.");
    return 1;
}

return 0;
