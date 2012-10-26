require POSIX;

push(@modules,"time");

if ($message =~ /^${sl}${cm}time$/i) {
    my $timestamp = POSIX::strftime('%H:%M:%S',localtime);
    ACT('MESSAGE',$target,"$receiver: $timestamp");
    return 1;
}

if ($message =~ /^${sl}${cm}time-?(utc|gmt)$/i) {
    my $timestamp = POSIX::strftime('%H:%M:%S',gmtime(time));
    ACT('MESSAGE',$target,"$receiver: $timestamp");
    return 1;
}
if ($message =~ /^${sl}${cm}time-?unix$/i) {
    my $timestamp = time;
    ACT('MESSAGE',$target,"$receiver: $timestamp");
    return 1;
}

if ($message =~ /^${sl}${cm}time\s+([+-][0-9]+)$/i) {
	my $offset = $1;
	my $hours = POSIX::strftime('%H',gmtime(time));
	my $minsec = POSIX::strftime('%M:%S',gmtime(time));
	$hours += $offset;
	if($hours > 23 || $hours < 0) { $hours = ($hours % 24); }
	my $timestamp = $hours.':'.$minsec;
	ACT('MESSAGE',$target,"$receiver: $timestamp");
	return 1;
}

if ($message =~ /^${sl}${cm}time-?internet$/i) {
	my @time_struct = gmtime(time);
	my $seconds_into_day = ($time_struct[2] * 3600 + $time_struct[1] * 60 + $time_struct[0] + 3600) % 86400; # + 3600 because 'BMT' = UTC+1
	$seconds_into_day = POSIX::floor($seconds_into_day); # Because printf rounds, badly
	my $timestamp = sprintf("@%03i",$seconds_into_day * 1000 / 86400);
	ACT('MESSAGE',$target,"$receiver: $timestamp");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+time$/i) {
	ACT('MESSAGE',$receiver,"The time module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !time                                     - Gives $self's current time.");
	ACT('MESSAGE',$receiver,"    !time-utc, !time-gmt                      - Gives current UTC/GMT time.");
	ACT('MESSAGE',$receiver,"    !time-unix                                - Gives $self's current time in seconds sinds 1-1-1970.");
	ACT('MESSAGE',$receiver,"    !time [+/-N]                              - Gives current UTC+N time.");
	ACT('MESSAGE',$receiver,"    !time-internet                            - Gives the 'internet' time.");  
	return 1;
}

return 0;

