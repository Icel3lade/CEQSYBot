push(@modules,"basic");

if ($message =~ /^${sl}${cm}about$/i) {
	ACT('MESSAGE',$target,"$about");
	return 1;
}

if ($message =~ /^${sl}${cm}?version$/i) {
    ACT('MESSAGE',$target,"$version");
    return 1;
}

if ($message =~ /^${sl}${cm}help$/i) {
	@modules = sort(@modules);
	my $modulesstring = join(", ",@modules);
	ACT('MESSAGE',$receiver,"$self currently supports the following modules: $modulesstring.");
	ACT('MESSAGE',$receiver,"For additional information about a module, type !help [modulename]. For example: \"!help karma\"");
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+basic$/i) {
	ACT('MESSAGE',$receiver,"The basic module supports the following commands:");
	ACT('MESSAGE',$receiver,"    !about                                    - Gives some information about $self.");
	ACT('MESSAGE',$receiver,"    !version                                  - Gives some information about the version.");
	ACT('MESSAGE',$receiver,"    !help [module]                            - Gives the main help menu [for a given module].");
	return 1;
}
return 0;
