push(@modules,"reverse");

if ($message =~ /^${sl}${cm}reverse\s+(.+)$/i) {
	my $string = scalar reverse($3);
	ACT('MESSAGE',$target,"$receiver: $string");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+reverse$/i) {
	ACT('MESSAGE',$receiver,"The reverse module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !reverse STRING                           - Gives the reverse of STRING.");
	return 1;
}

return 0;
