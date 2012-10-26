push(@modules,"ctcp");

#DEBUG:
#ACT('LITERAL',undef,"log>COOKIES>MESSAGE: $message");


if ($message =~ /^(VERSION|CLIENTINFO).*$/i) {
    ACT('NOTICE',$sender,"$1 $version");
    return 1;
}

if ($message =~ /^TIME.*$/i) {
    require POSIX;
    my $timestamp = POSIX::strftime('%m-%d-%Y %H:%M:%S',localtime);
    ACT('NOTICE',$sender,"TIME $timestamp");
    return 1;
}

if ($message =~ /^PING.*$/i) {
    my $timestamp = time;
    ACT('NOTICE',$sender,"PING $timestamp");
    return 1;
}

if ($message =~ /^FINGER.*$/i) {
    ACT('NOTICE',$sender,"FINGER Take your fingers off me!");
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+ctcp$/i) {
    ACT('MESSAGE',$receiver,"The CTCP module supports responses to the following commands:");
    ACT('MESSAGE',$receiver,"    VERSION|CLIENTVERSION                     - Returns the version.");
    ACT('MESSAGE',$receiver,"    TIME                                      - Gives the current time.");
    ACT('MESSAGE',$receiver,"    PING                                      - Enables replies to a PING request.");
    ACT('MESSAGE',$receiver,"    FINGER                                    - Enables replies to a FINGER request.");
    return 1;
}

return 0;
