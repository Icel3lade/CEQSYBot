push(@modules,"dice");

if ($message =~ /^${sl}${cm}d([0-9]+)$/i) {
	my $answer = int(rand($3))+1;
	ACT('MESSAGE',"$target","$receiver: The roll is $answer");
	return 1;
}


if ($message =~ /^${sl}${cm}([0-9]+)d([0-9]+)$/i) {
	if ($3 <= 9000) {
		my ($i, $rand, $rolls, $answer) = (0,0,"",0);
		while($i < $3) {
			$rand = int(rand($4))+1;
			$answer += $rand;
			$i += 1;
			if ($3 <= 50) {
				if ($i == 1) {
					$rolls = "$rand";
				} else {
					$rolls = "$rolls, $rand";
				}
			}
		}
		if ($3 <= 50) {
			ACT('MESSAGE',"$target","$receiver: The consecutive rolls were: [$rolls]");
		}
		ACT('MESSAGE',$target,"$receiver: The total is $answer");
	}
	else {
		ACT('MESSAGE',$target,"Help! $sender is trying to attack me! Their power level is OVER NINE THOUSAND!");
	}
	return 1;
}

if ($message =~ /^${sl}${cm}help\s+dice$/i) {
	ACT('MESSAGE',$receiver,"The dice module supports the following commands:");
	ACT('MESSAGE',$receiver,"    ![M]dN                                    - Rolls 1[or M] N sided dice once.");
	return 1;
}

return 0;
