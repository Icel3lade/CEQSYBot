push(@modules,"hug");

if ($message =~ /^${sl}${cm}hug\s+(.+)$/i) {
	my $person = $3;
	$person =~ s/\bme\b/$sender/i;
	ACT('ACTION',$target,"hugs $person");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+hug$/i) {
	ACT('MESSAGE',$receiver,"The hug module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !hug (NICK|me)                            - $self gives NICK or you a hug.");
	return 1;
}

return 0;
