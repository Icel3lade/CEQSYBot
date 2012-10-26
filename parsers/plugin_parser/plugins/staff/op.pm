push(@modules,"op");

if ($message =~ /^${sl}${cm}op(\s+([#&][$valid_chan_characters]+))?(\s+([$valid_nick_characters]+))?$/i) {
    my ($chanstr, $nickstr);
    if(!$4) { $chanstr = $target; } else { $chanstr = $4; }
    if(!$6) { $nickstr = $receiver; } else { $nickstr = $6; }
    if(CheckPerm($sender, "op", $chanstr, $target)) {
        CheckOps($chanstr) ? ACT('MODE',"$chanstr","+o","","$nickstr","") : ACT('MESSAGE','chanserv',"op $chanstr $nickstr");
    }
    return 1;
}

if ($message =~ /^${sl}${cm}deop(\s+([#&][$valid_chan_characters]+))?(\s+([$valid_nick_characters]+))?$/i) {
    my ($chanstr, $nickstr);
    if(!$4) { $chanstr = $target; } else { $chanstr = $4; }
    if(!$6) { $nickstr = $receiver; } else { $nickstr = $6; }
    if(CheckPerm($sender, "op", $chanstr, $target)) {
        CheckOps($chanstr) ? ACT('MODE',"$chanstr","-o","","$nickstr","") : ACT('MESSAGE','chanserv',"deop $chanstr $nickstr")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}opbot$/i) {
    if(CheckPerm($sender, "op", $target, $target)) {
        CheckOps($target) ? ACT('MODE',"$target","+o","","$self","") : ACT('MESSAGE','chanserv',"op $target $self")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}deopbot$/i) {
    if(CheckPerm($sender, "op", $target, $target)) {
        CheckOps($target) ? ACT('MODE',"$target","-o","","$self","") : ACT('MESSAGE','chanserv',"deop $target $self")
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+op$/i) {
    ACT('MESSAGE',$receiver,"The op module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !op [CHANNEL] [NICK]                      - Gives op privileges to the user [NICK] on the channel [CHANNEL].");
    ACT('MESSAGE',$receiver,"    !deop [CHANNEL] [NICK]                    - Removes op privileges from the user [NICK] on the channel [CHANNEL].");
    ACT('MESSAGE',$receiver,"    !opbot                                    - Gives op privileges to $self.");
    ACT('MESSAGE',$receiver,"    !deopbot                                  - Removes op privileges from $self.");
    return 1;
}

return 0;
