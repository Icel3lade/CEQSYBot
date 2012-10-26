push(@modules,"yesno");

if ($message =~ /^${sl}${cm}(yesno|yn)\s+(.+)$/i) {
	my @response;
	$response[0] = 'Yes';
	$response[1] = 'No';
	my $answer = int(rand(2));
	$answer = $response[$answer];

	ACT('MESSAGE',$target,"$receiver: $answer");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+yesno$/i) {
	ACT('MESSAGE',$receiver,"The yesno module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !yesno STRING                             - Gives a response to the question in STRING.");
	ACT('MESSAGE',$receiver,"    !yn STRING                                - Gives a response to the question in STRING.");
	return 1;
}

return 0;
