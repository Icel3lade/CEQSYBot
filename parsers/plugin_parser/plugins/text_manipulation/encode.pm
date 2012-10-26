push(@modules,"encode");

if ($message =~ /^${sl}${cm}encode\s+(.*)$/i) {
	my $string = uri_escape_utf8($3,"A-Za-z0-9\0-\377") if $3;
	ACT('MESSAGE',$target,"$receiver: $string");
	return 1;
}

if ($message =~ /^${sl}${cm}decode\s+(.*)$/i) {
	my $string = uri_unescape($3,"A-Za-z0-9\0-\377") if $3;
	ACT('MESSAGE',$target,"$receiver: $string");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+encode$/i) {
	ACT('MESSAGE',$receiver,"The encode module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !encode STRING                            - Gives a URI escaped UTF-8 version of STRING.");
	ACT('MESSAGE',$receiver,"    !decode STRING                            - Gives a URI unescaped UTF-8 version of STRING.");
	return 1;
}

return 0;
