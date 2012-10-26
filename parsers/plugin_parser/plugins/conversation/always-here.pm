if (($event eq 'public_message') && ($message =~ /(is )?any ?(one|body)\s+(around|available|awake|(out )?there|here)/i)) {
	sleep(3);
	ACT('MESSAGE',$target,"Hey there. I am always $3, but I assume you want one of the squishy human-folk...");
	return 1;
}

return 0;
