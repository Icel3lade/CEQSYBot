push(@modules,"speak");

if ($message =~ /^${sl}${cm}(?:tell|say)\s+([$valid_chan_characters]+)\s+(.+)$/i) {
    if(CheckPerm($sender, "speak", $3, $target)) {
        ACT('MESSAGE',$3,$4);
    }
    return 1;
}

if ($message =~ /^${sl}${cm}do\s+([$valid_chan_characters]+)\s+(.+)$/i) {
    if(CheckPerm($sender, "speak", $3, $target)) {
        ACT('ACTION',$3,$4);
    }
    return 1;
}

if ($message =~ /^${sl}${cm}noti(?:fy|ce)\s+([$valid_chan_characters]+)\s+(.+)$/i) {
    if(CheckPerm($sender, "speak", $3, $target)) {
        ACT('NOTICE',$3,$4);
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+speak$/i) {
    ACT('MESSAGE',$receiver,"The speak module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !tell CHANNEL STRING                      - Causes $self to say STRING in CHANNEL.");
    ACT('MESSAGE',$receiver,"    !say CHANNEL STRING                      - Causes $self to say STRING in CHANNEL.");
    ACT('MESSAGE',$receiver,"    !do CHANNEL STRING                        - Causes $self to send action STRING in CHANNEL.");
    ACT('MESSAGE',$receiver,"    !notify CHANNEL STRING                    - Causes $self to send a notice of STRING in CHANNEL.");
    ACT('MESSAGE',$receiver,"    !notice CHANNEL STRING                    - Causes $self to send a notice of STRING in CHANNEL.");
    return 1;
}

return 0;
