push(@modules,"quote");
my $home_path = $home_folder;
	$home_path =~ s/parsers\/plugin_parser//g;

my $sempath = ($home_path.'persistent/'.$server_network.'/quotes_'.$target.'.sem');
my $txtpath = ($home_path.'persistent/'.$server_network.'/quotes_'.$target.'.txt');

if ($message =~ /^${sl}${cm}q(uote)?([0-9]+)?(?:\s+(.*))?$/i) {
    my ($number, $grepme, @quotes, $count, $i, $rand, @rands);
    $number = $4;
    $grepme = $5;
    $number = 1 if (!$4);
    $grepme = "" if (!$5);
    
    open (SEMA, ">", $sempath) or die ("Can't open semaphore $!\n");
    flock SEMA, LOCK_EX or die ("Can't lock semaphore $!\n");
    
    open (QUOTESR, "<", $txtpath);
    my @lines = <QUOTESR>;
    close (QUOTESR);

    #ACT('MESSAGE',$target,"$receiver: Attempting to retrieve $number quotes that match the regex \"$grepme\" from $txtpath");

    $count = 0;
    foreach my $current_line (@lines) {
        $current_line =~ s/^#(.+)//; # # denotes a comment, so ignore this line.
        $current_line =~ s/^[\r\n\t\s]+//g;
        $current_line =~ s/[\r\n\t\s]+$//g;
        if ($current_line && $current_line =~ /^(.*$grepme.*)/i) {
            push(@quotes,"$1");
            $count++;
        }
    }
    
    $i = 0;
    if ($count > 0) {    
        while(($i < $number) && ($i < $count)) {
            if ($number >= $count) {
                ACT('MESSAGE',$target,"QUOTE: \"$quotes[$i]\"");
            }
            else {
                $rand = int(rand($count));
                while (grep /$rand$/, @rands) {
                $rand = int(rand($count));
            }
            push(@rands,"$rand");
            ACT('MESSAGE',$target,"QUOTE: \"$quotes[$rand]\"");
        }
        sleep 1; #Delay spamming to prevent flood kicks
        $i++;
        }
    }
    else {
        ACT('MESSAGE',$target,"No quotes were found that matched your query.");
    }
    flock SEMA, LOCK_UN;
    close (SEMA);
    #ACT('MESSAGE',$target,"Done. Displayed $i quotes out of $count matching quotes.");
    return 1;
}

if ($message =~ /^${sl}${cm}(aq|qa|add-?quote)\s+(.+)$/i) {
    my $q = $4;
    my $i = 0;
  
    $q =~ s/^[\r\n\t\s]+//g; #trim spaces at front
    $q =~ s/[\r\n\t\s]+$//g; #trim trailing spaces
  
    if ($q) {
        #ACT('MESSAGE',$target,"Attempting to add quote: \"$q\"");
      
        open (SEMA, ">", $sempath) or die ("Can't open semaphore $!\n");
        flock SEMA, LOCK_EX or die ("Can't lock semaphore $!\n");
        open (QUOTES, "<", $txtpath);
        my @lines = <QUOTES>;
        close (QUOTES);
        
        foreach my $current_line (@lines) {
            $current_line =~ s/^[\r\n\t\s]+//g;
            $current_line =~ s/[\r\n\t\s]+$//g;
            if ($current_line eq $q) {
                $i++;
            }
        }
        if ($i) {
            ACT('MESSAGE',$target,"Quote already in database.");
        }
        else {
            open (QUOTES, ">>", $txtpath) or die ("Can't open quotes file $!\n");;
            flock QUOTES, LOCK_EX or die ("Can't lock quotes file $!\n");;
            print QUOTES $q."\r\n";
            ACT('MESSAGE',$target,"Quote added: \"$q\"");   
            flock QUOTES, LOCK_UN;
            close(QUOTES);
        }
        flock SEMA, LOCK_UN;
        close (SEMA);
    }
    return 1;
}

if ($message =~ /^${sl}${cm}(rm|del|remove)-?quote\s+(.+)$/i) {
    my $q = $4;
    my $i = 0;
  
    $q =~ s/^[\r\n\t\s]+//g; #trim spaces at front
    $q =~ s/[\r\n\t\s]+$//g; #trim trailing spaces
  
    #ACT('MESSAGE',$target,"Attempting to delete quote: \"$q\"");
  
    if(CheckPerm($sender, "quote", $target, $target)) {
        open (SEMA, ">", $sempath) or die ("Can't open semaphore $!\n");
        flock SEMA, LOCK_EX or die ("Can't lock semaphore $!\n");
        open (QUOTES, "<", $txtpath);
        my @lines = <QUOTES>;
        close (QUOTES);
        
      
        foreach my $current_line (@lines) {
            $current_line =~ s/^[\r\n\t\s]+//g;
            $current_line =~ s/[\r\n\t\s]+$//g;
            if ($current_line eq $q) {
                $i++;
            }
        }
      
        if ($i) {
            open (QUOTES, "+>", $txtpath) or die ("Can't open quotes file $!\n");;
            flock QUOTES, LOCK_EX or die ("Can't lock quotes file $!\n");;
            foreach my $current_line (@lines) {
                $current_line =~ s/^\s*//g;
                $current_line =~ s/\s*$//g;
                if ($current_line ne $q) {
                    print QUOTES $current_line."\r\n" if ($current_line); # and line not empty
                }
                else {
                    ACT('MESSAGE',$target,"Deleted Quote: \"$q\""); 
                }
            }
            flock QUOTES, LOCK_UN;
            close(QUOTES);
        }
        flock SEMA, LOCK_UN;
        close (SEMA);
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+quote$/i) {
    ACT('MESSAGE',$receiver,"The quote module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !quote[N] [STRING]                        - Returns 1 [or N] quote(s) [that contain STRING].");
    ACT('MESSAGE',$receiver,"    !q[N] [STRING]                            - Returns 1 [or N] quote(s) [that contain STRING].");
    ACT('MESSAGE',$receiver,"    !add-quote STRING                         - Adds quote STRING to the database.");
    ACT('MESSAGE',$receiver,"    !aq STRING                                - Adds quote STRING to the database.");
    ACT('MESSAGE',$receiver,"    !remove-quote STRING                      - Deletes the quote STRING. Must be a literal match!");
    ACT('MESSAGE',$receiver,"    !del-quote STRING                         - Deletes the quote STRING. Must be a literal match!");
    ACT('MESSAGE',$receiver,"    !rm-quote STRING                          - Deletes the quote STRING. Must be a literal match!");
    return 1;
}

return 0;
