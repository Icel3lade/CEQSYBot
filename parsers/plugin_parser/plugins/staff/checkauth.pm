push(@modules,"checkauth");

#if ($message =~ /^${sl}${cm}check$/i) {
    #ACT('MESSAGE',$target,"$sender: Authorization of $hostname in $target is ".&CheckAuth($target,$hostname).".");
    #return 1;
#}

if ($message =~ /^${sl}${cm}check(?:perm)?(?:\s+([$valid_nick_characters]+))?(?:\s+([$server_chantype][$valid_chan_characters]+))?(?:\s+(.*))?$/i) {
    my $nickname = $3;
    $nickname = $sender if (!$3);
    my $channame = $4;
    $channame = $target if (!$4);
    my $perm = $5;
    $perm = "list" if (!$5);
    ACT('MESSAGE',$target,"CheckPerm called: Nick: $nickname, Perm: $perm, Chan: $channame, Target: $target.");
    CheckPerm($nickname, $perm, $channame, $target,"print");
    ACT('MESSAGE',$target,"Done with CheckPerm.");
    return 1;
}

#if ($message =~ /^${sl}${cm}checkfor\s+(.+)\s+([$valid_chan_characters]+)$/i) {
    #ACT('MESSAGE',$target,"$sender: Authorization of $3 in $4 is ".&CheckAuth($4,$3).".");
    #return 1;
#}

if ($message =~ /^${sl}${cm}help\s+checkauth$/i) {
    ACT('MESSAGE',$receiver,"The checkauth module supports the following commands:");
    #ACT('MESSAGE',$receiver,"----Old permissions system----");
    #ACT('MESSAGE',$receiver,"    !check                                    - Checks to see if the user is authorized for the bots admin functionality in the current channel.");
    #ACT('MESSAGE',$receiver,"    !checkfor HOSTMASK CHANNEL                - Checks to see if HOSTMASK is authorized for the bots admin functionality in CHANNEL.");
    #ACT('MESSAGE',$receiver,"----New permissions system----");
    ACT('MESSAGE',$receiver,"    !check [NICK] [CHANNEL] [PERMS]           - Checks to see if user [NICK] is authorized to use [PERMS] in [CHANNEL]. NICK or CHANNEL must be given before using PERMS.");
    ACT('MESSAGE',$receiver,"    !checkperm [NICK] [CHANNEL] [PERMS]       - Checks to see if user [NICK] is authorized to use [PERMS] in [CHANNEL]. NICK or CHANNEL must be given before using PERMS.");
    return 1;
}

return 0;
