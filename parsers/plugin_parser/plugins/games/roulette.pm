push(@modules,"roulette");
my $home_path = $home_folder;
    $home_path =~ s/parsers\/plugin_parser//g;

my $sempath = ($home_path.'persistent/'.$server_network.'/roulette_'.$target.'.sem');

if ($message =~ /^${sl}${cm}roulette$/i) {

    open ( ROULSEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock ROULSEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    ACT('LITERAL',undef,'get_variable_value>roulette'.$target.'chamber');
    my $chamber = <STDIN>;
    $chamber =~ s/[\r\n\t\s]+$//;
    
    if (!$chamber || ($chamber <= 1)) {
        ACT('MESSAGE',$target,'Starting new game of Russian Roulette.');
        $chamber = int(rand(6))+1;
        ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'chamber>'.$chamber);
        ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>1');
    }
    
    ACT('LITERAL',undef,'get_variable_value>roulette'.$target.'index');
    my $index = <STDIN>;
    $index =~ s/[\r\n\t\s]+$//;
    
    my $chamberstring = $index;
    ACT('MESSAGE',$target,"Pulling the trigger on chamber $chamberstring.");
    if ($chamber == $index) {
        ACT('MESSAGE',$target,"BANG! $sender is dead.");
        ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'chamber>1');
        ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>1');
        if(CheckOps($target)) {
            ACT('KICK',$target,$sender,"$sender just lost the game");
        } else {
            ACT('MESSAGE','chanserv',"op $target $self");
            sleep 4;
            ACT('KICK',$target,$sender,"$sender just lost the game");
            sleep 2;
            ACT('MESSAGE','chanserv',"deop $target $self");
        }
    }
    else {
        ACT('MESSAGE',$target,"Click. $sender lives this time.");
        $index++;
        ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>'.$index);
        if($server_network eq 'freenode') {
		if ($chamberstring eq '5') {
	            ACT('MESSAGE',$target,"There's only one chamber left, so it appears everyone is going to survive this round.");
	            ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'chamber>1');
	            ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>1');   
	        }
	}
    }
    flock ROULSEMA, LOCK_UN;
    close(ROULSEMA);
    return 1;
}

if ($message =~ /^${sl}${cm}roulette-reset$/i) {
    open ( ROULSEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock ROULSEMA, LOCK_EX or die("Can't lock semaphore $!\n");
     if(CheckPerm($sender, "roulette", $target, $target)) {
        ACT('MESSAGE',$target,'Starting new game of Russian Roulette.');
        my $chamber = int(rand(6))+1;
        ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'chamber>'.$chamber);
        ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>1');
    }
    flock ROULSEMA, LOCK_UN;
    close(ROULSEMA);
}

if ($message =~ /^${sl}${cm}help\s+roulette$/i) {
    ACT('MESSAGE',$receiver,"The roulette module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !roulette                                 - Plays a game of roulette.");
    ACT('MESSAGE',$receiver,"    !roulette-reset                           - Resets the game.");
    return 1;
}

return 0;
