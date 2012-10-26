push(@modules,"slap");

if ($message =~ /^${sl}${cm}slap\s+(.+)$/i) {
	my $person = $3;
	$person =~ s/\bme\b/$sender/i;
	ACT('ACTION',$target,"slaps $person around a bit with a large smelly trout!");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+slap$/i) {
	ACT('MESSAGE',$receiver,"The slap module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !slap (NICK|me)                           - $self slaps NICK around a bit with a large smelly trout.");
	return 1;
}

return 0;
