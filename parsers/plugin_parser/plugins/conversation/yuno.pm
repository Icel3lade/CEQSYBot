push(@modules,"yuno");

if ($message =~ /^${sl}${cm}yuno\s+([$valid_nick_characters]+)\s+(.+)$/i) {
	my $yuno = uc $4;
	if(!$3) {
		$receiver = uc $receiver;
	} else {
		$receiver = uc $3;
	}
	ACT('MESSAGE',$target,"$receiver! ლ(ಠ益ಠლ) Y U NO $yuno?");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+yuno$/i) {
	ACT('MESSAGE',$receiver,"The yuno module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !yuno NICK STRING                         - asks NICK Y U NO STRING?.");
	return 1;
}

return 0;
